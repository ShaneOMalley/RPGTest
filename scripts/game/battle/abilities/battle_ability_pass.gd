class_name BattleAbilityPass extends BattleAbility

func execute(target: BattleParticipant) -> void:
    super.execute(target)

    print("%s does nothing..." % _source)

    var timer := BattleManager.get_tree().create_timer(0.5)
    timer.timeout.connect(func(): end())
    

func is_valid_for_target(possible_target: BattleParticipant) -> bool:
    return possible_target == _source