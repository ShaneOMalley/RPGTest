class_name StateBattleTurnDecisionPlayer extends StateBattleTurnDecision

func _make_attack() -> BattleAbility:
	var source = BattleManager.test_get_player()
	var target = BattleManager.test_get_random_enemy()
	var attack = BattleAbilityAttack.new(source, target)
	return attack

func update(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		var attack = _make_attack()
		BattleManager.queue_ability(attack)
