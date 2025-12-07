extends Node

class RecruitEntry:
	var config_id: StringName
	var price: int
	var is_recruited: bool

var current_town_scene: Node
var current_recruit_data: Dictionary[StringName, RecruitEntry]

const config_path: String = "res://res/data/recruitment.json"
func build_recruit_data() -> void:
	var json_file := FileAccess.open(config_path, FileAccess.READ)
	var data = JSON.parse_string(json_file.get_as_text())
	
	var recruitment_group = data.recruitment_groups.test1
	for participant_config_id in recruitment_group:
		var recruit_entry = RecruitEntry.new()
		recruit_entry.config_id = participant_config_id
		recruit_entry.price = 50
		recruit_entry.is_recruited = false
		
		current_recruit_data[recruit_entry.config_id] = recruit_entry

func enter_town_scene() -> void:
	current_town_scene = preload("res://scenes/town/town.tscn").instantiate()
	get_tree().root.add_child(current_town_scene)
	build_recruit_data()
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
		
# func _ready() -> void:
# 	enter_town_scene()

func _process(delta: float) -> void:
	if Input.is_action_just_pressed(&"ui_right"):
		enter_town_scene()
