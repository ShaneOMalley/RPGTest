class_name StateBattleTurnDecisionEnemy extends StateBattleTurnDecision

func update(_delta: float) -> void:
	var source = BattleManager.get_current_turn_participant()
	var ability = BattleAbilityPass.new(source)
	BattleManager.queue_ability(ability, null)
