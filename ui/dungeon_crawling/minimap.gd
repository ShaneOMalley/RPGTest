class_name Minimap extends TextureRect

var _image: Image

const CELL_SIZE := 16 * 2
const GRID_SIZE := 16
const CELL_SURROUND_THICKNESS = 2

func add_rect(x1: int, y1: int, x2: int, y2: int, color: Color, overwrite_existing_pixels: bool, padding: int = 0):
	if !_image:
		return

	var half_padding := padding / 2
	for i in range(x1 - half_padding, x2 + 1 + half_padding):
		for j in range(y1 - half_padding, y2 + 1 + half_padding):
			if overwrite_existing_pixels or _image.get_pixel(i, j).a == 0:
				_image.set_pixel(i, j, color)

	texture = ImageTexture.create_from_image(_image)

func fill_cell(grid_x: int, grid_y: int, color: Color):
	add_rect(grid_x * CELL_SIZE, grid_y * CELL_SIZE, grid_x * CELL_SIZE + CELL_SIZE, grid_y * CELL_SIZE + CELL_SIZE, color, false)

func surround_cell(grid_x: int, grid_y: int, up: bool, down: bool, left: bool, right: bool, color: Color):
	if up:
		add_rect(grid_x * CELL_SIZE, grid_y * CELL_SIZE, grid_x * CELL_SIZE + CELL_SIZE, grid_y * CELL_SIZE, color, true, CELL_SURROUND_THICKNESS)
	if down:
		add_rect(grid_x * CELL_SIZE, grid_y * CELL_SIZE + CELL_SIZE, grid_x * CELL_SIZE + CELL_SIZE, grid_y * CELL_SIZE + CELL_SIZE, color, true, CELL_SURROUND_THICKNESS)
	if left:
		add_rect(grid_x * CELL_SIZE, grid_y * CELL_SIZE, grid_x * CELL_SIZE, grid_y * CELL_SIZE + CELL_SIZE, color, true, CELL_SURROUND_THICKNESS)
	if right:
		add_rect(grid_x * CELL_SIZE + CELL_SIZE, grid_y * CELL_SIZE, grid_x * CELL_SIZE + CELL_SIZE, grid_y * CELL_SIZE + CELL_SIZE, color, true, CELL_SURROUND_THICKNESS)

func minimap_set_player_position(grid_x: int, grid_y: int) -> void:
	($Player as Control).set_position(Vector2(grid_x * CELL_SIZE, grid_y * CELL_SIZE))

func minimap_set_player_rotation(rotation: float) -> void:
	($Player as Control).rotation = -rotation

func _ready():
	_image = Image.create_empty(GRID_SIZE * CELL_SIZE, GRID_SIZE * CELL_SIZE, false, Image.Format.FORMAT_RGBA8)
