class_name FSMBattle extends FiniteStateMachine

class FSMState1 extends FSMState:
	func update(_delta: float) -> void:
		pass
		# print("updating state 1")
	
	func on_enter() -> void:
		print("enter state 1")

class FSMState2:
	extends FSMState
	func update(_delta: float) -> void:
		pass
		# print("updating state 2")
	
	func on_enter() -> void:
		print("enter state 2")

var _time = 0.0

func _init() -> void:
	add_state("one", FSMState1.new())
	add_state("two", FSMState2.new())

	add_transition("one", "two", func(): return floori(self._time) % 2 == 0)
	add_transition("two", "one", func(): return floori(self._time) % 2 == 1)

	goto_state("one")

func _process(delta: float) -> void:
	super._process(delta)
	
	_time += delta	
