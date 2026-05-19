class_name UIPlayerParty extends Control

var _player_to_ui_index: Dictionary[StringName, int]

const MAX_PLAYERS := 4

class FXInstance:
	var target_uid: StringName
	var prototype: PackedScene
	var instance: UIFX
	
	func _init(in_target_uid: StringName, in_prototype: PackedScene, in_instance: UIFX) -> void:
		target_uid = in_target_uid
		prototype = in_prototype
		instance = in_instance
		
var _fx_instances: Array[FXInstance]

# FX
func play_fx(effect_prototype: PackedScene, target_uid: StringName):
	if !_player_to_ui_index.has(target_uid):
		return

	# TODO: Instantiate this on a bespoke canvas just for UI_FXs
	var instance := effect_prototype.instantiate() as UIFX
	var element := get_player_ui(_player_to_ui_index[target_uid])

	instance.position = element.get_global_transform_with_canvas().get_origin() + element.size / 2
	add_child(instance)
	
	_fx_instances.append(FXInstance.new(target_uid, effect_prototype, instance))
	
func stop_fx(effect_prototype: PackedScene, target_uid: StringName) -> void:
	var results := _fx_instances.filter(func(entry): return entry.target_uid == target_uid and entry.prototype == effect_prototype)
	results.map(func(entry): entry.instance.queue_free())
	_fx_instances = _fx_instances.filter(func(entry): return !results.has(entry))
	
# Animation
func play_animation(anim_id: StringName, target_uid: StringName) -> void:
	if !_player_to_ui_index.has(target_uid):
		return

	var element := get_player_ui(_player_to_ui_index[target_uid])
	element.play_animation(anim_id)

# Player
func get_player_ui(index: int) -> PlayerPartyMember:
	match index:
		0: return $PlayerPartyContainer/PlayerPartyMember1
		1: return $PlayerPartyContainer/PlayerPartyMember2
		2: return $PlayerPartyContainer/PlayerPartyMember3
		3: return $PlayerPartyContainer/PlayerPartyMember4
		_: return null

func add_player(uid: StringName, name_key: StringName, character_graphics: PackedScene, hp: int, max_hp: int, sp: int, max_sp: int) -> void:
	for index in range(MAX_PLAYERS):
		if _player_to_ui_index.find_key(index) == null:
			var player_ui = get_player_ui(index)
			player_ui.populate(name_key, character_graphics, hp, max_hp, sp, max_sp)
			_player_to_ui_index[uid] = index
			return
			
func clear_players():
	_player_to_ui_index.clear()

func update_player_hp(uid: StringName, hp: int, max_hp: int) -> void:
	var index = _player_to_ui_index[uid]
	get_player_ui(index).update_hp(hp, max_hp)
	
func update_player_sp(uid: StringName, sp: int, max_sp: int) -> void:
	var index = _player_to_ui_index[uid]
	get_player_ui(index).update_sp(sp, max_sp)
	
func set_player_highlighted(uid: StringName, highlighted: bool) -> void:
	var index = _player_to_ui_index[uid]
	get_player_ui(index).set_highlighted(highlighted)
	
func remove_player(uid: StringName) -> void:
	var index = _player_to_ui_index[uid]
	get_player_ui(index).hide_info()
	_player_to_ui_index.erase(uid)

func hide_all_players_info() -> void:
	for index in range(MAX_PLAYERS):
		get_player_ui(index).hide_info()

# Message
func show_message(message: String, duration: float) -> void:
	($MessageBox as Control).show()
	($MessageBox/Text as RichTextLabel).text = message
	($MessageBox/Timer as Timer).start(duration)

func _ready() -> void:
	var message_box := ($MessageBox as Control)
	message_box.hide()
	
	var timer := ($MessageBox/Timer as Timer)
	timer.timeout.connect(message_box.hide)
