extends Node

signal on_ability_and_target_selected(ability_id, target_id)

var battle_ui: UIBattle

# FX
func play_oneshot_fx(effect_prototype: PackedScene, target_id: StringName):
	battle_ui.play_oneshot_fx(effect_prototype, target_id)

# Enemy
func setup_enemy(id: StringName, hp: int, max_hp: int) -> void:
	battle_ui.add_enemy(id, hp, max_hp)

func update_enemy_hp(id: StringName, hp: int, max_hp: int) -> void:
	battle_ui.update_enemy_hp(id, hp, max_hp)

func remove_enemy(id: StringName) -> void:
	battle_ui.remove_enemy(id)

# Player
func setup_player(id: StringName, hp: int, max_hp: int) -> void:
	battle_ui.add_player(id, hp, max_hp)

func update_player_hp(id: StringName, hp: int, max_hp: int) -> void:
	battle_ui.update_player_hp(id, hp, max_hp)

func remove_player(id: StringName) -> void:
	battle_ui.remove_player(id)

# Battle Menu
func show_battle_menu(entries: Array[UIBattle.BattleMenuEntry]) -> void:
	battle_ui.show_battle_menu(entries)

func hide_battle_menu() -> void:
	battle_ui.hide_battle_menu()

# UI Management
func setup_ui() -> void:
	# TODO: Define this path in config (also, find out how to do config in Godot?)
	battle_ui = preload("res://ui/battle/battle_ui.tscn").instantiate()
	battle_ui.on_ability_and_target_selected.connect(on_ability_and_target_selected.emit)
	get_tree().root.add_child(battle_ui)

	battle_ui.hide_all_players_info()

func destroy_ui() -> void:
	battle_ui.queue_free()
