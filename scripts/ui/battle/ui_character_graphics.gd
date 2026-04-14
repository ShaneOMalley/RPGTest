class_name UICharacterGraphics extends Control

func play_animation(anim_id: StringName) -> void:
	if ($AnimationPlayer as AnimationPlayer).has_animation(anim_id):
		($AnimationPlayer as AnimationPlayer).play(anim_id)
		
	($AnimatedSpriteParent/AnimatedSprite2D as AnimatedSprite2D).play(anim_id)
	
func _ready() -> void:
	var animation_player := $AnimationPlayer as AnimationPlayer
	animation_player.animation_finished.connect(func(_anim_id): animation_player.play(&"idle"))
	
	var animated_sprite_2d := $AnimatedSpriteParent/AnimatedSprite2D as AnimatedSprite2D
	animated_sprite_2d.animation_finished.connect(func(): animated_sprite_2d.play(&"idle"))
