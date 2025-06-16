class_name StateBattleTurnAbility extends FSMState

func on_enter() -> void:
	BattleManager.start_blocking_timer(2.0)