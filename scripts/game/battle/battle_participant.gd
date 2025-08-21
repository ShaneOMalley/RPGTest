class_name BattleParticipant extends Node

var max_hp: int
var hp: int
var max_mp: int
var mp: int
var affiliation: BattleManager.Affiliation
# todo: pull stats from data asset
var config_id: StringName
var uid: StringName
var strength: int
var magic: int
var agility: int
var vitality: int

var abilities: Dictionary[StringName, BattleAbility]

# todo: make this scale with enemies somehow?
func get_turn_period() -> float:
	# return 25 - agility ** 0.7
	return 30 - agility

func _process(_delta: float):
	pass

func _to_string() -> String:
	return "「%s」" % uid

static var config_id_counters: Dictionary[StringName, int]
static func create_unique_id(in_config_id: StringName) -> StringName:
	var previous_count = config_id_counters.get_or_add(in_config_id, 0)
	config_id_counters[in_config_id] = previous_count + 1
	return "%s_%d" % [in_config_id, previous_count]

static func clear_unique_id_counters() -> void:
	config_id_counters.clear()

const config_path: String = "res://res/data/battle_characters.json"
static func create_from_config(in_config_id: StringName) -> BattleParticipant:
	# TODO: Don't read JSON file and parse every time
	var file := FileAccess.open(config_path, FileAccess.READ)
	var json = JSON.parse_string(file.get_as_text()) 
	var data = json[in_config_id]

	var participant := BattleParticipant.new();
	participant.config_id = in_config_id
	participant.uid = create_unique_id(in_config_id)
	participant.max_hp = data.max_hp
	participant.hp = data.max_hp
	participant.max_mp = data.max_mp
	participant.mp = data.max_mp
	participant.strength = data.strength
	participant.magic = data.magic
	participant.agility = data.agility
	participant.vitality = data.vitality

	if data.abilities:
		for ability_id in data.abilities:
			var ability_resource_path := BattleAbility.ability_class_registry[ability_id]
			# This is smelly. It would be better to refactor so that resources are read-only, and there is a separate "instance" ("spec" in GAS terminology)
			var ability = load(ability_resource_path).duplicate() as BattleAbility
			ability.initialize(participant)
			participant.abilities[ability_id] = ability

	return participant

# static func load_participants_async(in_ids: Array[StringName]) -> Callable: # -> Signal
static func load_participants_async(in_config_ids: Array[StringName], callback: Callable) -> void:
	var all_ability_paths: Dictionary[String, bool]

	for _id in in_config_ids:
		# TODO: Don't read JSON file and parse every time
		var file := FileAccess.open(config_path, FileAccess.READ)
		var json = JSON.parse_string(file.get_as_text()) 
		var data = json[_id]

		if data.abilities:
			for ability_id in data.abilities:
				var ability_resource_path := BattleAbility.ability_class_registry[ability_id]
				all_ability_paths[ability_resource_path] = true

	LoadHelper.load_multiple_async(all_ability_paths.keys(), callback)
