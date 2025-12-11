class_name DungeonTreasure extends Node3D

func open() -> void:
	$AnimationPlayer.play(&"open")
