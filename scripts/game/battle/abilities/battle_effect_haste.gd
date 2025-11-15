class_name BattleEffectHaste extends BattleEffect

func _init(in_source: BattleParticipant, in_target: BattleParticipant) -> void:
	super._init(in_source, in_target)
	_duration = Duration.DURATION
	_modifiers.append(BattleEffectModifier.new(&"_agility", 1.5, Operator.MULTIPLY))
