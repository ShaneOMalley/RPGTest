class_name Player extends Node3D

enum Direction { UP, RIGHT, DOWN, LEFT }

signal on_move(current_position: Vector3)
signal on_move_started(target_position: Vector3)
signal on_move_finished(target_position: Vector3)
signal on_rotation_started(target_rotation: float)
signal on_rotation_finished(target_rotation: float)
signal on_execute_interaction(interactable: DungeonInteractable)
signal on_interactable_updated(interactable: DungeonInteractable)

func _ready():
	($MovementController as PlayerMovementController).on_move.connect(on_move.emit)
	($MovementController as PlayerMovementController).on_move_started.connect(on_move_started.emit)
	($MovementController as PlayerMovementController).on_rotation_started.connect(on_rotation_started.emit)
	($MovementController as PlayerMovementController).on_move_finished.connect(on_move_finished.emit)
	($MovementController as PlayerMovementController).on_rotation_finished.connect(on_rotation_finished.emit)
	($InteractionController as PlayerInteractionController).on_execute_interaction.connect(on_execute_interaction.emit)
	($InteractionController as PlayerInteractionController).on_interactable_updated.connect(on_interactable_updated.emit)
	DungeonManager.set_player(self)
	
	($AnimationPlayer as AnimationPlayer).play(&"drop_in")
