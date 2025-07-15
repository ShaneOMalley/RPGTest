class_name BattleUI extends Control

@export var enemy_template: Resource

signal on_ability_and_target_selected(ability_id, target_id)

var _enemies: Dictionary[StringName, UIEnemy]
var _battle_menu_entries : Array[BattleMenuEntryUI]

class BattleMenuEntry:
	var ability_id: StringName
	var ability_string: String
	var valid_participant_targets: Array[StringName]

# Enemy
func add_enemy(id: StringName, hp: int, max_hp: int) -> void:
	var ui_enemy := enemy_template.instantiate() as UIEnemy
	assert(ui_enemy)

	_enemies[id] = ui_enemy

	$EnemiesContainer.add_child(ui_enemy)

	ui_enemy.update_hp(hp, max_hp)

func update_enemy_hp(id: StringName, hp: int, max_hp: int) -> void:
	_enemies[id].update_hp(hp, max_hp)

func remove_enemy(id: StringName) -> void:
	if is_instance_valid(_enemies[id]):
		_enemies[id].free()

# Battle Menu
func show_battle_menu(entries: Array[BattleMenuEntry]) -> void:
	var container := $PlayerPartyContainer2/BattleMenuBackground

	for index in range(entries.size()):
		var ui_entry: BattleMenuEntryUI

		if index >= _battle_menu_entries.size():
			ui_entry = container.find_child("BattleMenuEntryPrototype").duplicate()
			container.find_child("BattleMenuEntryPrototype").add_sibling(ui_entry)
			_battle_menu_entries.append(ui_entry)
		else:
			ui_entry = _battle_menu_entries[index]

		for connection in ui_entry.pressed.get_connections():
			ui_entry.pressed.disconnect(connection.callable)

		ui_entry.show()
		ui_entry.set_text(entries[index].ability_string)
		ui_entry.pressed.connect(func(): show_target_menu(entries[index].ability_id, entries[index].valid_participant_targets))

	for index in range(entries.size(), _battle_menu_entries.size()):
		_battle_menu_entries[index].hide()

	container.show()

func show_target_menu(ability_id: StringName, valid_participant_targets: Array[StringName]) -> void:
	var container := $PlayerPartyContainer2/BattleMenuBackground

	for index in range(valid_participant_targets.size()):
		var ui_entry: BattleMenuEntryUI

		if index >= _battle_menu_entries.size():
			ui_entry = container.find_child("BattleMenuEntryPrototype").duplicate()
			container.find_child("BattleMenuEntryPrototype").add_sibling(ui_entry)
			_battle_menu_entries.append(ui_entry)
		else:
			ui_entry = _battle_menu_entries[index]

		var target_id := valid_participant_targets[index]

		for connection in ui_entry.pressed.get_connections():
			ui_entry.pressed.disconnect(connection.callable)

		ui_entry.show()
		ui_entry.pressed.connect(func(): make_ability_and_target_selection(ability_id, target_id) )
		ui_entry.set_text(target_id)

	for index in range(valid_participant_targets.size(), _battle_menu_entries.size()):
		_battle_menu_entries[index].hide()

	_battle_menu_entries.front().grab_focus()

	container.show()

func make_ability_and_target_selection(ability_id: StringName, target_id: StringName) -> void:
	on_ability_and_target_selected.emit(ability_id, target_id)
	hide_battle_menu()

func hide_battle_menu() -> void:
	$PlayerPartyContainer2/BattleMenuBackground.hide()
