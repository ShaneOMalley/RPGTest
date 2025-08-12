class_name Utils extends Node

static func is_subclass_of(script: GDScript, base_script: GDScript) -> bool:
	var current = script
	while current:
		if current == base_script:
			return true
		current = current.get_base_script()
	return false