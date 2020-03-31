require "../../../enums/effect_calculation_type"

class EffectHandler::MaxMp < AbstractEffect
  @type : EffectCalculationType
  @power : Float64
  @heal : Bool

  def initialize(attach_cond, apply_cond, set, params)
    super

    @type = params.get_enum("type", EffectCalculationType, EffectCalculationType::DIFF)
    if @type.diff?
      @power = params.get_f64("power", 0)
    else
      @power = 1.0 + (params.get_f64("power", 0) / 100)
    end

    @heal = params.get_bool("heal", false)

    if params.empty?
      raise "@params must not be empty."
    end
  end

  def on_start(info)
    effected = info.effected
    char_stat = effected.stat
    amount = @power

    char_stat.sync do
      if @type.diff?
        func = FuncAdd.new(Stats::MAX_MP, 1, self, @power)
        char_stat.active_char.add_stat_func(func)
        if @heal
          effected.current_mp += @power
        end
      else
        max_mp = effected.max_mp.to_f
        func = FuncMul.new(Stats::MAX_MP, 1, self, @power)
        char_stat.active_char.add_stat_func(func)
        if @heal
          amount = (@power - 1) * max_mp
          effected.current_mp += amount
        end
      end
    end

    if @heal
      sm = SystemMessage.s1_mp_has_been_restored
      sm.add_int(amount)
      effected.send_packet(sm)
    end
  end

  def on_exit(info)
    char_stat = info.effected.stat
    char_stat.sync do
      char_stat.active_char.remove_stats_owner(self)
    end
  end
end
