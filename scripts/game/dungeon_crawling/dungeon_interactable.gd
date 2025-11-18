class_name DungeonInteractable extends Node

var message: String
var _on_execute: Callable

func execute() -> void:
	_on_execute.call()
	
func _init(in_on_execute: Callable, in_message: String) -> void:
	_on_execute = in_on_execute
	message = in_message
