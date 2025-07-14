class_name StateBattleTurnDecisionEnemy extends StateBattleTurnDecision

func _make_attack() -> BattleAbility:
	var source = BattleManager.get_current_turn().participant
	var target = BattleManager.test_get_player()
	var attack = BattleAbilityAttack.new(source, target)
	return attack

func update(_delta: float) -> void:
	var attack = _make_attack()
	# BattleManager.queue_ability(attack)
	var source = BattleManager.get_current_turn().participant
	BattleManager.queue_ability(BattleAbilityPass.new(source, null))
