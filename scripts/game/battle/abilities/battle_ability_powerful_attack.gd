class_name BattleAbilityPowerfulAttack extends BattleAbilityAttack

func _get_attack_effect() -> BattleEffect:
	return BattleEffectAttack.new(_source, _target, 1.5)
