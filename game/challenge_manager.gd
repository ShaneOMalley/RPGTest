extends Node

const MAX_CHALLENGES: int = 3

var _completed_challenges: Dictionary[int, bool]

func set_challenge_complete(in_level: int) -> void:
	_completed_challenges[in_level] = true
	
func get_is_challenge_completed(in_level: int) -> bool:
	return _completed_challenges.get(in_level, false)
	
func get_is_all_challenges_completed() -> bool:
	if _completed_challenges.size() < MAX_CHALLENGES:
		return false
	
	for challenge_level in _completed_challenges:
		if !_completed_challenges[challenge_level]:
			return false
	 
	return true
