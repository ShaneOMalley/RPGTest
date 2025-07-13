class_name StateBattleTurnDecisionEnemy extends StateBattleTurnDecision

func _make_attack() -> BattleAbility:
	var attack = BattleAbility.BattleAbilityAttack.new()
	attack.source = BattleManager.get_current_turn().participant
	attack.target = BattleManager.test_get_player()
	return attack

func update(_delta: float) -> void:
	var attack = _make_attack()
	BattleManager.queue_ability(attack)
