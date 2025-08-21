class_name StateBattlePreSetup extends FSMState

var encounter_group: Array[StringName]

func _on_load_complete() -> void:
	for participant_id in encounter_group:
		var participant = BattleParticipant.create_from_config(participant_id)
		participant.affiliation = BattleManager.Affiliation.ENEMY
		BattleManager.add_participant(participant)

	for player_participant in PlayerPartyManager.get_participants():
		BattleManager.add_participant(player_participant)

	BattleManager.set_is_finished_setting_up_participants(true)

# var _test_on_ready: Signal
const config_path: String = "res://res/data/battle_encounters.json"
func on_enter() -> void:
	var encounter_group_id := BattleManager.get_encounter_group_id()

	var file := FileAccess.open(config_path, FileAccess.READ)
	var json = JSON.parse_string(file.get_as_text()) 
	var data = json[&"encounter_groups"]

	encounter_group.clear()
	encounter_group.append_array(data[encounter_group_id])

	BattleParticipant.load_participants_async(encounter_group, _on_load_complete)

func on_exit() -> void:
	BattleManager.complete_pre_setup()
