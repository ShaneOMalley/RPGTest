class_name BattleAbilityAttack extends BattleAbility

func execute(in_target: BattleParticipant) -> void:
	super.execute(in_target)

	BattleManager.play_oneshot_fx(fx_activate, _source)

	set_timer(0.4, _apply_attack_effect)
	set_lifetime(1.2)

func _apply_attack_effect() -> void:
	var effect := BattleEffectAttack.new(_source, _target)
	effect.apply()

	BattleManager.play_oneshot_fx(fx_affect_target, _target)

func is_valid_for_target(possible_target: BattleParticipant) -> bool:
	return possible_target.affiliation != _source.affiliation
