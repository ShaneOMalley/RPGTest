class_name FSMBattle extends FiniteStateMachine

func _init() -> void:
	add_state("turn_setup", StateBattleTurnSetup.new())
	add_state("turn_decision_player", StateBattleTurnDecisionPlayer.new())
	add_state("turn_decision_enemy", StateBattleTurnDecisionEnemy.new())
	add_state("turn_ability", StateBattleTurnAbility.new())
	add_state("turn_handle_death", StateBattleTurnHandleDeath.new())
	
	# add_transition("one", "two", func(): return floori(self._time) % 2 == 0)
	add_transition("turn_decision_player", "turn_ability", func(): return BattleManager.has_queued_ability())
	add_transition("turn_ability", "turn_handle_death", func(): return !BattleManager.get_is_blocked())
	add_transition("turn_handle_death", "turn_decision_player", func(): return !BattleManager.get_is_blocked())
	
	goto_state("turn_decision_player")
	
	# _process(1)

func _process(delta: float) -> void:
	# print("hello")
	super._process(delta)
	
func _exit_tree() -> void:
	print("exit tree")
