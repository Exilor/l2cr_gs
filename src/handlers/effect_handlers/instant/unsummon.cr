class EffectHandler::Unsummon < AbstractEffect
  @chance : Int32

  def initialize(attach_cond, apply_cond, set, params)
    super
    @chance = params.get_i32("chance", 100)
  end

  def calc_success(info : BuffInfo) : Bool
    effector, effected, skill = info.effector, info.effected, info.skill
    magic_level = skill.magic_level

    if magic_level <= 0 || effected.level - 9 <= magic_level
      chance = @chance.to_f
      chance *= Formulas.attribute_bonus(effector, effected, skill)
      chance *= Formulas.general_trait_bonus(effector, effected, skill.trait_type, false)

      return chance > Rnd.rand * 100
    end

    false
  end

  def instant? : Bool
    true
  end

  def on_start(info)
    return unless smn = info.effected.summon
    owner = smn.owner

    smn.abort_attack
    smn.abort_cast
    smn.stop_all_effects
    smn.unsummon(owner)
    owner.send_packet(SystemMessageId::YOUR_SERVITOR_HAS_VANISHED)
  end
end
