class EffectHandler::FocusMaxEnergy < AbstractEffect
  def instant? : Bool
    true
  end

  def on_start(info)
    pc = info.effected
    return unless pc.is_a?(L2PcInstance)

    if mastery = (pc.skills[992]? || pc.skills[993]?)
      max_charge = mastery.level

      if max_charge != 0
        count = max_charge - pc.charges
        pc.increase_charges(count, max_charge)
      end
    end
  end
end
