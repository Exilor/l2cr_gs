require "./l2_npc_instance"

class L2VillageMasterInstance < L2NpcInstance
  def instance_type : InstanceType
    InstanceType::L2VillageMasterInstance
  end

  def get_html_path(npc_id, val)
    pom = val == 0 ? npc_id : "#{npc_id}-#{val}"
    "data/html/villagemaster/#{pom}.htm"
  end

  def on_bypass_feedback(pc : L2PcInstance, command : String)
    st = command.split

    case st.shift?
    when "create_clan"
      unless st.empty?
        clan_name = st.shift
        unless valid_name?(clan_name)
          pc.send_packet(SystemMessageId::CLAN_NAME_INCORRECT)
          return
        end
        ClanTable.create_clan(pc, clan_name)
      end
    when "create_academy"
      pc.send_message("Bypass \"create_academy\" not implemented.")
    when "rename_pledge"
      pc.send_message("Bypass \"rename_pledge\" not implemented.")
    when "create_royal"
      pc.send_message("Bypass \"create_royal\" not implemented.")
    when "create_knight"
      pc.send_message("Bypass \"create_knight\" not implemented.")
    when "assign_subpl_leader"
      pc.send_message("Bypass \"assign_subpl_leader\" not implemented.")
    when "create_ally"
      pc.send_message("Bypass \"create_ally\" not implemented.")
    when "dissolve_ally"
      pc.send_message("Bypass \"dissolve_ally\" not implemented.")
    when "dissolve_clan"
      pc.send_message("Bypass \"dissolve_clan\" not implemented.")
    when "change_clan_leader"
      pc.send_message("Bypass \"change_clan_leader\" not implemented.")
    when "cancel_clan_leader_change"
      pc.send_message("Bypass \"cancel_clan_leader_change\" not implemented.")
    when "recover_clan"
      pc.send_message("Bypass \"recover_clan\" not implemented.")
    when "increase_clan_level"
      if pc.clan.level_up_clan(pc)
        pc.broadcast_packet(MagicSkillUse.new(pc, 5103, 1, 0, 0))
        pc.broadcast_packet(MagicSkillLaunched.new(pc, 5103, 1))
      end
    when "learn_clan_skills"
      pc.send_message("Bypass \"learn_clan_skills\" not implemented.")
    when "Subclass"
      if pc.casting_now? || pc.casting_simultaneously_now?
        pc.send_packet(SystemMessageId::SUBCLASS_NO_CHANGE_OR_CREATE_WHILE_SKILL_IN_USE)
        return
      end

      html = NpcHtmlMessage.new(l2id)

      if pc.transformation?
        html.set_file(pc, "data/html/villagemaster/SubClass_NoTransformed.htm")
        pc.send_packet(html)
        return
      end

      if pc.has_summon?
        html.set_file(pc, "data/html/villagemaster/SubClass_NoSummon.htm")
        pc.send_packet(html)
        return
      end

      unless pc.inventory_under_90?(true)
        pc.send_packet(SystemMessageId::NOT_SUBCLASS_WHILE_INVENTORY_FULL)
        return
      end

      if pc.weight_penalty >= 2
        pc.send_packet(SystemMessageId::NOT_SUBCLASS_WHILE_OVERWEIGHT)
        return
      end

      cmd_choice = param_one = param_two = 0
      begin
        cmd_choice = command[9..10].strip.to_i # .. or ... ?
        end_index = command.index(' ', 11) || command.size

        if command.size > 11
          param_one = command[11..end_index].strip.to_i # .. or ... ?
          if command.size > end_index
            param_two = command.from(end_index).strip.to_i
          end
        end
      rescue e
        warn e
      end

      subs_available = nil
      debug "Command: #{cmd_choice}."
      exit_case = false

      case cmd_choice
      when 0
        html.set_file(pc, get_subclass_menu(pc.race))
      when 1 # add subclass
        if pc.total_subclasses >= Config.max_subclass
          debug "#{pc.name} already has the maximum number of subclasses #{Config.max_subclass}."
          html.set_file(pc, subclass_fail)
          exit_case = true
        end
        unless exit_case
          subs_available = get_available_subclasses(pc)
          debug subs_available
          if subs_available && !subs_available.empty?
            html.set_file(pc, "data/html/villagemaster/SubClass_Add.htm")
            content1 = subs_available.map do |sub|
              "<a action=\"bypass -h npc_%objectId%_Subclass 4 #{sub.to_i}\" " \
              "msg=\"1268;#{ClassListData.get_class!(sub.to_i).class_name}" \
              "\">#{ClassListData.get_class!(sub.to_i).client_code}" \
              "</a><br>"
            end
            html["%list%"] = content1.join
          else
            debug "No subclasses available."
            if pc.race.elf? || pc.race.dark_elf?
              html.set_file(pc, "data/html/villagemaster/SubClass_Fail_Elves.htm")
              pc.send_packet(html)
            elsif pc.race.kamael?
              html.set_file(pc, "data/html/villagemaster/SubClass_Fail_Kamael.htm")
              pc.send_packet(html)
            else
              pc.send_message("There are no sub classes available at this time.")
            end
            return
          end
        end
      when 2 # change subclass
        if pc.subclasses.empty?
          html.set_file(pc, "data/html/villagemaster/SubClass_ChangeNo.htm")
        else
          content2 = String.build(200) do |io|
            if check_village_master(pc.base_class)
              io << "<a action=\"bypass -h npc_%objectId%_Subclass 5 0\">"
              ClassListData.get_class!(pc.base_class).client_code(io)
              io << "</a><br>"
            end

            each_subclass(pc) do |subclass|
              if check_village_master(subclass.class_definition)
                io << "<a action=\"bypass -h npc_%objectId%_Subclass 5 "
                io << subclass.class_index.to_s << "\">"
                ClassListData.get_class!(subclass.class_id).client_code(io)
                io << "</a><br>"
              end
            end
          end

          if content2.size > 0
            html.set_file(pc, "data/html/villagemaster/SubClass_Change.htm")
            html["%list%"] = content2
          else
            html.set_file(pc, "data/html/villagemaster/SubClass_ChangeNotFound.htm")
          end
        end
      when 3 # change/cancel subclass
        if pc.subclasses.empty?
          html.set_file(pc, "data/html/villagemaster/SubClass_ModifyEmpty.htm")
        else
          if pc.total_subclasses > 3
            html.set_file(pc, "data/html/villagemaster/SubClass_ModifyCustom.htm")
            content3 = String.build(200) do |io|
              class_index = 1
              each_subclass(pc) do |subclass|
                io << "Sub-class #{class_index}<br><a action=\"bypass -h "
                io << "npc_%objectId%_Subclass 6 #{subclass.class_index}\">"
                ClassListData.get_class!(subclass.class_id).client_code(io)
                io << "</a><br>"
                class_index += 1
              end
            end
            html["%list%"] = content3
          else
            html.set_file(pc, "data/html/villagemaster/SubClass_Modify.htm")
            if temp = pc.subclasses[1]?.try &.class_id
              html["%sub1%"] = ClassListData.get_class!(temp).client_code
            else
              html["<a action=\"bypass -h npc_%objectId%_Subclass 6 1\">%sub1%</a><br>"] = ""
            end

            if temp = pc.subclasses[2]?.try &.class_id
              html["%sub2%"] = ClassListData.get_class!(temp).client_code
            else
              html["<a action=\"bypass -h npc_%objectId%_Subclass 6 2\">%sub2%</a><br>"] = ""
            end

            if temp = pc.subclasses[3]?.try &.class_id
              html["%sub3%"] = ClassListData.get_class!(temp).client_code
            else
              html["<a action=\"bypass -h npc_%objectId%_Subclass 6 3\">%sub3%</a><br>"] = ""
            end
          end
        end
      when 4 # add subclass (action)
        unless pc.flood_protectors.subclass.try_perform_action("add subclass")
          warn "Player #{pc.name} tried to change subclass too fast."
          return
        end

        allow_addition = true

        if pc.total_subclasses >= Config.max_subclass
          debug "#{pc.name} already has the maximum number of subclasses (#{Config.max_subclass})."
          allow_addition = false
        end

        if pc.level < 75
          debug "#{pc.name}'s level is too low to add a subclass."
          allow_addition = false
        end

        if allow_addition && !pc.subclasses.empty?
          each_subclass(pc) do |subclass|
            if subclass.level < 75
              debug "A subclass is below level 75."
              allow_addition = false
              break
            end
          end
        end
        # commented out to test it
        warn "TODO: Uncomment code at #{__FILE__}##{__LINE__}."
        # if allow_addition && !Config.alt_game_subclass_without_quests
        #   allow_addition = check_quests(pc)
        # end

        if allow_addition && valid_new_subclass?(pc, param_one)
          unless pc.add_subclass(param_one, pc.total_subclasses + 1)
            debug "L2VillageMasterInstance#on_bypass_feedback (line #{__LINE__}) pc.add_subclass returned false"
            return
          end
          pc.change_active_class(pc.total_subclasses)
          html.set_file(pc, "data/html/villagemaster/SubClass_AddOk.htm")
          pc.send_packet(SystemMessageId::ADD_NEW_SUBCLASS)
        else
          debug "#{pc} failed to add a subclass."
          html.set_file(pc, subclass_fail)
        end
      when 5 # change class (action)
        unless pc.flood_protectors.subclass.try_perform_action("change class")
          warn "Player #{pc.name} tried to change subclass too fast."
          return
        end

        if pc.class_index == param_one
          html.set_file(pc, "data/html/villagemaster/SubClass_Current.htm")
          exit_case = true
        end

        unless exit_case
          if param_one == 0
            unless check_village_master(pc.base_class)
              return
            end
          else
            unless temp = pc.subclasses[param_one]?.try &.class_definition
              return
            end
            unless check_village_master(temp)
              return
            end
          end

          pc.change_active_class(param_one)
          pc.send_packet(SystemMessageId::SUBCLASS_TRANSFER_COMPLETED)
          return
        end
      when 6 # change/cancel subclass (choice)
        if param_one < 1 || param_one > Config.max_subclass
          return
        end

        subs_available = get_available_subclasses(pc)
        if subs_available.nil? || subs_available.empty?
          pc.send_message("There are no sub classes available at this time.")
          return
        end

        content6 = String.build(200) do |io|
          subs_available.each do |subclass|
            io << "<a action=\"bypass -h npc_%objectId%_Subclass 7 "
            io << "#{param_one} #{subclass.to_i}\" msg=\"1445;\">"
            ClassListData.get_class!(subclass.to_i).client_code(io)
            io << "</a><br>"
          end
        end

        case param_one
        when 1
          html.set_file(pc, "data/html/villagemaster/SubClass_ModifyChoice1.htm")
        when 2
          html.set_file(pc, "data/html/villagemaster/SubClass_ModifyChoice2.htm")
        when 3
          html.set_file(pc, "data/html/villagemaster/SubClass_ModifyChoice3.htm")
        else
          html.set_file(pc, "data/html/villagemaster/SubClass_ModifyChoice.htm")
        end

        html["%list%"] = content6
      when 7 # change subclass (action)
        unless pc.flood_protectors.subclass.try_perform_action("change class")
          warn "Player #{pc.name} tried to change subclass too fast."
          return
        end

        unless valid_new_subclass?(pc, param_two)
          return
        end

        if pc.modify_subclass(param_one, param_two)
          pc.abort_cast
          pc.stop_all_effects_except_those_that_last_through_death
          pc.stop_all_effects_not_stay_on_subclass_change
          pc.stop_cubics
          pc.active_class = param_one

          html.set_file(pc, "data/html/villagemaster/SubClass_ModifyOk.htm")
          html["%name%"] = ClassListData.get_class!(param_two).client_code

          pc.send_packet(SystemMessageId::ADD_NEW_SUBCLASS)
        else
          pc.active_class = 0
          pc.send_message("The sub class could not be added, you have been reverted to your base class.")
          return
        end
      end

      html["%objectId%"] = l2id
      pc.send_packet(html)
    else
      super
    end
  end

  private def get_subclass_menu(race : Race) : String
    if Config.alt_game_subclass_everywhere || !race.kamael?
      return "data/html/villagemaster/SubClass.htm"
    end

    "data/html/villagemaster/SubClass_NoOther.htm"
  end

  private def subclass_fail : String
    "data/html/villagemaster/SubClass_Fail.htm"
  end

  private def check_quests(pc : L2PcInstance) : Bool
    pc.noble? ||
    pc.quest_completed?("Q00234_FatesWhisper") ||
    pc.get_quest_state("Q00235_MimirsElixir")
  end

  private def get_available_subclasses(pc : L2PcInstance) # : EnumSet(PlayerClass)?
    current_base_id = pc.base_class
    base_cid = ClassId[current_base_id]
    if base_cid.level > 2
      base_class_id = base_cid.parent.to_i
    else
      base_class_id = current_base_id
    end

    avail_subs = PlayerClass[base_class_id].get_available_subclasses(pc)

    if avail_subs
      avail_subs.each do |pclass|
        unless check_village_master(pclass)
          avail_subs.delete(pclass)
          next
        end
        avail_class_id = pclass.to_i
        cid = ClassId[avail_class_id]
        each_subclass(pc) do |prev_subclass|
          subclass_id = ClassId[prev_subclass.class_id]
          if subclass_id.equals_or_child_of?(cid)
            avail_subs.delete(pclass)
            break
          end
        end
      end
    else
      debug "PlayerClass#get_available_subclasses returned nil."
    end

    avail_subs
  end

  private def valid_new_subclass?(pc : L2PcInstance, class_id : Int32) : Bool
    return false unless check_village_master(class_id)

    cid = ClassId[class_id]
    each_subclass(pc) do |sub|
      subclass_id = ClassId[sub.class_id]
      if subclass_id.equals_or_child_of?(cid)
        return false
      end
    end

    current_base_id = pc.base_class
    base_cid = ClassId[current_base_id]

    if base_cid.level > 2
      base_class_id = base_cid.parent.to_i
    else
      base_class_id = current_base_id
    end

    avail_subs = PlayerClass[base_class_id].get_available_subclasses(pc)
    if avail_subs.nil? || avail_subs.empty?
      return false
    end

    avail_subs.any? { |pclass| pclass.to_i == class_id }
  end

  private def check_village_master_race(pclass : PlayerClass?) : Bool
    true
  end

  private def check_village_master_teach_type(pclass : PlayerClass?) : Bool
    true
  end

  def check_village_master(pclass : Int32) : Bool
    check_village_master(PlayerClass[pclass])
  end

  def check_village_master(pclass : PlayerClass?) : Bool
    if Config.alt_game_subclass_everywhere
      true
    else
      check_village_master_race(pclass) && check_village_master_teach_type(pclass)
    end
  end

  private def each_subclass(pc : L2PcInstance, & : Subclass ->)
    pc.subclasses.each_value { |sub| yield sub }
  end

  private def valid_name?(name : String) : Bool
    Config.clan_name_template === name
  end

  def self.show_pledge_skill_list(pc : L2PcInstance)
    unless pc.clan_leader?
      html = NpcHtmlMessage.new
      html.set_file(pc, "data/html/villagemaster/NotClanLeader.htm")
      pc.send_packet(html)
      pc.action_failed
      return
    end

    skills = SkillTreesData.get_available_pledge_skills(pc.clan)
    asl = AcquireSkillList.new(AcquireSkillType::PLEDGE)

    skills.each do |s|
      asl.add_skill(s.skill_id, s.skill_level, s.skill_level, s.level_up_sp, s.social_class.to_i)
    end

    if skills.size > 0
      if pc.clan.level < 8
        sm = SystemMessage.do_not_have_further_skills_to_learn_s1
        if pc.clan.level < 5
          sm.add_int(5)
        else
          sm.add_int(pc.clan.level  + 1)
        end
        pc.send_packet(sm)
      else
        html = NpcHtmlMessage.new
        html.set_file(pc, "data/html/villagemaster/NoMoreSkills.htm")
        pc.send_packet(html)
      end
    else
      pc.send_packet(asl)
    end

    pc.action_failed
  end
end
