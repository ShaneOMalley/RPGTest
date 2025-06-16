class_name BattleParticipant extends Node

var hp: int
var mp: int
var affiliation: BattleManager.Affiliation
# todo: pull stats from data asset
var participant_name: String
var strength: int
var magic: int
var agility: int
var vitality: int

# todo: make this scale with enemies somehow?
func get_turn_period() -> float:
	# return 25 - agility ** 0.7
	return 30 - agility

func _process(_delta: float):
	pass

func _to_string() -> String:
	return "「%s」" % participant_name
