class_name UIEnemy extends TextureRect

var _hp: int
var _max_hp: int

func populate(participant_name: String, hp: int, max_hp: int) -> void:
	$HPName.text = participant_name
	update_hp(hp, max_hp)
	pass

func update_hp(hp: int, max_hp: int) -> void:
	$HPText.text = "HP: %d/%d" % [hp, max_hp]
	_hp = hp
	_max_hp = max_hp
	
func handle_hit(damage: int) -> void:
	update_hp(_hp - damage, _max_hp)
	# TODO: Hit effect, make lost health bar section
	
func _transition_from_getting_hit() -> void:
	var animation_player := $AnimationPlayer as AnimationPlayer
	if _hp > 0:
		animation_player.play(&"idle")
	
func _ready() -> void:
	var animation_player := $AnimationPlayer as AnimationPlayer
	# animation_player.animation_finished.connect(func(_anim_id): animation_player.play(&"idle"))
	animation_player.animation_finished.connect(func(_anim_id): _transition_from_getting_hit())
	animation_player.play(&"idle")
	
func play_animation(anim_id: StringName) -> void:
	($AnimationPlayer as AnimationPlayer).play(anim_id)
