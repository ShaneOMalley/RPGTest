class_name BattleEffectAttack extends BattleEffect

# TODO: This should probably be defined in data, but executions can't happen in
# data (strength - vitality / 2 etc). Maybe implement someething similar to GAS's
# set_by_caller and pass this in from the ability

var damage: int

func _init(in_source: BattleParticipant, in_target: BattleParticipant, damage_multiplier: float = 1.0) -> void:
	super._init(in_source, in_target)
	damage = floori(max(0, source.get_attribute(&"_strength") * damage_multiplier - (target.get_attribute(&"_vitality") / 2.0)))
	_modifiers.append(BattleEffectModifier.new(&"_hp", -damage, Operator.ADDITIVE))
