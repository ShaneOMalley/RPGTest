class_name PlayerPartyMember extends ColorRect

var _hp: int
var _max_hp: int
var _character_graphics_instance: UICharacterGraphics

func populate(participant_name: String, character_graphics: PackedScene, hp: int, max_hp: int) -> void:
	_character_graphics_instance = character_graphics.instantiate()
	_character_graphics_instance.play_animation(&"idle")
	$Border/CharacterGraphicsParent.add_child(_character_graphics_instance)
	$Border/CharacterGraphicsParent.show()
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
	$Border/CharacterGraphicsParent.hide()
	$Border/TextName.hide()
	$Border/TextHP.hide()
	
func play_animation(anim_id: StringName) -> void:
	_character_graphics_instance.play_animation(anim_id)
