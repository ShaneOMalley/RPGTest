class_name BattleAbilityPotion extends BattleAbility

var effect: BattleEffectHealing

func execute(in_target: BattleParticipant, in_turn_target: BattleTurn = null) -> void:
	super.execute(in_target)
	
	BattleManager.play_fx(fx_activate, _source)
	BattleManager.play_animation(&"casting", _source)
	
	set_timer(0.4, _apply_healing_effect)
	set_lifetime(1.9)

func _apply_healing_effect() -> void:
	effect = BattleEffectHealing.new(_source, _target, 50)
	effect.apply()

	BattleManager.play_fx(fx_affect_target, _target)
	
	set_timer(0.3, show_message)
	
func is_valid_for_target(_possible_target: BattleParticipant) -> bool:
	return _possible_target.affiliation == _source.affiliation
	
func find_fallback_target() -> Array:
	var possible_targets = BattleManager.participants.filter(func(participant): return is_valid_for_target(participant))
	return [possible_targets.pick_random(), null]

func get_message() -> String:
	return "%s heals %s for %d hp!" % [_source.get_display_name(), _target.get_display_name(), effect.hp]
