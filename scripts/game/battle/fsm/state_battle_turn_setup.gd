class_name StateBattleTurnSetup extends FSMState

# go to next turn from list in BattleManager
func on_enter() -> void:
	var current_turn := BattleManager.get_current_turn()
	if is_instance_valid(current_turn):
		var turn_manipulation := BattleTurn.TurnManipulation.new()
		turn_manipulation.turns = [current_turn]
		turn_manipulation.anim_name = &"shrink"
		turn_manipulation.type = BattleTurn.TurnManipulation.Type.REMOVE
		BattleManager.on_battle_turn_manipulation.emit([turn_manipulation])
		
		set_timer(0.4, BattleManager.goto_next_turn)
		BattleManager.block_fsm(0.41)
	else:
		BattleManager.goto_next_turn()
