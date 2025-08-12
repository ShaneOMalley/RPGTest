class_name PlayerPartyMember extends ColorRect

var _hp: int
var _max_hp: int

func populate(participant_name: String, hp: int, max_hp: int) -> void:
	$Portrait.show()
	$TextName.show()
	$TextHP.show()

	$TextName.text = participant_name
	$TextHP.text = "HP: %d/%d" % [hp, max_hp]

func update_hp(hp: int, max_hp: int) -> void:
	$TextHP.text = "HP: %d/%d" % [hp, max_hp]
	_hp = hp
	_max_hp = max_hp

func handle_hit(damage: int) -> void:
	update_hp(_hp - damage, _max_hp)
	# TODO: Hit effect, make lost health bar section

func hide_info() -> void:
	$Portrait.hide()
	$TextName.hide()
	$TextHP.hide()