class_name StateBattleTurnDecisionEnemy extends StateBattleTurnDecision

func update(_delta: float) -> void:
	var source = BattleManager.get_current_turn().participant
	BattleManager.queue_ability(BattleAbilityPass.new(source), null)
