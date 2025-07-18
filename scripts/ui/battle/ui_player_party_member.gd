class_name PlayerPartyMember extends ColorRect

func populate(participant_name: String, hp: int, max_hp: int) -> void:
    $Portrait.show()
    $TextName.show()
    $TextHP.show()

    $TextName.text = participant_name
    $TextHP.text = "HP: %d/%d" % [hp, max_hp]

func update_hp(hp: int, max_hp: int) -> void:
    $TextHP.text = "HP: %d/%d" % [hp, max_hp]

func hide_info() -> void:
    $Portrait.hide()
    $TextName.hide()
    $TextHP.hide()