class_name BattleAbility extends Resource

var _source: BattleParticipant
var _is_executing := false
# var _valid_targets: Array[BattleParticipant]

@export var effect_activate: PackedScene
@export var effect_affect_target: PackedScene

static var ability_class_registry: Dictionary[StringName, String] = {
	"attack": "res://game/abilities/ability_attack.tres",
	"pass": "res://game/abilities/ability_pass.tres",
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
func is_valid_for_target(_possible_target: BattleParticipant) -> bool:
	return true

func can_activate() -> bool:
	for participant in BattleManager.get_participants():
		if is_valid_for_target(participant):
			return true
	return false

func initialize(in_source: BattleParticipant = null) -> void:
	_source = in_source

# func _init(in_source: BattleParticipant = null) -> void:
# 	_source = in_source