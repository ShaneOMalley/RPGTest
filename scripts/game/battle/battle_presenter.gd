extends Node

func on_pre_setup_complete() -> void:
	BattleView.setup_ui()

	var enemies := BattleManager.get_enemies()
	for enemy in enemies:
		BattleView.setup_enemy(enemy.id, enemy.hp, enemy.max_hp)

	var players := BattleManager.get_players()
	for player in players:
		BattleView.setup_player(player.id, player.hp, player.max_hp)

func on_battle_effect_applied(battle_effect: BattleEffect) -> void:
	var target = battle_effect.target

	# TODO: Make this happen somewhere else; don't assume that 0 health means removal
	if target.affiliation == BattleManager.Affiliation.ENEMY:
		if target.hp <= 0:
			BattleView.remove_enemy(target.id)
		else:
			BattleView.update_enemy_hp(target.id, target.hp, target.max_hp)
	elif target.affiliation == BattleManager.Affiliation.PLAYER:
		if target.hp <= 0:
			BattleView.remove_player(target.id)
		else:
			BattleView.update_player_hp(target.id, target.hp, target.max_hp)

	print(battle_effect.to_string())

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
			battle_menu_entry.valid_participant_targets.append(valid_participant.id)

		battle_menu_entries.append(battle_menu_entry)

	BattleView.show_battle_menu(battle_menu_entries)

func on_battle_player_turn_ended(battle_participant: BattleParticipant) -> void:
	BattleView.hide_battle_menu()
	pass

func on_ability_and_target_selected(ability_id: StringName, target_id: StringName) -> void:
	var current_participant := BattleManager.get_current_turn_participant()
	var ability := current_participant.abilities[ability_id]
	var target := BattleManager.get_participant(target_id)
	BattleManager.queue_ability_execution(ability, target)

func _ready():
	# battle_ui = preload("res://ui/battle/battle_ui.tscn").instantiate()
	BattleManager.on_battle_pre_setup_complete.connect(on_pre_setup_complete)
	BattleManager.on_battle_effect_applied.connect(on_battle_effect_applied)
	BattleManager.on_battle_player_turn_started.connect(on_battle_player_turn_started)
	BattleManager.on_battle_player_turn_ended.connect(on_battle_player_turn_ended)

	BattleView.on_ability_and_target_selected.connect(on_ability_and_target_selected)
