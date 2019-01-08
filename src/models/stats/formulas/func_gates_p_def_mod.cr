class FuncGatesPDefMod < AbstractFunction
  private def initialize
    super(Stats::POWER_DEFENCE)
  end

  def calc(effector, effected, skill, init_val)
    case SevenSigns.get_seal_owner(SevenSigns::SEAL_STRIFE)
    when SevenSigns::CABAL_DAWN
      init_val * Config.alt_siege_dawn_gates_pdef_mult
    when SevenSigns::CABAL_DUSK
      init_val * Config.alt_siege_dusk_gates_pdef_mult
    else
      init_val
    end
  end

  INSTANCE = new
end
