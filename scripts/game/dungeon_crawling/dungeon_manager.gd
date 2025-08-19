extends Node

const GRID_SIZE := 10.0

# If these bits are set, then movement can happen between this square and the neighboring square
const MOVEMENT_FLAG_UP := 1
const MOVEMENT_FLAG_DOWN := 2
const MOVEMENT_FLAG_LEFT := 4
const MOVEMENT_FLAG_RIGHT := 8

var _movement_data: Array[int]
var _grid_width: int
var _dungeon_scene: Node3D

func set_dungeon_scene(in_dungeon_scene: Node3D) -> void:
	_dungeon_scene = in_dungeon_scene
	_movement_data = _dungeon_scene.find_child("DungeonGeometry").get_meta("movement_data")
	_grid_width = _dungeon_scene.find_child("DungeonGeometry").get_meta("grid_width")

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
