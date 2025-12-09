class_name BattleEffectHealing extends BattleEffect

var hp: int

func _init(in_source: BattleParticipant, in_target: BattleParticipant, in_hp: int) -> void:
	super._init(in_source, in_target)
	hp = in_hp
	_modifiers.append(BattleEffectModifier.new(&"_hp", hp, Operator.ADDITIVE))
