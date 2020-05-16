module ItemHandler::ItemSkillsTemplate
  extend self
  extend ItemHandler

  def use_item(playable, item, force) : Bool
    unless playable.player? || playable.pet?
      return false
    end

    unless TvTEvent.on_scroll_use(playable.l2id)
      playable.action_failed
      return false
    end

    if playable.pet? && !item.tradeable?
      playable.send_packet(SystemMessageId::ITEM_NOT_FOR_PETS)
      return false
    end

    unless check_reuse(playable, nil, item)
      # debug "#check_reuse returned false."
      return false
    end

    tpl = item.etc_item!
    skills = tpl.skills

    if skills.nil? || skills.empty?
      warn { "#{tpl} has no skills." }
      return false
    end

    has_consume_skill = false

    skills.each do |sh|
      if skill = sh.skill
        if skill.item_consume_id > 0
          has_consume_skill = true
        end

        unless skill.check_condition(playable, playable.target, false)
          # debug { "Failed condition for #{skill}." }
          return false
        end

        if playable.skill_disabled?(skill)
          # debug { "#{skill} is disabled." }
          return false
        end

        unless check_reuse(playable, skill, item)
          # debug "Failed check_reuse"
          return false
        end

        if !item.potion? && !item.elixir? && !item.scroll? && playable.casting_now?
          return false
        end

        if playable.pet?
          sm = SystemMessage.pet_uses_s1
          sm.add_skill_name(skill)
          playable.send_packet(sm)
        end

        if skill.simultaneous_cast? || ((tpl.has_immediate_effect? || tpl.has_ex_immediate_effect?) && skill.static?)
          # debug "Doing simultaneous cast."
          playable.do_simultaneous_cast(skill)
        else
          playable.intention = AI::IDLE
          unless playable.use_magic(skill, force, false)
            # debug "#use_magic returned false."
            return false
          end
        end

        if skill.reuse_delay > 0
          playable.add_time_stamp(skill, skill.reuse_delay.to_i64)
        end
      end
    end

    if check_consume(item, has_consume_skill)
      unless playable.destroy_item("Consume", item.l2id, 1, playable, false)
        playable.send_packet(SystemMessageId::NOT_ENOUGH_ITEMS)
        return false
      end
    end

    true
  end

  private def check_consume(item, has_consume_skill)
    case item.template.default_action
    when ActionType::CAPSULE, ActionType::SKILL_REDUCE
      if !has_consume_skill && item.template.has_immediate_effect?
        return true
      end
    else
      # [automatically added else]
    end


    false
  end

  private def check_reuse(playable, skill, item)
    remaining_time = if skill
      playable.get_skill_remaining_reuse_time(skill.hash).to_i64
    else
      playable.get_item_remaining_reuse_time(item.l2id).to_i64
    end

    available = remaining_time <= 0

    if playable.player? && !available
      hours = remaining_time // 3_600_000
      minutes = (remaining_time % 3_600_000) // 60_000
      seconds = (remaining_time // 1000) % 60

      if hours > 0
        sm = SystemMessage.s2_hours_s3_minutes_s4_seconds_remaining_for_reuse_s1
        if skill.nil? || skill.static?
          sm.add_item_name(item)
        else
          sm.add_skill_name(skill)
        end

        sm.add_int(hours)
        sm.add_int(minutes)
      elsif minutes > 0
        sm = SystemMessage.s2_minutes_s3_seconds_remaining_for_reuse_s1
        if skill.nil? || skill.static?
          sm.add_item_name(item)
        else
          sm.add_skill_name(skill)
        end

        sm.add_int(minutes)
      else
        sm = SystemMessage.s2_seconds_remaining_for_reuse_s1
        if skill.nil? || skill.static?
          sm.add_item_name(item)
        else
          sm.add_skill_name(skill)
        end
      end

      sm.add_int(seconds)
      playable.send_packet(sm)
    end

    available
  end
end
