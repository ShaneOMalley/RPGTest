@tool
class_name DungeonSceneGenerator extends Node

const GRID_SIZE := 10
const WALL_HEIGHT := 10
const FLOOR_THICKNESS := 1
const WALL_THICKNESS := 1

static func create_box(position: Vector3, size: Vector3) -> MeshInstance3D:
    var mesh_instance := MeshInstance3D.new()
    var mesh := BoxMesh.new()
    mesh_instance.mesh = mesh

    mesh_instance.position = position
    mesh.size = size

    return mesh_instance

static func create_wall(grid_offset: Vector2, grid_start: Vector2, grid_end: Vector2) -> MeshInstance3D:
    # var grid_start_x = object.x + wall_data[i].x 
    # var grid_end_x = object.x + wall_data[i + 1].x 
    # var grid_start_y = object.y + wall_data[i].y 
    # var grid_end_y = object.y + wall_data[i + 1].y 
    var width = WALL_THICKNESS + abs(grid_end.x - grid_start.x) * GRID_SIZE
    var length = WALL_THICKNESS + abs(grid_end.y - grid_start.y) * GRID_SIZE
    var x = (grid_offset.x + (grid_start.x + grid_end.x) / 2) * GRID_SIZE
    var y = (grid_offset.y + (grid_start.y + grid_end.y) / 2) * GRID_SIZE
    return create_box(Vector3(x, WALL_HEIGHT / 2, y), Vector3(width, WALL_HEIGHT, length))

static func generate_dungeon(data: Variant) -> void:
    var scene = PackedScene.new()
    var root_node := Node3D.new()

    # Floor
    var level_width = data.width * GRID_SIZE
    var level_length = data.height * GRID_SIZE
    var floor_box := create_box(Vector3(level_width / 2, 0, level_length / 2), Vector3(level_width, FLOOR_THICKNESS, level_length))

    root_node.add_child(floor_box)
    floor_box.owner = root_node

    # Walls
    var object_group_data
    for layer in data.layers:
        if layer.type == "objectgroup":
            object_group_data = layer
            break

    if object_group_data:
        for object in object_group_data.objects:
            # var wall_data = object["polygon"]
            var wall_data = object.polygon if object.has("polygon") else null
            if !wall_data:
                wall_data = object.polyline if object.has("polyline") else null
            if wall_data:
                for i in range(wall_data.size() - 1):
                    # var grid_start_x = object.x + wall_data[i].x 
                    # var grid_end_x = object.x + wall_data[i + 1].x 
                    # var grid_start_y = object.y + wall_data[i].y 
                    # var grid_end_y = object.y + wall_data[i + 1].y 
                    # var width = (grid_end_x - grid_start_x) * GRID_SIZE
                    # var length = (grid_end_y - grid_start_y) * GRID_SIZE
                    # var x = ((grid_start_x + grid_end_x) / 2) * GRID_SIZE
                    # var y = ((grid_start_y + grid_end_y) / 2) * GRID_SIZE
                    var offset = Vector2(object.x, object.y)
                    var start = Vector2(wall_data[i].x, wall_data[i].y)
                    var end = Vector2(wall_data[i + 1].x, wall_data[i + 1].y)
                    var wall_box = create_wall(offset, start, end)
                    root_node.add_child(wall_box)
                    wall_box.owner = root_node

            if object.has("polygon"):
                var offset = Vector2(object.x, object.y)
                var start = Vector2(wall_data[0].x, wall_data[0].y)
                var end = Vector2(wall_data[-1].x, wall_data[-1].y)
                var wall_box = create_wall(offset, start, end)
                root_node.add_child(wall_box)
                wall_box.owner = root_node


    var result = scene.pack(root_node)
    if result == OK:
        var error = ResourceSaver.save(scene, "res://scenes/dungeons/dungeon.tscn")
        if error != OK:
            push_error("An error occured while saving the scene to disk")
