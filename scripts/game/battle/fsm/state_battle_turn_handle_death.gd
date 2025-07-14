class_name StateBattleTurnHandleDeath extends FSMState

func on_enter() -> void:

	var participants = BattleManager.get_participants()
	# var filter_enemies := func(participant: BattleParticipant) -> bool:
	#	return participant.affiliation == BattleManager.Affiliation.ENEMY
	# var enemies = participants.filter(filter_enemies)

	var participant_is_alive := func(participant: BattleParticipant) -> bool:
		return participant.hp > 0

	# TODO: Make this less messy
	BattleManager.participants = BattleManager.participants.filter(participant_is_alive)
	BattleManager._turns = BattleManager._turns.filter(func(turn: BattleTurn): return turn.participant.hp > 0)
	
	# BattleManager.start_blocking_timer(0.5)
