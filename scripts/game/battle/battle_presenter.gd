extends Node

@export var battle_ui: BattleUI

func setup_enemy(id: StringName, hp: int, max_hp: int) -> void:
    battle_ui.add_enemy(id, hp, max_hp)

func on_battle_started() -> void:
    var enemies := BattleManager.get_enemies()
    for enemy in enemies:
        setup_enemy(enemy.id, enemy.hp, enemy.max_hp)

func _ready():
    BattleManager.on_battle_started.connect(on_battle_started)