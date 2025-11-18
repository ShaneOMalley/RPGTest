class_name UIDungeonCrawling extends Control

func minimap_fill_cell(grid_x: int, grid_y: int, color: Color):
	($Minimap as Minimap).fill_cell(grid_x, grid_y, color)

func minimap_surround_cell(grid_x: int, grid_y: int, up: bool, down: bool, left: bool, right: bool, color: Color):
	($Minimap as Minimap).surround_cell(grid_x, grid_y, up, down, left, right, color)

func minimap_set_player_position(grid_x: float, grid_y: float):
	($Minimap as Minimap).minimap_set_player_position(grid_x, grid_y)

func minimap_set_player_rotation(in_rotation: float):
	($Minimap as Minimap).minimap_set_player_rotation(in_rotation)
		
func update_floor_progress(current_floor_number: int, num_floors: int):
	($DungeonFloorText as RichTextLabel).text = &"Floor %d/%d" % [current_floor_number, num_floors]
	
func update_player_interactables(messages: Array[String]):
	if !messages.is_empty():
		($InteractionText as RichTextLabel).show()
		($InteractionText as RichTextLabel).text = messages.reduce(func(accum, text): return &"%s\n%s" % [text, accum])
	else:
		($InteractionText as RichTextLabel).hide()

func test_draw_minimap() -> void:
	($Minimap as Minimap).test_draw()

func _ready():
	pass
