class_name StateBattleTurnHandleDeath extends FSMState

func on_enter() -> void:
	BattleManager.start_blocking_timer(1.0)
