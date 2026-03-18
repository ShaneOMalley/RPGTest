class_name UITownChallengeMode extends Control

var recruit_buttons: Dictionary[StringName, Button]

func on_click_challenge_mode(challenge_mode_entry: TownManager.ChallengeModeEntry) -> void:
	BattleManager.setup_challenge_mode_battle(challenge_mode_entry.config_id)
	hide()
	BattleManager.on_battle_finished.connect(_on_battle_finished)
	
func _on_battle_finished() -> void:
	show()
	BattleManager.on_battle_finished.disconnect(_on_battle_finished)

func setup_ui() -> void:
	var challenge_mode_data := TownManager.challenge_mode_data
	
	for config_id in challenge_mode_data:
		var challenge_mode_entry: TownManager.ChallengeModeEntry = challenge_mode_data[config_id]
		var button = ($Menu/ChallengeLevelTemplate.duplicate() as Button)
		button.pressed.connect(on_click_challenge_mode.bind(challenge_mode_entry))
		button.show()
		button.text = challenge_mode_entry.config_id
		$Menu/ChallengeLevelTemplate.add_sibling(button)
		
		# todo set button text
		
		recruit_buttons[config_id] = button

func go_back() -> void:
	TownManager.show_town_ui(load("res://ui/town/town_ui.tscn")) # preload doesn't work for some reason
	BattleManager.on_battle_finished.disconnect(_on_battle_finished)

func _ready() -> void:
	$Menu/ChallengeLevelTemplate.hide()
	($Menu/Back as Button).pressed.connect(go_back)
	($Menu/Back as Button).grab_focus()
	setup_ui()
