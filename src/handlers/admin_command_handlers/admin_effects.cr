module AdminCommandHandler::AdminEffects
  extend self
  extend AdminCommandHandler
  include Packets::Outgoing

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
      begin
        val1 = st.shift
        intensity = val1.to_i
        val2 = st.shift
        duration = val2.to_i
        eq = Earthquake.new(*pc.xyz, intensity, duration)
        pc.broadcast_packet(eq)
      rescue e
        warn e
        pc.send_message("Usage: //earthquake <intensity> <duration>")
      end
    elsif command.starts_with?("admin_atmosphere")
      begin
        type = st.shift
        state = st.shift
        duration = st.shift.to_i
        admin_atmosphere(type, state, duration, pc)
      rescue e
        warn e
        pc.send_message("Usage: //atmosphere <signsky dawn|dusk>|<sky day|night|red> <duration>")
      end
    elsif command == "admin_play_sounds"
      AdminHtml.show_admin_html(pc, "songs/songs#{command.from(18)}.htm")
    elsif command.starts_with?("admin_play_sound")
      begin
        play_admin_sound(pc, command.from(17))
      rescue e
        pc.send_message("Usage: //play_sound <soundname>")
        warn e
      end
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
      begin
        val = st.shift.to_i
        send_message = pc.affected_by_skill?(7029)
        pc.stop_skill_effects(val == 0 && send_message, 7029)
        if val >= 1 && val <= 4
          skill = SkillData[7029, val]
          pc.do_simultaneous_cast(skill)
        end
      rescue e
        warn e
        pc.send_message("Usage: //gmspeed <value> (0=off...4=max)")
      end

      if command.includes?("_menu")
        command = ""
        AdminHtml.show_admin_html(pc, "gm_menu.htm")
      end
    elsif command.starts_with?("admin_polyself")
      begin
        id = st.shift
        pc.poly.set_poly_info("npc", id)
        pc.tele_to_location(pc.location)
        info1 = CharInfo.new(pc)
        pc.broadcast_packet(info1)
        info2 = UserInfo.new(pc)
        pc.send_packet(info2)
        pc.broadcast_packet(ExBrExtraUserInfo.new(pc))
      rescue e
        warn e
        pc.send_message("Usage: //polyself <npcId>")
      end
    elsif command.starts_with?("admin_unpolyself")
      pc.poly.set_poly_info(nil, "1")
      pc.decay_me
      pc.spawn_me(*pc.xyz)
      info1 = CharInfo.new(pc)
      pc.broadcast_packet(info1)
      info2 = UserInfo.new(pc)
      pc.send_packet(info2)
      pc.broadcast_packet(ExBrExtraUserInfo.new(pc))
    elsif command == "admin_clearteams"
      begin
        pc.known_list.known_players.each_value do |pl|
          pl.team = Team::NONE
          pl.broadcast_user_info
        end
      rescue e
        warn e
      end
    elsif command.starts_with?("admin_setteam_close")
      begin
        val = st.shift
        radius = 400
        unless st.empty?
          radius = st.shift.to_i
        end
        team = Team.parse(val)
        pc.known_list.each_character(radius) do |char|
          char.team = team
        end
      rescue e
        warn e
        pc.send_message("Usage: //setteam_close <none|blue|red> [radius]")
      end
    elsif command.starts_with?("admin_setteam")
      begin
        unless target = pc.target.as?(L2Character)
          return false
        end
        team = Team.parse(st.shift)
        target.team = team
      rescue e
        warn e
        pc.send_message("Usage: //setteam <none|blue|red>")
      end
    elsif command.starts_with?("admin_social")
      begin
        obj = pc.target

        if st.size == 2
          social = st.shift.to_i
          if target = st.shift?
            if player = L2World.get_player(target)
              if perform_social(social, player, pc)
                pc.send_message("#{player.name} was affected by your command.")
              end
            else
              begin
                radius = target.to_i
                pc.known_list.known_objects.each_value do |object|
                  if pc.inside_radius?(object, radius, false, false)
                    perform_social(social, object, pc)
                  end
                end
                pc.send_message("#{radius} units radius affected by your command.")
              rescue e
                warn e
                pc.send_message("Incorrect parameter.")
              end
            end
          end
        elsif st.size == 1
          social = st.shift.to_i
          obj ||= pc

          if perform_social(social, obj, pc)
            pc.send_message("#{obj.name} was affected by your command.")
          end
        elsif !command.includes?("menu")
          pc.send_message("Usage: //social <social_id> [player_name|radius]")
        end
      rescue e
        warn e
      end
    elsif command.starts_with?("admin_ave_abnormal", "admin_ave_special", "admin_ave_event")
      if st.empty?
        tmp = command.sub("admin_", "")
        pc.send_message("Usage: //#{tmp} <AbnormalVisualEffect> [radius]")
      else
        param1 = st.shift
        unless ave = AbnormalVisualEffect.parse?(param1)
          return false
        end
        radius = 0
        if st.size == 1
          param2 = st.shift
          if param2.num?
            radius = param2.to_i
          end
        end

        if radius > 0
          pc.known_list.known_objects.each_value do |object|
            if pc.inside_radius?(object, radius, false, false)
              perform_abnormal_visual_effect(ave, object)
            end
          end

          pc.send_message("Affected all characters in radius #{param2} by #{param1} abnormal visual effect.")
        else
          obj = pc.target || pc
          if perform_abnormal_visual_effect(ave, obj)
            pc.send_message("#{obj.name} affected by #{param1} abnormal visual effect.")
          else
            pc.send_packet(SystemMessageId::NOTHING_HAPPENED)
          end
        end
      end
    elsif command.starts_with?("admin_effect")
      begin
        obj = pc.target
        level = hit_time = 1
        skill = st.shift.to_i
        unless st.empty?
          level = st.shift.to_i
        end
        unless st.empty?
          hit_time = st.shift.to_i
        end
        obj ||= pc
        if obj.is_a?(L2Character)
          msu = MagicSkillUse.new(obj, pc, skill, level, hit_time, 0)
          obj.broadcast_packet(msu)
          pc.send_message("#{obj.name} performed skill animation (id: #{skill}, level: #{level}) by your command")
        else
          pc.send_packet(SystemMessageId::INCORRECT_TARGET)
        end
      rescue e
        warn e
        pc.send_message("Usage: //effect skill [level | level hittime]")
      end
    elsif command.starts_with?("admin_set_displayeffect")
      unless npc = pc.target.as?(L2Npc)
        pc.send_packet(SystemMessageId::NOTHING_HAPPENED)
        return false
      end

      begin
        type = st.shift
        effect = type.to_i
        npc.display_effect = effect
      rescue e
        warn e
        pc.send_message("Usage: //set_displayeffect <id>")
      end
    end

    if command.includes?("menu") || command.includes?("ave_")
      show_main_page(pc, command)
    end

    true
  end

  private def perform_abnormal_visual_effect(ave, target)
    if target.is_a?(L2Character)
      if target.has_abnormal_visual_effect?(ave)
        target.stop_abnormal_visual_effect(true, ave)
      else
        target.start_abnormal_visual_effect(true, ave)
      end

      return true
    end

    false
  end

  private def perform_social(action, target, pc)
    begin
      if target.is_a?(L2Character)
        if target.is_a?(L2ChestInstance)
          pc.send_packet(SystemMessageId::NOTHING_HAPPENED)
          return false
        end

        if target.is_a?(L2Npc) && (action < 1 || action > 3)
          pc.send_packet(SystemMessageId::NOTHING_HAPPENED)
          return false
        end

        if target.is_a?(L2PcInstance) && (action < 2 || (action > 18 && action != SocialAction::LEVEL_UP))
          pc.send_packet(SystemMessageId::NOTHING_HAPPENED)
          return false
        end

        sa = SocialAction.new(target.l2id, action)
        target.broadcast_packet(sa)
      else
        return false
      end
    rescue e
      warn e
    end

    true
  end

  private def admin_atmosphere(type, state, duration, pc)
    case type
    when "signsky"
      case state
      when "dawn"
        packet = SSQInfo.new(2)
      when "dusk"
        packet = SSQInfo.new(1)
      else
        # automatically added
      end

    when "sky"
      case state
      when "night"
        packet = SunSet::STATIC_PACKET
      when "day"
        packet = SunRise::STATIC_PACKET
      when "red"
        if duration != 0
          packet = ExRedSky.new(duration)
        else
          packet = ExRedSky.new(10)
        end
      else
        # automatically added
      end

    else
      pc.send_message("Usage: //atmosphere <signsky dawn|dusk>|<sky day|night|red> <duration>")
    end

    if packet
      Broadcast.to_all_online_players(packet)
    end
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
    else
      # automatically added
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