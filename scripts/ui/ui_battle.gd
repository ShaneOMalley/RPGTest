class_name UIBattle extends Control

@export var enemy_template: Resource

signal on_ability_and_target_selected(ability_id, target_id)

var _enemies: Dictionary[StringName, UIEnemy]
var _battle_menu_entries : Array[UIBattleMenuEntry]

var player_to_ui_index: Dictionary[StringName, int]
const MAX_PLAYERS := 4

class BattleMenuEntry:
	var ability_id: StringName
	var ability_string: String
	var can_activate: bool
	var valid_participant_targets: Array[StringName]

# Enemy
func add_enemy(id: StringName, hp: int, max_hp: int) -> void:
	var ui_enemy := enemy_template.instantiate() as UIEnemy
	assert(ui_enemy)

	_enemies[id] = ui_enemy

	$EnemiesContainer.add_child(ui_enemy)

	ui_enemy.populate(id, hp, max_hp)

func update_enemy_hp(id: StringName, hp: int, max_hp: int) -> void:
	_enemies[id].update_hp(hp, max_hp)

func remove_enemy(id: StringName) -> void:
	if is_instance_valid(_enemies[id]):
		_enemies[id].free()

# Player

func get_player_ui(index: int) -> PlayerPartyMember:
	match index:
		0: return $PlayerPartyContainer/PlayerPartyMember1
		1: return $PlayerPartyContainer/PlayerPartyMember2
		2: return $PlayerPartyContainer/PlayerPartyMember3
		3: return $PlayerPartyContainer/PlayerPartyMember4
		_: return null

func add_player(id: StringName, hp: int, max_hp: int) -> void:
	for index in range(MAX_PLAYERS):
		if player_to_ui_index.find_key(index) == null:
			var player_ui = get_player_ui(index)
			player_ui.populate(id, hp, max_hp)
			player_to_ui_index[id] = index
			return

func update_player_hp(id: StringName, hp: int, max_hp: int) -> void:
	var index = player_to_ui_index[id]
	get_player_ui(index).update_hp(hp, max_hp)

func remove_player(id: StringName) -> void:
	var index = player_to_ui_index[id]
	get_player_ui(index).hide_info()
	player_to_ui_index.erase(id)

func hide_all_players_info() -> void:
	for index in range(MAX_PLAYERS):
		get_player_ui(index).hide_info()

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

		var entry := entries[index]

		ui_entry.show()
		ui_entry.set_text(entry.ability_string)
		# ui_entry.focus_entered.connect(func(): print("focus entered"))
		# ui_entry.focus_exited.connect(func(): print("focus exited"))
		# ui_entry.mouse_entered.connect(func(): print("mouse entered"))
		# ui_entry.mouse_exited.connect(func(): print("mouse exited"))
		ui_entry.disabled = !entry.can_activate
		ui_entry.pressed.connect(func(): show_target_menu(entry.ability_id, entry.valid_participant_targets))

	for index in range(entries.size(), _battle_menu_entries.size()):
		_battle_menu_entries[index].hide()

	container.show()

func show_target_menu(ability_id: StringName, valid_participant_targets: Array[StringName]) -> void:
	var container := $MenuContainer/BattleMenuBackground

	for index in range(valid_participant_targets.size()):
		var ui_entry: UIBattleMenuEntry

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
		ui_entry.disabled = false
		ui_entry.set_text(target_id)

	for index in range(valid_participant_targets.size(), _battle_menu_entries.size()):
		_battle_menu_entries[index].hide()

	_battle_menu_entries.front().grab_focus()

	container.show()

func make_ability_and_target_selection(ability_id: StringName, target_id: StringName) -> void:
	on_ability_and_target_selected.emit(ability_id, target_id)
	hide_battle_menu()

func hide_battle_menu() -> void:
	$MenuContainer/BattleMenuBackground.hide()
