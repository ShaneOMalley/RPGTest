extends Node

class RecruitEntry:
	var config_id: StringName
	var name_key: StringName
	var price: int
	var is_recruited: bool
	
class ChallengeModeEntry:
	var config_id: StringName
	var challenge_number: int
	var enemies: Array[Dictionary]
	var players: Array[Dictionary]
	var starting_time: float

var current_town_scene: Node
var current_recruit_data: Dictionary[StringName, RecruitEntry]
var challenge_mode_data: Dictionary[StringName, ChallengeModeEntry]

func build_recruit_data() -> void:
	const config_path: String = "res://res/data/recruitment.json"
	var json_file := FileAccess.open(config_path, FileAccess.READ)
	var data = JSON.parse_string(json_file.get_as_text())
	
	var recruitment_group = data.recruitment_groups.test1
	for participant_info in recruitment_group:
		var recruit_entry = RecruitEntry.new()
		recruit_entry.config_id = participant_info.config_id
		recruit_entry.name_key = participant_info.name_key
		recruit_entry.price = 50
		recruit_entry.is_recruited = false
		
		current_recruit_data[recruit_entry.config_id] = recruit_entry
		
func build_challenge_mode_data() -> void:
	const config_path: String = "res://res/data/challenge_mode.json"
	var json_file := FileAccess.open(config_path, FileAccess.READ)
	var data = JSON.parse_string(json_file.get_as_text())
	
	for level_data in data.levels:
		var entry := ChallengeModeEntry.new()
		entry.config_id = level_data.id
		entry.challenge_number = level_data.challenge_number
		for enemy_data in level_data.enemies:
			entry.enemies.append({ &"id": enemy_data.get(&"id"), &"hp": enemy_data.get(&"hp"), &"sp": enemy_data.get(&"sp") })
		for player_data in level_data.players:
			entry.players.append({ &"id": player_data.get(&"id"), &"hp": player_data.get(&"hp"), &"sp": player_data.get(&"sp") })
		entry.starting_time = level_data.start_time
		challenge_mode_data[entry.config_id] = entry

func enter_town_scene() -> void:
	current_town_scene = preload("res://scenes/town/town.tscn").instantiate()
	get_tree().root.add_child(current_town_scene)
	build_recruit_data()
	build_challenge_mode_data()
	show_town_ui(preload("res://ui/town/town_ui.tscn"))
	
func remove_town_scene() -> void:
	if current_town_scene:
		current_town_scene.queue_free()
		
func show_town_ui(ui_scene: PackedScene) -> void:
	var ui_parent = current_town_scene.find_child(&"UI")
	for child in ui_parent.get_children():
		ui_parent.remove_child(child)
	ui_parent.add_child(ui_scene.instantiate())

func reset() -> void:
	current_recruit_data.clear()
		
func _ready() -> void:
	enter_town_scene.call_deferred()

# func _process(delta: float) -> void:
	# if Input.is_action_just_pressed(&"ui_right"):
	# 	enter_town_scene()
