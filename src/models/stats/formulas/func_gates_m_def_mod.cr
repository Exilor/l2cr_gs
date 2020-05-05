class FuncGatesMDefMod < AbstractFunction
  private def initialize
    super(Stats::MAGIC_DEFENCE)
  end

  def calc(effector, effected, skill, init_val)
    case SevenSigns.instance.get_seal_owner(SevenSigns::SEAL_STRIFE)
    when SevenSigns::CABAL_DAWN
      init_val * Config.alt_siege_dawn_gates_mdef_mult
    when SevenSigns::CABAL_DUSK
      init_val * Config.alt_siege_dusk_gates_mdef_mult
    else
      init_val
    end
  end

  INSTANCE = new
end
