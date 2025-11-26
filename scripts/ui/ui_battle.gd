class_name UIBattle extends Control

# todo: delete PlayerPartyContainer from battle_ui.tscn

# todo: try and remember why I amn't just using the duplicate template pattern for this
@export var enemy_template: Resource

signal on_ability_and_target_selected(ability_id, target_id)
signal on_ability_prepare(ability_id, target_id)
signal on_ability_cancel(ability_id)
signal on_ability_cancel_prepare(ability_id)
signal on_setup_complete()

var _enemies: Dictionary[StringName, UIEnemy]
var _battle_menu_entries : Array[UIBattleMenuEntry]

class BattleMenuEntry:
	var ability_id: StringName
	var ability_string: String
	var can_activate: bool
	var valid_participant_targets: Array[StringName]

# Effects
func play_oneshot_fx(effect_prototype: PackedScene, target_uid: StringName):
	if !_enemies.has(target_uid):
		return

	# TODO: Instantiate this on a bespoke canvas just for UI_FXs
	var effect := effect_prototype.instantiate() as UIFX
	var element := _enemies[target_uid]

	effect.position = element.get_global_transform_with_canvas().get_origin() + element.size / 2
	add_child(effect)

# Enemy
func add_enemy(uid: StringName, hp: int, max_hp: int) -> void:
	var ui_enemy := enemy_template.instantiate() as UIEnemy
	assert(ui_enemy)

	_enemies[uid] = ui_enemy

	$EnemiesContainer.add_child(ui_enemy)

	ui_enemy.populate(uid, hp, max_hp)

func update_enemy_hp(uid: StringName, hp: int, max_hp: int) -> void:
	_enemies[uid].update_hp(hp, max_hp)

func remove_enemy(uid: StringName) -> void:
	if is_instance_valid(_enemies[uid]):
		_enemies[uid].queue_free()

# Battle Menu
func show_battle_menu(entries: Array[BattleMenuEntry]) -> void:
	var container := $MenuContainer/BattleMenuBackground

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
		ui_entry.pressed.connect(func(): show_target_menu(entry.ability_id, entry.valid_participant_targets, entries))

	for index in range(entries.size(), _battle_menu_entries.size()):
		_battle_menu_entries[index].hide()

	container.show()
	
func hide_battle_menu() -> void:
	$MenuContainer/BattleMenuBackground.hide()

func show_target_menu(ability_id: StringName, valid_participant_targets: Array[StringName], previous_entries: Array[BattleMenuEntry]) -> void:
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
			ui_entry.pressed.connect(func(): ability_cancel(ability_id, previous_entries))
			ui_entry.mouse_entered.connect(func(): ability_cancel_prepare(ability_id))
		else:
			ui_entry.pressed.connect(func(): ability_select_target(ability_id, target_uid))
			ui_entry.mouse_entered.connect(func(): ability_prepare(ability_id, target_uid))
		
		ui_entry.disabled = false
		ui_entry.set_text(target_uid)

	# for index in range(valid_participant_targets.size(), _battle_menu_entries.size()):
	for index in range(options.size(), _battle_menu_entries.size()):
		_battle_menu_entries[index].hide()

	_battle_menu_entries.front().grab_focus()

	container.show()
	
func ability_prepare(ability_id: StringName, target_uid: StringName) -> void:
	print(" -- PREPARE")
	on_ability_prepare.emit(ability_id, target_uid)
	
func ability_cancel(ability_id: StringName, previous_entries: Array[BattleMenuEntry]) -> void:
	print(" -- CANCEL")
	on_ability_cancel.emit(ability_id)
	show_battle_menu(previous_entries)
	
func ability_cancel_prepare(ability_id: StringName) -> void:
	print(" -- CANCEL PREPARE")
	on_ability_cancel_prepare.emit(ability_id)
	
func ability_select_target(ability_id: StringName, target_uid: StringName) -> void:
	print(" -- SELECT TARGET")
	on_ability_and_target_selected.emit(ability_id, target_uid)
	hide_battle_menu()

func fade_in() -> void:
	$AnimationPlayer.play(&"battle_fade")

func _ready():
	$AnimationPlayer.animation_finished.connect(func(_anim): on_setup_complete.emit())
