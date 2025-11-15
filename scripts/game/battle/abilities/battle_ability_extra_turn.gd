class_name BattleAbilityExtraTurn extends BattleAbility

var _created_turn: BattleTurn

func execute(in_target: BattleParticipant) -> void:
	super.execute(in_target)
	
	set_lifetime(1.3)
	
func prepare(in_target: BattleParticipant) -> void:
	# create move
	# play grow animation
	
	if is_instance_valid(_created_turn) && _created_turn.participant != in_target:
		BattleManager.remove_turn(_created_turn)
		_created_turn = null
	#var new_target := !is_instance_valid(_created_turn) or _created_turn
	
	if !is_instance_valid(_created_turn):
		var next_turn := BattleManager.get_next_turn_for_participant(in_target)
		_created_turn = BattleTurn.new(next_turn.time + 0.01, in_target, BattleTurn.TurnType.NORMAL)
		BattleManager.insert_turn(_created_turn)
		
		var create_turn := BattleTurn.TurnManipulation.new()
		create_turn.turns = [_created_turn]
		create_turn.anim_name = &"grow"
		create_turn.type = BattleTurn.TurnManipulation.Type.CREATE
		BattleManager.on_battle_turn_manipulation.emit([create_turn])
		
	super.prepare(in_target)

func cancel() -> void:
	# play shrink animation
	# remove move
	
	# todo: re-use already created turn that hasn't shrunk yet, in case of player repeatedly hovering
	
	# BattleManager.remove_turn(_created_turn)
	
	if is_instance_valid(_created_turn):
		BattleManager.remove_turn(_created_turn)
		_created_turn = null
	
	super.cancel()
	
func is_valid_for_target(possible_target: BattleParticipant) -> bool:
	return possible_target.affiliation == _source.affiliation
	
func end() -> void:
	super.end()
	_created_turn = null
