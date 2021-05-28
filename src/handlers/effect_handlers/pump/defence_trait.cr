class EffectHandler::DefenceTrait < AbstractEffect
  @defence_traits = Slice({UInt8, Float32}).empty

  def initialize(attach_cond : Condition?, apply_cond : Condition?, set : StatsSet, params : StatsSet)
    super

    if params.empty?
      raise "Params of #{self.class} must not be empty"
    end

    defence_traits = [] of {UInt8, Float32}

    params.each do |key, val|
      trait_type = TraitType.parse(key)
      value = val.to_f32
      next if value == 0

      defence_traits << {trait_type.to_u8, (value + 100) / 100}
    end

    @defence_traits = defence_traits.to_slice
  end

  def on_start(info : BuffInfo)
    return if @defence_traits.empty?

    stat = info.effected.stat
    @defence_traits.each do |trait_id, value|
      if value < 2
        stat.defence_traits[trait_id] *= value
        stat.defence_traits_count[trait_id] += 1
      else
        stat.traits_invul[trait_id] += 1
      end
    end
  end

  def on_exit(info : BuffInfo)
    return if @defence_traits.empty?

    stat = info.effected.stat
    @defence_traits.each do |trait_id, value|
      if value < 2
        stat.defence_traits[trait_id] /= value
        stat.defence_traits_count[trait_id] -= 1
      else
        stat.traits_invul[trait_id] -= 1
      end
    end
  end
end
