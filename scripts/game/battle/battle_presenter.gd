extends Node

var _previous_battle_turns: Array[BattleTurn]

# Setup
func on_battle_ui_setup_requested() -> void:
	BattleView.setup_battle_ui()

	var enemies := BattleManager.get_enemies()
	for enemy in enemies:
		BattleView.setup_enemy(enemy.uid, enemy.hp, enemy.max_hp)
		
	on_battle_turns_updated(BattleManager._turns)

func on_player_party_ui_setup_requested() -> void:
	BattleView.setup_player_party_ui()

	BattleView.hide_all_players_info()

	var players := PlayerPartyManager.get_participants()
	for player in players:
		BattleView.setup_player(player.uid, player.hp, player.max_hp)

func on_ui_setup_complete() -> void:
	BattleManager.set_ui_setup_is_complete(true)

# Tear Down
func on_battle_finished() -> void:
	_previous_battle_turns.clear()
	BattleView.destroy_battle_ui()

# Battle Abilities and Effects
func on_ability_and_target_selected(ability_id: StringName, target_uid: StringName) -> void:
	var current_participant := BattleManager.get_current_turn_participant()
	var ability := current_participant.abilities[ability_id]
	var target := BattleManager.get_participant(target_uid)
	BattleManager.queue_ability_execution(ability, target)

func on_battle_effect_applied(battle_effect: BattleEffect) -> void:
	var target = battle_effect.target

	# TODO: Make this happen somewhere else; don't assume that 0 health means removal
	if target.affiliation == BattleManager.Affiliation.ENEMY:
		BattleView.update_enemy_hp(target.uid, target.hp, target.max_hp)
	elif target.affiliation == BattleManager.Affiliation.PLAYER:
		BattleView.update_player_hp(target.uid, target.hp, target.max_hp)

	# print(battle_effect.to_string())
	
# weird bug where if I fully qualify second argument's type as `Array[BattleTurn.TurnManipulation]`, it doesn't call???
func on_battle_ability_execute(_battle_ability: BattleAbility, turn_manipulations: Array) -> void:
	for turn_manipulation in turn_manipulations:
		BattleView.play_turn_animation(turn_manipulation.turn.uid, turn_manipulation.anim_name)
		
# Battle FX
func on_battle_fx_requested(effect_prototype: PackedScene, target: BattleParticipant) -> void:
	BattleView.play_oneshot_fx(effect_prototype, target.uid)
	
# Turns
func on_battle_turns_updated(turns: Array[BattleTurn]) -> void:
	if !is_instance_valid(BattleView.turns_ui):
		return

	for old_turn in _previous_battle_turns:
		if !turns.has(old_turn):
			BattleView.delete_turn(old_turn.uid)
	
	for new_turn in turns:
		if !_previous_battle_turns.has(new_turn):
			BattleView.add_turn(new_turn.uid, new_turn.participant.uid, new_turn.participant.affiliation)
	
	_previous_battle_turns = turns.duplicate()

func on_battle_player_turn_started(battle_participant: BattleParticipant) -> void:
	var battle_menu_entries: Array[UIBattle.BattleMenuEntry]

	var abilities := battle_participant.abilities
	for ability_id in abilities:
		var ability := abilities[ability_id]

		var battle_menu_entry := UIBattle.BattleMenuEntry.new()
		battle_menu_entry.ability_id = ability_id
		battle_menu_entry.ability_string = ability_id
		battle_menu_entry.can_activate = ability.can_activate()

		var valid_participants = BattleManager.get_participants().filter(ability.is_valid_for_target)
		for valid_participant in valid_participants:
			battle_menu_entry.valid_participant_targets.append(valid_participant.uid)

		battle_menu_entries.append(battle_menu_entry)

	BattleView.show_battle_menu(battle_menu_entries)

func on_battle_player_turn_ended(_battle_participant: BattleParticipant) -> void:
	BattleView.hide_battle_menu()

# Misc
func on_battle_particiant_removed(battle_participant: BattleParticipant) -> void:
	if battle_participant.affiliation == BattleManager.Affiliation.ENEMY:
		BattleView.remove_enemy(battle_participant.uid)
	elif battle_participant.affiliation == BattleManager.Affiliation.PLAYER:
		BattleView.remove_player(battle_participant.uid)
	pass

func _ready():
	BattleManager.on_battle_ui_setup_requested.connect(on_battle_ui_setup_requested)
	BattleManager.on_player_party_ui_setup_requested.connect(on_player_party_ui_setup_requested)
	BattleManager.on_battle_finished.connect(on_battle_finished)
	BattleManager.on_battle_effect_applied.connect(on_battle_effect_applied)
	BattleManager.on_battle_ability_execute.connect(on_battle_ability_execute)
	BattleManager.on_battle_fx_requested.connect(on_battle_fx_requested)
	BattleManager.on_battle_player_turn_started.connect(on_battle_player_turn_started)
	BattleManager.on_battle_player_turn_ended.connect(on_battle_player_turn_ended)
	BattleManager.on_battle_particiant_removed.connect(on_battle_particiant_removed)
	BattleManager.on_battle_turns_updated.connect(on_battle_turns_updated)

	BattleView.on_ability_and_target_selected.connect(on_ability_and_target_selected)
	BattleView.on_ui_setup_complete.connect(on_ui_setup_complete)
