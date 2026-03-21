class_name StateBattleTurnDecisionPlayer extends StateBattleTurnDecision

func on_enter() -> void:
	var current_turn := BattleManager.get_current_turn()
	if !current_turn.get_modifier().forced_ability_id.is_empty():
		# assume that we need to execute the forced ability with a "self" target
		var participant := current_turn.participant
		var ability := participant.abilities[current_turn.get_modifier().forced_ability_id]
		BattleManager.queue_ability_execution(ability, participant)
		return
		
	BattleManager.request_show_battle_menu()
		
func on_exit() -> void:
	BattleManager.request_hide_battle_menu()
