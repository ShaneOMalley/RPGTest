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
var _fx_instances: Array[FXInstance]

class BattleMenuEntry:
	var ability_id: StringName
	var ability_string: String
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
func show_battle_menu(entries: Array[BattleMenuEntry]) -> void:
	var container := $MenuContainer/BattleMenuBackground
	
	clear_turns_ui_connections()

	for index in range(entries.size()):
		var ui_entry: UIBattleMenuEntry

		if index >= _battle_menu_entries.size():
			ui_entry = container.find_child("BattleMenuEntryPrototype").duplicate()
			container.find_child("BattleMenuEntryPrototype").add_sibling(ui_entry)
			_battle_menu_entries.append(ui_entry)
		else:
			ui_entry = _battle_menu_entries[index]

		for connection in ui_entry.pressed.get_connections():
			ui_entry.pressed.disconnect(connection.callable)
			
		for connection in ui_entry.mouse_entered.get_connections():
			ui_entry.mouse_entered.disconnect(connection.callable)
			
		for connection in ui_entry.mouse_exited.get_connections():
			ui_entry.mouse_exited.disconnect(connection.callable)

		var entry := entries[index]

		ui_entry.show()
		ui_entry.set_text(entry.ability_string)
		# ui_entry.focus_entered.connect(func(): print("focus entered"))
		# ui_entry.focus_exited.connect(func(): print("focus exited"))
		# ui_entry.mouse_entered.connect(func(): print("mouse entered"))
		# ui_entry.mouse_exited.connect(func(): print("mouse exited"))
		ui_entry.disabled = !entry.can_activate
		ui_entry.pressed.connect(func(): show_target_menu(entry.ability_id, entry.valid_participant_targets, entries, entry.requires_turn_target))

	for index in range(entries.size(), _battle_menu_entries.size()):
		_battle_menu_entries[index].hide()

	container.show()
	
func hide_battle_menu() -> void:
	$MenuContainer/BattleMenuBackground.hide()

func show_target_menu(ability_id: StringName, valid_participant_targets: Array[StringName], previous_entries: Array[BattleMenuEntry], requires_turn_target: bool = false) -> void:
	var container := $MenuContainer/BattleMenuBackground
	
	var options := valid_participant_targets.duplicate() as Array[StringName]
	options.append(&"cancel")
	
	for index in range(options.size()): # range(valid_participant_targets.size()):
		var ui_entry: UIBattleMenuEntry

		if index >= _battle_menu_entries.size():
			ui_entry = container.find_child("BattleMenuEntryPrototype").duplicate()
			container.find_child("BattleMenuEntryPrototype").add_sibling(ui_entry)
			_battle_menu_entries.append(ui_entry)
		else:
			ui_entry = _battle_menu_entries[index]

		var target_uid := options[index] # valid_participant_targets[index]

		for connection in ui_entry.pressed.get_connections():
			ui_entry.pressed.disconnect(connection.callable)

		ui_entry.show()
		
		if target_uid == &"cancel":
			ui_entry.pressed.connect(ability_cancel.bind(ability_id, previous_entries))
			ui_entry.mouse_entered.connect(ability_cancel_prepare.bind(ability_id))
		else:
			ui_entry.mouse_entered.connect(ability_prepare.bind(-1, ability_id, target_uid))
			ui_entry.pressed.connect(ability_select_target.bind(-1, ability_id, target_uid))
		
		ui_entry.disabled = false
		ui_entry.set_text(target_uid)
		
	if requires_turn_target:
		turns_ui.on_turn_pressed.connect(ability_select_target.bind(ability_id, &""))
		turns_ui.on_turn_hovered.connect(ability_prepare.bind(ability_id, &""))
	
	# for index in range(valid_participant_targets.size(), _battle_menu_entries.size()):
	for index in range(options.size(), _battle_menu_entries.size()):
		_battle_menu_entries[index].hide()

	_battle_menu_entries.front().grab_focus()

	container.show()
	
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
	
	clear_turns_ui_connections()
	hide_battle_menu()
	
func clear_turns_ui_connections() -> void:
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
