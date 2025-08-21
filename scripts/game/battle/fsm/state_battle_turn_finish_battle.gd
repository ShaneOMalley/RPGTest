class_name StateBattleFinishBattle extends FSMState

func on_enter() -> void:
	BattleManager.finish_battle()
