extends Node

## The battle manager holds important state about the battle

enum Affiliation { PLAYER, ENEMY }

const MAX_TURNS: int = 15 # 5

var participants: Array[BattleParticipant]

signal on_battle_started
signal on_battle_pre_setup_complete
signal on_battle_ui_setup_requested
# signal on_player_party_ui_setup_requested
signal on_battle_finished
signal on_message_requested(message: String, duration: float)
signal on_battle_effect_applied(effect: BattleEffect)
signal on_battle_turn_manipulation(turn_manipulations: Array[BattleTurn.TurnManipulation])
signal on_battle_ability_execute(turn_uid: int, ability_execution_info: AbilityExecution)
# signal on_battle_ability_prepare_start(ability: BattleAbility, turn_manipulations: Array[BattleTurn.TurnManipulation])
# signal on_battle_ability_prepare_cancel(ability: BattleAbility, turn_manipulations: Array[BattleTurn.TurnManipulation])
signal on_battle_fx_requested(effect_prototype: PackedScene, target: BattleParticipant)
signal on_battle_fx_stop_requested(effect_prototype: PackedScene, target: BattleParticipant)
signal on_battle_animation_requested(anim_id: StringName, target: BattleParticipant)
signal on_request_show_battle_menu(participant: BattleParticipant, battle_turn: BattleTurn)
signal on_request_out_of_combat_menu()
signal on_request_hide_battle_menu()
signal on_battle_participant_removed(participant: BattleParticipant)
signal on_battle_turns_updated(turns: Array[BattleTurn])

# todo: just make these public?
var _turns: Array[BattleTurn]
var _battle_time: float = 0
var _battle_start_time: float = 0 # this will be 0, except for in some challenges
var _state_machine: FSMBattle
var _encounter_group_id
var _current_battle_rewards: Dictionary[StringName, int]

var _challenge_mode_level_id: StringName
var _challenge_number: int

## FSM
func block_fsm(time: float) -> void:
	_state_machine.start_blocking_timer(time)

## State getters
func get_encounter_group_id() -> StringName:
	return _encounter_group_id
	
func get_challenge_mode_level_id() -> StringName:
	return _challenge_mode_level_id
	
func set_challenge_number(in_challenge_number: int) -> void:
	_challenge_number = in_challenge_number
	
func get_challenge_number() -> int:
	return _challenge_number
	
func is_challenge_mode() -> bool:
	return _challenge_mode_level_id != &""

func get_participants() -> Array[BattleParticipant]:
	return participants

func get_participant(uid: StringName) -> BattleParticipant:
	var index := participants.find_custom((func(participant): return participant.uid == uid))
	return participants[index]
	
var _is_forcing_lose := false
func force_lose() -> void:
	_is_forcing_lose = true
	
func get_is_forcing_lose() -> bool:
	return _is_forcing_lose
	
# TODO: Cache this instead of filtering each time it's called
func get_enemies() -> Array[BattleParticipant]:
	# var filter_enemies := func(participant: BattleParticipant) -> bool:
	# 	return participant.affiliation == BattleManager.Affiliation.ENEMY
	# return BattleManager.participants.filter(filter_enemies)

	return BattleManager.participants.filter(func(participant: BattleParticipant) -> bool:
		return participant.affiliation == BattleManager.Affiliation.ENEMY)

# TODO: Cache this instead of filtering each time it's called
func get_players() -> Array[BattleParticipant]:
	return BattleManager.participants.filter(func(participant: BattleParticipant) -> bool:
		return participant.affiliation == BattleManager.Affiliation.PLAYER)

## Loading and setting up participants
var _is_finished_setting_up_participants := false
func get_is_finished_setting_up_participants() -> bool:
	return _is_finished_setting_up_participants

func set_is_finished_setting_up_participants(value: bool) -> void:
	_is_finished_setting_up_participants = value
	
func get_rewards() -> Dictionary[StringName, int]:
	return _current_battle_rewards

## UI
var _ui_battle_fade_is_complete := false
func get_ui_battle_fade_is_complete() -> bool:
	return _ui_battle_fade_is_complete

func set_battle_fade_complete(value: bool) -> void:
	_ui_battle_fade_is_complete = value

func request_battle_ui_setup() -> void:
	on_battle_ui_setup_requested.emit()

func request_show_battle_menu() -> void:
	on_request_show_battle_menu.emit(get_current_turn_participant(), _current_turn)

func request_hide_battle_menu() -> void:
	on_request_hide_battle_menu.emit()
	
func request_out_of_combat_menu() -> void:
	on_request_out_of_combat_menu.emit()
	
# Message UI
func request_message(message: String, duration: float) -> void:
	on_message_requested.emit(message, duration);

