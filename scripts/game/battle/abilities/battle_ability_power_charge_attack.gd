class_name BattleAbilityPowerChargeAttack extends BattleAbilityAttack

func _get_attack_effect() -> BattleEffect:
	return BattleEffectAttack.new(_source, _target, 2.5)
