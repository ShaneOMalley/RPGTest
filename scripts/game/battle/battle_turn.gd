class_name BattleTurn extends Node

# todo: support restrictions in special turns. i.e. power up -> generate turn where you can only attack

enum TurnType { 
	NORMAL,		# Will be re-calculated
	SPECIAL,	# Will not be re-calculated
}

var time: float
var participant: BattleParticipant
var turn_type: TurnType

func _init(in_time: float, in_participant: BattleParticipant, in_turn_type: TurnType):
	time = in_time
	participant = in_participant
	turn_type = in_turn_type
	
func _to_string() -> String:
	return "Time: %6.1f, Participant %s" % [time, participant]
