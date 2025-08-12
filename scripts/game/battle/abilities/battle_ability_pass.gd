class_name BattleAbilityPass extends BattleAbility

func execute(target: BattleParticipant) -> void:
	super.execute(target)

	print("%s does nothing..." % _source)

	set_lifetime(0.5)
	
func is_valid_for_target(possible_target: BattleParticipant) -> bool:
	return possible_target == _source