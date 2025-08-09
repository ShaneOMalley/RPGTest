class_name FSMBattle extends FiniteStateMachine

func _init() -> void:
	add_state("pre_setup", StateBattlePreSetup.new())
	add_state("turn_setup", StateBattleTurnSetup.new())
	add_state("turn_decision_player", StateBattleTurnDecisionPlayer.new())
	add_state("turn_decision_enemy", StateBattleTurnDecisionEnemy.new())
	add_state("turn_ability", StateBattleTurnAbility.new())
	add_state("turn_handle_death", StateBattleTurnHandleDeath.new())
	
	add_transition("pre_setup", "turn_setup", func(): return BattleManager.get_is_finished_setting_up_participants())

	add_transition("turn_setup", "turn_decision_player", func(): return BattleManager.get_current_turn().get_affiliation() == BattleManager.Affiliation.PLAYER)
	add_transition("turn_setup", "turn_decision_enemy", func(): return BattleManager.get_current_turn().get_affiliation() == BattleManager.Affiliation.ENEMY)
	add_transition("turn_decision_player", "turn_ability", func(): return BattleManager.has_queued_ability())
	add_transition("turn_decision_enemy", "turn_ability", func(): return BattleManager.has_queued_ability())
	add_transition("turn_ability", "turn_handle_death", func(): return !BattleManager.has_executing_ability())
	add_transition("turn_handle_death", "turn_setup", func(): return true) # !BattleManager.get_is_blocked())
	
func start() -> void:
	goto_state("pre_setup")
	
func _exit_tree() -> void:
	print("FSMBattle: exit tree")
