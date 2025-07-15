class_name StateBattleTurnDecisionPlayer extends StateBattleTurnDecision

func update(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		var source = BattleManager.get_current_turn_participant()
		var target = BattleManager.test_get_random_enemy()
		var ability = BattleAbilityAttack.new(source)
		BattleManager.queue_ability(ability, target)
