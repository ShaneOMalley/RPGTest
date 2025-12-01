class_name BattleAbilitySkipTurn extends BattleAbility

func execute(in_target: BattleParticipant, in_turn_target: BattleTurn = null) -> void:
	super.execute(in_target, in_turn_target)
	
	in_turn_target.turn_modifier = BattleTurn.TurnModifierSkip.new()
	BattleManager.force_update_turns()
	
	set_lifetime(1.5)
	set_timer(0.2, show_message)
	
func is_valid_for_target(_possible_target: BattleParticipant) -> bool:
	return false

func requires_turn_target() -> bool:
	return true
	
func get_message() -> String:
	return "%s is doing skip turn for turn %d!" % [_source.get_display_name(), _turn_target.uid]
	
