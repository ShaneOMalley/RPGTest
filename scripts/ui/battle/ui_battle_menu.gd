class_name UIBattleMenu extends Control

signal on_ability_and_target_selected(ability_id, target_id, turn_target_uid)
signal on_ability_prepare(ability_id, target_id, turn_target_uid)
signal on_ability_cancel(ability_id)
signal on_ability_cancel_prepare(ability_id)
signal on_ability_out_of_combat_execute(ability_id, source_id, target_id)

var turns_ui: UIBattleTurns

var _battle_menu_entries : Array[UIBattleMenuEntry]
var _num_used_battle_menu_entries: int = 0

const CANCEL_BUTTON_PRIORITY := -999

# Battle Menu
func _hide_all_menu_buttons() -> void:
	for index in range(_battle_menu_entries.size()):
		_battle_menu_entries[index].hide()
	_num_used_battle_menu_entries = 0
	
func _make_menu_button(text: String, disabled: bool, mouse_entered_callback: Callable, pressed_callback: Callable, ui_sort_priority: int, disabled_callback: Callable = Callable(), is_cancel: bool = false) -> UIBattleMenuEntry:
	var container := $BattleMenuBackground/BattleMenu
	var ui_entry: UIBattleMenuEntry
	
	_num_used_battle_menu_entries += 1
	if _num_used_battle_menu_entries >= _battle_menu_entries.size():
		ui_entry = container.find_child(&"BattleMenuEntryPrototype").duplicate()
		container.find_child(&"BattleMenuEntryPrototype").add_sibling(ui_entry)
		_battle_menu_entries.append(ui_entry)
	else:
		ui_entry = _battle_menu_entries[_num_used_battle_menu_entries]
		ui_entry.disconnect_all()
		
	ui_entry.set_meta(&"ui_sort_priority", ui_sort_priority)
	
	if is_cancel:
		var shortcut = Shortcut.new()
		var action_event = InputEventAction.new()
		action_event.action = &"ui_cancel"
		shortcut.events.append(action_event)
		ui_entry.shortcut = shortcut
	else:
		ui_entry.shortcut = null
		
	ui_entry.show()
	ui_entry.set_text(text)
	ui_entry.disabled = disabled
	if pressed_callback:
		ui_entry.pressed.connect(pressed_callback)
		if disabled_callback:
			ui_entry.pressed.connect(func(): ui_entry.disabled = disabled_callback.call())
	if mouse_entered_callback:
		ui_entry.mouse_entered.connect(mouse_entered_callback)
		ui_entry.focus_entered.connect(mouse_entered_callback)
	
	# if _num_used_battle_menu_entries == 1:
	# 	print("grabbing focus on %s button", text)
	
	return ui_entry
	
func _sort_menu_buttons() -> void:
	var container := $BattleMenuBackground/BattleMenu
	
	var sorted_buttons: Array = container.get_children()#.duplicate()
	sorted_buttons.sort_custom(func(a, b): 
		var a_priority = a.get_meta(&"ui_sort_priority", -10)
		var b_priority = b.get_meta(&"ui_sort_priority", -10)
		return a_priority > b_priority)
		
	for i in range(sorted_buttons.size()):
		container.move_child(sorted_buttons[i], i)
		
	container.queue_sort()
	_highlight_first_button.call_deferred()

func _highlight_first_button() -> void:
	var container := $BattleMenuBackground/BattleMenu as VBoxContainer
	var num_buttons := container.get_child_count()
	
	for i in range(num_buttons):
		if container.get_child(i).visible:
			container.get_child(i).grab_focus()
			return
	
	
class BattleMenuEntry:
	var ability_id: StringName
	var category: StringName
	var ability_string: String
	var ability_sp_cost: int
	var can_activate: bool
	var valid_participant_targets: Array[StringName]
	var participant_blocked_func: Callable
	var requires_turn_target: bool
	var auto_target_id: StringName
	var ui_sort_priority: int

