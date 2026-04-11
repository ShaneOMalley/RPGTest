class_name StateGameOverNormal extends FSMState

func on_enter() -> void:
	BattleManager.request_message(tr("GAME_OVER_NORMAL"), 1.1)
	BattleManager.block_fsm(1.1)
	
	set_timer(1.1, _finish_battle)
	
func _finish_battle() -> void:
	BattleManager.finish_battle()
	DungeonManager.end_dungeon_crawling()