## Ability queueing
class AbilityExecution:
	var ability: BattleAbility
	var target: BattleParticipant
	var turn_target: BattleTurn

	func _init(in_ability: BattleAbility, in_target: BattleParticipant, in_turn_target: BattleTurn = null) -> void:
		ability = in_ability
		target = in_target
		turn_target = in_turn_target

	func execute() -> void:
		ability.execute(target, turn_target)

var _queued_ability_execution: AbilityExecution
func queue_ability_execution(in_ability: BattleAbility, in_target: BattleParticipant, in_turn_target: BattleTurn = null) -> void:
	_queued_ability_execution = AbilityExecution.new(in_ability, in_target, in_turn_target)
	
func has_queued_ability() -> bool:
	return _queued_ability_execution != null

func has_executing_ability() -> bool:
	return _queued_ability_execution and _queued_ability_execution.ability.get_is_executing()

func execute_queued_ability() -> void:
	_current_turn.ability_execution_info = _queued_ability_execution
	_queued_ability_execution.execute()
	on_battle_ability_execute.emit(_current_turn.uid, _queued_ability_execution)
	
func clear_queued_ability() -> void:
	_queued_ability_execution = null
	
func prepare_ability(in_ability: BattleAbility, in_target: BattleParticipant, in_turn_target: BattleTurn = null) -> void:
	in_ability.prepare(in_target, in_turn_target)

func cancel_ability(in_ability: BattleAbility) -> void:
	in_ability.cancel()
	
func cancel_prepare_ability(in_ability: BattleAbility) -> void:
	in_ability.cancel_prepare()
	
func execute_ability_out_of_combat(in_ability: BattleAbility, in_source: BattleParticipant, in_target: BattleParticipant) -> void:
	in_ability.execute_out_of_combat(in_source, in_target)
	
## FX Management
func play_fx(effect_prototype: PackedScene, target: BattleParticipant):
	on_battle_fx_requested.emit(effect_prototype, target)
	
func stop_fx(effect_prototype: PackedScene, target: BattleParticipant):
	on_battle_fx_stop_requested.emit(effect_prototype, target)
	
## Animation Management
func play_animation(anim_id: StringName, target: BattleParticipant):
	on_battle_animation_requested.emit(anim_id, target)
	
## Particpant Management
func add_participant(participant: BattleParticipant) -> void:
	participants.push_back(participant)

func kill_participant(participant: BattleParticipant) -> void:
	participants.erase(participant)
	_turns = _turns.filter(func(turn: BattleTurn): return turn.participant != participant)
	on_battle_participant_removed.emit(participant)
	on_battle_turns_updated.emit(_turns)
	PlayerPartyManager.remove_player_if_exists(participant)
	
	if participant.affiliation == Affiliation.ENEMY:
		_current_battle_rewards.get_or_add(&"gold", 0)
		_current_battle_rewards[&"gold"] += participant.generate_gold_reward()

## Turn Management
func set_battle_start_time(in_battle_start_time: float) -> void:
	# _battle_start_time = in_battle_start_time
	_battle_time = in_battle_start_time

var _current_turn: BattleTurn
var _last_actual_turn_time_for_participant: Dictionary[BattleParticipant, float]
func goto_next_turn() -> void:
	if _turns.front() == _current_turn:
		_turns.pop_front()
		
	_current_turn = _turns.front()
	_last_actual_turn_time_for_participant[_current_turn.participant] = _current_turn.time
	_battle_time = _current_turn.time
	
	_build_turns_list(MAX_TURNS - _turns.size())
	on_battle_turns_updated.emit(_turns)

func get_current_turn() -> BattleTurn:
	return _current_turn

func get_current_turn_participant() -> BattleParticipant:
	return _current_turn.participant
	
func get_turn_with_uid(turn_uid: int) -> BattleTurn:
	var index = BattleManager._turns.find_custom(func(turn): return turn.uid == turn_uid)
	if index != -1:
		return _turns[index]
	return null
	
func get_next_turn_for_participant(participant: BattleParticipant) -> BattleTurn:
	var index := _turns.find_custom(func(turn: BattleTurn): return turn.participant == participant and turn != _current_turn)
	return _turns[index]
	
func get_next_normal_turn_for_participant(participant: BattleParticipant) -> BattleTurn:
	var index := _turns.find_custom(func(turn: BattleTurn): return turn.participant == participant and turn != _current_turn and turn.get_modifier().type == BattleTurn.TurnModifier.Type.NORMAL)
	return _turns[index]
	
func get_turns_for_participant(participant: BattleParticipant) -> Array[BattleTurn]:
	return _turns.filter(func(turn: BattleTurn): return turn.participant == participant)
	
