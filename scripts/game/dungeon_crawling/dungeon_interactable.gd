class_name DungeonInteractable extends Node

var message: String
var direction: Player.Direction
var _on_execute: Callable

func execute() -> void:
	if _on_execute.is_valid():
		_on_execute.call()
	
func _init(in_direction: Player.Direction, in_on_execute: Callable, in_message: String) -> void:
	_on_execute = in_on_execute
	direction = in_direction
	message = in_message
