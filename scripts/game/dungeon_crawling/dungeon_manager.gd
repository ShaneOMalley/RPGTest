extends Node

const GRID_SIZE := 10.0
const ENCOUNTER_STEPS_MIN := 20
const ENCOUNTER_STEPS_MAX := 30

# If these bits are set, then movement can happen between this square and the neighboring square in that direction
const MOVEMENT_FLAG_UP := 1
const MOVEMENT_FLAG_DOWN := 2
const MOVEMENT_FLAG_LEFT := 4
const MOVEMENT_FLAG_RIGHT := 8

var interactable_data: Dictionary[Vector2i, Dictionary]
var _movement_data: Array[int]
var _grid_width: int

var _encounter_data_weighted: Dictionary[StringName, float]
var _player: Player
var _steps_until_next_encounter: int

var _current_dungeon_data: DungeonData
var _floors: Array[PackedScene]
var _current_scene: Node3D
var _current_floor_index: int

signal on_player_move(target_position: Vector3)
signal on_player_move_started(target_position: Vector3)
signal on_player_move_finished(target_position: Vector3)
signal on_player_rotation_started(target_rotation: float)
signal on_player_rotation_finished(target_rotation: float)
signal on_player_interactables_updated(interactables: Array)
signal on_dungeon_crawling_start(player_position: Vector3)
signal on_dungeon_crawling_finished()
signal on_dungeon_floor_start(current_floor_number: int, num_floors: int)

func get_grid_width() -> int:
	return _grid_width;

# Player Movement
func get_movement_data_for_cell(x: int, y: int) -> int:
	return _movement_data[x + y * _grid_width]

func can_move_up(x: int, y: int) -> bool:
	return get_movement_data_for_cell(x, y) & MOVEMENT_FLAG_UP

func can_move_down(x: int, y: int) -> bool:
	return get_movement_data_for_cell(x, y) & MOVEMENT_FLAG_DOWN

func can_move_left(x: int, y: int) -> bool:
	return get_movement_data_for_cell(x, y) & MOVEMENT_FLAG_LEFT

func can_move_right(x: int, y: int) -> bool:
	return get_movement_data_for_cell(x, y) & MOVEMENT_FLAG_RIGHT

# Random Encounters
func _reset_steps_counter() -> void:
	_steps_until_next_encounter = randi_range(ENCOUNTER_STEPS_MIN, ENCOUNTER_STEPS_MAX)

func _trigger_random_encounter() -> void:
	var encounter_id := (Utils.pick_random_weighted(_encounter_data_weighted) as StringName)
	BattleManager.setup_battle(encounter_id)
	_reset_steps_counter()

func _on_player_move_finished(target_position: Vector3) -> void:
	_steps_until_next_encounter -= 1
	if _steps_until_next_encounter <= 0 or Input.is_key_pressed(KEY_9):
		_trigger_random_encounter()

	on_player_move_finished.emit(target_position)

# Setup
const config_path: String = "res://res/data/battle_encounters.json"
func _setup_encounter_data(encounter_id: StringName) -> void:
	var json_file := FileAccess.open(config_path, FileAccess.READ)
	var data = JSON.parse_string(json_file.get_as_text())

	# TODO: Decide on non-hardcoded way of doing this
	var encounter_data := (data.dungeon_encounter_data[encounter_id] as Array)
	for entry in encounter_data:
		_encounter_data_weighted[entry.encounter_group] = entry.weight
		
func _setup_interactable_data(in_interactable_data: Dictionary[Vector2i, Dictionary]) -> void:
	interactable_data.clear()
	
	for position in in_interactable_data:
		interactable_data[position] = {}
		for direction in in_interactable_data[position]:
			interactable_data[position][direction] = []
			for interactable_id in in_interactable_data[position][direction]:
				match interactable_id:
					&"downstairs":
						interactable_data[position][direction].append(DungeonInteractable.new(goto_next_floor, "[E] Go Downstairs"))

func set_dungeon_floor_index(in_index: int) -> void:
	if _current_scene:
		_current_scene.queue_free()
	
	_current_floor_index = in_index
	_current_scene = _floors[in_index].instantiate()
	# get_tree().change_scene_to_packed(_floors[in_index])
	# await Engine.get_main_loop().process_frame # Stinky. There doesn't seem to be signal for scene change in Godot 4.4
	
	var geometry := _current_scene.find_child(&"GeometryParent").get_child(0)
	_movement_data = geometry.get_meta(&"movement_data")
	_grid_width = geometry.get_meta(&"grid_width")
	
	get_tree().root.add_child(_current_scene)
	
	_setup_encounter_data(_current_dungeon_data.encounter_data_per_floor[in_index])
	_setup_interactable_data(geometry.get_meta(&"interactable_data"))
	_reset_steps_counter()
	
	on_dungeon_floor_start.emit(_current_floor_index + 1, _floors.size())
	
func goto_next_floor() -> void:
	_current_floor_index += 1
	if _current_floor_index >= _floors.size():
		end_dungeon_crawling()
		TownManager.enter_town_scene()
	else:
		set_dungeon_floor_index(_current_floor_index)

func set_player(in_player: Player) -> void:
	_player = in_player
	_player.on_move.connect(on_player_move.emit)
	_player.on_move_started.connect(on_player_move_started.emit)
	_player.on_move_finished.connect(_on_player_move_finished)
	_player.on_rotation_started.connect(on_player_rotation_started.emit)
	_player.on_rotation_finished.connect(on_player_rotation_finished.emit)
	_player.on_interactables_updated.connect(on_player_interactables_updated.emit)
	
	BattleManager.request_player_party_ui_setup()
	on_dungeon_crawling_start.emit(_player.position)
	
const _dungeon_data_resource_path := "res://game/dungeon_crawling/dungeon_data_test.tres"
func reset() -> void:
	# todo: find non-blocking way of loading
	_current_dungeon_data = load(_dungeon_data_resource_path).duplicate() as DungeonData
	var possible_floors = _current_dungeon_data.dungeon_scenes.duplicate()
	possible_floors.shuffle()
	
	_floors.clear()
	var num_floors = _current_dungeon_data.num_floors
	while num_floors > 0:
		_floors.append(possible_floors.pop_front())
		num_floors -= 1
	
	_current_floor_index = -1

func end_dungeon_crawling() -> void:
	on_dungeon_crawling_finished.emit()

# func _ready():
# 	reset()

# func _process(delta: float) -> void:
# 	if Input.is_action_just_pressed(&"ui_right"):
# 		goto_next_floor()
