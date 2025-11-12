class_name BattleAbilityPass extends BattleAbility

func execute(in_target: BattleParticipant) -> void:
	super.execute(in_target)

	BattleManager.play_oneshot_fx(fx_activate, _source)

	print("%s does nothing..." % _source)

	set_lifetime(1.3)
	
func is_valid_for_target(possible_target: BattleParticipant) -> bool:
	return possible_target == _source
