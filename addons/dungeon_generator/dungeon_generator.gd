@tool
extends EditorPlugin

var control: Control

func _enter_tree() -> void:
	# Initialization of the plugin goes here.
	control = preload("res://addons/dungeon_generator/ui/import_dungeon.tscn").instantiate() # as Control
	add_control_to_container(CONTAINER_TOOLBAR, control)
	pass


func _exit_tree() -> void:
	remove_control_from_container(CONTAINER_TOOLBAR, control)
	control.free()
	# Clean-up of the plugin goes here.
	pass
