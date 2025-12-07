class_name BattleAbilityNuke extends BattleAbility

class BattleEffectNuke extends BattleEffect:
	func _init(in_source: BattleParticipant, in_target: BattleParticipant) -> void:
		super._init(in_source, in_target)
		var damage := 1000
		
		_modifiers.append(BattleEffectModifier.new(&"_hp", -damage, Operator.ADDITIVE))

func execute(in_target: BattleParticipant, in_turn_target: BattleTurn = null) -> void:
	super.execute(in_target)

	BattleManager.play_fx(fx_activate, _source)
	BattleManager.play_animation(&"attack", _source)
	
	set_timer(0.4, _apply_attack_effect)
	set_lifetime(1.2)

func _apply_attack_effect():
	for enemy_participant in BattleManager.get_enemies():
		var effect := BattleEffectNuke.new(_source, enemy_participant)
		effect.apply()

		BattleManager.play_fx(fx_affect_target, enemy_participant)
		
	set_timer(0.2, show_message)

func is_valid_for_target(possible_target: BattleParticipant) -> bool:
	return possible_target == _source
	
func get_message() -> String:
	return "%s drops a nuke" % _source.get_display_name()
