extends Node

signal on_ability_and_target_selected(ability_id, target_uid)
signal on_ui_setup_complete()

var battle_ui: UIBattle
var player_party_ui: UIPlayerParty
var turns_ui: UIBattleTurns
var debug_battle_ui: Control

const USE_DEBUG_UI: bool = false

# class TurnChange:
# 	enum Type { REMOVE, INSERT, MOVE }
# 	
# 	var type: Type
# 	var insert_position: int
# 	
# 	var prepare_anim_name: StringName
# 	var execute_anim_name: StringName
# 	
# var turn_change_diff: Dictionary[int, TurnChange] # map of turn_uid to change to apply to that turn
# 
# # Turns
# func queue_turn_change(turn_uid: int, turn_change: TurnChange) -> void:
# 	turn_change_diff[turn_uid] = turn_change;
# 	
# func clear_turn_changes() -> void:
# 	turn_change_diff.clear()
# 
# func play_prepare_turn_animations() -> void:
# 	for turn_uid in turn_change_diff:
# 		var turn_change := turn_change_diff[turn_uid]
# 		turns_ui.play_animation_for_turn(turn_uid, turn_change.prepare_anim_name)
# 		
# func play_execute_turn_animations() -> void:
# 	for turn_uid in turn_change_diff:
# 		var turn_change := turn_change_diff[turn_uid]
# 		turns_ui.play_animation_for_turn(turn_uid, turn_change.execute_anim_name)
# 		
# func reset_turn_animations() -> void:
# 	for turn_uid in turn_change_diff:
# 		turns_ui.reset_animation_for_turn()

func play_turn_animation(turn_uid: int, anim_name: StringName) -> void:
	turns_ui.play_animation_for_turn(turn_uid, anim_name)
		
func add_turn(turn_uid: int, participant_name: String, affiliation: BattleManager.Affiliation) -> void:
	turns_ui.add_turn(turn_uid, participant_name, affiliation)
	
func delete_turn(turn_uid: int) -> void:
	turns_ui.delete_turn(turn_uid)
	
# FX
func play_oneshot_fx(effect_prototype: PackedScene, target_uid: StringName):
	battle_ui.play_oneshot_fx(effect_prototype, target_uid)
	player_party_ui.play_oneshot_fx(effect_prototype, target_uid)

# Enemy
func setup_enemy(uid: StringName, hp: int, max_hp: int) -> void:
	battle_ui.add_enemy(uid, hp, max_hp)

func update_enemy_hp(uid: StringName, hp: int, max_hp: int) -> void:
	battle_ui.update_enemy_hp(uid, hp, max_hp)

func remove_enemy(uid: StringName) -> void:
	battle_ui.remove_enemy(uid)

# Player
func setup_player(uid: StringName, hp: int, max_hp: int) -> void:
	player_party_ui.add_player(uid, hp, max_hp)

func update_player_hp(uid: StringName, hp: int, max_hp: int) -> void:
	player_party_ui.update_player_hp(uid, hp, max_hp)

func remove_player(uid: StringName) -> void:
	player_party_ui.remove_player(uid)

func hide_all_players_info() -> void:
	player_party_ui.hide_all_players_info()

# Battle Menu
func show_battle_menu(entries: Array[UIBattle.BattleMenuEntry]) -> void:
	battle_ui.show_battle_menu(entries)

func hide_battle_menu() -> void:
	battle_ui.hide_battle_menu()

# UI Management
func setup_battle_ui() -> void:
	# TODO: Define this path in config (also, find out how to do config in Godot?)
	battle_ui = preload("res://ui/battle/battle_ui.tscn").instantiate()
	turns_ui = battle_ui.find_child(&"TurnsUI") as UIBattleTurns
	
	if USE_DEBUG_UI:
		debug_battle_ui = preload("res://ui/battle/debug_battle.tscn").instantiate()
		get_tree().root.add_child(debug_battle_ui)
	
	battle_ui.on_ability_and_target_selected.connect(on_ability_and_target_selected.emit)
	battle_ui.on_setup_complete.connect(on_ui_setup_complete.emit)
	get_tree().root.add_child(battle_ui)

	battle_ui.hide_battle_menu()

	battle_ui.fade_in()

func destroy_battle_ui() -> void:
	battle_ui.queue_free()
	
	if USE_DEBUG_UI:
		debug_battle_ui.queue_free()

func setup_player_party_ui() -> void:
	player_party_ui = preload("res://ui/battle/player_party_ui.tscn").instantiate()
	get_tree().root.add_child(player_party_ui)

func destroy_player_party_ui() -> void:
	player_party_ui.queue_free()
