extends Node

class MultiLoadRequest:
	var paths: Array[String]
	var on_finished: Callable

var _current_multi_loads: Array[MultiLoadRequest]

func load_multiple_async(paths: Array[String], callback: Callable) -> void:
	for path in paths:
		ResourceLoader.load_threaded_request(path)

	var entry = MultiLoadRequest.new();
	entry.paths = paths
	entry.on_finished = callback
	_current_multi_loads.append(entry)
	
func _is_request_loaded(multi_load_request: MultiLoadRequest):
	for path in multi_load_request.paths:
		var _status = ResourceLoader.load_threaded_get_status(path)
		if _status == ResourceLoader.THREAD_LOAD_IN_PROGRESS:
			return false
	return true
	
func _process(_delta: float):
	# if !Input.is_action_just_pressed("ui_left"):
	# 	return

	for i in range(_current_multi_loads.size() - 1, -1, -1):
		if _is_request_loaded(_current_multi_loads[i]):
			if _current_multi_loads[i].on_finished.is_valid():
				_current_multi_loads[i].on_finished.call()
			_current_multi_loads.remove_at(i)
