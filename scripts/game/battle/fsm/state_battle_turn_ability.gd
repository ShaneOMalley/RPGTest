class_name StateBattleTurnAbility extends FSMState

func on_enter() -> void:
	BattleManager.execute_queued_ability()
	
func on_exit() -> void:
	BattleManager.clear_queued_ability()
