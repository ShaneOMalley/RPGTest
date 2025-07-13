class_name StateBattleTurnDecisionEnemy extends StateBattleTurnDecision

func update(_delta: float) -> void:
	if Input.is_action_pressed("ui_accept"):
		var attack = BattleAbility.BattleAbilityPass.new()
		attack.source = BattleManager.get_current_turn().participant
		BattleManager.queue_ability(attack)
