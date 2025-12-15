class_name UIBattleEnemies extends Node

class FXInstance:
	var target_uid: StringName
	var prototype: PackedScene
	var instance: UIFX
	
	func _init(in_target_uid: StringName, in_prototype: PackedScene, in_instance: UIFX) -> void:
		target_uid = in_target_uid
		prototype = in_prototype
		instance = in_instance

var _enemies: Dictionary[StringName, UIEnemy]
var _fx_instances: Array[FXInstance]

# FX
func play_fx(effect_prototype: PackedScene, target_uid: StringName) -> void:
	if !_enemies.has(target_uid):
		return

	# TODO: Instantiate this on a bespoke canvas just for UI_FXs
	var instance := effect_prototype.instantiate() as UIFX
	var element := _enemies[target_uid]

	instance.position = element.get_global_transform_with_canvas().get_origin() + element.size / 2
	get_tree().root.add_child(instance)
	
	_fx_instances.append(FXInstance.new(target_uid, effect_prototype, instance))
	
func stop_fx(effect_prototype: PackedScene, target_uid: StringName) -> void:
	var results := _fx_instances.filter(func(entry): return entry.target_uid == target_uid and entry.prototype == effect_prototype)
	results.map(func(entry): entry.instance.queue_free())
	_fx_instances = _fx_instances.filter(func(entry): return !results.has(entry))
	
# Animation
func play_animation(anim_id: StringName, target_uid: StringName) -> void:
	if !_enemies.has(target_uid):
		return
		
	var element := _enemies[target_uid]
	element.play_animation(anim_id)
	
# Enemy
func add_enemy(uid: StringName, character_graphics: PackedScene, hp: int, max_hp: int) -> void:
	var ui_enemy := $EnemyPrototype.duplicate() as UIEnemy
	ui_enemy.populate(uid, character_graphics, hp, max_hp)
	ui_enemy.show()
	_enemies[uid] = ui_enemy
	add_child(ui_enemy)

func update_enemy_hp(uid: StringName, hp: int, max_hp: int) -> void:
	_enemies[uid].update_hp(hp, max_hp)

func remove_enemy(uid: StringName) -> void:
	if is_instance_valid(_enemies[uid]):
		_enemies[uid].queue_free()
		
func clear_enemies() -> void:
	_enemies.clear()
	_fx_instances.clear()
		
func _ready() -> void:
	$EnemyPrototype.hide()
