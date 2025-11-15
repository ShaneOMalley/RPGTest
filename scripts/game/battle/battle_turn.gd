class_name BattleTurn extends Node

# todo: support restrictions in special turns. i.e. power up -> generate turn where you can only attack

enum TurnType { 
	NORMAL,		# Turn time uill be recalculated based on agility
	SPECIAL,	# Turn time uill not be recalculated
}

var uid: int
var time: float
var participant: BattleParticipant
var turn_type: TurnType

func get_affiliation() -> BattleManager.Affiliation:
	return participant.affiliation

static var uid_count: int = 0
func _init(in_time: float, in_participant: BattleParticipant, in_turn_type: TurnType):
	uid = uid_count
	uid_count += 1
	time = in_time
	participant = in_participant
	turn_type = in_turn_type
	
func _to_string() -> String:
	return "T: %7.1f, %10s" % [time, participant]

class TurnManipulation:
	# todo: remove this
	enum Type { CREATE, REMOVE, RECALCULATE }

	var turns: Array[BattleTurn]
	var anim_name: StringName
	var type: Type