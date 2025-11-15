class_name StateBattleTurnHandleDeath extends FSMState

func on_enter() -> void:

	var participants = BattleManager.get_participants()
	var participant_is_dead := func(participant: BattleParticipant) -> bool:
		return participant.get_attribute(&"_hp") <= 0

	var dead_participants := participants.filter(participant_is_dead)
	
	if dead_participants.is_empty():
		return
	
	var turn_manipulation := BattleTurn.TurnManipulation.new()
	turn_manipulation.anim_name = &"shrink"
	turn_manipulation.type = BattleTurn.TurnManipulation.Type.REMOVE
	
	for participant in dead_participants:
		for participant_turn in BattleManager.get_turns_for_participant(participant):
			turn_manipulation.turns.push_back(participant_turn)
			
	BattleManager.on_battle_turn_manipulation.emit([turn_manipulation])
	
	set_timer(0.6, func(): _remove_participants(dead_participants))
	BattleManager.block_fsm(1)

func _remove_participants(participants: Array[BattleParticipant]) -> void:
	for participant in participants:
		BattleManager.remove_participant(participant)
