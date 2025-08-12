class_name StateBattlePreSetup extends FSMState

func _add_participant(config_name: String, affiliation: BattleManager.Affiliation):
	var participant = BattleParticipant.create_from_config(config_name)
	participant.affiliation = affiliation
	BattleManager.add_participant(participant)

func _on_load_complete() -> void:
	_add_participant(&"player", BattleManager.Affiliation.PLAYER)
	_add_participant(&"ghoul", BattleManager.Affiliation.ENEMY)
	_add_participant(&"goblin", BattleManager.Affiliation.ENEMY)

	BattleManager.set_is_finished_setting_up_participants(true)

# var _test_on_ready: Signal
func on_enter() -> void:
	# TODO: Add participants properly
	# _test_on_ready = BattleParticipant.load_participants_async([&"player", &"ghoul", &"goblin"])
	BattleParticipant.load_participants_async([&"player", &"ghoul", &"goblin"], _on_load_complete)
	#  print("wtf")
	#  print(_test_on_ready)
	# _test_on_ready.connect(func(): print("test"))
	# _test_on_ready.connect(_on_load_complete)
	# var connections = _test_on_ready.get_connections()
	pass

func on_exit() -> void:
	BattleManager.on_pre_setup_complete()
	pass