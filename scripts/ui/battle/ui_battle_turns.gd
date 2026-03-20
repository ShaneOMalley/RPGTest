class_name UIBattleTurns extends Control

const NUM_VISIBLE_TURNS: int = 6

signal on_turn_hovered(turn_uid: int)
signal on_turn_unhovered(turn_uid: int)
signal on_turn_pressed(turn_uid: int)

var _ui_turn_entries: Array[UIBattleTurn]
var _uid_to_ui_turn: Dictionary[int, UIBattleTurn]

func add_turn(turn_uid: int, character_graphics: PackedScene, affiliation: BattleManager.Affiliation) -> void:
	# var entry := $TurnsContainer/TurnPrototype.duplicate() as UIBattleTurn
	var container := $Mask/TurnsContainer as Container
	var entry := (container.find_child("TurnPrototype").duplicate() as UIBattleTurn)
	container.find_child("TurnPrototype").add_sibling(entry)
	entry.visible = true
	
	var color: Color
	if (affiliation == BattleManager.Affiliation.PLAYER):
		color = Color.GREEN
	elif (affiliation == BattleManager.Affiliation.ENEMY):
		color = Color.RED
	else:
		assert(false, "Affiliation color not supported for %s" % affiliation)
	
	entry.set_background_color(color)
	entry.set_character_graphics(character_graphics)
	
	_uid_to_ui_turn[turn_uid] = entry
	_ui_turn_entries.append(entry)
	
	entry.mouse_entered.connect(func(): on_turn_hovered.emit(turn_uid))
	entry.mouse_exited.connect(func(): on_turn_unhovered.emit(turn_uid))
	entry.pressed.connect(func(): on_turn_pressed.emit(turn_uid))
	
func sort_turns(sorted_turn_uids: Array) -> void:
	var container := $Mask/TurnsContainer as Container
	
	var max_index := -1
	var entries: Dictionary[int, UIBattleTurn]
	
	for turn_uid in _uid_to_ui_turn:
		if !_uid_to_ui_turn.has(turn_uid):
			continue
			
		var entry := _uid_to_ui_turn[turn_uid]
		if !is_instance_valid(entry):
			continue
			
		var index := sorted_turn_uids.find(turn_uid)
		if index == -1:
			continue
			
		max_index = max(index, max_index)
		entries[index] = entry
		
	for i in range(max_index):
		var entry := entries[i]
		if !is_instance_valid(entry):
			continue
			
		container.move_child(entry, i)
		
	container.queue_sort()
		
func set_turn_text_and_time(turn_uid: int, text: String, modifier_text: String, time: float) -> void:
	var entry := _uid_to_ui_turn[turn_uid]
	if !is_instance_valid(entry):
		return
		
	entry.set_modifier_text(modifier_text)
	entry.set_turn_text(text)
	entry.set_time(time)

func delete_turn(turn_uid: int) -> void:
	#if !_ui_turn_entries.has(turn_uid):
	#	return
	
	# var turn_ui = _ui_turn_entries_uid_to_ui_turn[turn_uid]]
	var turn_ui = _uid_to_ui_turn[turn_uid]
	
	#if (is_instance_valid(turn_ui)):
	#turn_ui.hide()
	turn_ui.queue_free()
	
	_ui_turn_entries.erase(_uid_to_ui_turn[turn_uid])
	_uid_to_ui_turn.erase(turn_uid)
	
func play_animation_for_turn(turn_uid: int, anim_name: StringName) -> void:
	var turn_ui := _uid_to_ui_turn[turn_uid]
	turn_ui.play_animation(anim_name)
	
func get_top_turn_button() -> Button:
	return _ui_turn_entries.front()
	
func reset_animation_for_turn() -> void:
	pass
	
func _ready():
	$Mask/TurnsContainer/TurnPrototype.visible = false
