class_name StateBattleTurnHandleDeath extends FSMState

func on_enter() -> void:

	var participants = BattleManager.get_participants()
	var participant_is_dead := func(participant: BattleParticipant) -> bool:
		return participant.hp <= 0

	var dead_participants := participants.filter(participant_is_dead)
	for participant in dead_participants:
		BattleManager.remove_participant(participant)
