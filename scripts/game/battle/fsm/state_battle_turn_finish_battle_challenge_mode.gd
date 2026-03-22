class_name StateBattleFinishBattleChallengeMode extends FSMState

func on_enter() -> void:
	var challenge_number := BattleManager.get_challenge_number()
	ChallengeManager.set_unlock_level(challenge_number + 1)
	
	BattleManager.finish_battle()
	BattleView.hide_ui()
	PlayerPartyManager.reload_participants()
