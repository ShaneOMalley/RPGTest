class_name StateBattlePreSetupChallengeMode extends FSMState

var enemy_group: Array[StringName]
var player_group: Array[StringName]
var combined_groups: Array[StringName]

func _on_load_complete() -> void:

	var enemy_participants: Array[BattleParticipant] = []
	var player_participants: Array[BattleParticipant] = []

	for participant_id in enemy_group:
		var participant = BattleParticipant.create_from_config(participant_id)
		participant.affiliation = BattleManager.Affiliation.ENEMY
		BattleManager.add_participant(participant)
		enemy_participants.append(participant)
		
	for participant_id in player_group:
		var participant = BattleParticipant.create_from_config(participant_id)
		participant.affiliation = BattleManager.Affiliation.PLAYER
		BattleManager.add_participant(participant)
		player_participants.append(participant)

	# for player_participant in PlayerPartyManager.get_participants():
	# 	BattleManager.add_participant(player_participant)
	
	PlayerPartyManager.save_participants()
	PlayerPartyManager.clear_participants()
	PlayerPartyManager._participants = BattleManager.get_players() # todo, encapsulate this
	# PlayerPartyManager.add_participants_async(player_group)
	
	var timer := BattleManager.get_tree().create_timer(0.5)
	timer.timeout.connect(func(): BattleManager.set_is_finished_setting_up_participants(true))

# var _test_on_ready: Signal
const config_path: String = "res://res/data/challenge_mode.json"
func on_enter() -> void:
	var challenge_mode_level_id := BattleManager.get_challenge_mode_level_id()

	var file := FileAccess.open(config_path, FileAccess.READ)
	var json = JSON.parse_string(file.get_as_text()) 
	# var level_data = json["levels"][challenge_mode_level_id]
	
	
	var found_index = json["levels"].find_custom(func(level_entry):
		return level_entry.id == challenge_mode_level_id
	)
	var level_data = json["levels"][found_index]
	
	BattleManager.set_battle_start_time(level_data["start_time"])
	
	enemy_group.clear()
	for enemy_data in level_data["enemies"]:
		enemy_group.append(enemy_data.id)
	
	player_group.clear()
	for player_data in level_data["players"]:
		player_group.append(player_data.id)
		
	combined_groups.clear()
	combined_groups.append_array(enemy_group)
	combined_groups.append_array(player_group)

	BattleParticipant.load_participants_async(combined_groups, _on_load_complete)
	
func on_exit() -> void:
	BattleView.setup_battle_ui()
	BattleView.show_ui()
	BattleView.hide_battle_ui()
	
	BattleManager.complete_pre_setup()
