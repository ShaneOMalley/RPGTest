class_name BattleAbilityHaste extends BattleAbility

var _agility_effect: BattleEffectHaste

func execute(in_target: BattleParticipant) -> void:
	super.execute(in_target)
	
	set_lifetime(1.3)

func prepare(in_target: BattleParticipant) -> void:
	# remove agility modifier from other participant
	if is_instance_valid(_agility_effect) and _agility_effect.target !=  in_target:
		var old_target = _agility_effect.target
		_agility_effect.remove()
		_agility_effect = null
		
		# recalculate turns
		BattleManager.recalculate_normal_turn_times(old_target)
	
	# apply agility modifier
	if !is_instance_valid(_agility_effect):
		_agility_effect = BattleEffectHaste.new(_source, in_target)
		_agility_effect.apply()
	
		# recalculate turns
		BattleManager.recalculate_normal_turn_times(in_target, &"grow")
	
	super.prepare(in_target)

func cancel() -> void:
	super.cancel()
	
func cancel_prepare() -> void:
	# remove agility modifier
	if is_instance_valid(_agility_effect):
		_agility_effect.remove()
		_agility_effect = null
		
		# recalculate turns
		BattleManager.recalculate_normal_turn_times(_target)
		
	super.cancel_prepare()

func is_valid_for_target(_possible_target: BattleParticipant) -> bool:
	return true
