class EffectHandler::ServitorShare < AbstractEffect
  @stats = EnumMap(Stats, Float64).new

  def initialize(attach_cond, apply_cond, set, params)
    super

    params.each_key do |k|
      @stats[Stats.from_value(k)] = params.get_f64(k, 1)
    end
  end

  def effect_flags : UInt32
    EffectFlag::SERVITOR_SHARE.mask
  end

  def effect_type : EffectType
    EffectType::BUFF
  end

  def on_start(info : BuffInfo)
    super

    pc = info.effected.acting_player.not_nil!

    pc.servitor_share = @stats

    if smn = pc.summon
      smn.broadcast_info
      smn.status.start_hp_mp_regeneration
    end
  end

  def on_exit(info : BuffInfo)
    pc = info.effected.acting_player.not_nil!
    pc.servitor_share = nil

    if smn = pc.summon
      smn.max_hp! if smn.current_hp > smn.max_hp
      smn.max_mp! if smn.current_mp > smn.max_mp
      smn.broadcast_info
    end
  end
end
