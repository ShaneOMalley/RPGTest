extends Node

signal on_player_party_updated(participants: Array[BattleParticipant])

# Party participants
var _participants: Array[BattleParticipant]
var _participants_copy: Array[BattleParticipant] # save participants until after challenge mode
var inventory: PlayerPartyInventory

func _on_new_item_added(item_id: StringName) -> void:
	for participant in _participants:
		PlayerPartyInventory.grant_item_ability_to_particpant(item_id, participant)

func _on_load_complete(participant_ids: Array[StringName]) -> void:
	for participant_id in participant_ids:
		var participant = BattleParticipant.create_from_config(participant_id)
		participant.affiliation = BattleManager.Affiliation.PLAYER
		for item_id in PlayerPartyManager.inventory.items:
			PlayerPartyInventory.grant_item_ability_to_particpant(item_id, participant)
		_participants.append(participant)
	on_player_party_updated.emit(_participants)
	
# For challenge mode
func save_participants() -> void:
	_participants_copy = _participants.duplicate()
	
# For challenge mode
func reload_participants() -> void:
	_participants = _participants_copy.duplicate()
	PlayerPartyManager.on_player_party_updated.emit(PlayerPartyManager._participants)

# For challenge mode
func clear_participants() -> void:
	_participants.clear()
	
func remove_player_if_exists(player: BattleParticipant) -> void:
	if _participants.has(player):
		_participants.erase(player)

func add_participants_async(ids: Array[StringName], callback := Callable()) -> void:
	BattleParticipant.load_participants_async(ids, func(): 
		_on_load_complete(ids)
		if callback.is_valid():
			callback.call())

func get_participants() -> Array[BattleParticipant]:
	return _participants
	
func get_participant_with_uid(uid: StringName) -> BattleParticipant:
	var index := _participants.find_custom((func(participant): return participant.uid == uid))
	return _participants[index]
	
func on_battle_finished() -> void:
	for participant in _participants:
		participant.remove_all_effects()
		
func _init() -> void:
	inventory = PlayerPartyInventory.new()
	
func reset_player_party():
	_participants.clear()
	add_participants_async([&"player_warrior", &"player_chronomancer"])
	# add_participants_async([&"player"])

func _ready():
	# add_participants_async([&"player", &"player"])
	# add_participants_async([&"player"])
	reset_player_party()
	BattleManager.on_battle_finished.connect(on_battle_finished)
	inventory.new_item_added.connect(_on_new_item_added)
