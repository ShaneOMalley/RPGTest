class_name FSMState extends Node2D

func on_enter() -> void:
	pass
	
func on_exit() -> void:
	pass

func update(_delta: float) -> void:
	pass
	
func set_timer(time: float, callable: Callable) -> void:
	# todo: investigate why we can't just call our own `get_tree()`
	var timer := BattleManager.get_tree().create_timer(time)
	timer.timeout.connect(callable)
