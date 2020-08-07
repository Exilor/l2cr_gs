class EffectHandler::SummonCubic < AbstractEffect
  @cubic_id : Int32
  @cubic_power : Int32
  @cubic_duration : Int32
  @cubic_delay : Int32
  @cubic_max_count : Int32
  @cubic_skill_chance : Int32

  def initialize(attach_cond, apply_cond, set, params)
    super

    @cubic_id = params.get_i32("cubicId", -1)
    @cubic_power = params.get_i32("cubicPower", 0)
    @cubic_duration = params.get_i32("cubicDuration", 0)
    @cubic_delay = params.get_i32("cubicDelay", 0)
    @cubic_max_count = params.get_i32("cubicMaxCount", -1)
    @cubic_skill_chance = params.get_i32("cubicSkillChance", 0)
  end

  def instant? : Bool
    true
  end

  def on_start(info)
    return unless pc = info.effected.as?(L2PcInstance)
    return if pc.in_observer_mode? || pc.mounted? || pc.dead?

    if @cubic_id < 0
      raise "Invalid cubic id #{@cubic_id}"
    end

    cubic_skill_level = info.skill.level
    if cubic_skill_level > 100
      cubic_skill_level = ((info.skill.level &- 100) // 7) &+ 8
    end

    if cubic = pc.get_cubic_by_id(@cubic_id)
      cubic.stop_action
      cubic.cancel_disappear
      pc.cubics.delete(@cubic_id)
    else
      allowed_count = pc.stat.max_cubic_count
      current_count = pc.cubics.size
      if current_count >= allowed_count
        cubic = pc.cubics.values_slice.sample(random: Rnd)
        cubic.stop_action
        cubic.cancel_disappear
        pc.cubics.delete(cubic.id)
      end
    end

    pc.add_cubic(@cubic_id, cubic_skill_level, @cubic_power, @cubic_delay, @cubic_skill_chance, @cubic_max_count, @cubic_duration, pc != info.effector)
    pc.broadcast_user_info
  end
end
