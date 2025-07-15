class_name BattleAbility extends Node

var _source: BattleParticipant
var _is_executing := false
# var _valid_targets: Array[BattleParticipant]

static var ability_class_registry: Dictionary[StringName, GDScript] = {
	"attack": BattleAbilityAttack,
	"pass": BattleAbilityPass,
}

# TODO: Right now there is an assumption that the only execution context 
# needed is an optional `_target`. There might be a more comprehensive struct
# implemented later
func execute(_target: BattleParticipant) -> void:
	_is_executing = true
	pass

func end() -> void:
	# TODO: remove this hacky blocking timer and uncomment above
	# var timer := BattleManager.get_tree().create_timer(0.5)
	# timer.timeout.connect(func(): self._is_executing = false)
	_is_executing = false
	pass

func get_is_executing() -> bool:
	return _is_executing

# This function must be subclassed and return true for valid targets
func is_valid_for_target(possible_target: BattleParticipant) -> bool:
	return true

func _init(in_source: BattleParticipant) -> void:
	_source = in_source