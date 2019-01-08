class EffectHandler::ServitorShare < AbstractEffect
  @stats = EnumMap(Stats, Float64).new

  def initialize(attach_cond, apply_cond, set, params)
    super

    params.each_key do |k|
      if k
        @stats[Stats.from_value(k)] = params.get_f64(k, 1)
      end
    end
  end

  def effect_flags
    EffectFlag::SERVITOR_SHARE.mask
  end

  def effect_type
    L2EffectType::BUFF
  end

  def on_start(info)
    super

    info.effected.acting_player.servitor_share = @stats

    if summon = info.effected.acting_player.summon
      summon.broadcast_info
      summon.status.start_hp_mp_regeneration
    end
  end

  def on_exit(info)
    info.effected.acting_player.servitor_share = nil

    if summon = info.effected.acting_player.summon
      summon.max_hp! if summon.current_hp > summon.max_hp
      summon.max_mp! if summon.current_mp > summon.max_mp
      summon.broadcast_info
    end
  end
end
