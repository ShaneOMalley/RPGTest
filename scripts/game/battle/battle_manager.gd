extends Node

## The battle manager holds important state about the battle

enum Affiliation { PLAYER, ENEMY }

const MAX_TURNS: int = 5

var participants: Array[BattleParticipant]

signal on_battle_started
signal on_battle_effect_applied(BattleEffect)

# todo: just make these public?
var _turns: Array[BattleTurn]
# var _battle_time: float = 0
var _state_machine: FSMBattle
var _is_battle_active: bool = false

## state getters
func get_participants() -> Array[BattleParticipant]:
	return participants

func get_is_battle_active() -> bool:
	return _is_battle_active

# TODO: Cache this instead of filtering each time it's called
func get_enemies() -> Array[BattleParticipant]:
	# var filter_enemies := func(participant: BattleParticipant) -> bool:
	# 	return participant.affiliation == BattleManager.Affiliation.ENEMY
	# return BattleManager.participants.filter(filter_enemies)

	return BattleManager.participants.filter(func(participant: BattleParticipant) -> bool:
		return participant.affiliation == BattleManager.Affiliation.ENEMY)

# TODO: Cache this instead of filtering each time it's called
func get_player_party() -> Array[BattleParticipant]:
	return BattleManager.participants.filter(func(participant: BattleParticipant) -> bool:
		return participant.affiliation == BattleManager.Affiliation.PLAYER)

## generic blocking timer
# var _is_blocked: bool
# func start_blocking_timer(time: float) -> void:
# 	var timer := get_tree().create_timer(time)
# 	_is_blocked = true
# 	timer.timeout.connect(func(): self._is_blocked = false)
# 	
# func get_is_blocked() -> bool:
# 	return _is_blocked

## ability queueing
class AbilityExecution:
	var ability: BattleAbility
	var target: BattleParticipant

	func _init(in_ability: BattleAbility, in_target: BattleParticipant) -> void:
		ability = in_ability
		target = in_target

var _queued_ability_execution: AbilityExecution
func queue_ability(in_ability: BattleAbility, in_target: BattleParticipant) -> void:
	_queued_ability_execution = AbilityExecution.new(in_ability, in_target)
	
func has_queued_ability() -> bool:
	return _queued_ability_execution != null

func has_executing_ability() -> bool:
	return _queued_ability_execution and  _queued_ability_execution.ability.get_is_executing()

func execute_queued_ability() -> void:
	_queued_ability_execution.ability.execute(_queued_ability_execution.target)
	
func clear_queued_ability() -> void:
	_queued_ability_execution = null

## Turn Management
var _current_turn: BattleTurn
func goto_next_turn() -> void:
	_current_turn = _turns.pop_front()
	_build_turns_list(MAX_TURNS - _turns.size())

func get_current_turn() -> BattleTurn:
	return _current_turn
	
## test functions
func test_get_random_enemy() -> BattleParticipant:
	return participants.filter(func(participant): return participant.affiliation == Affiliation.ENEMY).pick_random()
	
func test_get_player() -> BattleParticipant:
	return participants.filter(func(participant): return participant.affiliation == Affiliation.PLAYER).pick_random()

func _test_add_participants() -> void:
	var player = BattleParticipant.new()
	player.id = "! Player"
	player.agility = 14
	player.strength = 10
	player.max_hp = 100
	player.hp = 100
	player.affiliation = Affiliation.PLAYER

	var enemy_1 = BattleParticipant.new()
	enemy_1.id = "Ghoul"
	enemy_1.agility = 7
	enemy_1.strength = 2
	enemy_1.max_hp = 20
	enemy_1.hp = 20
	enemy_1.affiliation = Affiliation.ENEMY
	
	var enemy_2 = BattleParticipant.new()
	enemy_2.id = "Goblin"
	enemy_2.agility = 8
	enemy_2.strength = 2
	enemy_2.max_hp = 17
	enemy_2.hp = 17
	enemy_2.affiliation = Affiliation.ENEMY

	participants.push_back(player)
	participants.push_back(enemy_1)
	participants.push_back(enemy_2)

	for turn in _turns:
		print(turn.to_string())
	
# turn generation
# todo: support fallback time for units that come into battle mid-way
func _get_next_normal_turn_time(participant: BattleParticipant):
	var last_participant_turn: BattleTurn = _turns.filter(func(turn: BattleTurn): return turn.participant == participant).back()
	var period := participant.get_turn_period()
	return last_participant_turn.time + period if last_participant_turn else period

func _generate_normal_turn(time: float, participant: BattleParticipant):
	# var last_participant_turn: BattleTurn = _turns.filter(func(turn: BattleTurn): return turn.participant == participant).back()
	# var period := participant.get_turn_period()
	# var time := last_participant_turn.time + period if last_participant_turn else period
	_turns.push_back(BattleTurn.new(time, participant, BattleTurn.TurnType.NORMAL))

var _participant_frequency_tracker: Dictionary[BattleParticipant, float]
func _build_turns_list(num_turns: int):
	# var filter_func = func(battle_turn: BattleTurn) -> bool:
	# 	return battle_turn.turn_type != BattleTurn.TurnType.NORMAL
	# _turns.filter(filter_func)

	_participant_frequency_tracker.clear()
	for participant in participants:
		_participant_frequency_tracker[participant] = _get_next_normal_turn_time(participant) # participant.get_turn_period()

	var find_fastest_participant = func():
		var lowest_score := 10000.0
		var best_participant: BattleParticipant
		for participant in _participant_frequency_tracker:
			var score = _participant_frequency_tracker[participant]
			if score < lowest_score:
				best_participant = participant
				lowest_score = score
		return best_participant
	
	for i in range(num_turns):
		var fastest_participant = find_fastest_participant.call()
		_generate_normal_turn(_participant_frequency_tracker[fastest_participant], fastest_participant)
		_participant_frequency_tracker[fastest_participant] += fastest_participant.get_turn_period()
		
func _setup_battle():
	_test_add_participants()

	# TODO: Maybe let this be done in a setup state?
	_build_turns_list(MAX_TURNS)
	
	_state_machine = FSMBattle.new()
	add_child(_state_machine)

	_is_battle_active = true
	on_battle_started.emit()

func _cleanup_battle():
	_state_machine.free()
	_is_battle_active = false

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_down"):
		_setup_battle()
	
# func _ready() -> void:
# 	_setup_battle()
