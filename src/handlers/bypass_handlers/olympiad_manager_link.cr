module BypassHandler::OlympiadManagerLink
  extend self
  extend BypassHandler

  BUFFS = {
    4357, # Haste Lv2
    4342, # Wind Walk Lv2
    4356, # Empower Lv3
    4355, # Acumen Lv3
    4351, # Concentration Lv6
    4345, # Might Lv3
    4358, # Guidance Lv3
    4359, # Focus Lv3
    4360, # Death Whisper Lv3
    4352  # Berserker Spirit Lv2
  }

  class_getter(fewer_than) { "Fewer than #{Config.alt_oly_reg_display}" }
  class_getter(more_than) { "More than #{Config.alt_oly_reg_display}" }
  class_getter(gate_pass) { Config.alt_oly_comp_ritem }

  def use_bypass(command, pc, target) : Bool
    unless target.is_a?(L2OlympiadManagerInstance)
      return false
    end

    begin
      if command.downcase.starts_with?("olympiaddesc")
        val = command[13].to_i
        suffix = command.from(14)
        target.show_chat_window(pc, val, suffix)
      elsif command.downcase.starts_with?("olympiadnoble")
        html = NpcHtmlMessage.new(target.l2id)
        if pc.cursed_weapon_equipped?
          html.set_file(pc, Olympiad::OLYMPIAD_HTML_PATH + "noble_cursed_weapon.htm")
          pc.send_packet(html)
          return false
        end
        if pc.class_index != 0
          html.set_file(pc, Olympiad::OLYMPIAD_HTML_PATH + "noble_sub.htm")
          html["%objectId%"] = target.l2id
          pc.send_packet(html)
          return false
        end
        if !pc.noble? || pc.class_id.level < 3
          html.set_file(pc, Olympiad::OLYMPIAD_HTML_PATH + "noble_thirdclass.htm")
          html["%objectId%"] = target.l2id
          pc.send_packet(html)
          return false
        end

        val = command.from(14).to_i
        case val
        when 0 # H5 match selection
          if !OlympiadManager.registered?(pc)
            html.set_file(pc, Olympiad::OLYMPIAD_HTML_PATH + "noble_desc2a.htm")
            html["%objectId%"] = target.l2id
            html["%olympiad_period%"] = Olympiad.instance.period
            html["%olympiad_cycle%"] = Olympiad.instance.current_cycle
            html["%olympiad_opponent%"] = OlympiadManager.count_opponents
            pc.send_packet(html)
          else
            html.set_file(pc, Olympiad::OLYMPIAD_HTML_PATH + "noble_unregister.htm")
            html["%objectId%"] = target.l2id
            pc.send_packet(html)
          end
        when 1 # unregister
          OlympiadManager.unregister_noble(pc)
        when 2 # show waiting list | TODO: cleanup (not used anymore)
          non_classed = OlympiadManager.registered_non_class_based.size
          teams = OlympiadManager.registered_teams_based.size
          all_classed = OlympiadManager.registered_class_based.values
          classed = 0
          all_classed.each do |cls|
            if cls
              classed &+= cls.size
            end
          end
          html.set_file(pc, Olympiad::OLYMPIAD_HTML_PATH + "noble_registered.htm")
          if Config.alt_oly_reg_display > 0
            html["%listClassed%"] = classed < Config.alt_oly_reg_display ? fewer_than : more_than
            html["%listNonClassedTeam%"] = teams < Config.alt_oly_reg_display ? fewer_than : more_than
            html["%listNonClassed%"] = non_classed < Config.alt_oly_reg_display ? fewer_than : more_than
          else
            html["%listClassed%"] = classed
            html["%listNonClassedTeam%"] = teams
            html["%listNonClassed%"] = non_classed
          end
          html["%objectId%"] = target.l2id
          pc.send_packet(html)
        when 3 # There are %points% Grand Olympiad points granted for this event. | TODO: cleanup (not used anymore)
          points = Olympiad.instance.get_noble_points(pc.l2id)
          html.set_file(pc, Olympiad::OLYMPIAD_HTML_PATH + "noble_points1.htm")
          html["%points%"] = points
          html["%objectId%"] = target.l2id
          pc.send_packet(html)
        when 4 # register non classed
          OlympiadManager.register_noble(pc, CompetitionType::NON_CLASSED)
        when 5 # register classed
          OlympiadManager.register_noble(pc, CompetitionType::CLASSED)
        when 6 # request tokens reward
          passes = Olympiad.instance.get_noblesse_passes(pc, false)
          if passes > 0
            html.set_file(pc, Olympiad::OLYMPIAD_HTML_PATH + "noble_settle.htm")
            html["%objectId%"] = target.l2id
            pc.send_packet(html)
          else
            html.set_file(pc, Olympiad::OLYMPIAD_HTML_PATH + "noble_nopoints2.htm")
            html["%objectId%"] = target.l2id
            pc.send_packet(html)
          end
        when 7 # Equipment Rewards
          MultisellData.separate_and_send(102, pc, target, false)
        when 8 # Misc. Rewards
          MultisellData.separate_and_send(103, pc, target, false)
        when 9 # Your Grand Olympiad Score from the previous period is %points% point(s) | TODO: cleanup (not used anymore)
          point = Olympiad.instance.get_last_noble_olympiad_points(pc.l2id)
          html.set_file(pc, Olympiad::OLYMPIAD_HTML_PATH + "noble_points2.htm")
          html["%points%"] = point
          html["%objectId%"] = target.l2id
          pc.send_packet(html)
        when 10 # give tokens to player
          passes = Olympiad.instance.get_noblesse_passes(pc, true).to_i64
          if passes > 0
            item = pc.inventory.add_item("Olympiad", gate_pass, passes, pc, target).not_nil!

            iu = InventoryUpdate.modified(item)
            pc.send_packet(iu)

            sm = SystemMessage.earned_s2_s1_s
            sm.add_long(passes)
            sm.add_item_name(item)
            pc.send_packet(sm)
          end
        when 11 # register team
          OlympiadManager.register_noble(pc, CompetitionType::TEAMS)
        else
          warn { "Couldn't send packet for request '#{val}'." }
        end
      elsif command.downcase.starts_with?("olybuff")
        buff_count = pc.olympiad_buff_count
        if buff_count <= 0
          return false
        end

        html = NpcHtmlMessage.new(target.l2id)
        params = command.split

        unless params[1].number?
          warn { "npcId = #{target.id} has invalid buffGroup set in the bypass for the buff selected: #{params[1]}." }
          return false
        end

        index = params[1].to_i
        if index < 0 || index > BUFFS.size
          warn { "npcId = #{target.id} has invalid index sent in the bypass: #{index}." }
          return false
        end

        npc_buff_group_info = NpcBufferTable.get_skill_info(target.id, BUFFS[index])
        unless npc_buff_group_info
          warn { "npcId = #{target.id} Location: #{target.x}, #{target.y}, #{target.y} Player: #{pc} tried to use skill group #{params[1]} not assigned to the NPC Buffer." }
          return false
        end

        if buff_count > 0
          if skill = npc_buff_group_info.skill.skill?
            target.target = pc

            buff_count &-= 1
            pc.olympiad_buff_count = buff_count

            target.broadcast_packet(MagicSkillUse.new(target, pc, skill.id, skill.level, 0, 0))
            skill.apply_effects(pc, pc)
            if summon = pc.summon
              target.broadcast_packet(MagicSkillUse.new(target, summon, skill.id, skill.level, 0, 0))
              skill.apply_effects(summon, summon)
            end
          end
        end

        if buff_count > 0
          if buff_count == Config.alt_oly_max_buffs
            path = Olympiad::OLYMPIAD_HTML_PATH + "olympiad_buffs.htm"
          else
            path = Olympiad::OLYMPIAD_HTML_PATH + "olympiad_5buffs.htm"
          end
          html.set_file(pc, path)
          html["%objectId%"] = target.l2id
          pc.send_packet(html)
        else
          html.set_file(pc, Olympiad::OLYMPIAD_HTML_PATH + "olympiad_nobuffs.htm")
          html["%objectId%"] = target.l2id
          pc.send_packet(html)
          target.decay_me
        end
      elsif command.downcase.starts_with?("olympiad")
        val = command[9].to_i

        reply = NpcHtmlMessage.new(target.l2id)

        case val
        when 2 # show rank for a specific class, for example >> Olympiad 1_88
          class_id = command.from(11).to_i
          if class_id.between?(88, 118) || class_id.between?(131, 134) || class_id == 136
            names = Olympiad.instance.get_class_leader_board(class_id)
            reply.set_file(pc, Olympiad::OLYMPIAD_HTML_PATH + "olympiad_ranking.htm")

            index = 1
            names.each do |name|
              reply["%place#{index}%"] = index
              reply["%rank#{index}%"] = name
              index &+= 1
              if index > 10
                break
              end
            end
            while index <= 10
              reply["%place#{index}%"] = ""
              reply["%rank#{index}%"] = ""
              index &+= 1
            end

            reply["%objectId%"] = target.l2id
            pc.send_packet(reply)
          end
        when 4 # hero list
          pc.send_packet(ExHeroList.new)
        when 5 # hero certification
          if Hero.unclaimed_hero?(pc.l2id)
            Hero.claim_hero(pc)
            reply.set_file(pc, Olympiad::OLYMPIAD_HTML_PATH + "hero_receive.htm")
          else
            reply.set_file(pc, Olympiad::OLYMPIAD_HTML_PATH + "hero_notreceive.htm")
          end
          pc.send_packet(reply)
        else
          warn { "Olympiad System: Couldnt send packet for request #{val}." }
        end
      end
    rescue e
      error e
    end

    true
  end

  def commands
    {
      "olympiaddesc",
      "olympiadnoble",
      "olybuff",
      "olympiad"
    }
  end
end
