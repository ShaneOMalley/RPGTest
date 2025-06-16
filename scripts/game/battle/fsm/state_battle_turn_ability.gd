class_name StateBattleTurnAbility extends FSMState

func on_enter() -> void:
	BattleManager.execute_queued_ability()
	BattleManager.start_blocking_timer(1.0)
	
func on_exit() -> void:
	BattleManager.clear_queued_ability()
