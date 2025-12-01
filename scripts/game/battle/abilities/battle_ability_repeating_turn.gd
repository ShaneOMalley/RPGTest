class_name BattleAbilityRepeatingTurn extends BattleAbility

func execute(in_target: BattleParticipant, in_turn_target: BattleTurn = null) -> void:
	super.execute(in_target, in_turn_target)
	
	var current_turn := BattleManager.get_current_turn()
	
	var repeat_modifier := (current_turn.turn_modifier as BattleTurn.TurnModifierRepeat)
	assert(repeat_modifier)
	
	# Just execute ability on BattleManager. This will work since since it will happen before fsm has chance to advance
	set_timer(0.2, show_message)
	set_timer(1.4, func():
		var execution_info = repeat_modifier.ability_execution_info
		
		var target = execution_info.target
		var turn_target = execution_info.turn_target
		if !BattleManager.participants.has(target) or !execution_info.ability.is_valid_for_target(target):
			var result = execution_info.ability.find_fallback_target()
			if !result.is_empty():
				target = result[0]
				turn_target = result[1]
			else:
				end()
				return
				
		BattleManager.clear_queued_ability()
		BattleManager.queue_ability_execution(execution_info.ability, target, turn_target)
		execution_info.ability.on_end.connect(end)
		BattleManager.execute_queued_ability()
	)
	
func is_valid_for_target(possible_target: BattleParticipant) -> bool:
	return possible_target == _source
	
func get_message() -> String:
	return "%s is repeating their turn!" % _source.get_display_name()
	
