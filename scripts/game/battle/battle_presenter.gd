extends Node

var _previous_battle_turns: Array[BattleTurn]

# Setup
func on_battle_ui_setup_requested() -> void:
	BattleView.setup_battle_ui()

	var enemies := BattleManager.get_enemies()
	for enemy in enemies:
		BattleView.setup_enemy(enemy.uid, enemy.get_attribute(&"_hp"), enemy.get_attribute(&"_max_hp"))
		
	on_battle_turns_updated(BattleManager._turns)

func on_player_party_ui_setup_requested() -> void:
	BattleView.setup_player_party_ui()

	BattleView.hide_all_players_info()

	var players := PlayerPartyManager.get_participants()
	for player in players:
		BattleView.setup_player(player.uid, player.get_attribute(&"_hp"), player.get_attribute(&"_max_hp"))

func on_ui_setup_complete() -> void:
	BattleManager.set_ui_setup_is_complete(true)

# Tear Down
func on_battle_finished() -> void:
	_previous_battle_turns.clear()
	BattleView.destroy_battle_ui()

# Battle Abilities and Effects
func on_ability_prepare(ability_id: StringName, target_uid: StringName) -> void:
	var current_participant := BattleManager.get_current_turn_participant()
	var ability := current_participant.abilities[ability_id]
	var target := BattleManager.get_participant(target_uid)
	BattleManager.prepare_ability(ability, target)
	
func on_ability_cancel(ability_id: StringName) -> void:
	var current_participant := BattleManager.get_current_turn_participant()
	var ability := current_participant.abilities[ability_id]
	BattleManager.cancel_ability(ability)
	
func on_ability_cancel_prepare(ability_id: StringName) -> void:
	var current_participant := BattleManager.get_current_turn_participant()
	var ability := current_participant.abilities[ability_id]
	BattleManager.cancel_prepare_ability(ability)

func on_ability_and_target_selected(ability_id: StringName, target_uid: StringName) -> void:
	var current_participant := BattleManager.get_current_turn_participant()
	var ability := current_participant.abilities[ability_id]
	var target := BattleManager.get_participant(target_uid)
	BattleManager.queue_ability_execution(ability, target)

func on_battle_effect_applied(battle_effect: BattleEffect) -> void:
	var target = battle_effect.target

	# TODO: Make this happen somewhere else; don't assume that 0 health means removal
	if target.affiliation == BattleManager.Affiliation.ENEMY:
		BattleView.update_enemy_hp(target.uid, target.get_attribute(&"_hp"), target.get_attribute(&"_max_hp"))
	elif target.affiliation == BattleManager.Affiliation.PLAYER:
		BattleView.update_player_hp(target.uid, target.get_attribute(&"_hp"), target.get_attribute(&"_max_hp"))

	# print(battle_effect.to_string())
	
# weird bug where if I fully qualify second argument's type as `Array[BattleTurn.TurnManipulation]`, it doesn't call???
func on_battle_turn_manipulation(turn_manipulations: Array) -> void:
	for turn_manipulation in turn_manipulations:
		for turn in turn_manipulation.turns:
			BattleView.play_turn_animation(turn.uid, turn_manipulation.anim_name)

# Battle FX
func on_battle_fx_requested(effect_prototype: PackedScene, target: BattleParticipant) -> void:
	BattleView.play_oneshot_fx(effect_prototype, target.uid)

