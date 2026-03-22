class_name BattleAbilityPass extends BattleAbility

func execute(in_target: BattleParticipant, in_turn_target: BattleTurn = null) -> void:
	super.execute(in_target, in_turn_target)

	BattleManager.play_fx(fx_activate, _source)

	set_lifetime(1.3)
	show_message()
	
func is_valid_for_target(possible_target: BattleParticipant) -> bool:
	return possible_target == _source
	
func auto_select_sole_target() -> bool:
	return true
	
func get_message() -> String:
	return "%s does nothing..." % _source.get_display_name()
