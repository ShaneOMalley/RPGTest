extends Node

## The battle manager holds important state about the battle

enum Affiliation { PLAYER, ENEMY }

const MAX_TURNS = 20

var participants: Array[BattleParticipant]
var turns: Array[BattleTurn]
var battle_time: float = 0
var state_machine: FSMBattle

## generic blocking timer
var _is_blocked: bool
func start_blocking_timer(time: float) -> void:
	var timer := get_tree().create_timer(time)
	_is_blocked = true
	timer.timeout.connect(func(): self._is_blocked = false)
	
func get_is_blocked() -> bool:
	return _is_blocked

## ability queueing
var _queued_ability: BattleAbility
func queue_ability(in_queued_ability: BattleAbility) -> void:
	_queued_ability = in_queued_ability
	
func has_queued_ability() -> bool:
	return _queued_ability != null
	
func execute_queued_ability() -> void:
	_queued_ability.execute()

func _generate_normal_turn(time: float, participant: BattleParticipant):
	turns.push_back(BattleTurn.new(time, participant, BattleTurn.TurnType.NORMAL))
	
var _participant_frequency_tracker: Dictionary[BattleParticipant, float]

func test_get_random_enemy() -> BattleParticipant:
	return participants.filter(func(participant): return participant.affiliation == Affiliation.ENEMY).pick_random()

func _build_turns_list():
	var filter_func = func(battle_turn: BattleTurn) -> bool:
		return battle_turn.turn_type != BattleTurn.TurnType.NORMAL
	
	turns.filter(filter_func)

	_participant_frequency_tracker.clear()
	for participant in participants:
		_participant_frequency_tracker[participant] = participant.get_turn_period()

	var find_fastest_participant = func():
		var lowest_score := 10000
		var best_participant: BattleParticipant
		for participant in _participant_frequency_tracker:
			var score = _participant_frequency_tracker[participant]
			if score < lowest_score:
				best_participant = participant
				lowest_score = score
		return best_participant
	
	for i in range(MAX_TURNS):
		var fastest_participant = find_fastest_participant.call()
		_generate_normal_turn(_participant_frequency_tracker[fastest_participant], fastest_participant)
		_participant_frequency_tracker[fastest_participant] += fastest_participant.get_turn_period()

func _test_add_participants() -> void:
	var player = BattleParticipant.new()
	player.participant_name = "! Player"
	player.agility = 14

	var enemy_1 = BattleParticipant.new()
	enemy_1.participant_name = "Ghoul"
	enemy_1.agility = 7

	var enemy_2 = BattleParticipant.new()
	enemy_2.participant_name = "Goblin"
	enemy_2.agility = 8

	participants.push_back(player)
	participants.push_back(enemy_1)
	participants.push_back(enemy_2)

	for turn in turns:
		print(turn.to_string())
		
func _setup_battle():
	_test_add_participants()

	_build_turns_list()
	
	state_machine = FSMBattle.new()

func _cleanup_battle():
	state_machine.free()
	
func _ready() -> void:
	_setup_battle()
