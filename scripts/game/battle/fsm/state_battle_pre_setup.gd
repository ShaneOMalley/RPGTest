class_name StateBattlePreSetup extends FSMState

func _temp_add_participants():
    var player = BattleParticipant.create_from_config(&"player")
    player.affiliation = BattleManager.Affiliation.PLAYER

    var enemy_1 = BattleParticipant.create_from_config(&"ghoul")
    enemy_1.affiliation = BattleManager.Affiliation.ENEMY
    
    var enemy_2 = BattleParticipant.create_from_config(&"goblin")
    enemy_2.affiliation = BattleManager.Affiliation.ENEMY

    BattleManager.add_participant(player)
    BattleManager.add_participant(enemy_1)
    BattleManager.add_participant(enemy_2)

func on_enter() -> void:
    # TODO: Add this properly
    _temp_add_participants()

    BattleManager.set_is_finished_setting_up_participants(true)

func on_exit() -> void:
    BattleManager.on_pre_setup_complete()
    pass