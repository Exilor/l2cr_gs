class EffectHandler::AttackTrait < AbstractEffect
  @attack_traits = Slice({UInt8, Float32}).empty

  def initialize(attach_cond, apply_cond, set, params)
    super

    if params.empty?
      raise "params of #{self.class} must not be empty"
    end

    attack_traits = [] of {UInt8, Float32}

    params.each do |key, val|
      trait_type = TraitType.parse(key)
      value = (val.to_s.to_f32 + 100) / 100
      attack_traits << {trait_type.to_u8, value}
    end

    @attack_traits = attack_traits.to_slice
  end

  def on_start(info)
    return if @attack_traits.empty?

    stat = info.effected.stat
    stat.sync do
      @attack_traits.each do |trait_id, value|
        stat.attack_traits[trait_id] *= value
        stat.attack_traits_count[trait_id] += 1
      end
    end
  end

  def on_exit(info)
    return if @attack_traits.empty?

    stat = info.effected.stat
    stat.sync do
      @attack_traits.each do |trait_id, value|
        stat.attack_traits[trait_id] /= value
        stat.attack_traits_count[trait_id] -= 1
      end
    end
  end
end
