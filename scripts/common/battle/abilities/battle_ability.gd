class_name BattleAbility extends Resource

var _source: BattleParticipant
var _target: BattleParticipant
var _turn_target: BattleTurn
var _is_executing := false
# var _valid_targets: Array[BattleParticipant]

# TODO: Find some way of statically typing this. Is it possible?
@export var fx_activate: PackedScene
@export var fx_affect_target: PackedScene

static var ability_class_registry: Dictionary[StringName, String] = {
	# Common
	"attack": "res://game/abilities/ability_attack.tres",
	"pass": "res://game/abilities/ability_pass.tres",

	# Chronomancer
	"haste" : "res://game/abilities/ability_haste.tres",
	"slow" : "res://game/abilities/ability_slow.tres",
	"skip_turn" : "res://game/abilities/ability_skip_turn.tres",
	"skip_many_turns" : "res://game/abilities/ability_skip_many_turns.tres",

	# Debug
	"nuke": "res://game/abilities/ability_nuke.tres",
	"extra_turn": "res://game/abilities/ability_extra_turn.tres",
}

# TODO: Right now there is an assumption that the only execution context 
# needed is an optional `_target`. There might be a more comprehensive struct
# implemented later
func execute(in_target: BattleParticipant, in_turn_target: BattleTurn = null) -> void:
	_target = in_target
	_turn_target = in_turn_target
	
	_is_executing = true
	
	# all abilities: shrink current turn
	var turn_manipulation := BattleTurn.TurnManipulation.new()
	turn_manipulation.turns = [BattleManager.get_current_turn()]
	turn_manipulation.anim_name = &"shrink"
	turn_manipulation.type = BattleTurn.TurnManipulation.Type.REMOVE
	BattleManager.on_battle_turn_manipulation.emit([turn_manipulation])

func prepare(in_target: BattleParticipant) -> void:
	_target = in_target
	print(" - Preparing %s..." % resource_name)
	
	# todo: queue turn stuff
	# BattleManager.on_battle_ability_prepare_start.emit(self)
	
func cancel() -> void:
	_target = null
	print(" - Canceling Prepare %s!" % resource_name)
	
	# BattleManager.on_battle_ability_prepare_end.emit(self)
	
func cancel_prepare() -> void:
	pass

func end() -> void:
	_is_executing = false

func get_is_executing() -> bool:
	return _is_executing
	
# This function must be subclassed and return true for valid targets
func is_valid_for_target(_possible_target: BattleParticipant) -> bool:
	return true
	
func requires_turn_target() -> bool:
	return false

# Returns whether this ability can currently activate
func can_activate() -> bool:
	if requires_turn_target():
		return true
		
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
	
func get_message() -> String:
	return ""

func show_message() -> void:
	BattleManager.request_message(get_message())

# func _init(in_source: BattleParticipant = null) -> void:
# 	_source = in_source
