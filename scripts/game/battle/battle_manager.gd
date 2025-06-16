extends Node

enum Affiliation { PLAYER, ENEMY }

const MAX_TURNS = 20

var participants: Array[BattleParticipant]
var turns: Array[BattleTurn]

func _generate_normal_turn(order: float, participant: BattleParticipant):
	turns.push_back(BattleTurn.new(order, participant, BattleTurn.TurnType.NORMAL))
	
var _participant_frequency_tracker: Dictionary[BattleParticipant, float]

func build_turns_list():
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

func _test() -> void:
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

	build_turns_list()

	for turn in turns:
		print(turn.to_string())
	
func _ready() -> void:
	_test()
