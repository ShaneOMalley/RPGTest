class_name PlayerMovementController extends Node

var _is_moving := false
var _is_thudding := false
var _is_rotating := false
var _starting_position: Vector3
var _target_position: Vector3
var _starting_y_rotation: float
var _target_y_rotation: float
var _movement_t: float
var _rotation_t: float

@export var movement_speed: float
@export var rotation_speed: float
@export var thud_distance_factor: float
@export var thud_speed_factor: float

signal on_move(current_position: Vector3)
signal on_move_started(target_position: Vector3)
signal on_rotation_started(target_rotation: float)
signal on_move_finished(target_position: Vector3)
signal on_rotation_finished(target_rotation: float)

func _start_movement(in_target_position: Vector3) -> void:
	_starting_position = (owner as Node3D).position
	_target_position = in_target_position
	_movement_t = 0
	_is_moving = true

	on_move_started.emit(_target_position)

func _start_wall_thud(in_target_position: Vector3) -> void:
	_starting_position = (owner as Node3D).position
	_target_position = in_target_position
	_movement_t = 0
	_is_thudding = true

func _start_rotation(direction: ClockDirection) -> void:
	_starting_y_rotation = (owner as Node3D).global_rotation.y
	_target_y_rotation = _starting_y_rotation + ((PI / 2) if direction == COUNTERCLOCKWISE else (-PI / 2))
	_rotation_t = 0
	_is_rotating = true

	on_rotation_started.emit(_target_y_rotation)

func _handle_movement(delta: float) -> bool:
	var node3d_owner := owner as Node3D

	if _is_moving:
		var distance := (_target_position - _starting_position).length()
		_movement_t = minf(1, _movement_t + delta * movement_speed / distance)
		node3d_owner.position = lerp(_starting_position, _target_position, _movement_t)

		if is_equal_approx(_movement_t, 1):
			_is_moving = false
			on_move_finished.emit(_target_position)

		on_move.emit(node3d_owner.position)

		return true

	if _is_thudding:
		var distance := (_target_position - _starting_position).length() * thud_distance_factor
		# t values > 0.5 mean the thud is bringing the player back to its starting position
		_movement_t = minf(1, _movement_t + (delta * thud_speed_factor * movement_speed) / (distance * 2))
		var adjusted_t := minf(1, _movement_t * 2) - clampf(_movement_t * 2 - 1, 0, 1)
		node3d_owner.position = lerp(_starting_position, _target_position, adjusted_t)

		if is_equal_approx(_movement_t, 1):
			_is_thudding = false

		return true

	if _is_rotating:
		_rotation_t = minf(1, _rotation_t + delta * rotation_speed / (PI / 2))
		var rotation_angle := lerpf(_starting_y_rotation, _target_y_rotation, _rotation_t)
		node3d_owner.rotation.y = rotation_angle

		if is_equal_approx(_rotation_t, 1):
			_is_rotating = false
			on_rotation_finished.emit(_target_y_rotation)

		return true

	return false

func _handle_input(_delta: float) -> void:
	var node3d_owner := owner as Node3D

	const MOVEMENT_DEADZONE := 0.8
	var input_vector := Input.get_vector(&"player_left", &"player_right", &"player_backward", &"player_forward")
	var is_strafing := Input.is_action_pressed(&"player_strafe")

	var move_direction := -1

	if input_vector.y > MOVEMENT_DEADZONE:
		move_direction = Player.Direction.UP
	elif input_vector.y < -MOVEMENT_DEADZONE:
		move_direction = Player.Direction.DOWN
	elif input_vector.x > MOVEMENT_DEADZONE:
		if is_strafing:
			move_direction = Player.Direction.RIGHT
		else:
			_start_rotation(CLOCKWISE)
	elif input_vector.x < -MOVEMENT_DEADZONE:
		if is_strafing:
			move_direction = Player.Direction.LEFT
		else:
			_start_rotation(COUNTERCLOCKWISE)

	# Update grid movement position based on rotation
	if move_direction != -1:
		var offset = -roundi(node3d_owner.global_rotation.y / (PI / 2))
		var adjusted_move_direction = wrap(move_direction + offset, 0, Player.Direction.size())
		var grid_x := floori(node3d_owner.position.x / DungeonManager.GRID_SIZE)
		var grid_y := floori(node3d_owner.position.z / DungeonManager.GRID_SIZE)

		match adjusted_move_direction:
			Player.Direction.UP:
				if DungeonManager.can_move_up(grid_x, grid_y):
					_start_movement(owner.position + Vector3(0, 0, -DungeonManager.GRID_SIZE))
				else:
					_start_wall_thud(owner.position + Vector3(0, 0, -DungeonManager.GRID_SIZE * thud_distance_factor))
			Player.Direction.DOWN:
				if DungeonManager.can_move_down(grid_x, grid_y):
					_start_movement(owner.position + Vector3(0, 0, DungeonManager.GRID_SIZE))
				else:
					_start_wall_thud(owner.position + Vector3(0, 0, DungeonManager.GRID_SIZE * thud_distance_factor))
			Player.Direction.LEFT:
				if DungeonManager.can_move_left(grid_x, grid_y):
					_start_movement(owner.position + Vector3(-DungeonManager.GRID_SIZE, 0, 0))
				else:
					_start_wall_thud(owner.position + Vector3(-DungeonManager.GRID_SIZE * thud_distance_factor, 0, 0))
			Player.Direction.RIGHT:
				if DungeonManager.can_move_right(grid_x, grid_y):
					_start_movement(owner.position + Vector3(DungeonManager.GRID_SIZE, 0, 0))
				else:
					_start_wall_thud(owner.position + Vector3(DungeonManager.GRID_SIZE * thud_distance_factor, 0, 0))

func _process(delta: float):
	var is_moving := _handle_movement(delta)

	if !is_moving && !DungeonManager.get_player_input_blocked():
		_handle_input(delta)
