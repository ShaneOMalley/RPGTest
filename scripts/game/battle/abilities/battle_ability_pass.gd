class_name BattleAbilityPass extends BattleAbility

func execute(in_target: BattleParticipant) -> void:
	super.execute(in_target)

	BattleManager.play_oneshot_fx(fx_activate, _source)

	set_lifetime(1.3)
	show_message()
	
func is_valid_for_target(possible_target: BattleParticipant) -> bool:
	return possible_target == _source
	
func get_message() -> String:
	return "%s does nothing..." % _source.get_display_name()
