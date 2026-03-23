extends Node

const GRID_SIZE := 10.0
const ENCOUNTER_STEPS_MIN := 20
const ENCOUNTER_STEPS_MAX := 30

# If these bits are set, then movement can happen between this square and the neighboring square in that direction
const MOVEMENT_FLAG_UP := 1
const MOVEMENT_FLAG_DOWN := 2
const MOVEMENT_FLAG_LEFT := 4
const MOVEMENT_FLAG_RIGHT := 8

var interactable_data: Dictionary[Vector2i, DungeonInteractable]
var _movement_data: Array#[int]
var _grid_width: int

var _encounter_data_weighted: Dictionary[StringName, float]
var _treasure_data_weighted: Dictionary[StringName, float]
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
signal on_player_interactable_updated(interactable: DungeonInteractable)
signal on_dungeon_crawling_start(player_position: Vector3, player_rotation: float)
signal on_dungeon_crawling_finished()
signal on_dungeon_floor_start(current_floor_number: int, num_floors: int)

func get_grid_width() -> int:
	return _grid_width;

# Player Movement
static var player_input_block_uid: int = 0
func block_player_input_for_duration(duration: float) -> void:
	var timer := get_tree().create_timer(duration)
	set_player_input_blocked_reason(player_input_block_uid, true)
	timer.timeout.connect(set_player_input_blocked_reason.bind(player_input_block_uid, false))
	player_input_block_uid += 1
	
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
	
func _get_random_treasure() -> StringName:
	var treasure_id := (Utils.pick_random_weighted(_treasure_data_weighted) as StringName)
	PlayerPartyManager.inventory.add_item(treasure_id)
	return treasure_id

func _on_player_move_finished(target_position: Vector3) -> void:
	_steps_until_next_encounter -= 1
	if !Input.is_key_pressed(KEY_1) and (_steps_until_next_encounter <= 0 or Input.is_key_pressed(KEY_9)):
		_trigger_random_encounter()

	on_player_move_finished.emit(target_position)

# Setup
func _setup_encounter_data(encounter_id: StringName) -> void:
	const config_path: String = "res://res/data/battle_encounters.json"
	var json_file := FileAccess.open(config_path, FileAccess.READ)
	var data = JSON.parse_string(json_file.get_as_text())

	var encounter_data := (data.dungeon_encounter_data[encounter_id] as Array)
	for entry in encounter_data:
		_encounter_data_weighted[entry.encounter_group] = entry.weight

func _setup_treasure_data(treasure_table_id: String) -> void:
	const config_path: String = "res://res/data/dungeon_treasure.json"
	var json_file := FileAccess.open(config_path, FileAccess.READ)
	var data = JSON.parse_string(json_file.get_as_text())

	var treasure_data := (data.treasure_tables[treasure_table_id] as Array)
	for entry in treasure_data:
		_treasure_data_weighted[entry.item] = entry.weight
	
func get_closest_interactable_mesh(collection: Array, grid_x: int, grid_y: int) -> Node3D:
	var local_collection := collection.duplicate()
	var cell_position := Vector3(grid_x * GRID_SIZE, 0, grid_y * GRID_SIZE)
	local_collection.sort_custom(func(a, b): return a.position.distance_to(cell_position) < b.position.distance_to(cell_position))
	return local_collection.front()
	
