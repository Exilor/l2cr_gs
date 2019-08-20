class FriendlyMobKnownList < AttackableKnownList
  def add_known_object(object : L2Object)
    return false unless super

    if object.player? && active_char.intention.idle?
      active_char.intention = AI::ACTIVE
    end

    true
  end

  def remove_known_object(object, forget : Bool) : Bool
    return false unless super
    return true unless object.character?

    mob = active_char

    if mob.ai?
      mob.notify_event(AI::FORGET_OBJECT, object)
      if mob.target == object
        mob.target = nil
      end
    end

    if mob.visible? && known_players.empty? && known_summons.empty?
      mob.clear_aggro_list
      if mob.ai?
        mob.intention = AI::IDLE
      end
    end

    true
  end

  def active_char : L2FriendlyMobInstance
    super.as(L2FriendlyMobInstance)
  end
end
