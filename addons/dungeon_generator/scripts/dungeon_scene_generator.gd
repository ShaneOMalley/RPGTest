@tool
class_name DungeonSceneGenerator extends Node

const GRID_SIZE := 10.0
const WALL_HEIGHT := 10.0
const FLOOR_THICKNESS := 1.0
const WALL_THICKNESS := 1.0

const DOOR_WIDTH := GRID_SIZE * 0.5
const DOOR_HEIGHT := GRID_SIZE * 0.7
const DOOR_THICKNESS := GRID_SIZE * 0.1

enum Direction { UP, RIGHT, DOWN, LEFT }

# If these bits are set, then movement can happen between this square and the neighboring square
const MOVEMENT_FLAG_UP := 1
const MOVEMENT_FLAG_DOWN := 2
const MOVEMENT_FLAG_LEFT := 4
const MOVEMENT_FLAG_RIGHT := 8
# If these bits are set, then skip test for ability to move to neighboring square (because it was already tested by that neigbhor, and movement is associative)
const MOVEMENT_FLAG_UP_SKIPTEST := 16
const MOVEMENT_FLAG_DOWN_SKIPTEST := 32
const MOVEMENT_FLAG_LEFT_SKIPTEST := 64
const MOVEMENT_FLAG_RIGHT_SKIPTEST := 128

const GRID_TILE_FLOOR = 1
const GRID_TILE_EMPTY = 2

class WallData:
	class Wall:
		var start: Vector2i
		var end: Vector2i

		func _init(in_start: Vector2i, in_end: Vector2i):
			start = in_start
			end = in_end

		func _to_string() -> String:
			return "(%d, %d) -> (%d, %d)" % [start.x, start.y, end.x, end.y]

	# The horizontal and vertical walls, indexed by their x and y values, respectively
	var horizontal_walls: Dictionary[int, Array]
	var vertical_walls: Dictionary[int, Array]

	func crosses_any_horizontal_wall(grid_x: int, grid_y: int, direction: int):
		var center_x := grid_x + 0.5

		var row = grid_y + (1 if direction > 0 else 0);
		return horizontal_walls.has(row) and horizontal_walls[row].any(func(wall): return sign(center_x - wall.start.x) != sign(center_x - wall.end.x))

	func crosses_any_vertical_wall(grid_x: int, grid_y: int, direction: int):
		var center_y := grid_y + 0.5

		var column = grid_x + (1 if direction > 0 else 0)
		return vertical_walls.has(column) and vertical_walls[column].any(func(wall): return sign(center_y - wall.start.y) != sign(center_y - wall.end.y))

static func create_box(position: Vector3, size: Vector3, name: String = "") -> MeshInstance3D:
	var mesh_instance := MeshInstance3D.new()
	var mesh := BoxMesh.new()

	mesh_instance.name = name
	mesh_instance.mesh = mesh
	mesh_instance.position = position
	mesh.size = size

	return mesh_instance

static var wall_counter = 0
static func create_wall(grid_start: Vector2i, grid_end: Vector2i) -> MeshInstance3D:
	var width = WALL_THICKNESS + abs(grid_end.x - grid_start.x) * GRID_SIZE
	var length = WALL_THICKNESS + abs(grid_end.y - grid_start.y) * GRID_SIZE
	var x = ((grid_start.x + grid_end.x) / 2.0) * GRID_SIZE
	var y = ((grid_start.y + grid_end.y) / 2.0) * GRID_SIZE
	var name = "Wall%d" % wall_counter
	wall_counter += 1
	return create_box(Vector3(x, WALL_HEIGHT / 2, y), Vector3(width, WALL_HEIGHT, length), name)
	
static func create_door(grid_x: int, grid_y: int, direction: Direction) -> MeshInstance3D:
	var center: Vector3
	var rotation: float
	const size := Vector3(DOOR_WIDTH, DOOR_HEIGHT, DOOR_THICKNESS)
	
	center.y = FLOOR_THICKNESS + DOOR_HEIGHT / 2
	const door_offset_from_wall = (WALL_THICKNESS / 2 + DOOR_THICKNESS / 2)
	
	match direction:
		Direction.LEFT:
			center.x = grid_x * GRID_SIZE + door_offset_from_wall
			center.z = (grid_y + 0.5) * GRID_SIZE
			rotation = - PI / 2
		Direction.RIGHT:
			center.x = (grid_x + 1) * GRID_SIZE - door_offset_from_wall
			center.z = (grid_y + 0.5) * GRID_SIZE
			rotation = PI / 2
		Direction.UP:
			center.x = (grid_x + 0.5) * GRID_SIZE
			center.z = grid_y * GRID_SIZE + door_offset_from_wall
			rotation = 0
		Direction.DOWN:
			center.x = (grid_x + 0.5) * GRID_SIZE
			center.z = (grid_y + 1) * GRID_SIZE - door_offset_from_wall
			rotation = PI 
			
	var door := create_box(center, size)
	var material := StandardMaterial3D.new()
	material.albedo_color = Color.GOLD
	door.material_override = material
	door.rotate_object_local(Vector3.UP, rotation)
			
	return door

