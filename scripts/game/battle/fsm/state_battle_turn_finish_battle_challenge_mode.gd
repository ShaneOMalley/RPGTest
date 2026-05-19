class_name StateBattleFinishBattleChallengeMode extends FSMState

func on_enter() -> void:
	var challenge_number := BattleManager.get_challenge_number()
	ChallengeManager.set_challenge_complete(challenge_number)
	
	BattleManager.finish_battle()
	BattleView.hide_ui()
	PlayerPartyManager.reload_participants()
