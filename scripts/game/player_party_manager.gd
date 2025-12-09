extends Node

# Party participants
var _participants: Array[BattleParticipant]
var inventory: PlayerPartyInventory

func on_new_item_added(item_id: StringName) -> void:
	for participant in _participants:
		var ability_id := PlayerPartyInventory.get_item_ability_id(item_id)
		var ability := PlayerPartyInventory.instantiate_item_ability(item_id, participant)
		participant.abilities[ability_id] = ability
		participant.temp_item_abilities.append(ability_id)

func on_item_depleted(item_id: StringName) -> void:
	# do nothig for now (to accommodate use item -> repeat turn trick)
	pass

func _add_participant(participant: BattleParticipant) -> void:
	for item_id in PlayerPartyManager.inventory.items:
		var ability_id := PlayerPartyInventory.get_item_ability_id(item_id)
		var ability := PlayerPartyInventory.instantiate_item_ability(item_id, participant)
		participant.abilities[ability_id] = ability
		participant.temp_item_abilities.append(ability_id)

func _on_load_complete(participant_ids: Array[StringName]) -> void:
	for participant_id in participant_ids:
		var participant = BattleParticipant.create_from_config(participant_id)
		participant.affiliation = BattleManager.Affiliation.PLAYER
		_participants.append(participant)

func clear_participants() -> void:
	_participants.clear()

func add_participants_async(ids: Array[StringName], callback := Callable()) -> void:
	BattleParticipant.load_participants_async(ids, func(): 
		_on_load_complete(ids)
		if callback.is_valid():
			callback.call())

func get_participants() -> Array[BattleParticipant]:
	return _participants
	
func on_battle_finished() -> void:
	for participant in _participants:
		participant.remove_all_effects()
		
func _init() -> void:
	inventory = PlayerPartyInventory.new()

func _ready():
	# add_participants_async([&"player", &"player"])
	add_participants_async([&"player"])
	BattleManager.on_battle_finished.connect(on_battle_finished)
	inventory.new_item_added.connect(on_new_item_added)
