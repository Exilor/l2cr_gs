require "./attackable_known_list"

class MonsterKnownList < AttackableKnownList
  def add_known_object(object : L2Object) : Bool
    return false unless super

    if object.player? && active_char.ai.intention.idle?
      active_char.ai.intention = AI::ACTIVE
    end

    true
  end

  def remove_known_object(object : L2Object?, forget : Bool) : Bool
    return false unless super
    return true unless object.is_a?(L2Character)

    mob = active_char

    if mob.ai?
      mob.notify_event(AI::FORGET_OBJECT, object)
    end

    if mob.visible? && known_players.empty? && known_summons.empty?
      mob.clear_aggro_list
    end

    true
  end

  def active_char : L2MonsterInstance
    super.as(L2MonsterInstance)
  end
end
