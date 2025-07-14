class_name FiniteStateMachine extends Node2D

class Transition:
	extends RefCounted
	
	var from_state: StringName
	var to_state: StringName
	var condition: Callable
	
var _states: Dictionary[StringName, FSMState]
var _current_state: FSMState
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

func goto_state(new_state: StringName) -> void:
	if !_states.has(new_state):
		return
		
	if _current_state:
		_current_state.on_exit()

	print("going to %s" % new_state)
		
	_current_state = _states[new_state]
	_current_state.on_enter()
	
	var filter_func := func(transition: Transition) -> bool:
		return transition.from_state == new_state
	
	_current_valid_transitions.clear()
	_current_valid_transitions = _transitions.filter(filter_func)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
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
