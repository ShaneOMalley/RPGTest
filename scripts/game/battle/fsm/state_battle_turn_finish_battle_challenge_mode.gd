class_name StateBattleFinishBattleChallengeMode extends FSMState

func on_enter() -> void:
	BattleManager.finish_battle()
	BattleView.hide_ui()
	PlayerPartyManager.reload_participants()
