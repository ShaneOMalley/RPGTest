class_name StateBattleTurnDecisionEnemy extends StateBattleTurnDecision

func update(_delta: float) -> void:
	# var participant = BattleManager.get_current_turn_participant()
	# var ability := participant.abilities["pass"] as BattleAbility
	# BattleManager.queue_ability_execution(ability, null)

	var participant = BattleManager.get_current_turn_participant()
	var ability_attack := participant.abilities[&"attack"] as BattleAbility

	if ability_attack.can_activate() and BattleManager._current_turn.is_ability_allowed(&"attack"):
		var target = BattleManager.get_players().pick_random()
		BattleManager.queue_ability_execution(ability_attack, target)
	else:
		var ability_pass := participant.abilities[&"pass"] as BattleAbility
		BattleManager.queue_ability_execution(ability_pass, null)
