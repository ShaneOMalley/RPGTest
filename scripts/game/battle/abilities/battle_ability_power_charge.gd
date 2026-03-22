class_name BattleAbilityPowerCharge extends BattleAbility

var _modified_turn: BattleTurn

func execute(in_target: BattleParticipant, in_turn_target: BattleTurn = null) -> void:
	super.execute(in_target, in_turn_target)
	
	# hack until turn_target feature is removed
	in_turn_target = BattleManager.get_next_normal_turn_for_participant(in_target)
	
	# Normally, turn modification is done in prepare. This handles case wheren turn is repeating
	if !is_instance_valid(_modified_turn):
		_modified_turn = BattleManager.get_next_normal_turn_for_participant(in_target)
		_modified_turn.set_modifier(BattleTurn.TurnModifierPowerCharge.new())
		BattleManager.force_update_turns()
	
	BattleManager.play_animation(&"casting", _source)
	set_lifetime(1.5)
	set_timer(0.2, show_message)
	
	_modified_turn = null
	
func prepare(in_target: BattleParticipant, in_turn_target: BattleTurn = null) -> void:
	if is_instance_valid(_modified_turn):
		_modified_turn.clear_modifier()
		
	_modified_turn = BattleManager.get_next_normal_turn_for_participant(in_target)
	_modified_turn.set_modifier(BattleTurn.TurnModifierPowerCharge.new())
	BattleManager.force_update_turns()
	
	super.prepare(in_target, in_turn_target)
	
func cancel_prepare() -> void:
	if is_instance_valid(_modified_turn):
		_modified_turn.clear_modifier()
		BattleManager.force_update_turns()
		
	super.cancel_prepare()
	
func cancel() -> void:
	if is_instance_valid(_modified_turn):
		_modified_turn.clear_modifier()
		BattleManager.force_update_turns()
		
	super.cancel()
	
func is_valid_for_target(possible_target: BattleParticipant) -> bool:
	return possible_target == _source
	
func auto_select_sole_target() -> bool:
	return true
	
func get_message() -> String:
	return "%s is gearing up for a big attack!" % _target.get_display_name()
