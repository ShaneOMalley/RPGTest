class_name PlayerPartyMember extends ColorRect

var _hp: int
var _max_hp: int

func populate(participant_name: String, hp: int, max_hp: int) -> void:
	$Border/Portrait.show()
	$Border/TextName.show()
	$Border/TextHP.show()

	$Border/TextName.text = participant_name
	$Border/TextHP.text = "HP: %d/%d" % [hp, max_hp]

func update_hp(hp: int, max_hp: int) -> void:
	$Border/TextHP.text = "HP: %d/%d" % [hp, max_hp]
	_hp = hp
	_max_hp = max_hp

func handle_hit(damage: int) -> void:
	update_hp(_hp - damage, _max_hp)
	# TODO: Hit effect, make lost health bar section

func hide_info() -> void:
	$Border/Portrait.hide()
	$Border/TextName.hide()
	$Border/TextHP.hide()
	
func _ready() -> void:
	# ($Border/AnimationPlayer as AnimationPlayer).animation_started.connect(AnimationCallbackManager.on_animation_started)
	# ($Border/AnimationPlayer as AnimationPlayer).animation_finished.connect(AnimationCallbackManager.on_animation_finished)
	var animation_player := $Border/AnimationPlayer as AnimationPlayer
	animation_player.animation_finished.connect(func(anim_id): animation_player.play(&"RESET"))
	
func play_animation(anim_id: StringName) -> void:
	($Border/AnimationPlayer as AnimationPlayer).play(anim_id)
	
func handle_animation_event(event_id: StringName) -> void:
	AnimationCallbackManager.raise_event(event_id)