func force_update_turns():
	on_battle_turns_updated.emit(_turns)
	
## Test functions
func test_get_random_enemy() -> BattleParticipant:
	return participants.filter(func(participant): return participant.affiliation == Affiliation.ENEMY).pick_random()
	
func test_get_player() -> BattleParticipant:
	return participants.filter(func(participant): return participant.affiliation == Affiliation.PLAYER).pick_random()

# turn generation
# todo: support fallback time for units that come into battle mid-way
func insert_turn(new_turn: BattleTurn) -> void:
	var index := _turns.find_custom(func(turn): return turn.time > new_turn.time)
	if index == -1:
		_turns.push_back(new_turn)
	else:
		_turns.insert(index, new_turn)
	
	# This function is doing insertion sort, so no need to call `_sort_turns()`
	_sort_turns()
	on_battle_turns_updated.emit(_turns)
	
func remove_turn(turn: BattleTurn) -> void:
	_turns.erase(turn)
	on_battle_turns_updated.emit(_turns)
	
func recalculate_all_turn_times(participant: BattleParticipant, turn_manipulation_anim: StringName = &"") -> void:
	recalculate_normal_turn_times(participant, turn_manipulation_anim)
	recalculate_linked_turn_times(participant, turn_manipulation_anim)
	
func recalculate_normal_turn_times(participant: BattleParticipant, turn_manipulation_anim: StringName = &"") -> void:
	var last_turn_time := _last_actual_turn_time_for_participant.get(participant, 0.0) as float
	
	var period := participant.get_turn_period()
	
	var participant_normal_turns = _turns.filter(func(turn):
		return turn.participant == participant and turn.turn_type == BattleTurn.TurnType.NORMAL and turn != _current_turn
	)
		
	for turn: BattleTurn in participant_normal_turns:
		turn.time = max(_battle_time,  last_turn_time + period)
		last_turn_time = turn.time
	
	_sort_turns()
	on_battle_turns_updated.emit(_turns)
	
	if turn_manipulation_anim:
		var turn_manipulation := BattleTurn.TurnManipulation.new()
		turn_manipulation.turns = participant_normal_turns
		turn_manipulation.anim_name = turn_manipulation_anim
		turn_manipulation.type = BattleTurn.TurnManipulation.Type.RECALCULATE
		BattleManager.on_battle_turn_manipulation.emit([turn_manipulation])

func recalculate_linked_turn_times(participant: BattleParticipant, turn_manipulation_anim: StringName =  &"") -> void:
	var participant_linked_turns = _turns.filter(func(turn):
		return turn.participant == participant and turn.turn_type == BattleTurn.TurnType.LINKED and turn != _current_turn
	)
	
	for turn: BattleTurn in participant_linked_turns:
		turn.time = turn.linked_turn.time + turn.time_offset_from_linked_turn
		
	_sort_turns()
	on_battle_turns_updated.emit(_turns)
	
	if turn_manipulation_anim:
		var turn_manipulation := BattleTurn.TurnManipulation.new()
		turn_manipulation.turns = participant_linked_turns
		turn_manipulation.anim_name = turn_manipulation_anim
		turn_manipulation.type = BattleTurn.TurnManipulation.Type.RECALCULATE
		BattleManager.on_battle_turn_manipulation.emit([turn_manipulation])

func _sort_turns() -> void:
	# todo: support "linked turns" (turns that have time relative to another turn. e.g. repeated turns)
	_turns.sort_custom(func(a, b): return a.time < b.time)

func _get_next_normal_turn_time(participant: BattleParticipant) -> float:
	var _participant_turns = _turns.filter(func(turn: BattleTurn):
		return turn.participant == participant and turn.turn_type == BattleTurn.TurnType.NORMAL
	)
	# if !_participant_turns.is_empty():

	var last_participant_turn: BattleTurn = _participant_turns.back() if !_participant_turns.is_empty() else null
	var period := participant.get_turn_period()
	
	# Support for nuking participant from turns list and recalculating mid-battle. Maybe don't do it this way:
	# if is_instance_valid(last_participant_turn):
	# 	return last_participant_turn.time + period
	# elif _last_actual_turn_time_for_participant.has(participant):
	# 	_last_actual_turn_time_for_participant[participant] + period
	# 	return last_participant_turn.time + period if last_participant_turn else period
	# 	period
	# else
	# 	period
	
	if is_instance_valid(last_participant_turn):
		return last_participant_turn.time + period
	else:
		return _last_actual_turn_time_for_participant.get(participant, 0.0) + period
		
	# return last_participant_turn.time + period if last_participant_turn else period

	# return 0

