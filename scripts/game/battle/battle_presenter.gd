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
	
func on_dungeon_crawling_finished() -> void:
	BattleView.destroy_battle_ui()
	BattleView.destroy_player_party_ui()
	
# Message UI
func on_message_requested(message: String) -> void:
	BattleView.show_message(message)

# Battle Abilities and Effects
func on_ability_prepare(ability_id: StringName, target_uid: StringName, in_turn_target_uid: int) -> void:
	var current_participant := BattleManager.get_current_turn_participant()
	var ability := current_participant.abilities[ability_id]
	var target := BattleManager.get_participant(target_uid)
	var turn_target := BattleManager.get_turn_with_uid(in_turn_target_uid)
	BattleManager.prepare_ability(ability, target, turn_target)
	
func on_ability_cancel(ability_id: StringName) -> void:
	var current_participant := BattleManager.get_current_turn_participant()
	var ability := current_participant.abilities[ability_id]
	BattleManager.cancel_ability(ability)
	
func on_ability_cancel_prepare(ability_id: StringName) -> void:
	var current_participant := BattleManager.get_current_turn_participant()
	var ability := current_participant.abilities[ability_id]
	BattleManager.cancel_prepare_ability(ability)

func on_ability_and_target_selected(ability_id: StringName, target_uid: StringName, turn_target_uid: int) -> void:
	var current_participant := BattleManager.get_current_turn_participant()
	var ability := current_participant.abilities[ability_id]
	var target := BattleManager.get_participant(target_uid)
	var turn_target := BattleManager.get_turn_with_uid(turn_target_uid)
	BattleManager.queue_ability_execution(ability, target, turn_target)
	
func on_turn_hovered(turn_uid: int) -> void:
	var highlight_fx_template = preload("res://game/ui_fx/uifx_highlight.tscn")
	var index = BattleManager._turns.find_custom(func(turn): return turn.uid == turn_uid)
	if index == -1:
		return
		
	var participant = BattleManager._turns[index].participant
	BattleManager.play_fx(highlight_fx_template, participant)
	
func on_turn_unhovered(turn_uid: int) -> void:
	var highlight_fx_template = preload("res://game/ui_fx/uifx_highlight.tscn")
	var index = BattleManager._turns.find_custom(func(turn): return turn.uid == turn_uid)
	if index == -1:
		return
		
	var participant = BattleManager._turns[index].participant
	BattleManager.stop_fx(highlight_fx_template, participant)

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
	BattleView.play_fx(effect_prototype, target.uid)
	
func on_battle_fx_stop_requested(effect_prototype: PackedScene, target: BattleParticipant) -> void:
	BattleView.stop_fx(effect_prototype, target.uid)
	
# Battle Animation
func on_battle_animation_requested(anim_id: StringName, target: BattleParticipant) -> void:
	BattleView.play_animation(anim_id, target.uid)
	
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
		var control_string = "%s: uid: %d" % [turn.participant.uid, turn.uid]
		var turn_modifier := turn.turn_modifier
		var modifier_text: String 
		if turn_modifier:
			if turn_modifier.type == BattleTurn.TurnModifier.Type.SKIP:
				modifier_text = "skipping!"
			if turn_modifier.type == BattleTurn.TurnModifier.Type.REPEAT:
				modifier_text = "repeating!"
				
		BattleView.set_turn_text_and_time(turn.uid, control_string, modifier_text, turn.time)
		
	BattleView.sort_turns(sorted_turn_uids)
	
	_previous_battle_turns = turns.duplicate()

func on_request_show_battle_menu(battle_participant: BattleParticipant, battle_turn: BattleTurn) -> void:
	var battle_menu_entries: Array[UIBattle.BattleMenuEntry]

	var abilities := battle_participant.abilities
	for ability_id in abilities:
		if battle_turn.is_ability_allowed(ability_id):
			var ability := abilities[ability_id]

			var battle_menu_entry: UIBattle.BattleMenuEntry = UIBattle.BattleMenuEntry.new()
			battle_menu_entry.ability_id = ability_id
			battle_menu_entry.ability_string = ability_id
			battle_menu_entry.can_activate = ability.can_activate()
			battle_menu_entry.requires_turn_target = ability.requires_turn_target()

			var valid_participants = BattleManager.get_participants().filter(ability.is_valid_for_target)
			for valid_participant in valid_participants:
				battle_menu_entry.valid_participant_targets.append(valid_participant.uid)

			battle_menu_entries.append(battle_menu_entry)

	BattleView.show_battle_menu(battle_menu_entries)

func on_request_hide_battle_menu(_battle_participant: BattleParticipant) -> void:
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
	
	BattleManager.on_message_requested.connect(on_message_requested)
	
	BattleManager.on_battle_effect_applied.connect(on_battle_effect_applied)
	
	BattleManager.on_battle_turn_manipulation.connect(on_battle_turn_manipulation)
	# BattleManager.on_battle_ability_execute.connect(on_battle_ability_execute)
	# BattleManager.on_battle_ability_prepare_start.connect(on_battle_ability_prepare_start)
	# BattleManager.on_battle_ability_prepare_cancel.connect(on_battle_ability_prepare_end)
	
	BattleManager.on_battle_fx_requested.connect(on_battle_fx_requested)
	BattleManager.on_battle_fx_stop_requested.connect(on_battle_fx_stop_requested)
	BattleManager.on_battle_animation_requested.connect(on_battle_animation_requested)
	
	BattleManager.on_request_show_battle_menu.connect(on_request_show_battle_menu)
	BattleManager.on_request_hide_battle_menu.connect(on_request_hide_battle_menu)
	BattleManager.on_battle_particiant_removed.connect(on_battle_particiant_removed)
	BattleManager.on_battle_turns_updated.connect(on_battle_turns_updated)
	
	BattleView.on_ability_and_target_selected.connect(on_ability_and_target_selected)
	
	BattleView.on_turn_hovered.connect(on_turn_hovered)
	BattleView.on_turn_unhovered.connect(on_turn_unhovered)
	
	BattleView.on_ability_prepare.connect(on_ability_prepare)
	BattleView.on_ability_cancel.connect(on_ability_cancel)
	BattleView.on_ability_cancel_prepare.connect(on_ability_cancel_prepare)
	
	BattleView.on_ui_setup_complete.connect(on_ui_setup_complete)
	
	DungeonManager.on_dungeon_crawling_finished.connect(on_dungeon_crawling_finished)

