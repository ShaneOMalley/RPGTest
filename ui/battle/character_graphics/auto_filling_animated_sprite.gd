extends AnimatedSprite2D

var parent: Control

func _ready() -> void:
	parent = get_parent()
	if parent is Control:
		parent.resized.connect(_on_parent_resized)
		_on_parent_resized.call_deferred()

func _on_parent_resized() -> void:
	if !sprite_frames:
		return
		
	var frame_tex = sprite_frames.get_frame_texture(animation, frame)
	if !frame_tex:
		return
		
	var sprite_size := frame_tex.get_size()
	var parent_size := parent.size
	
	var scale_factor_x := parent_size.x / sprite_size.x
	var scale_factor_y := parent_size.y / sprite_size.y
	var final_scale = min(scale_factor_x, scale_factor_y)
	
	scale = Vector2(final_scale, final_scale)
	position = (parent_size - (sprite_size * final_scale)) / 2
	pass
	
func _process(delta: float) -> void:
	# _on_parent_resized()
	pass
