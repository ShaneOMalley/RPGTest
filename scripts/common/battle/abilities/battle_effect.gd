class_name BattleEffect extends Node

# Note: only instantaneous additive effects for now

# TODO: Support status effects and other _duration effects
enum Duration { INSTANT, DURATION }

# TODO: Support multiplicative
enum Operator { ADDITIVE, MULTIPLY }

class BattleEffectModifier:
	var attribute: StringName
	var magnitude: float
	var operator: Operator = Operator.ADDITIVE

	func _init(in_attribute: StringName, in_magnitude: float, in_operator: Operator) -> void:
		attribute = in_attribute
		magnitude = in_magnitude
		operator = in_operator
		# todo: assert that this effect's duration makes sense to apply to this modifier

var source: BattleParticipant
var target: BattleParticipant
var _duration: Duration = Duration.INSTANT
var _modifiers: Array[BattleEffectModifier]

# TODO: Put visual stuff in here

func apply() -> void:
	if _duration == Duration.INSTANT:
		for modifier in _modifiers:
			if modifier.operator == Operator.ADDITIVE:
				var current = target.get(modifier.attribute)
				target.set(modifier.attribute, current + modifier.magnitude)
			elif modifier.operator == Operator.MULTIPLY:
				assert(false, "multiplicative instant modifiers not yet supported")
	elif _duration == Duration.DURATION:
		target.add_effect(self)

	target.apply_attribute_caps()
	
	# TODO: Support status effects and other _duration effects
	# TODO: Support multiplicative
	BattleManager.on_battle_effect_applied.emit(self)
	
func remove() -> void:
	if _duration == Duration.DURATION:
		target.remove_effect(self)
		
func _to_string() -> String:
	var result := "source=%s target=%s\n" % [source.to_string(), target.to_string()]
	for modifier in _modifiers:
		var operator_string = {Operator.ADDITIVE : "additive", Operator.MULTIPLY : "multiply"}.get(modifier.operator)
		result += "-- attribute: %s, magnitude=%d, operator=%s\n" % [modifier.attribute, modifier.magnitude, operator_string]
	return result

func _init(in_source: BattleParticipant, in_target: BattleParticipant) -> void:
	source = in_source
	target = in_target
