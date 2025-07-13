class_name StateBattleTurnSetup extends FSMState

# pop turn from list in BattleManager, make that next turn
func on_enter() -> void:
	BattleManager.goto_next_turn()
