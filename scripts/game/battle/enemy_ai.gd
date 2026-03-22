extends Node

func ai_scaredy_cat(self_participant: BattleParticipant, ally_participants: Array[BattleParticipant], opposing_participants: Array[BattleParticipant]) -> BattleManager.AbilityExecution:
	if self_participant.get_attribute(&"_hp") < self_participant.get_attribute(&"_max_hp"):
		self_participant.run_away_reason = &"damaged"
		
	for participant in opposing_participants:
		var next_turn := BattleManager.get_next_turn_for_participant(participant)
		if next_turn.get_modifier().type == BattleTurn.TurnModifier.Type.POWER_CHARGE_ATTACK:
			self_participant.run_away_reason = &"enemy power charging"
			break
			
	var pass_ability := self_participant.abilities[&"scaredy_cat_run"]
	return BattleManager.AbilityExecution.new(pass_ability, self_participant)
	
func ai_smasher(self_participant: BattleParticipant, ally_participants: Array[BattleParticipant], opposing_participants: Array[BattleParticipant]) -> BattleManager.AbilityExecution:
	var target = opposing_participants.back()
	var attack_ability := self_participant.abilities[&"smasher_smash"]
	return BattleManager.AbilityExecution.new(attack_ability, target)
	
func ai_grim_reaper(self_participant: BattleParticipant, ally_participants: Array[BattleParticipant], opposing_participants: Array[BattleParticipant]) -> BattleManager.AbilityExecution:
	var target: BattleParticipant = null
	
	if ally_participants.size() == 1 && ally_participants[0] == self_participant:
		target = self_participant # grim_reaper ability with self target = leave
	
	for participant in opposing_participants:
		if participant.get_attribute(&"_hp") <= participant.get_attribute(&"_max_hp") * 0.1:
			target = participant
		
	var grim_reaper_kill_ability := self_participant.abilities[&"grim_reaper_kill"]
	return BattleManager.AbilityExecution.new(grim_reaper_kill_ability, target)

var enemy_ai: Dictionary[StringName, Callable] = {
	&"challenge_scaredy_cat": ai_scaredy_cat,
	&"challenge_smasher": ai_smasher,
	&"challenge_grim_reaper": ai_grim_reaper,
}
