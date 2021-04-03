class FuncGatesMDefMod < AbstractFunction
  private def initialize
    super(Stats::MAGIC_DEFENCE)
  end

  def calc(effector : L2Character, effected : L2Character?, skill : Skill?, value : Float64) : Float64
    case SevenSigns.instance.get_seal_owner(SevenSigns::SEAL_STRIFE)
    when SevenSigns::CABAL_DAWN
      value *= Config.alt_siege_dawn_gates_mdef_mult
    when SevenSigns::CABAL_DUSK
      value *= Config.alt_siege_dusk_gates_mdef_mult
    end

    value
  end

  INSTANCE = new
end
