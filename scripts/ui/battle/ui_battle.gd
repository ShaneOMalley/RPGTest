class_name UIBattle extends Control

# todo: delete PlayerPartyContainer from battle_ui.tscn

# todo: try and remember why I amn't just using the duplicate template pattern for this
@export var enemy_template: Resource

signal on_ability_and_target_selected(ability_id, target_id, turn_target_uid)
signal on_ability_prepare(ability_id, target_id, turn_target_uid)
signal on_ability_cancel(ability_id)
signal on_ability_cancel_prepare(ability_id)
signal on_setup_complete()

var turns_ui: UIBattleTurns

class FXInstance:
	var target_uid: StringName
	var prototype: PackedScene
	var instance: UIFX
	
	func _init(in_target_uid: StringName, in_prototype: PackedScene, in_instance: UIFX) -> void:
		target_uid = in_target_uid
		prototype = in_prototype
		instance = in_instance
		
var _enemies: Dictionary[StringName, UIEnemy]
var _battle_menu_entries : Array[UIBattleMenuEntry]
var _num_used_battle_menu_entries: int = 0
var _fx_instances: Array[FXInstance]

class BattleMenuEntry:
	var ability_id: StringName
	var category: StringName
	var ability_string: String
	var ability_sp_cost: int
	var can_activate: bool
	var valid_participant_targets: Array[StringName]
	var requires_turn_target: bool

# FX
func play_fx(effect_prototype: PackedScene, target_uid: StringName) -> void:
	if !_enemies.has(target_uid):
		return

	# TODO: Instantiate this on a bespoke canvas just for UI_FXs
	var instance := effect_prototype.instantiate() as UIFX
	var element := _enemies[target_uid]

	instance.position = element.get_global_transform_with_canvas().get_origin() + element.size / 2
	add_child(instance)
	
	_fx_instances.append(FXInstance.new(target_uid, effect_prototype, instance))
	
func stop_fx(effect_prototype: PackedScene, target_uid: StringName) -> void:
	var results := _fx_instances.filter(func(entry): return entry.target_uid == target_uid and entry.prototype == effect_prototype)
	results.map(func(entry): entry.instance.queue_free())
	_fx_instances = _fx_instances.filter(func(entry): return !results.has(entry))
	
# Animation
func play_animation(anim_id: StringName, target_uid: StringName) -> void:
	if !_enemies.has(target_uid):
		return
		
	var element := _enemies[target_uid]
	element.play_animation(anim_id)
	
# Enemy
func add_enemy(uid: StringName, character_graphics: PackedScene, hp: int, max_hp: int) -> void:
	var ui_enemy := enemy_template.instantiate() as UIEnemy
	assert(ui_enemy)

	_enemies[uid] = ui_enemy

	$EnemiesContainer.add_child(ui_enemy)

	ui_enemy.populate(uid, character_graphics, hp, max_hp)

func update_enemy_hp(uid: StringName, hp: int, max_hp: int) -> void:
	_enemies[uid].update_hp(hp, max_hp)

func remove_enemy(uid: StringName) -> void:
	if is_instance_valid(_enemies[uid]):
		_enemies[uid].queue_free()

# Battle Menu
func _hide_all_menu_buttons() -> void:
	for index in range(_battle_menu_entries.size()):
		_battle_menu_entries[index].hide()
	_num_used_battle_menu_entries = 0
	
func _make_menu_button(text: String, disabled: bool, mouse_entered_callback: Callable, pressed_callback: Callable) -> UIBattleMenuEntry:
	var container := $MenuContainer/BattleMenuBackground
	var ui_entry: UIBattleMenuEntry
	
	_num_used_battle_menu_entries += 1
	if _num_used_battle_menu_entries >= _battle_menu_entries.size():
		ui_entry = container.find_child("BattleMenuEntryPrototype").duplicate()
		container.find_child("BattleMenuEntryPrototype").add_sibling(ui_entry)
		_battle_menu_entries.append(ui_entry)
	else:
		ui_entry = _battle_menu_entries[_num_used_battle_menu_entries]
		ui_entry.disconnect_all()

	ui_entry.show()
	ui_entry.set_text(text)
	ui_entry.disabled = disabled
	ui_entry.pressed.connect(pressed_callback)
	ui_entry.mouse_entered.connect(mouse_entered_callback)
	
	return ui_entry
	
