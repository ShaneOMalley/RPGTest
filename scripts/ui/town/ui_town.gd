class_name UITown extends Control

func _start_dungeon() -> void:
	TownManager.remove_town_scene()
	DungeonManager.reset()
	DungeonManager.goto_next_floor()
	
func _do_recruitment() -> void:
	TownManager.show_town_ui(preload("res://ui/town/town_recruitment_ui.tscn"))
	
func _do_challenge_mode() -> void:
	TownManager.show_town_ui(preload("res://ui/town/town_challenge_mode_ui.tscn"))

func _ready() -> void:
	($Menu/StartDungeon as Button).pressed.connect(_start_dungeon)
	($Menu/Recruitment as Button).pressed.connect(_do_recruitment)
	($Menu/ChallengeMode as Button).pressed.connect(_do_challenge_mode)
	($Menu/StartDungeon as Button).grab_focus()
