extends Node

func update_player_position(target_position: Vector3) -> void:
	# Assumption: If a neighbouring cell cannot be moved to, it is because of a wall
	var grid_x := floori(target_position.x / DungeonManager.GRID_SIZE)
	var grid_y := floori(target_position.z / DungeonManager.GRID_SIZE)
	var movement_data = DungeonManager.get_movement_data_for_cell(grid_x, grid_y)

	var up: bool = (movement_data & DungeonManager.MOVEMENT_FLAG_UP) == 0
	var down: bool = (movement_data & DungeonManager.MOVEMENT_FLAG_DOWN) == 0
	var left: bool = (movement_data & DungeonManager.MOVEMENT_FLAG_LEFT) == 0
	var right: bool = (movement_data & DungeonManager.MOVEMENT_FLAG_RIGHT) == 0

	DungeonCrawlingView.minimap_fill_cell(grid_x, grid_y, up, down, left, right)

	# var normalized_x := target_position.x / DungeonManager.GRID_SIZE - 0.5
	# var normalized_y := target_position.z / DungeonManager.GRID_SIZE - 0.5
	# DungeonCrawlingView.minimap_set_player_position(normalized_x, normalized_y)

	DungeonCrawlingView.minimap_set_player_position(grid_x, grid_y)

func update_player_rotation(target_rotation: float) -> void:
	DungeonCrawlingView.minimap_set_player_rotation(target_rotation)
	
func update_floor_progress(current_floor_number: int, num_floors: int) -> void:
	DungeonCrawlingView.update_floor_progress(current_floor_number, num_floors)
	
func update_player_interactable(interactable: DungeonInteractable) -> void:
	var message = interactable.message if is_instance_valid(interactable) else ""
	DungeonCrawlingView.update_player_interactable(message)

func on_dungeon_crawling_start(player_position: Vector3, player_rotation: float) -> void:
	DungeonCrawlingView.setup_ui()
	update_player_position(player_position)
	update_player_rotation(player_rotation)
	
func on_dungeon_crawling_finished() -> void:
	DungeonCrawlingView.destroy_ui()

func on_battle_started() -> void:
	DungeonCrawlingView.hide_ui()

func on_battle_finished() -> void:
	DungeonCrawlingView.show_ui()

func _ready():
	# DungeonManager.on_player_move.connect(update_player_position)
	DungeonManager.on_player_move_started.connect(update_player_position)
	DungeonManager.on_player_rotation_started.connect(update_player_rotation)
	DungeonManager.on_player_interactable_updated.connect(update_player_interactable)
	DungeonManager.on_dungeon_crawling_start.connect(on_dungeon_crawling_start)
	DungeonManager.on_dungeon_crawling_finished.connect(on_dungeon_crawling_finished)
	DungeonManager.on_dungeon_floor_start.connect(update_floor_progress)

	BattleManager.on_battle_started.connect(on_battle_started)
	BattleManager.on_battle_finished.connect(on_battle_finished)
