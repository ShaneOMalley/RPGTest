class_name BattleAbilitySmasherSmash extends BattleAbility

var target_effect: BattleEffect
var self_damage_effect: BattleEffect

class BattleEffectSmasherSmashTargetDamage extends BattleEffect:
	var damage: int
	func _init(in_source: BattleParticipant, in_target: BattleParticipant) -> void:
		super._init(in_source, in_target)
		damage = ceili(max(0, target.get_attribute(&"_max_hp") * 0.95))
		_modifiers.append(BattleEffectModifier.new(&"_hp", -damage, Operator.ADDITIVE))

class BattleEffectSmasherSmashSelfDamage extends BattleEffect:
	var damage: int
	func _init(in_source: BattleParticipant, in_target: BattleParticipant) -> void:
		super._init(in_source, in_target)
		damage = ceili(max(0, source.get_attribute(&"_max_hp") * 0.20))
		_modifiers.append(BattleEffectModifier.new(&"_hp", -damage, Operator.ADDITIVE))
		

func execute(in_target: BattleParticipant, in_turn_target: BattleTurn = null) -> void:
	super.execute(in_target)

	BattleManager.play_fx(fx_activate, _source)
	BattleManager.play_animation(&"attack", _source)

	set_timer(0.4, _apply_attack_effect)
	set_timer(1.8, _apply_self_damage_effect)
	set_lifetime(4.0)
	# AnimationCallbackManager.get_event_signal(&"on_animation_finished").connect(func(anim_id): if anim_id == "attack": end())

func _apply_attack_effect() -> void:
	target_effect = BattleEffectSmasherSmashTargetDamage.new(_source, _target)
	target_effect.apply()

	BattleManager.play_fx(fx_affect_target, _target)
	BattleManager.play_animation(&"getting_hit", _target)
	
func _apply_self_damage_effect() -> void:
	self_damage_effect = BattleEffectSmasherSmashSelfDamage.new(_source, _source)
	self_damage_effect.apply()

	BattleManager.play_fx(fx_affect_target, _source)
	BattleManager.play_animation(&"getting_hit", _source)
	
	set_timer(0.3, show_message.bind(1.8))
	
func is_valid_for_target(possible_target: BattleParticipant) -> bool:
	return possible_target.affiliation != _source.affiliation
	
func get_message() -> String:
	return "%s attacks %s for %d damage, but also hurts itself!" % [_source.get_display_name(), _target.get_display_name(), target_effect.damage]
