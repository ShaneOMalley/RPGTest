class_name StateBattleTurnDecisionEnemy extends StateBattleTurnDecision

func on_enter() -> void:
	var current_turn := BattleManager.get_current_turn()
	var participant := current_turn.participant
	
	if participant.ai != &"":
		var enemies := BattleManager.get_enemies()
		var players := BattleManager.get_players()
	
		# var fuck_you = EnemyAI.enemy_ai
		var ability_execution = EnemyAI.enemy_ai[participant.ai].call(participant, enemies, players)
		assert(ability_execution != null)
		
		BattleManager.queue_ability_execution(ability_execution.ability, ability_execution.target, ability_execution.turn_target)
		
	else:
		if !current_turn.turn_modifier.forced_ability_id.is_empty():
			# assume that we need to execute the forced ability with a "self" target
			var ability := participant.abilities[current_turn.turn_modifier.forced_ability_id]
			BattleManager.queue_ability_execution(ability, participant)
			return

		var ability_attack := participant.abilities[&"attack"] as BattleAbility

		if ability_attack.can_activate() and BattleManager._current_turn.is_ability_allowed(&"attack"):
			var target = BattleManager.get_players().pick_random()
			BattleManager.queue_ability_execution(ability_attack, target)
		else:
			var ability_pass := participant.abilities[&"pass"] as BattleAbility
			BattleManager.queue_ability_execution(ability_pass, null)