func show_battle_menu(entries: Array[BattleMenuEntry], current_category: StringName = &"") -> void:
	_hide_all_menu_buttons()
	_clear_turns_ui_connections()
	_hide_battle_menu_header()
	
	var seen_categories: Dictionary[StringName, bool]
	
	if current_category != &"":
		_make_menu_button(tr("ABILITY_CANCEL"), false, Callable(), func(): show_battle_menu(entries, &""), CANCEL_BUTTON_PRIORITY, Callable(), true)
	
	for index in range(entries.size()):
		var entry := entries[index]
		
		if current_category == entry.category:
			var text: String
			if entry.ability_sp_cost > 0:
				text = tr("ABILITY_WITH_SP_COST").format({"ability": entry.ability_string, "sp_cost": entry.ability_sp_cost})
			else:
				text = entry.ability_string
				
			var on_pressed: Callable
			if entry.auto_target_id == &"":
				on_pressed = func(): show_target_menu(entry.ability_id, entry.category, entry.valid_participant_targets, entries, text, entry.participant_blocked_func, entry.requires_turn_target)
			else:
				on_pressed = func(): ability_select_target(-1, entry.ability_id, entry.auto_target_id)
	
			_make_menu_button(text, !entry.can_activate, Callable(), on_pressed, entry.ui_sort_priority)
		elif current_category == &"":
			# make category buttons
			if !seen_categories.get(entry.category, false):
				seen_categories[entry.category] = true
				
				var text := "ABILITY_CATEGORY_" + entry.category.to_upper()
				var on_pressed := func(): show_battle_menu(entries, entry.category)
				_make_menu_button(text, false, Callable(), on_pressed, BattleAbility.ability_category_ui_sort_priorities[entry.category])
				
	_sort_menu_buttons()
	show()
	
func show_target_menu(ability_id: StringName, ability_category: StringName, valid_participant_targets: Array[StringName], previous_entries: Array[BattleMenuEntry], ability_string: String, participant_blocked_func: Callable, requires_turn_target: bool = false) -> void:
	_hide_all_menu_buttons()
	_show_battle_menu_header(ability_string)
	
	var options := valid_participant_targets.duplicate() as Array[StringName]
	options.push_front(&"cancel")
	
	for index in range(options.size()): # range(valid_participant_targets.size()):
		var target_uid := options[index] # valid_participant_targets[index]

		var pressed_callback: Callable
		var mouse_entered_callback: Callable
		var text: StringName
		var priority: int
		var disabled: bool
		var is_cancel: bool
		
		if target_uid == &"cancel":
			pressed_callback = ability_cancel.bind(ability_id, previous_entries, ability_category)
			mouse_entered_callback = ability_cancel_prepare.bind(ability_id)
			text = tr("ABILITY_CANCEL")
			priority = CANCEL_BUTTON_PRIORITY
			disabled = false
			is_cancel = true
		else:
			var participant: BattleParticipant= BattleManager.get_participant(target_uid)
			mouse_entered_callback = ability_prepare.bind(-1, ability_id, target_uid)
			pressed_callback = ability_select_target.bind(-1, ability_id, target_uid)
			text = participant.get_display_name()
			priority = 2 if participant.affiliation == BattleManager.Affiliation.PLAYER else 1
			disabled = participant_blocked_func.call(BattleManager.get_participant(target_uid)) if participant_blocked_func else false
			is_cancel = false
		
		var button := _make_menu_button(text, disabled, mouse_entered_callback, pressed_callback, priority, Callable(), is_cancel)
		print("right neighbor", button.focus_neighbor_right)
		
	if requires_turn_target:
		turns_ui.on_turn_pressed.connect(ability_select_target.bind(ability_id, &""))
		turns_ui.on_turn_hovered.connect(ability_prepare.bind(ability_id, &""))
		turns_ui.get_top_turn_button().grab_focus()
		
	_sort_menu_buttons()
	
	# _battle_menu_entries.front().grab_focus()

	# $BattleMenuBackground.show()
	
class OutOfCombatAbilityEntry:
	var ability_id: StringName
	var source_id: StringName
	var category_id: StringName
	var display_name_func: Callable
	var can_activate_func: Callable
	var valid_participant_targets_func: Callable
	var valid_for_target_func: Callable
	var participant_blocked_func: Callable
	var ui_sort_priority: int

