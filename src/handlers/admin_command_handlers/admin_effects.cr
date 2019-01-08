module AdminCommandHandler::AdminEffects
  extend self
  extend AdminCommandHandler

  def use_admin_command(command, pc)
    st = command.split
    st.shift?

    if command == "admin_invis_menu"
      if pc.invisible?
        pc.invisible = false
        pc.broadcast_user_info
        pc.send_message("You are now visible.")
      else
        pc.invisible = true
        pc.broadcast_user_info
        pc.decay_me
        pc.spawn_me
        pc.send_message("You are now invisible.")
      end
    elsif command.starts_with?("admin_invis")
      pc.invisible = true
      pc.broadcast_user_info
      pc.decay_me
      pc.spawn_me
      pc.send_message("You are now invisible.")
    elsif command.starts_with?("admin_vis")
      pc.invisible = false
      pc.broadcast_user_info
      pc.send_message("You are now visible.")
    elsif command.starts_with?("admin_setinvis")
      unless target = pc.target.as?(L2Character)
        pc.send_packet(SystemMessageId::INCORRECT_TARGET)
        return false
      end

      target.invisible = !target.invisible?
      pc.send_message("You\"ve made #{target.name} #{target.invisible? ? "invisible" : "visible"}.")
      if target.is_a?(L2PcInstance)
        target.broadcast_user_info
      end
    elsif command.starts_with?("admin_earthquake")
      pc.send_message("admin_earthquake not implemented yet.")
    elsif command.starts_with?("admin_atmosphere")
      pc.send_message("admin_atmosphere not implemented yet.")
    elsif command == "admin_play_sounds"
      AdminCommandHandler::AdminHtml.show_admin_html(pc, "songs/songs#{command.from(18)}.htm")
    elsif command.starts_with?("admin_play_sound")
      pc.send_message("admin_play_sound* is not implemented yet.")
    elsif command == "admin_para_all"
      pc.known_list.each_character do |p|
        unless p.gm?
          p.start_abnormal_visual_effect(true, AbnormalVisualEffect::PARALYZE)
          p.paralyzed = true
          p.start_paralyze
        end
      end
    elsif command == "admin_unpara_all"
      pc.known_list.each_character do |p|
        p.stop_abnormal_visual_effect(true, AbnormalVisualEffect::PARALYZE)
        p.paralyzed = false
      end
    elsif command.starts_with?("admin_para")
      type = st.shift? || "1"
      player = pc.target
      if player.is_a?(L2Character)
        if type == "1"
          player.start_abnormal_visual_effect(true, AbnormalVisualEffect::PARALYZE)
        else
          player.start_abnormal_visual_effect(true, AbnormalVisualEffect::FLESH_STONE)
        end
        player.paralyzed = true
        player.start_paralyze
      end
    elsif command.starts_with?("admin_unpara")
      type = st.shift? || "1"
      player = pc.target
      if player.is_a?(L2Character)
        if type == "1"
          player.stop_abnormal_visual_effect(true, AbnormalVisualEffect::PARALYZE)
        else
          player.stop_abnormal_visual_effect(true, AbnormalVisualEffect::FLESH_STONE)
        end
        player.paralyzed = false
      end
    elsif command.starts_with?("admin_bighead")
      if player = pc.target.as?(L2Character)
        player.start_abnormal_visual_effect(true, AbnormalVisualEffect::BIG_HEAD)
      end
    elsif command.starts_with?("admin_shrinkhead")
      if player = pc.target.as?(L2Character)
        player.stop_abnormal_visual_effect(true, AbnormalVisualEffect::BIG_HEAD)
      end
    elsif command.starts_with?("admin_gmspeed")
      val = st.shift.to_i
      send_message = pc.affected_by_skill?(7029)
      pc.stop_skill_effects(val == 0 && send_message, 7029)
      if val >= 1 && val <= 4
        skill = SkillData[7029, val]
        pc.do_simultaneous_cast(skill)
      end

      if command.includes?("_menu")
        command = ""
        AdminCommandHandler::AdminHtml.show_admin_html(pc, "gm_menu.htm")
      end

    elsif command.starts_with?("admin_polyself")
      warn %q(TODO: command.starts_with?("admin_polyself"))
    elsif command.starts_with?("admin_unpolyself")
      warn %q(TODO: command.starts_with?("admin_unpolyself"))
    elsif command == "admin_clearteams"
      warn %q(TODO: command == "admin_clearteams")
    elsif command.starts_with?("admin_setteam_close")
      warn %q(TODO: command.starts_with?("admin_setteam_close"))
    elsif command.starts_with?("admin_setteam")
      warn %q(TODO: command.starts_with?("admin_setteam"))
    elsif command.starts_with?("admin_social")
      warn %q(TODO: command.starts_with?("admin_social"))
    elsif command.starts_with?("admin_ave_abnormal", "admin_ave_special", "admin_ave_event")
      warn %q(TODO: command.starts_with?("admin_ave_abnormal", "admin_ave_special", "admin_ave_event"))
    elsif command.starts_with?("admin_effect")
      warn %q(TODO: command.starts_with?("admin_effect"))
    elsif command.starts_with?("admin_set_displayeffect")
      warn %q(TODO: command.starts_with?("admin_set_displayeffect"))
    end

    if command.includes?("menu") || command.includes?("ave_")
      show_main_page(pc, command)
    end

    true
  end

  private def play_admin_sound(pc, sound)
    snd = PlaySound.create_sound(sound)
    pc.send_packet(snd)
    pc.broadcast_packet(snd)
    pc.send_message("Playing #{sound}.")
  end

  private def show_main_page(pc, command)
    filename = "effects_menu.htm"

    case command
    when .includes?("ave_abnormal")
      filename = "ave_abnormal.htm"
    when .includes?("ave_event")
      filename = "ave_event.htm"
    when .includes?("social")
      filename = "social.htm"
    end

    AdminHtml.show_admin_html(pc, filename)
  end

  def commands
    {
      "admin_invis",
      "admin_invisible",
      "admin_setinvis",
      "admin_vis",
      "admin_visible",
      "admin_invis_menu",
      "admin_earthquake",
      "admin_earthquake_menu",
      "admin_bighead",
      "admin_shrinkhead",
      "admin_gmspeed",
      "admin_gmspeed_menu",
      "admin_unpara_all",
      "admin_para_all",
      "admin_unpara",
      "admin_para",
      "admin_unpara_all_menu",
      "admin_para_all_menu",
      "admin_unpara_menu",
      "admin_para_menu",
      "admin_polyself",
      "admin_unpolyself",
      "admin_polyself_menu",
      "admin_unpolyself_menu",
      "admin_clearteams",
      "admin_setteam_close",
      "admin_setteam",
      "admin_social",
      "admin_effect",
      "admin_effect_menu",
      "admin_ave_abnormal",
      "admin_ave_special",
      "admin_ave_event",
      "admin_social_menu",
      "admin_play_sounds",
      "admin_play_sound",
      "admin_atmosphere",
      "admin_atmosphere_menu",
      "admin_set_displayeffect",
      "admin_set_displayeffect_menu"
    }
  end
end
