class_name BattleAbilityAttack extends BattleAbility

func execute(target: BattleParticipant) -> void:
	super.execute(target)

	var effect = BattleEffectAttack.new(_source, target)
	effect.apply()

	end()