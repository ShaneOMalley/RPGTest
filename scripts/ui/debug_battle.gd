extends Control

func _process(delta: float) -> void:
	var filter_enemies := func(participant: BattleParticipant) -> bool:
		return participant.affiliation == BattleManager.Affiliation.ENEMY

	var filter_player := func(participant: BattleParticipant) -> bool:
		return participant.affiliation == BattleManager.Affiliation.PLAYER

	var enemies = BattleManager.participants.filter(filter_enemies)
	var players = BattleManager.participants.filter(filter_player)

	var result := ""

	# for participant in participants:
	result += "-- ENEMIES --\n"
	for enemy in enemies:
		result += "    %s %d/%d" % [enemy.to_string(), enemy.hp, enemy.max_hp]
	result += "\n"

	result += "-- PLAYER --\n"
	for player in players:
		result += "    %s %d/%d" % [player.to_string(), player.hp, player.max_hp]

	$PanelContainer/RichTextLabel.text = result
