class_name BattleTurn extends Node

class TurnModifier:
	enum Type { NORMAL, SKIP, REPEAT, MID_BLOOD_RITUAL, POWER_CHARGE_ATTACK }
	
	var disallowed_ability_ids: Array[StringName]
	var forced_ability_id: StringName
	var only_allow_these_ability_ids: Array[StringName]
	var type: Type
	
	func is_ability_allowed(ability_id: StringName) -> bool:
		if disallowed_ability_ids.has(ability_id):
			return false
			
		if !only_allow_these_ability_ids.is_empty() and !only_allow_these_ability_ids.has(ability_id):
			return false
			
		return true
	
	func _init(in_only_allow_these_ability_ids: Array[StringName], in_disallowed_ability_ids: Array[StringName], in_forced_ability_id: StringName, in_type: Type):
		only_allow_these_ability_ids = in_only_allow_these_ability_ids
		disallowed_ability_ids = in_disallowed_ability_ids
		forced_ability_id = in_forced_ability_id
		type = in_type
		
class TurnModifierNormal extends TurnModifier:
	func _init():
		super._init([], [&"repeating_turn"], &"", TurnModifier.Type.NORMAL)
		
class TurnModifierSkip extends TurnModifier:
	func _init():
		super._init([], [], &"pass", TurnModifier.Type.SKIP)
		
class TurnModifierRepeat extends TurnModifier:
	var turn_uid_to_repeat: int
	var ability_execution_info: BattleManager.AbilityExecution
	
	func on_battle_ability_execute(turn_uid: int, in_ability_execution_info: BattleManager.AbilityExecution):
		if turn_uid == turn_uid_to_repeat:
			ability_execution_info = in_ability_execution_info
	
	func _init():
		super._init([], [], &"repeating_turn", TurnModifier.Type.REPEAT)
		BattleManager.on_battle_ability_execute.connect(on_battle_ability_execute)
		
class TurnModifierPowerCharge extends TurnModifier:
	func _init():
		super._init([&"power_charge_attack"], [], &"", TurnModifier.Type.POWER_CHARGE_ATTACK)
	
	# func _ready():
	# 	BattleManager.on_battle_ability_execute.connect(on_battle_ability_execute)
	
# static var TurnModifierNormal := TurnModifier.new([], [&"repeat_turn"], TurnModifier.Type.NORMAL)
# static var TurnModifierSkip := TurnModifier.new([&"pass"], [], TurnModifier.Type.SKIP)
# static var TurnModifierRepeat := TurnModifier.new([], [], TurnModifier.Type.REPEAT)
# static var TurnModifierMidBloodRitual := TurnModifier.new([], [], TurnModifier.Type.MID_BLOOD_RITUAL)
# static var TurnModifierPowerChargeAttack := TurnModifier.new([], [], TurnModifier.Type.POWER_CHARGE_ATTACK)

# blood ritual, power charge change what you can do (enable/disable abilities)
# skip, repeat do something automatically for you
# - can implement this behaviour as "change what you can do" for now

enum TurnType 
{
	NORMAL,		# Turn time will be recalculated based on agility
	LINKED,		# Turn time will be recalculated as offset from linked turn's time
}

var uid: int
var time: float
var participant: BattleParticipant
var turn_type: TurnType
var turn_modifier: TurnModifier
var linked_turn: BattleTurn
var time_offset_from_linked_turn: float
var ability_execution_info: BattleManager.AbilityExecution

func get_affiliation() -> BattleManager.Affiliation:
	return participant.affiliation
	
func is_ability_allowed(ability_id: StringName) -> bool:
	return !is_instance_valid(turn_modifier) or turn_modifier.is_ability_allowed(ability_id)

static var uid_count: int = 0
func _init(in_time: float, in_participant: BattleParticipant, in_turn_type: TurnType):
	uid = uid_count
	uid_count += 1
	time = in_time
	participant = in_participant
	turn_type = in_turn_type
	turn_modifier = TurnModifierNormal.new()
	
func _to_string() -> String:
	return "T: %7.1f, %10s" % [time, participant]

class TurnManipulation:
	# todo: remove this
	enum Type { CREATE, REMOVE, RECALCULATE }

	var turns: Array[BattleTurn]
	var anim_name: StringName
	var type: Type
