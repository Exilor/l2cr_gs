class SkillChannelizer
  @task : TaskScheduler::PeriodicTask?

  getter! channelized : Array(L2Character)
  getter! skill : Skill

  getter_initializer channelizer : L2Character

  def has_channelized? : Bool
    !!@channelized
  end

  def start_channeling(skill : Skill)
    if channeling?
      return
    end

    @skill = skill
    delay = skill.channeling_tick_initial_delay
    interval = skill.channeling_tick_interval
    @task = ThreadPoolManager.schedule_general_at_fixed_rate(self, delay, interval)
  end

  def stop_channeling
    unless channeling?
      return
    end

    if task = @task
      task.cancel
      @task = nil
    end

    if ch = @channelized
      ch.each do |char|
        char.skill_channelized
        .remove_channelizer(skill.channeling_skill_id, @channelizer)
      end

      @channelized = nil
    end

    @skill = nil
  end

  def channeling? : Bool
    !!@task
  end

  def call
    return unless channeling?
    return unless _skill = @skill
    if _skill.mp_per_channeling > 0
      if @channelizer.current_mp < _skill.mp_per_channeling
        if @channelizer.player?
          @channelizer.send_packet(SystemMessageId::SKILL_REMOVED_DUE_LACK_MP)
        end
        @channelizer.abort_cast
        return
      end
      @channelizer.reduce_current_mp(_skill.mp_per_channeling.to_f)
    end

    if _skill.channeling_skill_id > 0
      unless SkillData[_skill.channeling_skill_id, 1]?
        @channelizer.abort_cast
        return
      end

      target_list = [] of L2Character

      _skill.get_target_list(@channelizer).each do |char|
        if char.is_a?(L2Character)
          target_list << char
          char.skill_channelized
          .add_channelizer(_skill.channeling_skill_id, channelizer)
        end
      end

      return if target_list.empty?

      @channelized = target_list

      target_list.each do |character|
        if !Util.in_range?(_skill.effect_range, @channelizer, character, true)
          next
        elsif !GeoData.can_see_target?(@channelizer, character)
          next
        else
          max_skill_level = SkillData.get_max_level(_skill.channeling_skill_id)
          skill_level = Math.min(character.skill_channelized.get_channelizers_size(_skill.channeling_skill_id), max_skill_level)
          info = character.effect_list.get_buff_info_by_skill_id(_skill.channeling_skill_id)

          if info.nil? || info.skill.level < skill_level
            unless skill = SkillData[_skill.channeling_skill_id, skill_level]?
              @channelizer.abort_cast
              return
            end

            if character.playable? && channelizer.player? && skill.bad?
              channelizer.as(L2PcInstance).update_pvp_status(character)
            end

            skill.apply_effects(channelizer, character)

            if _skill.use_spiritshot?
              if @channelizer.charged_shot?(ShotType::BLESSED_SPIRITSHOTS)
                @channelizer.set_charged_shot(ShotType::BLESSED_SPIRITSHOTS, false)
              else
                @channelizer.set_charged_shot(ShotType::SPIRITSHOTS, false)
              end
            else
              @channelizer.set_charged_shot(ShotType::SOULSHOTS, false)
            end
          end

          msl = Packets::Outgoing::MagicSkillLaunched.new(@channelizer, _skill.id, _skill.level, character)
          @channelizer.broadcast_packet(msl)
        end
      end
    end
  end
end
