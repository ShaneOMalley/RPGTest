class_name UIBattle extends Control

# todo: delete PlayerPartyContainer from battle_ui.tscn

signal on_battle_fade_complete()

func fade_in() -> void:
	$AnimationPlayer.play(&"battle_fade")
	
func show_battle_ui() -> void:
	$BattleBackground.show()

func hide_battle_ui() -> void:
	$BattleBackground.hide()

func _ready():
	$AnimationPlayer.animation_finished.connect(func(anim): if anim == &"battle_fade": on_battle_fade_complete.emit())
