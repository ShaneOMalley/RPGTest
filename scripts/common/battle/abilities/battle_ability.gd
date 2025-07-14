class_name BattleAbility extends Node

var source: BattleParticipant
var target: BattleParticipant
var _is_executing := false

func execute() -> void:
	_is_executing = true
	pass

# var _is_blocked: bool
# func start_blocking_timer(time: float) -> void:
# 	var timer := get_tree().create_timer(time)
# 	_is_blocked = true
# 	timer.timeout.connect(func(): self._is_blocked = false)
# 	
# func get_is_blocked() -> bool:
# 	return _is_blocked

func end() -> void:
	#_is_executing = false
	# TODO: remove this hacky blocking timer and uncomment above
	var timer := BattleManager.get_tree().create_timer(0.5)
	timer.timeout.connect(func(): self._is_executing = false)
	pass

func get_is_executing() -> bool:
	return _is_executing

func _init(in_source: BattleParticipant, in_target: BattleParticipant) -> void:
	source = in_source
	target = in_target

# class BattleAbilityAttack extends BattleAbility:
# 	
# 	func execute():
# 		var damage := floori(max(0, source.strength - (target.vitality / 2.0)))
# 		target.hp -= damage
# 
# 		print("%s hit %s for %d damage!" % [source.to_string(), target.to_string(), damage])
# 
# 		end()

# class BattleAbilityPass extends BattleAbility:
# 
# 	func execute():
# 		print("%s does nothing..." % source)
