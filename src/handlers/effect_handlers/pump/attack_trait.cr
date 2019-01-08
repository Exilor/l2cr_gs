class EffectHandler::AttackTrait < AbstractEffect
  @attack_traits : EnumMap(TraitType, Float32)?

  def initialize(attach_cond, apply_cond, set, params)
    super

    if params.empty?
      warn "This effect must have parameters."
      return
    end

    attack_traits = EnumMap(TraitType, Float32).new

    params.each do |key, val|
      trait = TraitType.parse(key)
      value = (val.to_s.to_f32 + 100) / 100
      attack_traits[trait] = value
    end

    @attack_traits = attack_traits
  end

  def on_start(info)
    return unless traits = @attack_traits

    stat = info.effected.stat
    stat.sync do
      traits.each do |trait, value|
        stat.attack_traits[trait.to_i] *= value
        stat.attack_traits_count[trait.to_i] += 1
      end
    end
  end

  def on_exit(info)
    return unless traits = @attack_traits

    stat = info.effected.stat
    stat.sync do
      traits.each do |trait, value|
        stat.attack_traits[trait.to_i] /= value
        stat.attack_traits_count[trait.to_i] -= 1
      end
    end
  end
end
