extends Control

func _process(_delta: float) -> void:

	if !BattleManager.get_is_battle_active():
		return

	# Battle State
	var enemies = BattleManager.get_enemies()
	var players = BattleManager.get_players()

	var battle_state_string := ""
	battle_state_string += "-- ENEMIES --\n"
	for enemy: BattleParticipant in enemies:
		battle_state_string += "    %s %d/%d" % [enemy.to_string(), enemy.hp, enemy.max_hp]
	battle_state_string += "\n"

	battle_state_string += "-- PLAYER --\n"
	for player: BattleParticipant in players:
		battle_state_string += "    %s %d/%d" % [player.to_string(), player.hp, player.max_hp]

	$PanelContainer/BattleStateText.text = battle_state_string

	# FSM
	$PanelContainer/FSMText.text = BattleManager._state_machine._current_state_name

	# Turns
	if (is_instance_valid(BattleManager.get_current_turn())):
		var turns_string := ""
		turns_string += "[color=yellow]%s[/color]    \n" % BattleManager.get_current_turn().to_string()
		for turn: BattleTurn in BattleManager._turns:
			turns_string += "%s\n" % turn.to_string()

		$PanelContainer/TurnsText.text = turns_string
	else:
		$PanelContainer/TurnsText.text = ""
