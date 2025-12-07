class_name BattleParticipant extends Node

var affiliation: BattleManager.Affiliation
var config_id: StringName
var uid: StringName

var abilities: Dictionary[StringName, BattleAbility]
var active_effects: Array[BattleEffect]

# Instant Attributes: Should only be affected by INSTANT effects
var _hp: int
var _mp: int

# Duration Attributes: Should only be affected by DURATION effects
var _max_hp: int
var _max_mp: int
var _strength: int
var _magic: int
var _agility: int
var _vitality: int

var _gold_reward_min: int
var _gold_reward_max: int

# Attributes
func get_attribute(attribute_id: StringName) -> Variant:
	var base = get(attribute_id)
	
	assert(base != null, "%s has no attribute named \"%s\"" % [name, base])
	
	var multiplier = active_effects.reduce(func(accum, effect):
		var total_for_effect := 0.0
		
		for modifier in effect._modifiers:
			if modifier.attribute == attribute_id and modifier.operator == BattleEffect.Operator.MULTIPLY:
				total_for_effect += modifier.magnitude - 1.0
				
		return accum + total_for_effect
	, 1.0)
	
	var additive = active_effects.reduce(func(accum, effect):
		var total_for_effect := 0.0
		
		for modifier in effect._modifiers:
			if modifier.attribute == attribute_id and modifier.operator == BattleEffect.Operator.ADDITIVE:
				total_for_effect += modifier.magnitude
		return accum + total_for_effect
	, 0.0)
	
	return (base + additive) * multiplier
	
func add_effect(battle_effect: BattleEffect) -> void:
	active_effects.append(battle_effect)
	
func remove_effect(battle_effect: BattleEffect) -> void:
	active_effects.erase(battle_effect)
	
func remove_all_effects() -> void:
	active_effects.clear()

# todo: make this scale with enemies somehow?
func get_turn_period() -> float:
	# return 25 - agility ** 0.7
	return max(1,  30 - get_attribute(&"_agility"))
	
func generate_gold_reward() -> int:
	return randi_range(_gold_reward_min, _gold_reward_max)

func _process(_delta: float):
	pass

func _to_string() -> String:
	return "「%s」" % uid
	
func get_display_name() -> String:
	return config_id
	
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
	participant._max_hp = data.max_hp
	participant._hp = data.max_hp
	participant._max_mp = data.max_mp
	participant._mp = data.max_mp
	participant._strength = data.strength
	participant._magic = data.magic
	participant._agility = data.agility
	participant._vitality = data.vitality
	
	if data.has(&"gold_reward_min") and data.has(&"gold_reward_max"):
		participant._gold_reward_min = data.gold_reward_min
		participant._gold_reward_max = data.gold_reward_max
	else:
		participant._gold_reward_min = 0
		participant._gold_reward_max = 0

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
