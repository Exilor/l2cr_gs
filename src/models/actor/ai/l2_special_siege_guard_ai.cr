class L2SpecialSiegeGuardAI < L2SiegeGuardAI
  getter ally = [] of Int32

  private def auto_attack_condition(target : L2Character)
    if @ally.includes?(target.l2id)
      return false
    end

    super
  end
end
