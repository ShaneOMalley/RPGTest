class_name BattleEffectSlow extends BattleEffect

func _init(in_source: BattleParticipant, in_target: BattleParticipant) -> void:
	super._init(in_source, in_target)
	_duration = Duration.DURATION
	_modifiers.append(BattleEffectModifier.new(&"_agility", 0.5, Operator.MULTIPLY))