func _generate_normal_turn(time: float, participant: BattleParticipant):
	# var last_participant_turn: BattleTurn = _turns.filter(func(turn: BattleTurn): return turn.participant == participant).back()
	# var period := participant.get_turn_period()
	# var time := last_participant_turn.time + period if last_participant_turn else period
	var participant_index := participants.find(participant)
	const time_stagger := 0.05
	time += participant_index * time_stagger
	
	_turns.push_back(BattleTurn.new(time, participant, BattleTurn.TurnType.NORMAL))
	_sort_turns()
	on_battle_turns_updated.emit(_turns)

var _participant_next_turn_time: Dictionary[BattleParticipant, float]
func _build_turns_list(num_turns: int):
	# var filter_func = func(battle_turn: BattleTurn) -> bool:
	# 	return battle_turn.turn_type != BattleTurn.TurnType.NORMAL
	# _turns.filter(filter_func)
	
	if num_turns == 0:
		return

	_participant_next_turn_time.clear()
	for participant in participants:
		_participant_next_turn_time[participant] = _get_next_normal_turn_time(participant) # participant.get_turn_period()

	var find_soonest_participant = func():
		var lowest_score := 10000.0
		var soonest_participant: BattleParticipant
		for participant in _participant_next_turn_time:
			var score = _participant_next_turn_time[participant]
			if score < lowest_score:
				soonest_participant = participant
				lowest_score = score
		return soonest_participant

	for i in range(num_turns):
		var soonest_participant = find_soonest_participant.call()
		_generate_normal_turn(_participant_next_turn_time[soonest_participant], soonest_participant)
		_participant_next_turn_time[soonest_participant] += soonest_participant.get_turn_period()
		
func setup_battle(in_encounter_group_id: StringName):
	# _test_add_participants()
	# _build_turns_list(MAX_TURNS)
	DungeonManager.set_player_input_blocked_reason(&"battle", true)

	_battle_time = 0.0
	_battle_start_time = 0.0
	_current_turn = null
	_last_actual_turn_time_for_participant.clear()
	
	_encounter_group_id = in_encounter_group_id
	_challenge_mode_level_id = &""
	
	_is_finished_setting_up_participants = false
	_ui_battle_fade_is_complete = false

	_state_machine = FSMBattle.new()
	_state_machine.on_state_entered.connect(_on_state_entered)
	_state_machine.on_state_exited.connect(_on_state_exited)
	add_child(_state_machine)
	_state_machine.start()

	on_battle_started.emit()
	
func setup_challenge_mode_battle(in_challenge_mode_level_id: StringName):
	DungeonManager.set_player_input_blocked_reason(&"battle", true)
	
	_battle_time = 0.0
	_battle_start_time = 0.0
	_current_turn = null
	_last_actual_turn_time_for_participant.clear()
	
	_encounter_group_id = &""
	_challenge_mode_level_id = in_challenge_mode_level_id 
	
	_is_finished_setting_up_participants = false
	_ui_battle_fade_is_complete = false

	_state_machine = FSMBattle.new()
	_state_machine.on_state_entered.connect(_on_state_entered)
	_state_machine.on_state_exited.connect(_on_state_exited)
	add_child(_state_machine)
	_state_machine.start()

	on_battle_started.emit()

func finish_battle():
	DungeonManager.set_player_input_blocked_reason(&"battle", false)
	
	_turns.clear()
	participants.clear()
	_state_machine.queue_free()
	_current_battle_rewards.clear()
	on_battle_finished.emit()
	_is_forcing_lose = false

func complete_pre_setup():
	_build_turns_list(MAX_TURNS)
	
	while _turns.front().time < _battle_time:
		_turns.pop_front()
	
	_build_turns_list(MAX_TURNS - _turns.size())
	
	on_battle_pre_setup_complete.emit()

func _on_state_entered(id: StringName) -> void:
	if id == &"turn_decision_player":
		pass
		# on_battle_player_turn_started.emit(get_current_turn_participant(), _current_turn)

func _on_state_exited(id: StringName) -> void:
	pass
	# if id == &"turn_decision_player":
	# 	on_battle_player_turn_ended.emit(get_current_turn_participant())

func _process(_delta: float) -> void:
	pass
	# if Input.is_action_just_pressed(&"ui_left"):
	# 	PlayerPartyManager.inventory.add_item(&"potion")
	# 	PlayerPartyManager.inventory.add_item(&"dud")
	
func _ready() -> void:
	# hacky hack hack
	# preload("res://game/participants/enemies/enemy_goblin.tres")
	# preload("res://game/participants/player/player_base.tres")
	print("debug buld:", OS.is_debug_build())
	pass
# 	_setup_battle()
