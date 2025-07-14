class_name BattleUI extends Control

@export var enemy_template: Resource

var _enemies: Dictionary[StringName, UIEnemy]

func add_enemy(id: StringName, hp: int, max_hp: int) -> void:
	# var ui_enemy := load("res://scenes/ui_enemy.tscn").instantiate() as UIEnemy
	var ui_enemy := enemy_template.instantiate() as UIEnemy
	assert(ui_enemy)

	_enemies[id] = ui_enemy

	$EnemiesContainer.add_child(ui_enemy)

	ui_enemy.update_hp(hp, max_hp)

# func _ready() -> void:
# 	add_enemy("fucker", 20, 20)
# 	add_enemy("cunt", 30, 30)
# 	pass
