class EffectHandler::ConsumeFakeDeath < AbstractEffect
  @power : Float64

  def initialize(attach_cond : Condition?, apply_cond : Condition?, set : StatsSet, params : StatsSet)
    super

    @power = params.get_f64("power", 0)
    @ticks = params.get_i32("ticks")
  end

  def effect_type : EffectType
    EffectType::FAKE_DEATH
  end

  def on_start(info : BuffInfo)
    info.effected.start_fake_death
  end

  def on_action_time(info : BuffInfo) : Bool
    target = info.effected
    return false if target.dead?
    mana_dam = @power * ticks_multiplier
    if mana_dam < 0 && target.current_mp + mana_dam <= 0
      if info.skill.toggle?
        target.send_packet(SystemMessageId::SKILL_REMOVED_DUE_LACK_MP)
        return false
      end
    end

    amount = Math.min(target.current_mp + mana_dam, target.max_recoverable_mp).to_f64
    target.current_mp = amount

    true
  end

  def on_exit(info : BuffInfo)
    char = info.effected
    if char.is_a?(L2PcInstance)
      char.fake_death = false
      char.recent_fake_death = true
    end

    cwt = ChangeWaitType.new(char, ChangeWaitType::STOP_FAKE_DEATH)
    char.broadcast_packet(cwt)
    char.broadcast_packet(Revive.new(char))
  end
end
