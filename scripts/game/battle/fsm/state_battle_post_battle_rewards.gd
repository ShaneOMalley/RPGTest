class_name StateBattlePostBattleRewards extends FSMState

func on_enter() -> void:
	var rewards := BattleManager.get_rewards()
	var gold: int = rewards.get_or_add(&"gold", 0)
	
	PlayerPartyManager.inventory.gold += gold
	
	for player_participant in PlayerPartyManager.get_participants():
		var hp = player_participant.get_attribute(&"_max_hp")
		var sp = player_participant.get_attribute(&"_max_sp")
		
		var healing_effect = BattleEffectHealing.new(player_participant, player_participant, hp * 0.1)
		var restore_sp_effect = BattleEffectRestoreSp.new(player_participant, player_participant, sp * 0.1)
		
		healing_effect.apply()
		restore_sp_effect.apply()
	
	BattleManager.request_message("you got %d gold!\nRestored some hp and sp" % gold, 1.1)
	BattleManager.block_fsm(1.1)
