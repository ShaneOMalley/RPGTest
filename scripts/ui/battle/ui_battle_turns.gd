class_name UIBattleTurns extends Control

const NUM_VISIBLE_TURNS: int = 6

var _ui_turn_entries: Array[UIBattleTurn]
var _uid_to_ui_turn: Dictionary[int, UIBattleTurn]

func add_turn(turn_uid: int, affiliation: BattleManager.Affiliation) -> void:
	# var entry := $TurnsContainer/TurnPrototype.duplicate() as UIBattleTurn
	var container := $Mask/TurnsContainer as Container
	var entry := (container.find_child("TurnPrototype").duplicate() as UIBattleTurn)
	container.find_child("TurnPrototype").add_sibling(entry)
	entry.visible = true
	
	var color: Color
	if (affiliation == BattleManager.Affiliation.PLAYER):
		color = Color.DARK_OLIVE_GREEN
	elif (affiliation == BattleManager.Affiliation.ENEMY):
		color = Color.CRIMSON
	else:
		assert(false, "Affiliation color not supported for %s" % affiliation)
		
	entry.set_background_color(color)
		
	_uid_to_ui_turn[turn_uid] = entry
	_ui_turn_entries.append(entry)
	
func sort_turns(sorted_turn_uids: Array) -> void:
	var container := $Mask/TurnsContainer as Container
	
	for turn_uid in _uid_to_ui_turn:
		if !_uid_to_ui_turn.has(turn_uid):
			continue
			
		var entry := _uid_to_ui_turn[turn_uid]
		if !is_instance_valid(entry):
			continue
			
		var index := sorted_turn_uids.find(turn_uid)
		if index == -1:
			continue
			
		container.move_child(entry, index)
		
func set_turn_text_and_time(turn_uid: int, text: String, time: float) -> void:
	var entry := _uid_to_ui_turn[turn_uid]
	if !is_instance_valid(entry):
		return
		
	entry.set_text(text)
	entry.set_time(time)

func delete_turn(turn_uid: int) -> void:
	#if !_ui_turn_entries.has(turn_uid):
	#	return
	
	# var turn_ui = _ui_turn_entries_uid_to_ui_turn[turn_uid]]
	var turn_ui = _uid_to_ui_turn[turn_uid]
	
	#if (is_instance_valid(turn_ui)):
	#turn_ui.hide()
	turn_ui.queue_free()
	
	_ui_turn_entries.erase(turn_uid)
	_uid_to_ui_turn.erase(turn_uid)
	
func play_animation_for_turn(turn_uid: int, anim_name: StringName) -> void:
	var turn_ui := _uid_to_ui_turn[turn_uid]
	turn_ui.play_animation(anim_name)
	
func reset_animation_for_turn() -> void:
	pass
	
func _ready():
	$Mask/TurnsContainer/TurnPrototype.visible = false
