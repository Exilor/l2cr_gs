class EffectHandler::RebalanceHP < AbstractEffect
  def effect_type
    L2EffectType::REBALANCE_HP
  end

  def instant?
    true
  end

  def on_start(info)
    skill, effector = info.skill, info.effector
    return unless effector.player?
    return unless party = info.effector.party?

    full_hp = 0.0
    current_hps = 0.0

    party.each_with_summon do |m|
      if m.alive? && Util.in_range?(skill.affect_range, effector, m, true)
        full_hp += m.max_hp
        current_hps += m.current_hp
      end
    end

    percent_hp = current_hps / full_hp

    party.each_with_summon do |m|
      if m.alive? && Util.in_range?(skill.affect_range, effector, m, true)
        new_hp = m.max_hp * percent_hp
        if new_hp > m.max_recoverable_hp
          new_hp = m.current_hp
        elsif new_hp > m.max_recoverable_hp
          new_hp = m.max_recoverable_hp
        end

        m.current_hp = new_hp.to_f64
      end
    end
  end
end
