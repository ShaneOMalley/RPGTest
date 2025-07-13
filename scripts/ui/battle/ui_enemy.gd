class_name UIEnemy extends TextureRect

var _participant_id: StringName
var _hp: int
var _max_hp: int

func update_hp(hp: int, max_hp: int) -> void:
    $HPText.text = "%d/%d" % [hp, max_hp]
    _hp = hp
    _max_hp = max_hp

func handle_hit(damage: int) -> void:
    update_hp(_hp - damage, _max_hp)
    # TODO: Hit effect, make lost health bar section
