extends Node

# Party participants
var _participants: Array[BattleParticipant]

# Inventory and stuff
var gold: int = 200

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

func _ready():
	# add_participants_async([&"player", &"player"])
	add_participants_async([&"player"])
	
	BattleManager.on_battle_finished.connect(on_battle_finished)