func show_battle_menu(entries: Array[BattleMenuEntry], current_category: StringName = &"") -> void:
	_hide_all_menu_buttons()
	_clear_turns_ui_connections()
	
	var seen_categories: Dictionary[StringName, bool]
	
	for index in range(entries.size()):
		var entry := entries[index]
		
		if current_category == entry.category:
			var text: String
			if entry.ability_sp_cost > 0:
				text = "%s (SP: %d)" % [entry.ability_string, entry.ability_sp_cost]
			else:
				text = entry.ability_string
			var on_pressed := func(): show_target_menu(entry.ability_id, entry.valid_participant_targets, entries, entry.requires_turn_target)
			_make_menu_button(text, !entry.can_activate, Callable(), on_pressed)
		elif current_category == &"":
			# make category buttons
			if !seen_categories.get(entry.category, false):
				seen_categories[entry.category] = true
				
				var text := entry.category
				var on_pressed := func(): show_battle_menu(entries, entry.category)
				_make_menu_button(text, false, Callable(), on_pressed)
	
	if current_category != &"":
		_make_menu_button("cancel", false, Callable(), func(): show_battle_menu(entries, &""))
				
	$MenuContainer/BattleMenuBackground.show()
	
func show_target_menu(ability_id: StringName, valid_participant_targets: Array[StringName], previous_entries: Array[BattleMenuEntry], requires_turn_target: bool = false) -> void:
	_hide_all_menu_buttons()
	
	var options := valid_participant_targets.duplicate() as Array[StringName]
	options.append(&"cancel")
	
	for index in range(options.size()): # range(valid_participant_targets.size()):
		var target_uid := options[index] # valid_participant_targets[index]

		var pressed_callback: Callable
		var mouse_entered_callback: Callable
		if target_uid == &"cancel":
			pressed_callback = ability_cancel.bind(ability_id, previous_entries)
			mouse_entered_callback = ability_cancel_prepare.bind(ability_id)
		else:
			mouse_entered_callback = ability_prepare.bind(-1, ability_id, target_uid)
			pressed_callback = ability_select_target.bind(-1, ability_id, target_uid)
		
		_make_menu_button(target_uid, false, mouse_entered_callback, pressed_callback)
		
	if requires_turn_target:
		turns_ui.on_turn_pressed.connect(ability_select_target.bind(ability_id, &""))
		turns_ui.on_turn_hovered.connect(ability_prepare.bind(ability_id, &""))
	
	_battle_menu_entries.front().grab_focus()

	$MenuContainer/BattleMenuBackground.show()
	
func hide_battle_menu() -> void:
	$MenuContainer/BattleMenuBackground.hide()

func ability_prepare(turn_target_uid: int, ability_id: StringName, target_uid: StringName) -> void:
	print(" -- PREPARE")
	on_ability_prepare.emit(ability_id, target_uid, turn_target_uid)
	
func ability_cancel(ability_id: StringName, previous_entries: Array[BattleMenuEntry]) -> void:
	print(" -- CANCEL")
	on_ability_cancel.emit(ability_id)
	show_battle_menu(previous_entries)
	
func ability_cancel_prepare(ability_id: StringName) -> void:
	print(" -- CANCEL PREPARE")
	on_ability_cancel_prepare.emit(ability_id)
	
func ability_select_target(turn_target_uid: int, ability_id: StringName, target_uid: StringName) -> void:
	print(" -- SELECT TARGET")
	on_ability_and_target_selected.emit(ability_id, target_uid, turn_target_uid)
	
	_clear_turns_ui_connections()
	hide_battle_menu()
	
func _clear_turns_ui_connections() -> void:
	for connection in turns_ui.on_turn_pressed.get_connections():
		if connection.callable.get_object() == self:
			turns_ui.on_turn_pressed.disconnect(connection.callable)
		
	for connection in turns_ui.on_turn_hovered.get_connections():
		if connection.callable.get_object() == self:
			turns_ui.on_turn_hovered.disconnect(connection.callable)
		
	for connection in turns_ui.on_turn_unhovered.get_connections():
		if connection.callable.get_object() == self:
			turns_ui.on_turn_unhovered.disconnect(connection.callable)

func fade_in() -> void:
	$AnimationPlayer.play(&"battle_fade")

func _ready():
	turns_ui = $TurnsUI as UIBattleTurns
	$AnimationPlayer.animation_finished.connect(func(_anim): on_setup_complete.emit())
