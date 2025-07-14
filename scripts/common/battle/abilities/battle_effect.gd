class_name BattleEffect extends Node

# Note: only instantaneous additive effects for now

# TODO: Support status effects and other _duration effects
enum Duration { INSTANT }

# TODO: Support multiplicative
enum Operator { ADDITIVE }

class BattleEffectModifier:

    var attribute_id: StringName
    var magnitude: int
    var operator: Operator = Operator.ADDITIVE

    func _init(in_attribute_id: StringName, in_magnitude: int, in_operator: Operator) -> void:
        attribute_id = in_attribute_id
        magnitude = in_magnitude
        operator = in_operator

var source: BattleParticipant
var target: BattleParticipant
var _duration: Duration = Duration.INSTANT
var _modifiers: Array[BattleEffectModifier]

func grant() -> void:
    if _duration == Duration.INSTANT:
        for modifier in _modifiers:
            if modifier.operator == Operator.ADDITIVE:
                var current = target.get(modifier.attribute_id)
                target.set(modifier.attribute_id, current + modifier.magnitude)
    # TODO: Support status effects and other _duration effects
    # TODO: Support multiplicative

func _init(in_source: BattleParticipant, in_target: BattleParticipant) -> void:
    source = in_source
    target = in_target