func show_out_of_combat_menu(entries: Array[OutOfCombatAbilityEntry]) -> void:
	_hide_all_menu_buttons()
	_hide_battle_menu_header()
	
	var first_source_id := entries[0].source_id if !entries.is_empty() else &""
	var ability_sort_priorities := BattleAbility.ability_category_ui_sort_priorities
	_make_menu_button(tr("ABILITY_CANCEL"), false, Callable(), hide, CANCEL_BUTTON_PRIORITY, Callable(), true) # $BattleMenuBackground.hide)
	_make_menu_button(tr("ABILITY_CATEGORY_MAGIC"), false, Callable(), out_of_combat_select_source.bind(entries, &"magic"), ability_sort_priorities[&"magic"])
	_make_menu_button(tr("ABILITY_CATEGORY_ITEM"), false, Callable(), out_of_combat_select_ability.bind(entries, &"item", first_source_id), ability_sort_priorities[&"item"])

	# $BattleMenuBackground.show()
		
	_sort_menu_buttons()
	show()
	
func out_of_combat_select_source(entries: Array[OutOfCombatAbilityEntry], category_filter: StringName) -> void:
	_hide_all_menu_buttons()
	_hide_battle_menu_header()
	
	var sources: Dictionary[StringName, bool]
	for entry in entries:
		sources[entry.source_id] = true
		
	_make_menu_button(tr("ABILITY_CANCEL"), false, Callable(), show_out_of_combat_menu.bind(entries), CANCEL_BUTTON_PRIORITY, Callable(), true)
		
	for source_id in sources.keys():
		_make_menu_button(source_id, false, Callable(), out_of_combat_select_ability.bind(entries, category_filter, source_id), 0)
		
	_sort_menu_buttons()
	
func out_of_combat_select_ability(entries: Array[OutOfCombatAbilityEntry], category_filter: StringName, source_filter: StringName) -> void:
	_hide_all_menu_buttons()
	_hide_battle_menu_header()
	
	if category_filter == &"item":
		_make_menu_button(tr("ABILITY_CANCEL"), false, Callable(), show_out_of_combat_menu.bind(entries), CANCEL_BUTTON_PRIORITY, Callable(), true)
	else:
		_make_menu_button(tr("ABILITY_CANCEL"), false, Callable(), out_of_combat_select_source.bind(entries, category_filter), CANCEL_BUTTON_PRIORITY, Callable(), true)
		
	# var valid_entries: Array[OutOfCombatAbilityEntry]
	for entry in entries:
		if entry.source_id == source_filter and entry.category_id == category_filter:
			# _make_menu_button(entry.display_name_func.call(), !entry.can_activate_func.call(), Callable(), out_of_combat_select_target.bind())
			_make_menu_button(entry.display_name_func.call(), !entry.can_activate_func.call(), Callable(), out_of_combat_select_target.bind(entries, entry), entry.ui_sort_priority)
		
	_sort_menu_buttons()
	
func out_of_combat_select_target(entries: Array[OutOfCombatAbilityEntry], current_entry: OutOfCombatAbilityEntry) -> void:
	_hide_all_menu_buttons()
	# _show_battle_menu_header(current_entry.display_name_func.call())
	var update_header = func(): _show_battle_menu_header(current_entry.display_name_func.call())
	update_header.call_deferred()
	
	var valid_targets = current_entry.valid_participant_targets_func.call()
	_make_menu_button(tr("ABILITY_CANCEL"), false, Callable(), out_of_combat_select_ability.bind(entries, current_entry.category_id, current_entry.source_id), CANCEL_BUTTON_PRIORITY, Callable(), true)
	
	for target_id in valid_targets:
		var participant := PlayerPartyManager.get_participant_with_uid(target_id)
		var text := participant.get_display_name()
		# var disabled = !current_entry.valid_for_target_func.call(target_id) or (current_entry.participant_blocked_func and current_entry.participant_blocked_func.call(participant))
		var disabled_func = func(): return !current_entry.valid_for_target_func.call(target_id) or (current_entry.participant_blocked_func and current_entry.participant_blocked_func.call(participant))
		_make_menu_button(text, disabled_func.call(), Callable(), out_of_combat_execute_ability.bind(entries, current_entry, target_id), 0, disabled_func)
		
	_sort_menu_buttons()
	
