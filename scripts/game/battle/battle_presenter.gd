extends Node

# @export var battle_ui: BattleUI
var battle_ui: BattleUI

func setup_enemy(id: StringName, hp: int, max_hp: int) -> void:
	battle_ui.add_enemy(id, hp, max_hp)

func on_battle_started() -> void:
	# TODO: Define this path in config (also, find out how to do config in Godot?)
	battle_ui = preload("res://ui/battle/battle_ui.tscn").instantiate()
	get_tree().root.add_child(battle_ui)

	var enemies := BattleManager.get_enemies()
	for enemy in enemies:
		setup_enemy(enemy.id, enemy.hp, enemy.max_hp)

func on_battle_effect_applied(battle_effect: BattleEffect) -> void:
	var target = battle_effect.target

	# TODO: Make this happen somewhere else; don't assume that 0 health means removal
	if target.hp <= 0:
		battle_ui.remove_enemy(target.id)
	else:
		battle_ui.update_enemy_hp(target.id, target.hp, target.max_hp)

	print(battle_effect.to_string())

func _ready():
	# battle_ui = preload("res://ui/battle/battle_ui.tscn").instantiate()
	BattleManager.on_battle_started.connect(on_battle_started)
	BattleManager.on_battle_effect_applied.connect(on_battle_effect_applied)
