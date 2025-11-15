class_name FiniteStateMachine extends Node2D

class Transition:
	extends RefCounted
	
	var from_state: StringName
	var to_state: StringName
	var condition: Callable

signal on_state_entered(StringName)
signal on_state_exited(StringName)
	
var _states: Dictionary[StringName, FSMState]
var _current_state: FSMState
var _current_state_name: StringName
var _transitions: Array[Transition]
var _current_valid_transitions: Array[Transition]

func add_state(state_name: StringName, state: FSMState) -> void:
	_states[state_name] = state
	
func add_transition(from_state: StringName, to_state: StringName, condition: Callable) -> void:
	var transition = Transition.new()
	transition.from_state = from_state
	transition.to_state = to_state
	transition.condition = condition
	_transitions.push_back(transition)

func goto_state(new_state_name: StringName) -> void:
	if !_states.has(new_state_name):
		return
		
	if _current_state:
		_current_state.on_exit()
		on_state_exited.emit(_current_state_name)

	print("going to %s" % new_state_name)
		
	_current_state = _states[new_state_name]
	_current_state.on_enter()
	_current_state_name = new_state_name
	on_state_entered.emit(new_state_name)
	
	var filter_func := func(transition: Transition) -> bool:
		return transition.from_state == new_state_name
	
	_current_valid_transitions.clear()
	_current_valid_transitions = _transitions.filter(filter_func)
	
var _is_blocked: bool
func start_blocking_timer(time: float) -> void:
	var timer := get_tree().create_timer(time)
	_is_blocked = true
	timer.timeout.connect(func(): self._is_blocked = false)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if _is_blocked:
		return
		
	var predicate := func(transition: Transition) -> bool:
		return transition.condition.call()
	
	var found_index = _current_valid_transitions.find_custom(predicate)
	if (found_index != -1):
		var transition := _current_valid_transitions[found_index]
		goto_state(transition.to_state)
		# todo: decide whether or not to do this recursively
		# _process(delta)
	
	if _current_state:
		_current_state.update(delta)
