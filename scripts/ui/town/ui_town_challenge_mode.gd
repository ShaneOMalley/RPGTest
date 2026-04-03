class_name UITownChallengeMode extends Control

var challenge_buttons: Dictionary[int, Button]
var check_icon: Texture2D

func on_click_challenge_mode(challenge_mode_entry: TownManager.ChallengeModeEntry) -> void:
	BattleManager.setup_challenge_mode_battle(challenge_mode_entry.config_id)
	hide()
	BattleManager.on_battle_finished.connect(_on_battle_finished)
	
func _on_battle_finished() -> void:
	refresh_ui()
	show()
	BattleManager.on_battle_finished.disconnect(_on_battle_finished)
	
func refresh_ui() -> void:
	if Input.is_key_pressed(KEY_9):
		ChallengeManager.set_unlock_level(ChallengeManager.MAX_CHALLENGES + 1)
		
	var unlock_level = ChallengeManager.get_unlock_level()
	for challenge_number in challenge_buttons:
		var challenge_button = challenge_buttons[challenge_number]
		challenge_button.disabled = unlock_level < challenge_number
		challenge_button.icon = check_icon if unlock_level > challenge_number else null
		
	if unlock_level >= ChallengeManager.MAX_CHALLENGES + 1:
		$AllChallengesComplete.show()

func setup_ui() -> void:
	var challenge_mode_data := TownManager.challenge_mode_data
	
	check_icon = $Menu/ChallengeLevelTemplate.icon
	
	for config_id in challenge_mode_data:
		var challenge_mode_entry: TownManager.ChallengeModeEntry = challenge_mode_data[config_id]
		var button = ($Menu/ChallengeLevelTemplate.duplicate() as Button)
		button.pressed.connect(on_click_challenge_mode.bind(challenge_mode_entry))
		button.show()
		button.text = tr("UI_CHALLENGE_MODE_LEVEL").format({"level_number": challenge_mode_entry.challenge_number})
		$Menu/ChallengeLevelTemplate.add_sibling(button)
		
		# todo set button text
		
		challenge_buttons[challenge_mode_entry.challenge_number] = button
		
	refresh_ui()

func go_back() -> void:
	TownManager.show_town_ui(load("res://ui/town/town_ui.tscn")) # preload doesn't work for some reason
	BattleManager.on_battle_finished.disconnect(_on_battle_finished)

func _ready() -> void:
	$Menu/ChallengeLevelTemplate.hide()
	($Menu/Back as Button).pressed.connect(go_back)
	($Menu/Back as Button).grab_focus()
	$AllChallengesComplete.hide()
	setup_ui()
