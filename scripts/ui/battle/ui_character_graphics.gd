class_name UICharacterGraphics extends Control

func play_animation(anim_id: StringName) -> void:
	($AnimationPlayer as AnimationPlayer).play(anim_id)
	
func _ready() -> void:
	var animation_player := $AnimationPlayer as AnimationPlayer
	animation_player.animation_finished.connect(func(_anim_id): animation_player.play(&"idle"))
