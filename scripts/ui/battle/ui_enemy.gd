class_name UIEnemy extends Control

var _hp: int
var _max_hp: int
var _character_graphics_instance: UICharacterGraphics

func populate(name_key: String, character_graphics: PackedScene, hp: int, max_hp: int) -> void:
	_character_graphics_instance = character_graphics.instantiate()
	_character_graphics_instance.play_animation(&"idle")
	$CharacterGraphicsParent.add_child(_character_graphics_instance)
	$HPName.text = tr(name_key)
	update_hp(hp, max_hp)
	pass

func update_hp(hp: int, max_hp: int) -> void:
	$HPText.text = "HP: %d/%d" % [hp, max_hp]
	_hp = hp
	_max_hp = max_hp
	
func handle_hit(damage: int) -> void:
	update_hp(_hp - damage, _max_hp)
	# TODO: Hit effect, make lost health bar section
	
func play_animation(anim_id: StringName) -> void:
	_character_graphics_instance.play_animation(anim_id)
