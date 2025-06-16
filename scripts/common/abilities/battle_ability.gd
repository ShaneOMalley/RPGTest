class_name BattleAbility extends Node

var source: BattleParticipant
var target: BattleParticipant

func execute():
	pass

class BattleAbilityAttack extends BattleAbility:
	
	func execute():
		var damage := floori(max(0, source.strength - (target.vitality / 2.0)))
		target.hp -= damage
		
		print("hit %s for %d damage!")

class BattleAbilityPass extends BattleAbility:

	func execute():
		print("%s does nothing...")
