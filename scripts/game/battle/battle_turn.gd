class_name BattleTurn extends Node

# todo: support restrictions in special turns. i.e. power up -> generate turn where you can only attack

enum TurnType 
{
	NORMAL,		# Turn time uill be recalculated based on agility
	SPECIAL,	# Turn time uill not be recalculated
}

# skip, duplicate, mid blood ritual, power charge only attack

class TurnModifier:
	enum Type { NORMAL, SKIP, DUPLICATE, MID_BLOOD_RITUAL, POWER_CHARGE_ATTACK }
	
	var disallowed_ability_ids: Array[StringName]
	var only_allow_these_ability_ids: Array[StringName]
	var type: Type
	
	func is_ability_allowed(ability_id: StringName) -> bool:
		if disallowed_ability_ids.has(ability_id):
			return false
			
		if !only_allow_these_ability_ids.is_empty() and !only_allow_these_ability_ids.has(ability_id):
			return false
			
		return true
	
	func _init(in_only_allow_these_ability_ids: Array[StringName], in_disallowed_ability_ids: Array[StringName], in_type: Type):
		only_allow_these_ability_ids = in_only_allow_these_ability_ids
		disallowed_ability_ids = in_disallowed_ability_ids
		type = in_type
		
static var TurnModifierPass := TurnModifier.new([&"pass"], [], TurnModifier.Type.SKIP)
# static var TurnModifierDuplicate := TurnModifier.new([], [], TurnModifier.Type.DUPLICATE)
# static var TurnModifierMidBloodRitual := TurnModifier.new([], [], TurnModifier.Type.MID_BLOOD_RITUAL)
# static var TurnModifierPowerChargeAttack := TurnModifier.new([], [], TurnModifier.Type.POWER_CHARGE_ATTACK)

# blood ritual, power charge change what you can do (enable/disable abilities)
# skip, duplicate do something automatically for you
# - can implement this behaviour as "change what you can do" for now

var uid: int
var time: float
var participant: BattleParticipant
var turn_type: TurnType
var turn_modifier: TurnModifier

func get_affiliation() -> BattleManager.Affiliation:
	return participant.affiliation
	
func is_ability_allowed(ability_id: StringName) -> bool:
	print("thing!! ")
	print(is_instance_valid(turn_modifier))
	return !is_instance_valid(turn_modifier) or turn_modifier.is_ability_allowed(ability_id)

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
