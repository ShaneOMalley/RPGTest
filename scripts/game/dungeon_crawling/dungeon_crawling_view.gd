extends Node

# var _filled_cells: Dictionary[int, bool]

var dungeon_crawling_ui: UIDungeonCrawling

# Update minimap
func minimap_add_walls(grid_x: int, grid_y: int, up: bool, down: bool, left: bool, right: bool) -> void:
	dungeon_crawling_ui.minimap_surround_cell(grid_x, grid_y, up, down, left, right, Color.WHITE)

func minimap_add_floor(grid_x: int, grid_y: int) -> void:
	# var index := grid_x + grid_y * DungeonManager.get_grid_width()
	# if !_filled_cells.get(index):
	# 	_filled_cells[index] = true
	# 	print("!!!")
	
	dungeon_crawling_ui.minimap_fill_cell(grid_x, grid_y, Color.OLIVE)

func minimap_set_player_position(grid_x: int, grid_y: int) -> void:
	dungeon_crawling_ui.minimap_set_player_position(grid_x, grid_y)

func minimap_set_player_rotation(rotation: float) -> void:
	dungeon_crawling_ui.minimap_set_player_rotation(rotation)

func setup_ui() -> void:
	dungeon_crawling_ui = preload("res://ui/dungeon_crawling/dungeon_crawling_ui.tscn").instantiate()
	get_tree().root.add_child.call_deferred(dungeon_crawling_ui)
