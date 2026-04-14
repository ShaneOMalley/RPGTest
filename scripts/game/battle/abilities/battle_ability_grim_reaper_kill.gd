class_name BattleAbilityGrimReaperKill extends BattleAbility

var kill_effect: BattleEffectAttack

func execute(in_target: BattleParticipant, in_turn_target: BattleTurn = null) -> void:
	super.execute(in_target, in_turn_target)

	# BattleManager.play_fx(fx_activate, _source)
	BattleManager.play_fx(fx_activate, _source)
	BattleManager.play_animation(&"attack", _source)

	set_lifetime(3)
	set_timer(0.2, show_message.bind(2.6))
	
	if _target:
		if _target == _source:
			set_timer(2.8, _do_leave)
		else:
			set_timer(0.2, _kill_target)
	
func _kill_target() -> void:
	kill_effect = BattleEffectAttack.new(_source, _target, 100)
	kill_effect.apply()
	
	BattleManager.play_fx(fx_affect_target, _target)
	BattleManager.play_animation(&"getting_hit", _target)
	
func _do_leave() -> void:
	var turn_manipulation := BattleTurn.TurnManipulation.new()
	turn_manipulation.anim_name = &"shrink"
	turn_manipulation.type = BattleTurn.TurnManipulation.Type.REMOVE
	
	for participant_turn in BattleManager.get_turns_for_participant(_target):
		turn_manipulation.turns.push_back(participant_turn)
		
	BattleManager.on_battle_turn_manipulation.emit([turn_manipulation])
	
	set_timer(0.6, _remove_participant)
	BattleManager.block_fsm(1)
	
func _remove_participant() -> void:
	BattleManager.kill_participant(_target)
	
func is_valid_for_target(possible_target: BattleParticipant) -> bool:
	return true
	
func get_message() -> String:
	if _target:
		if _target == _source:
			return tr("ABILITY_MESSAGE_GRIM_REAPER_LEAVE").format({"source": _source.get_display_name()})
		else:
			return tr("ABILITY_MESSAGE_GRIM_REAPER_KILL").format({"source": _source.get_display_name(), "target": _target.get_display_name()})
	else:
		return tr("ABILITY_MESSAGE_GRIM_REAPER_WAIT").format({"source": _source.get_display_name()})
