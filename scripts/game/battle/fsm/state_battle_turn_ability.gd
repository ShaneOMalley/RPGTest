class_name StateBattleTurnAbility extends FSMState

func on_enter() -> void:
	BattleManager.execute_queued_ability()
	BattleManager.start_blocking_timer(0.5)
	
func on_exit() -> void:
	BattleManager.clear_queued_ability()
