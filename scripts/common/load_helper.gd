extends Node

class MultiLoadEntry:
	var paths: Array[String]
	var on_finished: Callable

var _current_multi_loads: Array[MultiLoadEntry]

func load_multiple_async(paths: Array[String], callback: Callable) -> void:
	for path in paths:
		ResourceLoader.load_threaded_request(path)

	var entry = MultiLoadEntry.new();
	entry.paths = paths
	entry.on_finished = callback
	_current_multi_loads.append(entry)

func _process(_delta: float):
	# if !Input.is_action_just_pressed("ui_left"):
	# 	return

	for i in range(_current_multi_loads.size() - 1, -1, -1):
		var _all_finished = true
		for path in _current_multi_loads[i].paths:
			var _status = ResourceLoader.load_threaded_get_status(path)
			match _status:
				ResourceLoader.THREAD_LOAD_IN_PROGRESS:
					_all_finished = false
					break

		if _all_finished:
			_current_multi_loads[i].on_finished.call()
			_current_multi_loads.remove_at(i)
