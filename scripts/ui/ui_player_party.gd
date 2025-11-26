class_name UIPlayerParty extends Control

var _player_to_ui_index: Dictionary[StringName, int]

const MAX_PLAYERS := 4

# Effects
func play_oneshot_fx(effect_prototype: PackedScene, target_uid: StringName):
	if !_player_to_ui_index.has(target_uid):
		return

	# TODO: Instantiate this on a bespoke canvas just for UI_FXs
	var effect := effect_prototype.instantiate() as UIFX
	var element := get_player_ui(_player_to_ui_index[target_uid])

	effect.position = element.get_global_transform_with_canvas().get_origin() + element.size / 2
	add_child(effect)

# Player
func get_player_ui(index: int) -> PlayerPartyMember:
	match index:
		0: return $PlayerPartyContainer/PlayerPartyMember1
		1: return $PlayerPartyContainer/PlayerPartyMember2
		2: return $PlayerPartyContainer/PlayerPartyMember3
		3: return $PlayerPartyContainer/PlayerPartyMember4
		_: return null

func add_player(uid: StringName, hp: int, max_hp: int) -> void:
	for index in range(MAX_PLAYERS):
		if _player_to_ui_index.find_key(index) == null:
			var player_ui = get_player_ui(index)
			player_ui.populate(uid, hp, max_hp)
			_player_to_ui_index[uid] = index
			return

func update_player_hp(uid: StringName, hp: int, max_hp: int) -> void:
	var index = _player_to_ui_index[uid]
	get_player_ui(index).update_hp(hp, max_hp)

func remove_player(uid: StringName) -> void:
	var index = _player_to_ui_index[uid]
	get_player_ui(index).hide_info()
	_player_to_ui_index.erase(uid)

func hide_all_players_info() -> void:
	for index in range(MAX_PLAYERS):
		get_player_ui(index).hide_info()

func show_message(message: String) -> void:
	($MessageBox as Control).show()
	($MessageBox/Text as RichTextLabel).text = message
	($MessageBox/Timer as Timer).start(1.1)

func _ready() -> void:
	var message_box := ($MessageBox as Control)
	message_box.hide()
	
	var timer := ($MessageBox/Timer as Timer)
	timer.timeout.connect(message_box.hide)
