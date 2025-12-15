extends Node

signal on_ability_and_target_selected(ability_id, target_uid, turn_target_uid)
signal on_ability_prepare(ability_id, target_uid, turn_target_uid)
signal on_ability_cancel(ability_id)
signal on_ability_cancel_prepare(ability_id)
signal on_battle_fade_complete()
signal on_ui_setup()
signal on_turn_hovered(turn_uid: int)
signal on_turn_unhovered(turn_uid: int)

var battle_ui: UIBattle
var enemies_ui: UIBattleEnemies
var battle_menu_ui: UIBattleMenu
var player_party_ui: UIPlayerParty
var turns_ui: UIBattleTurns
var debug_battle_ui: Control
var ui_is_setup: bool = false

const USE_DEBUG_UI := false

func play_turn_animation(turn_uid: int, anim_name: StringName) -> void:
	turns_ui.play_animation_for_turn(turn_uid, anim_name)
		
func add_turn(turn_uid: int, character_graphics: PackedScene, affiliation: BattleManager.Affiliation) -> void:
	turns_ui.add_turn(turn_uid, character_graphics, affiliation)
	
func sort_turns(sorted_turn_uids: Array) -> void:
	turns_ui.sort_turns(sorted_turn_uids)
	
func set_turn_text_and_time(turn_uid: int, text: String, modifier_text: String, time: float) -> void:
	turns_ui.set_turn_text_and_time(turn_uid, text, modifier_text, time)
	
func delete_turn(turn_uid: int) -> void:
	turns_ui.delete_turn(turn_uid)
	
# FX
func play_fx(effect_prototype: PackedScene, target_uid: StringName) -> void:
	# Just attempt to play for both enemies and player characters
	enemies_ui.play_fx(effect_prototype, target_uid)
	player_party_ui.play_fx(effect_prototype, target_uid)
	
func stop_fx(effect_prototype: PackedScene, target_uid: StringName) -> void:
	# Just attempt to stop for both enemies and player characters
	enemies_ui.stop_fx(effect_prototype, target_uid)
	player_party_ui.stop_fx(effect_prototype, target_uid)
	
# Battle Animation
func play_animation(anim_id: StringName, target_uid: StringName) -> void:
	enemies_ui.play_animation(anim_id, target_uid)
	player_party_ui.play_animation(anim_id, target_uid)

# Enemy
func clear_enemies() -> void:
	enemies_ui.clear_enemies()

func setup_enemy(uid: StringName, character_graphics: PackedScene, hp: int, max_hp: int) -> void:
	enemies_ui.add_enemy(uid, character_graphics, hp, max_hp)

func update_enemy_hp(uid: StringName, hp: int, max_hp: int) -> void:
	enemies_ui.update_enemy_hp(uid, hp, max_hp)

func remove_enemy(uid: StringName) -> void:
	enemies_ui.remove_enemy(uid)

# Player
func setup_player(uid: StringName, character_graphics: PackedScene, hp: int, max_hp: int, sp: int, max_sp: int) -> void:
	player_party_ui.add_player(uid, character_graphics, hp, max_hp, sp, max_sp)

func update_player_hp(uid: StringName, hp: int, max_hp: int) -> void:
	player_party_ui.update_player_hp(uid, hp, max_hp)
	
func update_player_sp(uid: StringName, sp: int, max_sp: int) -> void:
	player_party_ui.update_player_sp(uid, sp, max_sp)

func remove_player(uid: StringName) -> void:
	player_party_ui.remove_player(uid)

func hide_all_players_info() -> void:
	player_party_ui.hide_all_players_info()
	
# Message UI
func show_message(message: String, duration: float) -> void:
	player_party_ui.show_message(message, duration)

# Battle Menu
func show_battle_menu(entries: Array[UIBattleMenu.BattleMenuEntry]) -> void:
	battle_menu_ui.show_battle_menu(entries)

func hide_battle_menu() -> void:
	battle_menu_ui.hide_battle_menu()

# UI Management
func setup_battle_ui() -> void:
	# TODO: Define this path in config (also, find out how to do config in Godot?)
	battle_ui = preload("res://ui/battle/battle_ui.tscn").instantiate()
	turns_ui = battle_ui.find_child(&"Turns")
	enemies_ui = battle_ui.find_child(&"BattleEnemies")
	battle_menu_ui = battle_ui.find_child(&"BattleMenu")
	player_party_ui = battle_ui.find_child(&"PlayerParty")
	
	if USE_DEBUG_UI:
		debug_battle_ui = preload("res://ui/battle/debug_battle.tscn").instantiate()
		get_tree().root.add_child(debug_battle_ui)
	
	battle_menu_ui.on_ability_and_target_selected.connect(on_ability_and_target_selected.emit)
	battle_menu_ui.on_ability_prepare.connect(on_ability_prepare.emit)
	battle_menu_ui.on_ability_cancel.connect(on_ability_cancel.emit)
	battle_menu_ui.on_ability_cancel_prepare.connect(on_ability_cancel_prepare.emit)
	battle_menu_ui.hide_battle_menu()
	
	turns_ui.on_turn_hovered.connect(on_turn_hovered.emit)
	turns_ui.on_turn_unhovered.connect(on_turn_unhovered.emit)
	
	battle_ui.on_battle_fade_complete.connect(on_battle_fade_complete.emit)
	get_tree().root.add_child(battle_ui)
	
	ui_is_setup = true
	on_ui_setup.emit()

func show_battle_ui() -> void:
	battle_ui.show_battle_ui()
	battle_ui.fade_in()
	
	if USE_DEBUG_UI:
		debug_battle_ui.show()

func hide_battle_ui() -> void:
	battle_ui.hide_battle_ui()
	
	if USE_DEBUG_UI:
		debug_battle_ui.hide()

func hide_player_party_ui() -> void:
	player_party_ui.hide()

func hide_ui() -> void:
	battle_ui.hide()
	
func show_ui() -> void:
	battle_ui.show()
