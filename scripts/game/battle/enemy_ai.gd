extends Node

var enemy_ai: Dictionary[StringName, Callable] = {
	&"challenge_scaredy_cat": func(self_participant: BattleParticipant, ally_participants: Array[BattleParticipant], opposing_participants: Array[BattleParticipant]) -> BattleManager.AbilityExecution:
		if self_participant.get_attribute(&"_hp") < self_participant.get_attribute(&"_max_hp"):
			self_participant.run_away_reason = &"damaged"
			# var run_ability := self_participant.abilities[&"run_away"]
			# return BattleManager.AbilityExecution.new(run_ability, self_participant)
			
		for participant in opposing_participants:
			var next_turn := BattleManager.get_next_turn_for_participant(participant)
			if next_turn.get_modifier().type == BattleTurn.TurnModifier.Type.POWER_CHARGE_ATTACK:
				self_participant.run_away_reason = &"enemy power charging"
				break
				# var run_ability := self_participant.abilities[&"run_away"]
				# return BattleManager.AbilityExecution.new(run_ability, self_participant)
				
		var pass_ability := self_participant.abilities[&"scaredy_cat_run"]
		return BattleManager.AbilityExecution.new(pass_ability, self_participant)
}