# Turns
func on_battle_turns_updated(turns: Array[BattleTurn]) -> void:
	if !is_instance_valid(BattleView.turns_ui):
		return
	
	for old_turn in _previous_battle_turns:
		if !turns.has(old_turn):
			BattleView.delete_turn(old_turn.uid)
	
	for new_turn in turns:
		if !_previous_battle_turns.has(new_turn):
			#var previous_turn_index := turns.find_custom(func(turn): return turn.time > new_turn.time)
			#var previous_turn_uid := turns[previous_turn_index].uid if previous_turn_index != -1 else -1
			#BattleView.add_turn(new_turn.uid, new_turn.participant.uid, new_turn.participant.affiliation, previous_turn_uid)
			# var turn_index := turns.find(new_turn)
			# if turn_index <= 0:
			# 	BattleView.add_turn(new_turn.uid, new_turn.participant.uid, new_turn.participant.affiliation)
			# else:
			# 	var previous_turn_uid := turns[turn_index - 1].uid
			# 	BattleView.add_turn(new_turn.uid, new_turn.participant.uid, new_turn.participant.affiliation, previous_turn_uid)
			
			# BattleView.add_turn(new_turn.uid, new_turn.participant.uid, new_turn.participant.affiliation)
			BattleView.add_turn(new_turn.uid, new_turn.participant.affiliation)
	
	# TODO: Check if map maintains order, if not: uncomment next line
	# var variant_turns: Array[Variant] = turns.duplicate()
	var sorted_turn_uids := turns.map(func(turn): return turn.uid)
	# var sorted_turn_uids: Array[int] = variant_turns.map(func(turn): return turn.uid)
	# sorted_turn_uids.sort_custom(func(a, b): return turns.find(a) < turns.find(b))
	
	for turn in turns:
		# BattleView.add_turn(new_turn.uid, new_turn.participant.uid, new_turn.participant.affiliation)
		var control_string = "%s: uid: %d" % [turn.participant.uid, turn.time]
		BattleView.set_turn_text_and_time(turn.uid, control_string, turn.time)
	
	BattleView.sort_turns(sorted_turn_uids)
	
	_previous_battle_turns = turns.duplicate()

func on_battle_player_turn_started(battle_participant: BattleParticipant) -> void:
	var battle_menu_entries: Array[UIBattle.BattleMenuEntry]

	var abilities := battle_participant.abilities
	for ability_id in abilities:
		var ability := abilities[ability_id]

		var battle_menu_entry := UIBattle.BattleMenuEntry.new()
		battle_menu_entry.ability_id = ability_id
		battle_menu_entry.ability_string = ability_id
		battle_menu_entry.can_activate = ability.can_activate()

		var valid_participants = BattleManager.get_participants().filter(ability.is_valid_for_target)
		for valid_participant in valid_participants:
			battle_menu_entry.valid_participant_targets.append(valid_participant.uid)

		battle_menu_entries.append(battle_menu_entry)

	BattleView.show_battle_menu(battle_menu_entries)

func on_battle_player_turn_ended(_battle_participant: BattleParticipant) -> void:
	BattleView.hide_battle_menu()

# Misc
func on_battle_particiant_removed(battle_participant: BattleParticipant) -> void:
	if battle_participant.affiliation == BattleManager.Affiliation.ENEMY:
		BattleView.remove_enemy(battle_participant.uid)
	elif battle_participant.affiliation == BattleManager.Affiliation.PLAYER:
		BattleView.remove_player(battle_participant.uid)
	pass

func _ready():
	BattleManager.on_battle_ui_setup_requested.connect(on_battle_ui_setup_requested)
	BattleManager.on_player_party_ui_setup_requested.connect(on_player_party_ui_setup_requested)
	BattleManager.on_battle_finished.connect(on_battle_finished)
	BattleManager.on_battle_effect_applied.connect(on_battle_effect_applied)
	
	BattleManager.on_battle_turn_manipulation.connect(on_battle_turn_manipulation)
	# BattleManager.on_battle_ability_execute.connect(on_battle_ability_execute)
	# BattleManager.on_battle_ability_prepare_start.connect(on_battle_ability_prepare_start)
	# BattleManager.on_battle_ability_prepare_cancel.connect(on_battle_ability_prepare_end)
	
	BattleManager.on_battle_fx_requested.connect(on_battle_fx_requested)
	BattleManager.on_battle_player_turn_started.connect(on_battle_player_turn_started)
	BattleManager.on_battle_player_turn_ended.connect(on_battle_player_turn_ended)
	BattleManager.on_battle_particiant_removed.connect(on_battle_particiant_removed)
	BattleManager.on_battle_turns_updated.connect(on_battle_turns_updated)

	BattleView.on_ability_and_target_selected.connect(on_ability_and_target_selected)
	
	BattleView.on_ability_prepare.connect(on_ability_prepare)
	BattleView.on_ability_cancel.connect(on_ability_cancel)
	BattleView.on_ability_cancel_prepare.connect(on_ability_cancel_prepare)
	
	BattleView.on_ui_setup_complete.connect(on_ui_setup_complete)
