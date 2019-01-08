require "./npc_status"

class AttackableStatus < NpcStatus
  def reduce_hp(value : Float64, attacker : L2Character?)
    reduce_hp(value, attacker, true, false, false)
  end

  def reduce_hp(value : Float64, attacker : L2Character?, awake : Bool, dot : Bool, hp_consume : Bool)
    att = active_char
    return if att.dead?

    if value > 0
      if att.overhit?
        att.set_overhit_values(attacker, value)
      else
        att.overhit = false
      end
    else
      att.overhit = false
    end

    super

    if att.dead?
      att.overhit = false
    end
  end

  def active_char
    super.as(L2Attackable)
  end
end
