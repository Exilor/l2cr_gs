require "../tasks/cubic/*"

class L2CubicInstance
  # include Identifiable
  include Packets::Outgoing
  include Loggable

  # Type of Cubics
  STORM_CUBIC = 1
  VAMPIRIC_CUBIC = 2
  LIFE_CUBIC = 3
  VIPER_CUBIC = 4
  POLTERGEIST_CUBIC = 5
  BINDING_CUBIC = 6
  AQUA_CUBIC = 7
  SPARK_CUBIC = 8
  ATTRACT_CUBIC = 9
  SMART_CUBIC_EVATEMPLAR = 10
  SMART_CUBIC_SHILLIENTEMPLAR = 11
  SMART_CUBIC_ARCANALORD = 12
  SMART_CUBIC_ELEMENTALMASTER = 13
  SMART_CUBIC_SPECTRALMASTER = 14

  # Max range of cubic skills
  # TODO: Check/fix the max range
  MAX_MAGIC_RANGE = 900

  # Cubic skills
  SKILL_CUBIC_HEAL = 4051
  SKILL_CUBIC_CURE = 5579

  @cubic_delay : Int32
  @action_task : Runnable::PeriodicTask?
  @disappear_task : Runnable::DelayedTask?
  @active = false
  getter skills = [] of Skill
  getter owner, cubic_power, cubic_max_count
  getter? given_by_other
  property target : L2Character?

  def initialize(@owner : L2PcInstance, @cubic_id : Int32, @level : Int32, @cubic_power : Int32, cubic_delay : Int32, @cubic_skill_chance : Int32, @cubic_max_count : Int32, @cubic_duration : Int32, @given_by_other : Bool)
    @cubic_delay = cubic_delay * 1000

    case @cubic_id
    when STORM_CUBIC
      @skills << SkillData[4049, level]
    when VAMPIRIC_CUBIC
      @skills << SkillData[4050, level]
    when LIFE_CUBIC
      @skills << SkillData[4051, level]
      do_action
    when VIPER_CUBIC
      @skills << SkillData[4052, level]
    when POLTERGEIST_CUBIC
      @skills << SkillData[4053, level]
      @skills << SkillData[4054, level]
      @skills << SkillData[4055, level]
    when BINDING_CUBIC
      @skills << SkillData[4164, level]
    when AQUA_CUBIC
      @skills << SkillData[4165, level]
    when SPARK_CUBIC
      @skills << SkillData[4166, level]
    when ATTRACT_CUBIC
      @skills << SkillData[5115, level]
      @skills << SkillData[5116, level]
    when SMART_CUBIC_ARCANALORD
      @skills << SkillData[4051, 7]
      @skills << SkillData[4165, 9]
    when SMART_CUBIC_ELEMENTALMASTER
      @skills << SkillData[4049, 8]
      @skills << SkillData[4166, 9]
    when SMART_CUBIC_SPECTRALMASTER
      @skills << SkillData[4049, 8]
      @skills << SkillData[4052, 6]
    when SMART_CUBIC_EVATEMPLAR
      @skills << SkillData[4053, 8]
      @skills << SkillData[4165, 9]
    when SMART_CUBIC_SHILLIENTEMPLAR
      @skills << SkillData[4049, 8]
    end

    task = CubicDisappear.new(self)
    @disappear_task = ThreadPoolManager.schedule_general(task, @cubic_duration * 1000)

    debug "New cubic:"
    debug "  owner: #{@owner}"
    debug "  cubic_id: #{@cubic_id}"
    debug "  level: #{level}"
    debug "  cubic_power: #{@cubic_power}"
    debug "  cubic_delay: #{@cubic_delay}"
    debug "  cubic_skill_chance: #{@cubic_skill_chance}"
    debug "  cubic_max_count: #{@cubic_max_count}"
    debug "  cubic_duration: #{@cubic_duration}"
    debug "  given_by_other: #{@given_by_other}"
  end

  def do_action
    # debug "do_action interval : #{@cubic_delay}"
    return if @active
    @active = true

    case @cubic_id
    when LIFE_CUBIC
      task = CubicHeal.new(self)
      @action_task = ThreadPoolManager.schedule_effect_at_fixed_rate(task, 0, @cubic_delay)
    else
      task = CubicAction.new(self, @cubic_skill_chance)
      @action_task = ThreadPoolManager.schedule_effect_at_fixed_rate(task, 0, @cubic_delay)
    end
  end

  def id : Int32
    @cubic_id
  end

  def stop_action
    @target = nil
    if task = @action_task
      task.cancel
      @action_task = nil
    end
    @active = false
  end

  def cancel_disappear
    if task = @disappear_task
      task.cancel
      @disappear_task = nil
    end
  end

  def cubic_target
    @target = nil
    return unless owner_target = @owner.target

    # TODO: tvt event check

    if @owner.in_duel?
      duel = DuelManager.get_duel(@owner.duel_id).not_nil!
      player_a = duel.team_leader_a
      player_b = duel.team_leader_b

      if duel.party_duel?
        party_a = player_a.party?
        party_b = player_b.party?
        party_enemy = nil

        if party_a
          if party_a.members.includes?(@owner)
            if party_b
              party_enemy = party_b
            else
              @target = player_b
            end
          else
            party_enemy = party_a
          end
        else
          if player_a == @owner
            if party_b
              party_enemy = party_b
            else
              @target = player_b
            end
          else
            @target = player_a
          end
        end

        if @target == player_a || @target == player_b
          if @target == owner_target
            return
          end
        end

        if party_enemy
          if party_enemy.members.includes?(owner_target)
            @target = owner_target.as(L2Character)
          end

          return
        end
      end

      if player_a != @owner && owner_target == player_a
        @target = player_a
        return
      end

      if player_b != @owner && owner_target == player_b
        @target = player_b
        return
      end
    end

    # TODO: olympiad check

    if owner_target.is_a?(L2Character) && owner_target != @owner.summon && owner_target != @owner
      if attackable = owner_target.as?(L2Attackable)
        if attackable.in_aggro_list?(@owner) && attackable.alive?
          @target = attackable
          return
        end

        if summon = @owner.summon
          if attackable.in_aggro_list?(summon) && attackable.alive?
            @target = attackable
            return
          end
        end
      end

      enemy = nil
      target_it = true

      if ((@owner.pvp_flag > 0) && !@owner.inside_peace_zone?) || @owner.inside_pvp_zone?
        if owner_target.alive?
          enemy = owner_target.acting_player
        end

        if enemy
          target_it = true
          if party = @owner.party?
            if party.includes?(enemy)
              debug "#{@owner} and #{enemy} are in the same party."
              target_it = false
            elsif party.command_channel?
              if party.command_channel.includes?(enemy)
                debug "#{@owner} and #{enemy} are in the same command channel."
                target_it = false
              end
            end
          end

          clan = @owner.clan?
          if clan && !@owner.inside_pvp_zone?
            if clan.member?(enemy.l2id)
              debug "#{@owner} and #{enemy} are in the same clan."
              target_it = false
            end

            if @owner.ally_id > 0 && enemy.ally_id > 0
              if @owner.ally_id == enemy.ally_id
                debug "#{@owner} and #{enemy} are in the same alliance."
                target_it = false
              end
            end
          end

          if enemy.pvp_flag == 0 && !enemy.inside_pvp_zone?
            debug "#{enemy} is not pvp flagged and is not inside a PVP zone."
            target_it = false
          end

          if enemy.inside_peace_zone?
            debug "#{enemy} is inside peace zone."
            target_it = false
          end

          if @owner.siege_state > 0 && @owner.siege_state == enemy.siege_state
            debug "#{@owner} and #{enemy} are on the same siege side."
            target_it = false
          end

          unless enemy.visible?
            debug "#{enemy} is not visible."
            target_it = false
          end

          if target_it
            @target = enemy
            # debug "#{@target}"
            return
          end
        end
      end
    end
  end

  def use_cubic_continuous(skill : Skill, targets : Enumerable(L2Object))
    targets.each do |target|
      next if target.dead?

      if skill.bad?
        shld = Formulas.shld_use(@owner, target, skill)
        acted = Formulas.cubic_skill_success(self, target, skill, shld)
        unless acted
          @owner.action_failed
          next
        end
      end

      skill.apply_effects(@owner, target, false, false, true, 0)
    end
  end

  def use_cubic_m_dam(skill : Skill, targets : Array(L2Object))
    targets.each do |target|
      if target.looks_dead?
        if target.player?
          target.stop_fake_death(true)
        else
          next
        end
      end

      mcrit = Formulas.m_crit(@owner.get_m_critical_hit(target, skill).to_f)
      shld = Formulas.shld_use(@owner, target, skill)
      damage = Formulas.magic_dam(self, target, skill, mcrit, shld)

      if damage > 0
        if !target.raid? && Formulas.atk_break(target, damage)
          target.break_attack
          target.break_cast
        end

        if target.calc_stat(Stats::VENGEANCE_SKILL_MAGIC_DAMAGE, 0, target, skill) > Rnd.rand(100)
          damage = 0
        else
          @owner.send_damage_message(target, damage.to_i, mcrit, false, false)
          target.reduce_current_hp(damage, @owner, skill)
        end
      end
    end
  end

  def use_cubic_drain(skill : Skill, targets : Array(L2Object))
    targets.each do |target|
      if target.looks_dead?
        if target.player?
          target.stop_fake_death(true)
        else
          next
        end
      end

      mcrit = Formulas.m_crit(@owner.get_m_critical_hit(target, skill).to_f)
      shld = Formulas.shld_use(@owner, target, skill)
      damage = Formulas.magic_dam(self, target, skill, mcrit, shld)
      hp_add = 0.4 * damage
      hp = @owner.current_hp + hp_add > @owner.max_hp ? @owner.max_hp : @owner.current_hp + hp_add
      @owner.current_hp = hp.to_f64
      if damage > 0
        if !target.raid? && Formulas.atk_break(target, damage)
          target.break_attack
          target.break_cast
        end

        if target.calc_stat(Stats::VENGEANCE_SKILL_MAGIC_DAMAGE, 0, target, skill) > Rnd.rand(100)
          damage = 0
        else
          @owner.send_damage_message(target, damage.to_i, mcrit, false, false)
          target.reduce_current_hp(damage, @owner, skill)
        end
      end
    end
  end

  def use_cubic_disabler(skill : Skill, targets : Array(L2Object))
    targets.each do |target|
      if target.looks_dead?
        if target.player?
          target.stop_fake_death(true)
        else
          next
        end
      end

      shld = Formulas.shld_use(@owner, target, skill)
      if skill.has_effect_type?(L2EffectType::STUN, L2EffectType::PARALYZE, L2EffectType::ROOT, L2EffectType::AGGRESSION)
        if Formulas.cubic_skill_success(self, target, skill, shld)
          skill.apply_effects(@owner, target, false, false, true, 0)
        end
      end
    end
  end

  def self.in_cubic_range?(owner : L2Character?, target : L2Character?) : Bool
    return false unless owner && target

    range = MAX_MAGIC_RANGE
    x = owner.x - target.x
    y = owner.y - target.y
    z = owner.z - target.z
    (x * x) + (y * y) + (z * z) <= range.abs2
  end

  def cubic_target_for_heal
    target = nil
    percent_left = 100.0
    party = @owner.party?

    if @owner.in_duel?
      unless DuelManager.get_duel(@owner.duel_id).not_nil!.party_duel?
        party = nil
      end
    end

    if party && !@owner.in_olympiad_mode?
      party.each do |m|
        if m.alive?
          if L2CubicInstance.in_cubic_range?(@owner, m)
            if m.current_hp < m.max_hp
              if percent_left > m.current_hp / m.max_hp
                percent_left = m.current_hp / m.max_hp
                target = m
              end
            end
          end
        end

        if summon = m.summon
          next if summon.dead?
          next unless L2CubicInstance.in_cubic_range?(@owner, summon)

          if summon.current_hp < summon.max_hp
            if percent_left > summon.current_hp / m.max_hp
              percent_left = summon.current_hp / summon.max_hp
              target = summon
            end
          end
        end
      end
    else
      if @owner.current_hp < @owner.max_hp
        percent_left = @owner.current_hp / @owner.max_hp
        target = @owner
      end

      if summon = @owner.summon
        if summon.alive? && summon.current_hp < summon.max_hp
          if percent_left > summon.current_hp / summon.max_hp
            if L2CubicInstance.in_cubic_range?(@owner, summon)
              target = summon
            end
          end
        end
      end
    end

    @target = target
  end

  def to_log(io : IO)
    name =
    case @cubic_id
    when STORM_CUBIC then "Storm Cubic"
    when VAMPIRIC_CUBIC then "Vampiric Cubic"
    when LIFE_CUBIC then "Life Cubic "
    when VIPER_CUBIC then "Viper Cubic"
    when POLTERGEIST_CUBIC then "Poltergeist Cubic"
    when BINDING_CUBIC then "Binding Cubic"
    when AQUA_CUBIC then "Aqua Cubic"
    when SPARK_CUBIC then "Spark Cubic"
    when ATTRACT_CUBIC then "Attract Cubic"
    when SMART_CUBIC_ARCANALORD then "Smart Cubic AL"
    when SMART_CUBIC_ELEMENTALMASTER then "Smart Cubic EM"
    when SMART_CUBIC_SPECTRALMASTER then "Smart Cubic SM"
    when SMART_CUBIC_EVATEMPLAR then "Smart Cubic ET"
    when SMART_CUBIC_SHILLIENTEMPLAR then "Smart Cubic ST"
    else "unknown cubic!"
    end

    io << @owner << "'s " << name
  end
end
