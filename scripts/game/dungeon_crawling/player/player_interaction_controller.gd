class_name PlayerInteractionController extends Node

signal on_execute_interaction(interactable: DungeonInteractable)
signal on_interactables_updated(interactables: Array)

var _valid_interactables: Array

func prepare_interactables(grid_x: int, grid_y: int, direction: Player.Direction) -> void:
	# var grid_x := floori(target_position.x / DungeonManager.GRID_SIZE)
	# var grid_y := floori(target_position.z / DungeonManager.GRID_SIZE)
	
	# var node3d_owner := owner as Node3D
	# var offset = -roundi(node3d_owner.global_rotation.y / (PI / 2))
	# var direction = wrap(0 + offset, 0, Player.Direction.size())
	
	var grid_position = Vector2i(grid_x, grid_y)
	
	var cell_interactables = DungeonManager.interactable_data.get(grid_position)
	if cell_interactables and cell_interactables.has(direction):
		_valid_interactables = cell_interactables.get(direction).duplicate()
		
	on_interactables_updated.emit(_valid_interactables)
	
	# for cell_interactables in DungeonManager.interactable_data[grid_position]:
	# 	if cell_interactables.has[direction]:
	# 		_valid_interactables.append_array(cell_interactables[direction])
	
func clear_interactables() -> void:
	_valid_interactables.clear()
	on_interactables_updated.emit(_valid_interactables)
	
func _on_player_move_started(target_position: Vector3) -> void:
	clear_interactables()

func _on_player_move_finished(target_position: Vector3) -> void:
	var node3d_owner := owner as Node3D
	var grid_x := floori(target_position.x / DungeonManager.GRID_SIZE)
	var grid_y := floori(target_position.z / DungeonManager.GRID_SIZE)
	var direction = -roundi(node3d_owner.global_rotation.y / (PI / 2))
	
	prepare_interactables(grid_x, grid_y, direction)
	
func _on_player_rotation_started(target_rotation: float) -> void:
	clear_interactables()
	on_interactables_updated.emit(_valid_interactables)

func _on_player_rotation_finished(target_rotation: float) -> void:
	var node3d_owner := owner as Node3D
	var grid_x := floori(node3d_owner.position.x / DungeonManager.GRID_SIZE)
	var grid_y := floori(node3d_owner.position.z / DungeonManager.GRID_SIZE)
	var direction = -roundi(target_rotation / (PI / 2))
	
	prepare_interactables(grid_x, grid_y, direction)

func _ready() -> void:
	(owner as Player).on_move_started.connect(_on_player_move_started)
	(owner as Player).on_move_finished.connect(_on_player_move_finished)
	(owner as Player).on_rotation_started.connect(_on_player_rotation_started)
	(owner as Player).on_rotation_finished.connect(_on_player_rotation_finished)

func _process(delta: float) -> void:
	if BattleManager.get_is_battle_active():
		return
	
	if Input.is_action_just_pressed(&"player_interact"):
		for interactable in _valid_interactables:
			interactable.execute()
			on_execute_interaction.emit(interactable)
