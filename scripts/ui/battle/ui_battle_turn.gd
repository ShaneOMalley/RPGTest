class_name UIBattleTurn extends ColorRect

var uid: int

func set_background_color(in_color: Color) -> void:
	($Background as ColorRect).color = in_color

func set_text(text: String) -> void:
	($Text as RichTextLabel).set_text(text)
	
func set_time(time: float) -> void:
	($DebugTime as RichTextLabel).set_text("%0.2f" % time)
	
func play_animation(anim_name: StringName) -> void:
	($AnimationPlayer as AnimationPlayer).play(anim_name)
	
func reset_animation() -> void:
	($AnimationPlayer as AnimationPlayer).play(&"RESET")
