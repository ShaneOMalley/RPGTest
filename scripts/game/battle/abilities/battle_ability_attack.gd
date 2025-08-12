class_name BattleAbilityAttack extends BattleAbility

func execute(target: BattleParticipant) -> void:
	super.execute(target)

	var effect = BattleEffectAttack.new(_source, target)
	effect.apply()

	set_lifetime(0.5)

func is_valid_for_target(possible_target: BattleParticipant) -> bool:
	return possible_target.affiliation != _source.affiliation