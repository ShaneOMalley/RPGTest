class_name DungeonData extends Resource

@export var dungeon_scenes: Array[PackedScene]
@export var num_floors: int
@export var encounter_data_per_floor: Dictionary[int, StringName]
@export var treasure_data_per_floor: Dictionary[int, StringName]
