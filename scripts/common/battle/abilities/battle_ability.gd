class_name BattleAbility extends Resource

var _source: BattleParticipant
var _target: BattleParticipant
var _is_executing := false
# var _valid_targets: Array[BattleParticipant]

# TODO: Find some way of statically typing this. Is it possible?
@export var fx_activate: PackedScene
@export var fx_affect_target: PackedScene

static var ability_class_registry: Dictionary[StringName, String] = {
	"attack": "res://game/abilities/ability_attack.tres",
	"pass": "res://game/abilities/ability_pass.tres",
	"nuke": "res://game/abilities/ability_nuke.tres",
}

# TODO: Right now there is an assumption that the only execution context 
# needed is an optional `_target`. There might be a more comprehensive struct
# implemented later
func execute(in_target: BattleParticipant) -> void:
	_target = in_target
	_is_executing = true

func end() -> void:
	_is_executing = false

func get_is_executing() -> bool:
	return _is_executing

# This function must be subclassed and return true for valid targets
func is_valid_for_target(_possible_target: BattleParticipant) -> bool:
	return true

# Returns whether this ability can currently activate
func can_activate() -> bool:
	for participant in BattleManager.get_participants():
		if is_valid_for_target(participant):
			return true
	return false

# Helper function for calling a callable after a certain amount of time
func set_timer(time: float, callable: Callable) -> void:
	var timer := BattleManager.get_tree().create_timer(time)
	timer.timeout.connect(callable)

# Helper function for ending ability after certain amount of time
func set_lifetime(lifetime: float) -> void:
	set_timer(lifetime, end)

func initialize(in_source: BattleParticipant = null) -> void:
	_source = in_source

# func _init(in_source: BattleParticipant = null) -> void:
# 	_source = in_source