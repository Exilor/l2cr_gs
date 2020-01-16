class EffectHandler::FocusSouls < AbstractEffect
  @charge : Int32

  def initialize(attach_cond, apply_cond, set, params)
    super
    @charge = params.get_i32("charge", 0)
  end

  def instant? : Bool
    true
  end

  def on_start(info)
    return if !info.effected.player? || info.effected.looks_dead?
    return unless target = info.effected.acting_player

    max_souls = target.calc_stat(Stats::MAX_SOULS, 0).to_i

    if max_souls > 0
      amount = @charge
      if target.charged_souls < max_souls
        if target.charged_souls + amount <= max_souls
          count = amount
        else
          count = max_souls - target.charged_souls
        end
        target.increase_souls(count)
      else
        target.send_packet(SystemMessageId::SOUL_CANNOT_BE_INCREASED_ANYMORE)
      end
    end
  end
end
