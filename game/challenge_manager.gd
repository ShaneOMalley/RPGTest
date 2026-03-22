extends Node

const MAX_CHALLENGES: int = 3

var _unlocked_challenge_level: int = 1

func set_unlock_level(in_level: int) -> void:
	_unlocked_challenge_level = min(in_level, MAX_CHALLENGES + 1)
	
func get_unlock_level() -> int:
	return _unlocked_challenge_level