func out_of_combat_execute_ability(entries: Array[OutOfCombatAbilityEntry], current_entry: OutOfCombatAbilityEntry, target_id: StringName) -> void:
	on_ability_out_of_combat_execute.emit(current_entry.ability_id, current_entry.source_id, target_id)
	if !current_entry.can_activate_func.call():
		out_of_combat_select_ability(entries, current_entry.category_id, current_entry.source_id)
	else:
		var update_header = func(): _show_battle_menu_header(current_entry.display_name_func.call())
		update_header.call_deferred()

func hide_battle_menu() -> void:
	hide()
	
var _current_highlight_participant_uid: StringName
func update_highlight_participant(new_participant_uid: StringName):
	var highlight_fx_template := preload("res://game/ui_fx/uifx_highlight.tscn")
	if _current_highlight_participant_uid != &"":
		var old_participant := BattleManager.get_participant(_current_highlight_participant_uid)
		BattleManager.stop_fx(highlight_fx_template, old_participant)
	
	if new_participant_uid != &"":
		var participant := BattleManager.get_participant(new_participant_uid)
		BattleManager.play_fx(highlight_fx_template, participant)
	
	_current_highlight_participant_uid = new_participant_uid
	
func _show_battle_menu_header(header: String) -> void:
	if header != "":
		$BattleMenuBackground/BattleMenuHeader.text = header
		$BattleMenuBackground/BattleMenuHeader.show()
	else:
		$BattleMenuBackground/BattleMenuHeader.hide()
		
func _hide_battle_menu_header() -> void:
	$BattleMenuBackground/BattleMenuHeader.hide()

func stop_highlight_participant():
	update_highlight_participant(&"")

func ability_prepare(turn_target_uid: int, ability_id: StringName, target_uid: StringName) -> void:
	print(" -- PREPARE")
	update_highlight_participant(target_uid)
	on_ability_prepare.emit(ability_id, target_uid, turn_target_uid)
	
func ability_cancel(ability_id: StringName, previous_entries: Array[BattleMenuEntry], ability_category: StringName) -> void:
	print(" -- CANCEL")
	_hide_battle_menu_header()
	on_ability_cancel.emit(ability_id)
	stop_highlight_participant()
	show_battle_menu(previous_entries, ability_category)
	
func ability_cancel_prepare(ability_id: StringName) -> void:
	print(" -- CANCEL PREPARE")
	stop_highlight_participant()
	on_ability_cancel_prepare.emit(ability_id)
	
func ability_select_target(turn_target_uid: int, ability_id: StringName, target_uid: StringName) -> void:
	print(" -- SELECT TARGET")
	_hide_battle_menu_header()
	stop_highlight_participant()
	on_ability_and_target_selected.emit(ability_id, target_uid, turn_target_uid)
	
	_clear_turns_ui_connections()
	hide_battle_menu()
	
func _clear_turns_ui_connections() -> void:
	for connection in turns_ui.on_turn_pressed.get_connections():
		if connection.callable.get_object() == self:
			turns_ui.on_turn_pressed.disconnect(connection.callable)
		
	for connection in turns_ui.on_turn_hovered.get_connections():
		if connection.callable.get_object() == self:
			turns_ui.on_turn_hovered.disconnect(connection.callable)
		
	for connection in turns_ui.on_turn_unhovered.get_connections():
		if connection.callable.get_object() == self:
			turns_ui.on_turn_unhovered.disconnect(connection.callable)

func _ready() -> void:
	turns_ui = get_parent().find_child(&"BattleBackground").find_child(&"Turns")
	hide()
	$BattleMenuBackground/BattleMenuHeader.hide()
