class_name StateBattleTurnSetup extends FSMState

# go to next turn from list in BattleManager
func on_enter() -> void:
	BattleManager.goto_next_turn()
