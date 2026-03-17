class_name BattleEffectRestoreSp extends BattleEffect

var sp: int

func _init(in_source: BattleParticipant, in_target: BattleParticipant, in_sp: int) -> void:
	super._init(in_source, in_target)
	sp = in_sp
	_modifiers.append(BattleEffectModifier.new(&"_sp", sp, Operator.ADDITIVE))
