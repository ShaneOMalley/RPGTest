class_name StateBattlePostBattleRewards extends FSMState

func on_enter() -> void:
	var rewards := BattleManager.get_rewards()
	var gold: int = rewards.get_or_add(&"gold", 0)
	
	PlayerPartyManager.inventory.gold += gold
	
	BattleManager.request_message("you got %d gold!" % gold)
	BattleManager.block_fsm(1.1)
