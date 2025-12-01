class_name BattleAbilityRepeatTurn extends BattleAbility

var _created_turn: BattleTurn

func execute(in_target: BattleParticipant, in_turn_target: BattleTurn = null) -> void:
	super.execute(in_target, in_turn_target)
	
	set_lifetime(1.3)
	show_message()
	
func prepare(in_target: BattleParticipant, in_turn_target: BattleTurn = null) -> void:
	
	if is_instance_valid(_created_turn) and _created_turn.uid != in_turn_target.uid and in_turn_target.uid != _created_turn.linked_turn.uid:
		BattleManager.remove_turn(_created_turn)
		_created_turn = null
		
	if !is_instance_valid(_created_turn):
		var participant := in_turn_target.participant
		_created_turn = BattleTurn.new(in_turn_target.time + 0.01, participant, BattleTurn.TurnType.LINKED)
		_created_turn.linked_turn = in_turn_target
		_created_turn.time_offset_from_linked_turn = 0.01
		
		_created_turn.turn_modifier = BattleTurn.TurnModifierRepeat.new()
		(_created_turn.turn_modifier as BattleTurn.TurnModifierRepeat).turn_uid_to_repeat = in_turn_target.uid
		
		BattleManager.insert_turn(_created_turn)
		
		var create_turn := BattleTurn.TurnManipulation.new()
		create_turn.turns = [_created_turn]
		create_turn.anim_name = &"grow"
		create_turn.type = BattleTurn.TurnManipulation.Type.CREATE
		BattleManager.on_battle_turn_manipulation.emit([create_turn])

	super.prepare(in_target, in_turn_target)
	
func cancel() -> void:
	if is_instance_valid(_created_turn):
		BattleManager.remove_turn(_created_turn)
		_created_turn = null
	
	super.cancel()
	
func cancel_prepare() -> void:
	super.cancel_prepare()
	
func end() -> void:
	super.end()
	_created_turn = null
	
func is_valid_for_target(_possible_target: BattleParticipant) -> bool:
	return false
	
func requires_turn_target() -> bool:
	return true

func get_message() -> String:
	return "%s will repeat their turn!" % _turn_target.participant.get_display_name()
	
