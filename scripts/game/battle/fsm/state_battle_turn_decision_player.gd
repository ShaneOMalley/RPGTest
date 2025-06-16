class_name StateBattleTurnDecisionPlayer extends StateBattleTurnDecision

func make_attack() -> void:
	var attack = BattleAbility.BattleAbilityAttack.new()
	attack.source = self
	attack.target = BattleManager.test_get_random_enemy()

func _process(_delta: float) -> void:
	if Input.is_action_pressed("ui_accept"):
		var attack = make_attack()
