extends Node

const GRID_SIZE := 10.0
const ENCOUNTER_STEPS_MIN := 20
const ENCOUNTER_STEPS_MAX := 30

# If these bits are set, then movement can happen between this square and the neighboring square
const MOVEMENT_FLAG_UP := 1
const MOVEMENT_FLAG_DOWN := 2
const MOVEMENT_FLAG_LEFT := 4
const MOVEMENT_FLAG_RIGHT := 8

var _movement_data: Array[int]
var _grid_width: int
var _encounter_data_weighted: Dictionary[StringName, float]
var _dungeon_scene: Node3D
var _player: Player
var _steps_until_next_encounter: int

signal on_player_move(target_position: Vector3)
signal on_player_move_started(target_position: Vector3)
signal on_player_move_finished(target_position: Vector3)
signal on_player_rotation_started(target_rotation: float)
signal on_player_rotation_finished(target_rotation: float)
signal on_dungeon_crawling_start(player_position: Vector3)

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
func setup_encounter_data() -> void:
	var json_file := FileAccess.open(config_path, FileAccess.READ)
	var data = JSON.parse_string(json_file.get_as_text())

	# TODO: Decide on non-hardcoded way of doing this
	const dungeon_id := &"test_dungeon" # &"test_single_ghoul"

	var encounter_data := (data.dungeon_encounter_data[dungeon_id] as Array)
	for entry in encounter_data:
		_encounter_data_weighted[entry.encounter_group] = entry.weight

func set_dungeon_scene(in_dungeon_scene: Node3D) -> void:
	_dungeon_scene = in_dungeon_scene
	_movement_data = _dungeon_scene.find_child("DungeonGeometry").get_meta("movement_data")
	_grid_width = _dungeon_scene.find_child("DungeonGeometry").get_meta("grid_width")
	_reset_steps_counter()
	setup_encounter_data()

	# TODO: Find some better way of handling dependencies
	#  if _player:
	#  	on_dungeon_crawling_start.emit(_player.position)

func set_player(in_player: Player) -> void:
	_player = in_player
	_player.on_move.connect(on_player_move.emit)
	_player.on_move_started.connect(on_player_move_started.emit)
	_player.on_move_finished.connect(_on_player_move_finished)
	_player.on_rotation_started.connect(on_player_rotation_started.emit)
	_player.on_rotation_finished.connect(on_player_rotation_finished.emit)

	# TODO: Find some better way of handling dependencies
	var timer := BattleManager.get_tree().create_timer(0.2)
	timer.timeout.connect(func(): 
		BattleManager.request_player_party_ui_setup()
		on_dungeon_crawling_start.emit(_player.position)
		)

	# on_dungeon_crawling_start.emit.call_deferred(_player.position)
	# BattleManager.request_player_party_ui_setup.call_deferred()

	# TODO: Find some better way of handling dependencies
	# if _dungeon_scene:
	# 	on_dungeon_crawling_start.emit(_player.position)
