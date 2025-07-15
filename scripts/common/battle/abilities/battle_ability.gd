class_name BattleAbility extends Node

var _source: BattleParticipant
var _is_executing := false

# TODO: Right now there is an assumption that the only execution context 
# needed is an optional `_target`. There might be a more comprehensive struct
# implemented later
func execute(_target: BattleParticipant) -> void:
	_is_executing = true
	pass

# var _is_blocked: bool
# func start_blocking_timer(time: float) -> void:
# 	var timer := get_tree().create_timer(time)
# 	_is_blocked = true
# 	timer.timeout.connect(func(): self._is_blocked = false)
# 	
# func get_is_blocked() -> bool:
# 	return _is_blocked

static var ability_class_registry: Dictionary[StringName, GDScript] = {
	"attack": BattleAbilityAttack,
	"pass": BattleAbilityPass,
}

# TODO: Find some elegant way of doing this and letting BattleAbility subclasses register themselves
# static func _register_ability(id: StringName, ability: GDScript) -> void:
# 	assert(Utils.is_subclass_of(ability, BattleAbility))
# 	_ability_class_registry[id] = ability

func end() -> void:
	#_is_executing = false
	# TODO: remove this hacky blocking timer and uncomment above
	var timer := BattleManager.get_tree().create_timer(0.5)
	timer.timeout.connect(func(): self._is_executing = false)
	pass

func get_is_executing() -> bool:
	return _is_executing

func _init(in_source: BattleParticipant) -> void:
	_source = in_source