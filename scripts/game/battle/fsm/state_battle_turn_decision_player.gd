class_name StateBattleTurnDecisionPlayer extends StateBattleTurnDecision

func make_attack() -> BattleAbility:
	var attack = BattleAbility.BattleAbilityAttack.new()
	attack.source = BattleManager.test_get_player()
	attack.target = BattleManager.test_get_random_enemy()
	return attack

func update(_delta: float) -> void:
	if Input.is_action_pressed("ui_accept"):
		var attack = make_attack()
		BattleManager.queue_ability(attack)
