class_name BattleAbilityPotion extends BattleAbility

var effect: BattleEffectHealing

const HEAL_AMOUNT: int = 50

func execute(in_target: BattleParticipant, _in_turn_target: BattleTurn = null) -> void:
	super.execute(in_target)
	
	BattleManager.play_fx(fx_activate, _source)
	BattleManager.play_animation(&"casting", _source)
	
	set_timer(0.4, _apply_healing_effect)
	set_lifetime(1.9)

func _apply_healing_effect() -> void:
	effect = BattleEffectHealing.new(_source, _target, HEAL_AMOUNT)
	effect.apply()

	BattleManager.play_fx(fx_affect_target, _target)
	
	set_timer(0.3, show_message)
	
func is_valid_for_target(_possible_target: BattleParticipant) -> bool:
	return _possible_target.affiliation == _source.affiliation
	
func find_fallback_target() -> Array:
	var possible_targets = BattleManager.participants.filter(func(participant): return is_valid_for_target(participant))
	return [possible_targets.pick_random(), null]

func get_message() -> String:
	return tr("ABILITY_MESSAGE_POTION").format({"source": _source.get_display_name(), "target": _target.get_display_name(), "hp_amount": effect.hp})

func execute_out_of_combat(_in_source: BattleParticipant, _in_target: BattleParticipant) -> void:
	super.execute_out_of_combat(_in_source, _in_target)
	effect = BattleEffectHealing.new(_in_source, _in_target, HEAL_AMOUNT)
	effect.apply()

func can_execute_out_of_combat() -> bool:
	return true
