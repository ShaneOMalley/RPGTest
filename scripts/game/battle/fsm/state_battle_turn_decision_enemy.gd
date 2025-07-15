class_name StateBattleTurnDecisionEnemy extends StateBattleTurnDecision

func update(_delta: float) -> void:
	var participant = BattleManager.get_current_turn_participant()
	var ability := participant.abilities["pass"] as BattleAbility
	BattleManager.queue_ability_execution(ability, null)
