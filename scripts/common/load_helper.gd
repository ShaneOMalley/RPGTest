extends Node

class MultiLoadEntry:
    var paths: Array[String]
    var on_finished: Callable

# var _load_check_timer: Timer
var _current_loads: Dictionary[String, Callable]
var _current_multi_loads: Array[MultiLoadEntry]

# const FREQUENCY := 0.05

# TODO: Is this really the way to do it?
# func load_async(path: String) -> Resource:
#     ResourceLoader.load_threaded_request(path)
# 
#     var _on_load_complete := Signal()
#     _current_loads[path] = _on_load_complete
#     await _on_load_complete
# 
#     return ResourceLoader.load_threaded_get(path)

# func load_multiple_async(paths: Array[String], callback: Callable) -> Callable: # -> Signal
func load_multiple_async(paths: Array[String], callback: Callable) -> void:
    for path in paths:
        ResourceLoader.load_threaded_request(path)

    var entry = MultiLoadEntry.new();
    entry.paths = paths
    entry.on_finished = callback
    _current_multi_loads.append(entry)

func _process(_delta: float):
    # if !_current_loads.is_empty():
    #     for i in range(_current_loads.size() - 1, -1, -1):
    #         ResourceLoader.load_threaded_get_status()
    if !Input.is_action_just_pressed("ui_left"):
        return

    var _keys := _current_loads.keys()
    for i in range(_keys.size() - 1, -1, -1):
        var path = _keys[i]
        var _status = ResourceLoader.load_threaded_get_status(path)
        match _status:
            ResourceLoader.THREAD_LOAD_IN_PROGRESS:
                pass
            # ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
            #     pass
            # ResourceLoader.THREAD_LOAD_FAILED:
            #     pass
            # ResourceLoader.THREAD_LOAD_LOADED:
            #     pass
            _:
                var on_load_complete := _current_loads[path]
                # on_load_complete.emit()
                _keys.remove_at(i)

    for i in range(_current_multi_loads.size() - 1, -1, -1):
        var _all_finished = true
        for path in _current_multi_loads[i].paths:
            var _status = ResourceLoader.load_threaded_get_status(path)
            match _status:
                ResourceLoader.THREAD_LOAD_IN_PROGRESS:
                    _all_finished = false
                    break

        if _all_finished:
            # _current_multi_loads[i].on_finished.emit()
            _current_multi_loads[i].on_finished.call() 
            _current_multi_loads.remove_at(i)


# func _init():
    # _load_check_timer.ignore_time_scale
    # _load_check_timer.one_shot = false

