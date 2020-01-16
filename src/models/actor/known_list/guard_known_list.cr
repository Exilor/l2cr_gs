class GuardKnownList < AttackableKnownList
  def add_known_object(object : L2Object) : Bool
    return false unless super

    guard = active_char

    if object.is_a?(L2PcInstance)
      if object.karma > 0
        if guard.intention.idle?
          guard.intention = AI::ACTIVE
        end
      end
    elsif Config.guard_attack_aggro_mob
      if guard.in_active_region? && object.is_a?(L2MonsterInstance)
        if object.aggressive?
          if guard.intention.idle?
            guard.intention = AI::ACTIVE
          end
        end
      end
    end

    true
  end

  def remove_known_object(object, forget : Bool) : Bool
    return false unless super

    guard = active_char

    if guard.aggro_list.empty?
      if guard.ai? && guard.walker?
        guard.intention = AI::IDLE
      end
    end

    true
  end

  def active_char : L2GuardInstance
    super.as(L2GuardInstance)
  end
end
