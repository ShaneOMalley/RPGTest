class_name BattleAbilitySlow extends BattleAbility

var _agility_effect: BattleEffectSlow

func execute(in_target: BattleParticipant, in_turn_target: BattleTurn = null) -> void:
	super.execute(in_target)
	
	BattleManager.play_animation(&"casting", _source)
	set_lifetime(1.3)
	show_message()
	
	_agility_effect = null

func prepare(in_target: BattleParticipant, in_turn_target: BattleTurn = null) -> void:
	# remove agility modifier from other participant
	if is_instance_valid(_agility_effect) and _agility_effect.target !=  in_target:
		var old_target = _agility_effect.target
		_agility_effect.remove()
		_agility_effect = null
		
		# recalculate turns
		BattleManager.recalculate_all_turn_times(old_target)
	
	# apply agility modifier
	if !is_instance_valid(_agility_effect):
		_agility_effect = BattleEffectSlow.new(_source, in_target)
		_agility_effect.apply()
	
		# recalculate turns
		BattleManager.recalculate_all_turn_times(in_target, &"grow")
	
	super.prepare(in_target, in_turn_target)

func cancel() -> void:
	super.cancel()
		
func cancel_prepare() -> void:
	# remove agility modifier
	if is_instance_valid(_agility_effect):
		_agility_effect.remove()
		_agility_effect = null
		
		# recalculate turns
		BattleManager.recalculate_all_turn_times(_target)
	
	super.cancel_prepare()

func is_valid_for_target(_possible_target: BattleParticipant) -> bool:
	return true
	
func get_message() -> String:
	return tr("ABILITY_MESSAGE_SLOW").format({"source": _source.get_display_name(), "target": _target.get_display_name()})
