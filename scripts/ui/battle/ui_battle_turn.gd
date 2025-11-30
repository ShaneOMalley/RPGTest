class_name UIBattleTurn extends Button

var uid: int

func set_background_color(in_color: Color) -> void:
	self_modulate = in_color

func set_turn_text(in_text: String) -> void:
	($Text as RichTextLabel).set_text(in_text)
	
func set_modifier_text(in_text: String) -> void:
	var label := ($ModifierText as RichTextLabel)
	if in_text.is_empty():
		label.hide()
	else:
		label.show()
		label.set_text(in_text)
	
func set_time(time: float) -> void:
	($DebugTime as RichTextLabel).set_text("%0.2f" % time)
	
func play_animation(anim_name: StringName) -> void:
	($AnimationPlayer as AnimationPlayer).play(anim_name)
	
func reset_animation() -> void:
	($AnimationPlayer as AnimationPlayer).play(&"RESET")
