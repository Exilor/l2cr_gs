require "./char_status"

class SiegeFlagStatus < CharStatus
  def reduce_hp(value : Float64, attacker : L2Character?)
    reduce_hp(value, attacker, true, false, false)
  end

  def reduce_hp(value : Float64, attacker : L2Character?, awake : Bool, dot : Bool, hp_consume : Bool)
    if active_char.advanced_headquarter?
      value /= 2
    end

    super(value, attacker, awake, dot, hp_consume)
  end

  def active_char : L2SiegeFlagInstance
    super.as(L2SiegeFlagInstance)
  end
end
