class FuncGatesPDefMod < AbstractFunction
  private def initialize
    super(Stats::POWER_DEFENCE)
  end

  def calc(effector, effected, skill, value)
    case SevenSigns.instance.get_seal_owner(SevenSigns::SEAL_STRIFE)
    when SevenSigns::CABAL_DAWN
      value *= Config.alt_siege_dawn_gates_pdef_mult
    when SevenSigns::CABAL_DUSK
      value *= Config.alt_siege_dusk_gates_pdef_mult
    end

    value
  end

  INSTANCE = new
end
