class EffectHandler::DefenceTrait < AbstractEffect
  @traits : EnumMap(TraitType, Float32)?

  def initialize(attach_cond, apply_cond, set, params)
    super

    if params.empty?
      warn { "Params of #{self.class} must not be empty" }
      return
    end

    traits = EnumMap(TraitType, Float32).new
    params.each do |k, v|
      trait_type = TraitType.parse(k)
      value = v.to_s.to_f32
      next if value == 0

      traits[trait_type] = (value + 100) // 100
    end

    @traits = traits
  end

  def on_start(info)
    return unless traits = @traits
    stat = info.effected.stat
    traits.each do |type, value|
      if value < 2
        stat.defence_traits[type.to_i] *= value
        stat.defence_traits_count[type.to_i] += 1
      else
        stat.traits_invul[type.to_i] += 1
      end
    end
  end

  def on_exit(info)
    return unless traits = @traits
    stat = info.effected.stat
    traits.each do |type, value|
      if value < 2
        stat.defence_traits[type.to_i] /= value
        stat.defence_traits_count[type.to_i] -= 1
      else
        stat.traits_invul[type.to_i] -= 1
      end
    end
  end
end