func _setup_interactable_data(in_interactable_data):#: Dictionary[Vector2i, Dictionary]) -> void:
	interactable_data.clear()
	
	# var thing: Array[Node] = _current_scene.get_children(true).filter(func(child): return child is DungeonTreasure)
	# jank
	var treasures = _current_scene.find_child(&"GeometryParent").get_child(0).find_child(&"Geometry").find_child(&"Treasure").get_children()
	var downstairs_doors = _current_scene.find_child(&"GeometryParent").get_child(0).find_child(&"Geometry").find_child(&"Doors").get_children()
	
	var interactable_positions = in_interactable_data.keys().duplicate()
	interactable_positions.shuffle()
	
	var num_downstairs_doors := 0
	var num_treasures := 0
	var max_downstairs_doors := 1
	var max_treasures := randi_range(1, 3)
	
	for position in interactable_positions:
		var direction_interactables = in_interactable_data[position]
		assert(direction_interactables.size() == 1, "there must be only one interactable per cell")
		var direction = direction_interactables.keys()[0]
		var interactable_id = direction_interactables.values()[0][0]
		
		var cell_position := Vector3(position.x * GRID_SIZE, 0, position.y * GRID_SIZE)
		var comp := func(a, b): return a.position.distance_to(cell_position) < b.position.distance_to(cell_position)
		
		match interactable_id:
			&"downstairs":
				if num_downstairs_doors < max_downstairs_doors:
					interactable_data[position] = DungeonInteractable.new(direction, goto_next_floor, "[E] Go Downstairs")
				else:
					var closest_downstairs_door := get_closest_interactable_mesh(downstairs_doors, position.x, position.y)
					closest_downstairs_door.visible = false
				num_downstairs_doors += 1
			&"treasure":
				treasures.sort_custom(comp)
				var closest_treasure := get_closest_interactable_mesh(treasures, position.x, position.y)
				if num_treasures < max_treasures:
					interactable_data[position] = DungeonInteractable.new(direction, get_treasure.bind(closest_treasure), "[E] Open Chest")
				else:
					closest_treasure.visible = false
				num_treasures += 1

func set_dungeon_floor_index(in_index: int) -> void:
	if _current_scene:
		_current_scene.queue_free()
	
	_current_floor_index = in_index
	_current_scene = _floors[in_index].instantiate()
	# get_tree().change_scene_to_packed(_floors[in_index])
	# await Engine.get_main_loop().process_frame # Stinky. There doesn't seem to be signal for scene change in Godot 4.4
	
	var geometry := _current_scene.find_child(&"GeometryParent").get_child(0)
	print("meta list: ", geometry.get_meta_list())
	print("movement_data: ", geometry.get_meta(&"movement_data"))
	_movement_data = (geometry.get_meta(&"movement_data") as Array[int])
	_grid_width = geometry.get_meta(&"grid_width")
	
	get_tree().root.add_child(_current_scene)
	
	_setup_encounter_data(_current_dungeon_data.encounter_data_per_floor[in_index])
	_setup_treasure_data(_current_dungeon_data.treasure_data_per_floor[in_index])
	var interactable_data = geometry.get_meta(&"interactable_data")
	_setup_interactable_data(interactable_data)
	_reset_steps_counter()
	
	on_dungeon_floor_start.emit(_current_floor_index + 1, _floors.size())
	
func goto_next_floor() -> void:
	_current_floor_index += 1
	if _current_floor_index >= _floors.size():
		end_dungeon_crawling()
		TownManager.enter_town_scene()
		PlayerPartyManager.reset_player_party()
		BattleView.hide_ui()
	else:
		set_dungeon_floor_index(_current_floor_index)
		
func get_treasure(closest_treasure: DungeonTreasure) -> void:
	var treasure_id := _get_random_treasure()
	BattleManager.request_message("You got a %s!" % treasure_id, 1.1)
	DungeonManager.block_player_input_for_duration(1.1)
	closest_treasure.open()

func set_player(in_player: Player) -> void:
	_player = in_player
	_player.on_move.connect(on_player_move.emit)
	_player.on_move_started.connect(on_player_move_started.emit)
	_player.on_move_finished.connect(_on_player_move_finished)
	_player.on_rotation_started.connect(on_player_rotation_started.emit)
	_player.on_rotation_finished.connect(on_player_rotation_finished.emit)
	_player.on_interactable_updated.connect(on_player_interactable_updated.emit)
	on_dungeon_crawling_start.emit(_player.position, _player.global_rotation.y)
	
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
	
var _player_input_blocked_reasons: Dictionary[Variant, bool]
func get_player_input_blocked() -> bool:
	return _player_input_blocked_reasons.values().has(true)
	
func set_player_input_blocked_reason(reason: Variant, blocked: bool) -> void:
	_player_input_blocked_reasons[reason] = blocked
	
# func _ready():
# 	reset()

# func _process(delta: float) -> void:
# 	if Input.is_action_just_pressed(&"ui_right"):
# 		goto_next_floor()
