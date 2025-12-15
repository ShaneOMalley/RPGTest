class_name PlayerPartyInventory extends Node

class InventoryItemData:
	var item_id: StringName
	var ability_id: StringName
	var _ability_template: BattleAbility
	# var display_name: String
	# var inventory_icon: Texture
	
	func _init(in_item_id: StringName, in_ability_id: StringName) -> void:
		item_id = in_item_id
		ability_id = in_ability_id
		
	func instantiate_ability_from_template(source: BattleParticipant) -> BattleAbility:
		assert(ability_id)
			
		if !is_instance_valid(_ability_template):
			var ability_resource_path := BattleAbility.ability_class_registry[ability_id]
			_ability_template = load(ability_resource_path).duplicate() as BattleAbility
		var ability_instance := _ability_template.duplicate()
		ability_instance.initialize(source, ability_id)
		ability_instance._consumable_item_id = item_id
		return ability_instance
		
	func preload_ability() -> void:
		if ability_id != &"":
			var ability_resource_path := BattleAbility.ability_class_registry[ability_id]
			LoadHelper.load_multiple_async([ability_resource_path], Callable())
		
	func unload_ability() -> void:
		_ability_template = null

static var item_data: Dictionary[StringName, InventoryItemData] = { 
	&"potion": InventoryItemData.new(&"potion", &"potion"),
	&"dud": InventoryItemData.new(&"dud", &""),
}

static func get_item_ability_id(item_id: StringName) -> StringName:
	return item_data[item_id].ability_id
	
static func grant_item_ability_to_particpant(item_id: StringName, participant: BattleParticipant) -> void:
	var item := item_data[item_id]
	var ability_id = item.ability_id
	if ability_id == &"":
		return
		
	var ability := item.instantiate_ability_from_template(participant)
	participant.abilities[ability_id] = ability
	
var gold: int = 200
var items: Dictionary[StringName, int]

signal new_item_added(item_id: StringName)
signal item_depleted(item_id: StringName)

func add_item(item_id: StringName) -> void:
	if !items.has(item_id):
		items[item_id] = 0
		item_data[item_id].preload_ability()
		new_item_added.emit(item_id)
	
	items[item_id] += 1
	
func remove_item(item_id: StringName) -> void:
	if !items.has(item_id):
		return
	
	items[item_id] -= 1
	if items[item_id] <= 0:
		items.erase(item_id)
		item_data[item_id].unload_ability()
		item_depleted.emit(item_id)

func get_all_item_ability_ids() -> Array[StringName]:
	var unique_ability_ids: Dictionary[StringName, bool]
	for item_id in items:
		var ability_id := item_data[item_id].ability_id
		unique_ability_ids[ability_id] = true
	return unique_ability_ids.keys().duplicate()
