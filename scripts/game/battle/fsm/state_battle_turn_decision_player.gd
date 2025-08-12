class_name StateBattleTurnDecisionPlayer extends StateBattleTurnDecision

func update(_delta: float) -> void:
	pass
	# if Input.is_action_just_pressed("ui_accept"):
	# 	var participant = BattleManager.get_current_turn_participant()
	# 	var target = BattleManager.test_get_random_enemy()
	# 	var ability := participant.abilities["attack"] as BattleAbility
	# 	BattleManager.queue_ability_execution(ability, target)