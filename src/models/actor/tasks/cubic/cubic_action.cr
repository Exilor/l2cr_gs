class CubicAction
  include Loggable

  @current_count = Atomic(Int32).new(0)

  initializer cubic : L2CubicInstance, chance : Int32

  def call
    if @cubic.owner.dead? || !@cubic.owner.online?
      @cubic.stop_action
      @cubic.owner.cubics.delete(@cubic.id)
      @cubic.owner.broadcast_user_info
      @cubic.cancel_disappear
      return
    end

    unless AttackStances.includes?(@cubic.owner)
      if @cubic.owner.has_summon?
        unless AttackStances.includes?(@cubic.owner.summon)
          @cubic.stop_action
          return
        end
      else
        @cubic.stop_action
        return
      end
    end

    if @cubic.cubic_max_count > -1
      if @current_count.get >= @cubic.cubic_max_count
        @cubic.stop_action
        return
      end
    end

    use_cubic_cure = false

    if @cubic.id.between?(L2CubicInstance::SMART_CUBIC_EVATEMPLAR, L2CubicInstance::SMART_CUBIC_SPECTRALMASTER)
      @cubic.owner.effect_list.debuffs.each do |info|
        unless info.skill.irreplaceable_buff?
          use_cubic_cure = true
          info.effected.effect_list.stop_skill_effects(true, info.skill)
        end
      end
    end

    if use_cubic_cure
      msu = Packets::Outgoing::MagicSkillUse.new(@cubic.owner, @cubic.owner, L2CubicInstance::SKILL_CUBIC_CURE, 1, 0, 0)
      @cubic.owner.broadcast_packet(msu)
      @current_count.add(1)
    elsif Rnd.rand(1..100) < @chance
      return unless skill = @cubic.skills.sample?(random: Rnd)

      if skill.id == L2CubicInstance::SKILL_CUBIC_HEAL
        @cubic.cubic_target_for_heal
      else
        @cubic.cubic_target

        unless L2CubicInstance.in_cubic_range?(@cubic.owner, @cubic.target)
          @cubic.target = nil
        end
      end

      target = @cubic.target
      if target && target.alive?
        msu = Packets::Outgoing::MagicSkillUse.new(@cubic.owner, target, skill.id, skill.level, 0, 0)
        @cubic.owner.broadcast_packet(msu)
        targets = [target]

        # if skill.continuous?
        #   @cubic.use_cubic_continuous(skill, targets)
        # else
        #   skill.activate_skill(@cubic, targets)
        # end

        # if skill.has_effect_type?(EffectType::MAGICAL_ATTACK)
        #   @cubic.use_cubic_m_dam(skill, targets)
        # elsif skill.has_effect_type?(EffectType::HP_DRAIN)
        #   @cubic.use_cubic_drain(skill, targets)
        # elsif skill.has_effect_type?(EffectType::STUN, EffectType::ROOT, EffectType::PARALYZE)
        #   @cubic.use_cubic_disabler(skill, targets)
        # elsif skill.has_effect_type?(EffectType::DMG_OVER_TIME)
        #   @cubic.use_cubic_continuous(skill, targets)
        # elsif skill.has_effect_type?(EffectType::AGGRESSION)
        #   @cubic.use_cubic_disabler(skill, targets)
        # end

        if skill.has_effect_type?(EffectType::MAGICAL_ATTACK)
          @cubic.use_cubic_m_dam(skill, targets)
        elsif skill.has_effect_type?(EffectType::HP_DRAIN)
          @cubic.use_cubic_drain(skill, targets)
        elsif skill.has_effect_type?(EffectType::STUN, EffectType::ROOT, EffectType::PARALYZE)
          @cubic.use_cubic_disabler(skill, targets)
        elsif skill.continuous?
          @cubic.use_cubic_continuous(skill, targets)
        elsif skill.has_effect_type?(EffectType::AGGRESSION)
          @cubic.use_cubic_disabler(skill, targets)
        else
          skill.activate_skill(@cubic, targets)
        end

        @current_count.add(1)
      end
    end
  end
end
