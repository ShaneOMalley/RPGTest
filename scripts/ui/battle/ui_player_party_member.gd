class_name PlayerPartyMember extends ColorRect

var _hp: int
var _max_hp: int
var _sp: int
var _max_sp: int
var _character_graphics_instance: UICharacterGraphics

func populate(participant_name: StringName, character_graphics: PackedScene, hp: int, max_hp: int, sp: int, max_sp: int) -> void:
	_character_graphics_instance = character_graphics.instantiate()
	_character_graphics_instance.play_animation(&"idle")
	$Border/Content/CharacterGraphicsParent.add_child(_character_graphics_instance)
	$Border/Content.show()

	$Border/Content/TextName.text = tr(participant_name)
	update_hp(hp, max_hp)
	update_sp(sp, max_sp)

func update_hp(hp: int, max_hp: int) -> void:
	$Border/Content/TextHP.text = "HP: %d/%d" % [hp, max_hp]
	_hp = hp
	_max_hp = max_hp
	
func update_sp(sp: int, max_sp: int) -> void:
	$Border/Content/TextSP.text = "SP: %d/%d" % [sp, max_sp]
	_sp = sp
	_max_sp = max_sp

func handle_hit(damage: int) -> void:
	update_hp(_hp - damage, _max_hp)
	# TODO: Hit effect, make lost health bar section

func hide_info() -> void:
	$Border/Content.hide()
	
func play_animation(anim_id: StringName) -> void:
	_character_graphics_instance.play_animation(anim_id)
