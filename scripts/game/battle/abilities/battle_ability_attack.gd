class_name BattleAbilityAttack extends BattleAbility

func execute() -> void:
	super.execute()

	var effect = BattleEffectAttack.new(source, target)
	effect.apply()

	end()