static func generate_dungeon(data: Variant) -> void:
	var scene = PackedScene.new()

	var root_node := Node3D.new()
	var geometry_node := Node3D.new()
	geometry_node.name = "Geometry"
	var floors_node := Node3D.new()
	floors_node.name = "Floors"
	var walls_node := Node3D.new()
	walls_node.name = "Walls"
	var doors_node := Node3D.new()
	doors_node.name = "Doors"

	root_node.add_child(geometry_node)
	geometry_node.add_child(floors_node)
	geometry_node.add_child(walls_node)
	geometry_node.add_child(doors_node)

	geometry_node.owner = root_node
	floors_node.owner = root_node
	walls_node.owner = root_node
	doors_node.owner = root_node

	# Floor
	var floor_width = data.width * GRID_SIZE
	var floor_length = data.height * GRID_SIZE
	var floor_box := create_box(Vector3(floor_width / 2, 0, floor_length / 2), Vector3(floor_width, FLOOR_THICKNESS, floor_length), "Floor")

	floors_node.add_child(floor_box)
	floor_box.owner = root_node

	# Organize Walls
	var object_group_data
	for layer in data.layers:
		if layer.type == "objectgroup":
			object_group_data = layer
			break
	
	var interactable_data: Dictionary[Vector2i, Dictionary] # Dictionary[Vector2i, Dictionary[Direction, Array[StringName]]]
	
	var wall_data := WallData.new()
	if object_group_data:
		for object in object_group_data.objects:
			# var walls = object.polygon if object.has("polygon") else null
			# if !walls:
			# 	walls = object.polyline if object.has("polyline") else null
			
			var walls
			if object.has("polygon"):
				walls = object.polygon
			if object.has("polyline"):
				walls = object.polyline
			
			if walls:
				var last_index = walls.size() if object.has("polygon") else walls.size() - 1
				for i in range(last_index):
					var next_index = (i + 1) % walls.size()
					var offset := Vector2i(object.x, object.y)
					var start := offset + Vector2i(walls[i].x, walls[i].y)
					var end := offset + Vector2i(walls[next_index].x, walls[next_index].y)
					var wall := WallData.Wall.new(start, end)

					if start.x == end.x:
						wall_data.vertical_walls.get_or_add(start.x, []).append(wall)
					elif start.y == end.y:
						wall_data.horizontal_walls.get_or_add(start.y, []).append(wall)
					else:
						push_error("There is a wall that is neither horizontal nor vertical")

					var wall_box := create_wall(start, end)
					walls_node.add_child(wall_box)
					wall_box.owner = root_node
					
			if object.name == "downstairs":
				var grid_x := floor(object.x)
				var grid_y := floor(object.y)
				var relative_x = fmod(object.x, 1)
				var relative_y = fmod(object.y, 1)
				
				var a = relative_y - relative_x
				var b = relative_y + relative_x - 1
				
				var direction: Direction
				if a > 0:
					if b > 0:
						direction = Direction.DOWN
					else:
						direction = Direction.LEFT
				else:
					if b > 0:
						direction = Direction.RIGHT
					else:
						direction = Direction.UP
						
				var door_box := create_door(grid_x, grid_y, direction)
				doors_node.add_child(door_box)
				door_box.owner = root_node
				
				var cell_interactable_data = interactable_data.get_or_add(Vector2i(grid_x, grid_y), {})
				cell_interactable_data.get_or_add(direction, []).append(&"downstairs")

	# Build Movement Data
	var tile_layer_index = data.layers.find_custom(func(layer): return layer.type == "tilelayer")
	var tile_layer = data.layers[tile_layer_index]
	
	var tile_data: Array = tile_layer.data
	var grid_width: int = tile_layer.width
	var num_tiles = tile_data.size()

	var movement_data: Array[int]
	movement_data.resize(num_tiles)
	movement_data.fill(0)

	for tile_index in range(num_tiles):
		var tile = tile_data[tile_index]
		if tile == GRID_TILE_FLOOR:
			var grid_x := tile_index % grid_width
			var grid_y := tile_index / grid_width

			# up
			var up_index := tile_index - grid_width
			if up_index < num_tiles and !(movement_data[tile_index] & MOVEMENT_FLAG_UP_SKIPTEST) and tile_data[up_index] == GRID_TILE_FLOOR and !wall_data.crosses_any_horizontal_wall(grid_x, grid_y, -1):
				movement_data[tile_index] |= MOVEMENT_FLAG_UP
				movement_data[up_index] |= MOVEMENT_FLAG_DOWN
				movement_data[up_index] |= MOVEMENT_FLAG_DOWN_SKIPTEST

			# down
			var down_index := tile_index + grid_width
			if down_index < num_tiles and !(movement_data[tile_index] & MOVEMENT_FLAG_DOWN_SKIPTEST) and tile_data[down_index] == GRID_TILE_FLOOR and !wall_data.crosses_any_horizontal_wall(grid_x, grid_y, +1):
					movement_data[tile_index] |= MOVEMENT_FLAG_DOWN
					movement_data[down_index] |= MOVEMENT_FLAG_UP
					movement_data[down_index] |= MOVEMENT_FLAG_UP_SKIPTEST

			# left
			var left_index := tile_index - 1
			if left_index < num_tiles and !(movement_data[tile_index] & MOVEMENT_FLAG_LEFT_SKIPTEST) and tile_data[left_index] == GRID_TILE_FLOOR and !wall_data.crosses_any_vertical_wall(grid_x, grid_y, -1):
				movement_data[tile_index] |= MOVEMENT_FLAG_LEFT
				movement_data[left_index] |= MOVEMENT_FLAG_RIGHT
				movement_data[left_index] |= MOVEMENT_FLAG_RIGHT_SKIPTEST

			# right
			var right_index := tile_index + 1
			if right_index < num_tiles and !(movement_data[tile_index] & MOVEMENT_FLAG_RIGHT_SKIPTEST) and tile_data[right_index] == GRID_TILE_FLOOR and !wall_data.crosses_any_vertical_wall(grid_x, grid_y, +1):
				movement_data[tile_index] |= MOVEMENT_FLAG_RIGHT
				movement_data[right_index] |= MOVEMENT_FLAG_LEFT
				movement_data[right_index] |= MOVEMENT_FLAG_LEFT_SKIPTEST

	root_node.set_meta(&"movement_data", movement_data)
	root_node.set_meta(&"grid_width", grid_width)
	root_node.set_meta(&"interactable_data", interactable_data)

	var debug_node := Node3D.new()
	debug_node.name = "Debug"
	root_node.add_child(debug_node)
	debug_node.owner = root_node

	# Drop Debug Cubes
	for tile_index in movement_data.size():
		var tile = movement_data[tile_index]
		var x := tile_index % grid_width
		var y := tile_index / grid_width

		if tile & MOVEMENT_FLAG_UP:
			var debug_box = create_box(Vector3((x + 0.5) * GRID_SIZE, FLOOR_THICKNESS, (y + 0.2) * GRID_SIZE), Vector3(0.5, 0.5, 3))
			debug_node.add_child(debug_box)
			debug_box.owner = root_node
		if tile & MOVEMENT_FLAG_DOWN:
			var debug_box = create_box(Vector3((x + 0.5) * GRID_SIZE, FLOOR_THICKNESS, (y + 0.8) * GRID_SIZE), Vector3(0.5, 0.5, 3))
			debug_node.add_child(debug_box)
			debug_box.owner = root_node
		if tile & MOVEMENT_FLAG_LEFT:
			var debug_box = create_box(Vector3((x + 0.2) * GRID_SIZE, FLOOR_THICKNESS, (y + 0.5) * GRID_SIZE), Vector3(3, 0.5, 0.5))
			debug_node.add_child(debug_box)
			debug_box.owner = root_node
		if tile & MOVEMENT_FLAG_RIGHT:
			var debug_box = create_box(Vector3((x + 0.8) * GRID_SIZE, FLOOR_THICKNESS, (y + 0.5) * GRID_SIZE), Vector3(3, 0.5, 0.5))
			debug_node.add_child(debug_box)
			debug_box.owner = root_node

	var result = scene.pack(root_node)
	if result == OK:
		var filename = Time.get_datetime_string_from_system().replace(":", "_")
		var error = ResourceSaver.save(scene, "res://scenes/dungeon_geometry/%s.tscn" % filename)
		if error != OK:
			push_error("An error occured while saving the scene to disk")
