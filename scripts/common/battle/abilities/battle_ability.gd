class_name BattleAbility extends Resource

var _ability_id: StringName
var _source: BattleParticipant
var _target: BattleParticipant
var _turn_target: BattleTurn
var _is_executing := false
var _consumable_item_id: StringName
# var _valid_targets: Array[BattleParticipant]

signal on_end()

# TODO: Find some way of statically typing this. Is it possible?
@export var fx_activate: PackedScene
@export var fx_affect_target: PackedScene
@export var sp_cost: int = 0

static var ability_class_registry: Dictionary[StringName, String] = {
	# Common
	&"attack": "res://game/abilities/ability_attack.tres",
	&"pass": "res://game/abilities/ability_pass.tres",

	# Chronomancer
	&"haste" : "res://game/abilities/ability_haste.tres",
	&"slow" : "res://game/abilities/ability_slow.tres",
	&"skip_turn" : "res://game/abilities/ability_skip_turn.tres",
	&"skip_many_turns" : "res://game/abilities/ability_skip_many_turns.tres",
	&"repeat_turn" : "res://game/abilities/ability_repeat_turn.tres",
	
	# Warrior
	&"power_charge": "res://game/abilities/ability_power_charge.tres",
	&"power_charge_attack": "res://game/abilities/ability_power_charge_attack.tres",

	# Misc
	&"repeating_turn" : "res://game/abilities/ability_repeating_turn.tres",
	
	# Items
	&"potion" : "res://game/abilities/ability_potion.tres",

	# Debug
	&"nuke": "res://game/abilities/ability_nuke.tres",
	&"extra_turn": "res://game/abilities/ability_extra_turn.tres",
	
	# Challenge Scaredy Cat
	&"run_away": "res://game/abilities/ability_run_away.tres",
	&"scaredy_cat_run": "res://game/abilities/ability_scaredy_cat_run.tres",
	
	# Challenge Smasher
	&"smasher_smash": "res://game/abilities/ability_smasher_smash.tres",
	
	# Challenge Grim Reaper
	&"grim_reaper_kill": "res://game/abilities/ability_grim_reaper_kill.tres",
}

static var ability_categories: Dictionary[StringName, StringName] = {
	# Common
	&"attack": &"",
	&"pass": &"",

	# Chronomancer
	&"haste": &"magic",
	&"slow": &"magic",
	&"skip_turn": &"magic",
	&"skip_many_turns": &"magic",
	
	# Warrior
	&"power_charge": &"",
	&"power_charge_attack": &"",
	
	# Misc
	&"repeat_turn": &"magic",
	
	# Items
	&"potion" : &"item",

	# Debug
	&"nuke": &"debug",
	&"extra_turn": &"debug",

	# Forced
	&"repeating_turn": &"",
	
	# Challenge Scaredy Cat
	&"run_away": &"",
	&"scaredy_cat_run": &"",
}

# TODO: Right now there is an assumption that the only execution context 
# needed is an optional `_target`. There might be a more comprehensive struct
# implemented later
func execute(in_target: BattleParticipant, in_turn_target: BattleTurn = null) -> void:
	_target = in_target
	_turn_target = in_turn_target
	
	_is_executing = true
	
	# todo: make player not consume resources if their turn is being repeated
	consume_resources()
	
	# all abilities: shrink current turn
	var turn_manipulation := BattleTurn.TurnManipulation.new()
	turn_manipulation.turns = [BattleManager.get_current_turn()]
	turn_manipulation.anim_name = &"shrink"
	turn_manipulation.type = BattleTurn.TurnManipulation.Type.REMOVE
	BattleManager.on_battle_turn_manipulation.emit([turn_manipulation])
	
func execute_out_of_combat(_in_source: BattleParticipant, _in_target: BattleParticipant) -> void:
	consume_resources()
	
func can_execute_out_of_combat() -> bool:
	return false

func prepare(in_target: BattleParticipant, in_turn_target: BattleTurn = null) -> void:
	_target = in_target
	_turn_target = in_turn_target
	print(" - Preparing %s..." % resource_name)
	
	# todo: queue turn stuff
	# BattleManager.on_battle_ability_prepare_start.emit(self)
	
func cancel() -> void:
	_target = null
	print(" - Canceling Prepare %s!" % resource_name)
	
	# BattleManager.on_battle_ability_prepare_end.emit(self)
	
func cancel_prepare() -> void:
	pass

func end() -> void:
	_is_executing = false
	on_end.emit()

func get_is_executing() -> bool:
	return _is_executing
	
# This function must be subclassed and return true for valid targets
func is_valid_for_target(_possible_target: BattleParticipant) -> bool:
	return true
	
func requires_turn_target() -> bool:
	return false
	
func get_message() -> String:
	return ""
	
func get_display_name() -> String:
	if _consumable_item_id == &"":
		return _ability_id
		
	var consumable_item_count = PlayerPartyManager.inventory.items.get(_consumable_item_id, 0)
	return "%s (x%d)" % [_ability_id, consumable_item_count]
	
# This handles case where turn is repeated, but the original target is no longer valid
# return in format: [target: Participant, turn_target: BattleTurn]
func find_fallback_target() -> Array:
	return []

# Returns whether this ability can currently activate
func can_activate() -> bool:
	if sp_cost > 0 and sp_cost > _source.get_attribute(&"_sp"):
		return false
		
	if requires_turn_target():
		return true
		
	for participant in BattleManager.get_participants():
		if is_valid_for_target(participant):
			return true
			
	return false
	
func is_hidden() -> bool:
	if _consumable_item_id == &"":
		return false
		
	return !PlayerPartyManager.inventory.items.has(_consumable_item_id)

# Helper function for calling a callable after a certain amount of time
func set_timer(time: float, callable: Callable) -> void:
	var timer := BattleManager.get_tree().create_timer(time)
	timer.timeout.connect(callable)

# Helper function for ending ability after certain amount of time
func set_lifetime(lifetime: float) -> void:
	set_timer(lifetime, end)

func initialize(in_source: BattleParticipant, in_ability_id: StringName) -> void:
	_source = in_source
	_ability_id = in_ability_id

func show_message(time: float = 1.1) -> void:
	BattleManager.request_message(get_message(), time)
	
func consume_resources() -> void:
	consume_sp()
	if _consumable_item_id != &"":
		PlayerPartyManager.inventory.remove_item(_consumable_item_id)
		
func has_enough_resources() -> bool:
	if sp_cost > 0:
		return _source.get_attribute(&"_sp") >= 0
	elif _consumable_item_id != &"":
		return PlayerPartyManager.inventory.get_item_count(_consumable_item_id) > 0
	else:
		return true
	
class BattleEffectConsumeSP extends BattleEffect:
	func _init(in_source: BattleParticipant, in_target: BattleParticipant, sp_cost: int) -> void:
		super._init(in_source, in_target)
		_duration = Duration.INSTANT
		_modifiers.append(BattleEffectModifier.new(&"_sp", -sp_cost, Operator.ADDITIVE))
	
func consume_sp() -> void:
	var effect := BattleEffectConsumeSP.new(_source, _source, sp_cost)
	effect.apply()
