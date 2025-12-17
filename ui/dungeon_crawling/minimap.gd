class_name Minimap extends TextureRect

var _image: Image

const PLAYER_SIZE := 20
const CELL_SIZE := 24
const GRID_SIZE := 16
const CELL_SURROUND_THICKNESS = 2

func add_rect(x1: int, y1: int, x2: int, y2: int, color: Color, overwrite_existing_pixels: bool, padding: int = 0) -> void:
	if !_image:
		return

	var half_padding := padding / 2
	for i in range(x1 - half_padding, x2 + 1 + half_padding):
		for j in range(y1 - half_padding, y2 + 1 + half_padding):
			if overwrite_existing_pixels or _image.get_pixel(i, j).a == 0:
				_image.set_pixel(i, j, color)

func update_texture() -> void:
	texture = ImageTexture.create_from_image(_image)

func fill_cell(grid_x: int, grid_y: int, color: Color) -> void:
	add_rect(grid_x * CELL_SIZE, grid_y * CELL_SIZE, grid_x * CELL_SIZE + CELL_SIZE, grid_y * CELL_SIZE + CELL_SIZE, color, false)
	update_texture()

func surround_cell(grid_x: int, grid_y: int, up: bool, down: bool, left: bool, right: bool, color: Color) -> void:
	if up:
		add_rect(grid_x * CELL_SIZE, grid_y * CELL_SIZE, grid_x * CELL_SIZE + CELL_SIZE, grid_y * CELL_SIZE, color, true, CELL_SURROUND_THICKNESS)
	if down:
		add_rect(grid_x * CELL_SIZE, grid_y * CELL_SIZE + CELL_SIZE, grid_x * CELL_SIZE + CELL_SIZE, grid_y * CELL_SIZE + CELL_SIZE, color, true, CELL_SURROUND_THICKNESS)
	if left:
		add_rect(grid_x * CELL_SIZE, grid_y * CELL_SIZE, grid_x * CELL_SIZE, grid_y * CELL_SIZE + CELL_SIZE, color, true, CELL_SURROUND_THICKNESS)
	if right:
		add_rect(grid_x * CELL_SIZE + CELL_SIZE, grid_y * CELL_SIZE, grid_x * CELL_SIZE + CELL_SIZE, grid_y * CELL_SIZE + CELL_SIZE, color, true, CELL_SURROUND_THICKNESS)

	update_texture()

func minimap_set_player_position(grid_x: float, grid_y: float) -> void:
	const OFFSET = (CELL_SIZE - PLAYER_SIZE) / 2
	($Player as Control).set_position(Vector2(grid_x * CELL_SIZE + OFFSET, grid_y * CELL_SIZE + OFFSET))

func minimap_set_player_rotation(rotation: float) -> void:
	($Player as Control).rotation = -rotation

func _ready():
	_image = Image.create_empty(GRID_SIZE * CELL_SIZE, GRID_SIZE * CELL_SIZE, false, Image.Format.FORMAT_RGBA8)
