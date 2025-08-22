class_name Utils extends Node

static func is_subclass_of(script: GDScript, base_script: GDScript) -> bool:
	var current = script
	while current:
		if current == base_script:
			return true
		current = current.get_base_script()
	return false

static func pick_random_weighted(data: Dictionary) -> Variant:
	if data.is_empty():
		return null

	var total_weight = data.values().reduce(func(accum, weight): return accum + weight)
	var selection = randf() * total_weight

	var keys = data.keys()
	for key in keys:
		var weight = data[key]
		selection -= weight
		if selection <= 0:
			return key

	return keys.back()
