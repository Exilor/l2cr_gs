class L2SpecialSiegeGuardAI < L2SiegeGuardAI
  getter ally = [] of Int32

  private def auto_attack_condition(target : L2Character)
    return false if @ally.includes?(target.l2id)
    super
  end
end
