class_name BattleAbilityScaredyCatRun extends BattleAbility

var _turns_remaining_until_run := 2

func execute(in_target: BattleParticipant, in_turn_target: BattleTurn = null) -> void:
	super.execute(in_target, in_turn_target)

	var will_run := _target.run_away_reason != &"" or _turns_remaining_until_run <= 1
	if !will_run:
		BattleManager.play_fx(fx_activate, _source)

	set_lifetime(1.5)
	set_timer(0.2, show_message)
	
	if will_run:
		set_timer(1.5, _do_run_away)
		
func end() -> void:
	super.end()
	_turns_remaining_until_run -= 1
	
func _do_run_away() -> void:
	var turn_manipulation := BattleTurn.TurnManipulation.new()
	turn_manipulation.anim_name = &"shrink"
	turn_manipulation.type = BattleTurn.TurnManipulation.Type.REMOVE
	
	for participant_turn in BattleManager.get_turns_for_participant(_target):
		turn_manipulation.turns.push_back(participant_turn)
		
	BattleManager.on_battle_turn_manipulation.emit([turn_manipulation])
	
	set_timer(0.6, _remove_participant)
	BattleManager.block_fsm(1)
	
func _remove_participant() -> void:
	BattleManager.kill_participant(_target)
	
func is_valid_for_target(possible_target: BattleParticipant) -> bool:
	return possible_target == _source
	
func get_message() -> String:
	if _turns_remaining_until_run == 1:
		return "%s runs away!" % _source.get_display_name()
	elif _target.run_away_reason == &"damaged":
		return "%s is injured and runs away!" % _target.get_display_name()
	elif _target.run_away_reason == &"enemy power charging":
		return "%s runs away to avoid power charge!" % _target.get_display_name()
	elif _turns_remaining_until_run == 2:
		return "%s will run away on its next turn" % _source.get_display_name()
	else:
		return "%s [invalid scaredy_cat_run behaviour]!" % _source.get_display_name()
