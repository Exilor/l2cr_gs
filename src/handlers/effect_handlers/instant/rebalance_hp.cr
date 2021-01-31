class EffectHandler::RebalanceHP < AbstractEffect
  def effect_type : EffectType
    EffectType::REBALANCE_HP
  end

  def instant? : Bool
    true
  end

  def on_start(info : BuffInfo)
    skill, effector = info.skill, info.effector
    return unless pc = effector.as?(L2PcInstance)

    full_hp = 0.0
    current_hps = 0.0

    unless party = info.effector.party
      return unless summon = pc.summon
      return unless summon.alive?
      return unless Util.in_range?(skill.affect_range, pc, summon, true)

      {pc, summon}.each do |m|
        if m.alive? && Util.in_range?(skill.affect_range, effector, m, true)
          full_hp += m.max_hp
          current_hps += m.current_hp
        end
      end
      percent_hp = current_hps / full_hp
      {pc, summon}.each do |m|
        if m.alive? && Util.in_range?(skill.affect_range, effector, m, true)
          new_hp = m.max_hp * percent_hp
          if new_hp > m.current_hp
            if m.current_hp > m.max_recoverable_hp
              new_hp = m.current_hp
            elsif new_hp > m.max_recoverable_hp
              new_hp = m.max_recoverable_hp
            end
          end

          m.current_hp = new_hp.to_f64
        end
      end

      return
    end

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
        if new_hp > m.current_hp
          if m.current_hp > m.max_recoverable_hp
            new_hp = m.current_hp
          elsif new_hp > m.max_recoverable_hp
            new_hp = m.max_recoverable_hp
          end
        end

        m.current_hp = new_hp.to_f64
      end
    end
  end
end
