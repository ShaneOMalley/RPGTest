class_name BattleAbilityAttack extends BattleAbility

var effect: BattleEffectAttack

func execute(in_target: BattleParticipant, in_turn_target: BattleTurn = null) -> void:
	super.execute(in_target)

	BattleManager.play_fx(fx_activate, _source)
	BattleManager.play_animation(&"attack", _source)

	set_timer(0.4, _apply_attack_effect)
	set_lifetime(1.9)
	# AnimationCallbackManager.get_event_signal(&"on_animation_finished").connect(func(anim_id): if anim_id == "attack": end())

func _apply_attack_effect() -> void:
	effect = BattleEffectAttack.new(_source, _target)
	effect.apply()

	BattleManager.play_fx(fx_affect_target, _target)
	BattleManager.play_animation(&"getting_hit", _target)
	
	set_timer(0.3, show_message)
	
func is_valid_for_target(possible_target: BattleParticipant) -> bool:
	return possible_target.affiliation != _source.affiliation
	
func find_fallback_target() -> Array:
	var possible_targets = BattleManager.participants.filter(func(participant): return is_valid_for_target(participant))
	return [possible_targets.pick_random(), null]

func get_message() -> String:
	return "%s attacks %s for %d damage!" % [_source.get_display_name(), _target.get_display_name(), effect.damage]
