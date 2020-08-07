require "./l2_npc_instance"

class L2VillageMasterInstance < L2NpcInstance
  def instance_type : InstanceType
    InstanceType::L2VillageMasterInstance
  end

  def get_html_path(npc_id, val)
    if val == 0
      "data/html/villagemaster/#{npc_id}.htm"
    else
      "data/html/villagemaster/#{npc_id}-#{val}.htm"
    end
  end

  def on_bypass_feedback(pc : L2PcInstance, command : String)
    st = command.split

    case st.shift?
    when "create_clan"
      unless st.empty?
        clan_name = st.shift
        if !st.empty? || !valid_name?(clan_name)
          pc.send_packet(SystemMessageId::CLAN_NAME_INCORRECT)
          return
        end

        ClanTable.create_clan(pc, clan_name)
      end
    when "create_academy"
      unless st.empty?
        create_subpledge(pc, st.shift, nil, L2Clan::SUBUNIT_ACADEMY, 5)
      end
    when "rename_pledge"
      if st.size > 1
        rename_subpledge(pc, st.shift.to_i, st.shift)
      end
    when "create_royal"
      if st.size > 1
        create_subpledge(pc, st.shift, st.shift, L2Clan::SUBUNIT_ROYAL1, 6)
      end
    when "create_knight"
      if st.size > 1
        create_subpledge(pc, st.shift, st.shift, L2Clan::SUBUNIT_KNIGHT1, 7)
      end
    when "assign_subpl_leader"
      if st.size > 1
        assign_subpledge_leader(pc, st.shift, st.shift)
      end
    when "create_ally"
      unless (clan = pc.clan) && pc.clan_leader?
        pc.send_packet(SystemMessageId::ONLY_CLAN_LEADER_CREATE_ALLIANCE)
        return
      end

      unless st.empty?
        clan.create_ally(pc, st.shift)
      end
    when "dissolve_ally"
      pc.clan.not_nil!.dissolve_ally(pc)
    when "dissolve_clan"
      dissolve_clan(pc)
    when "change_clan_leader"
      unless (clan = pc.clan) && pc.clan_leader?
        pc.send_packet(SystemMessageId::YOU_ARE_NOT_AUTHORIZED_TO_DO_THAT)
        return
      end

      if st.empty?
        return
      end

      new_leader_name = st.shift

      unless member = clan.get_clan_member(new_leader_name)
        sm = SystemMessage.s1_does_not_exist
        sm.add_string(new_leader_name)
        pc.send_packet(sm)
        return
      end

      unless member.online? && (new_leader = member.player_instance)
        pc.send_packet(SystemMessageId::INVITED_USER_NOT_ONLINE)
        return
      end

      if new_leader.academy_member?
        pc.send_packet(SystemMessageId::RIGHT_CANT_TRANSFERRED_TO_ACADEMY_MEMBER)
        return
      end

      if Config.alt_clan_leader_instant_activation
        clan.set_new_leader(member)
        return
      end

      msg = NpcHtmlMessage.new(l2id)
      if clan.new_leader_id == 0
        clan.set_new_leader_id(member.l2id, true)
        msg.set_file(pc, "data/scripts/village_master/Clan/9000-07-success.htm")
      else
        msg.set_file(pc, "data/scripts/village_master/Clan/9000-07-in-progress.htm")
      end

      pc.send_packet(msg)
    when "cancel_clan_leader_change"
      unless (clan = pc.clan) && pc.clan_leader?
        pc.send_packet(SystemMessageId::YOU_ARE_NOT_AUTHORIZED_TO_DO_THAT)
        return
      end

      msg = NpcHtmlMessage.new(l2id)
      if clan.new_leader_id != 0
        clan.set_new_leader_id(0, true)
        msg.set_file(pc, "data/scripts/village_master/Clan/9000-07-canceled.htm")
      else
        msg.html = "<html><body>You don't have clan leader delegation applications submitted yet!</body></html>"
      end

      pc.send_packet(msg)
    when "recover_clan"
      recover_clan(pc)
    when "increase_clan_level"
      if pc.clan.not_nil!.level_up_clan(pc)
        pc.broadcast_packet(MagicSkillUse.new(pc, 5103, 1, 0, 0))
        pc.broadcast_packet(MagicSkillLaunched.new(pc, 5103, 1))
      end
    when "learn_clan_skills"
      L2VillageMasterInstance.show_pledge_skill_list(pc)
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
              "msg=\"1268;#{ClassListData.get_class(sub.to_i).class_name}" \
              "\">#{ClassListData.get_class(sub.to_i).client_code}" \
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
              ClassListData.get_class(pc.base_class).client_code(io)
              io << "</a><br>"
            end

            each_subclass(pc) do |subclass|
              if check_village_master(subclass.class_definition)
                io << "<a action=\"bypass -h npc_%objectId%_Subclass 5 "
                io << subclass.class_index.to_s << "\">"
                ClassListData.get_class(subclass.class_id).client_code(io)
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
                ClassListData.get_class(subclass.class_id).client_code(io)
                io << "</a><br>"
                class_index &+= 1
              end
            end
            html["%list%"] = content3
          else
            html.set_file(pc, "data/html/villagemaster/SubClass_Modify.htm")
            if temp = pc.subclasses[1]?.try &.class_id
              html["%sub1%"] = ClassListData.get_class(temp).client_code
            else
              html["<a action=\"bypass -h npc_%objectId%_Subclass 6 1\">%sub1%</a><br>"] = ""
            end

            if temp = pc.subclasses[2]?.try &.class_id
              html["%sub2%"] = ClassListData.get_class(temp).client_code
            else
              html["<a action=\"bypass -h npc_%objectId%_Subclass 6 2\">%sub2%</a><br>"] = ""
            end

            if temp = pc.subclasses[3]?.try &.class_id
              html["%sub3%"] = ClassListData.get_class(temp).client_code
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
          unless pc.add_subclass(param_one, pc.total_subclasses &+ 1)
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
            ClassListData.get_class(subclass.to_i).client_code(io)
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
          html["%name%"] = ClassListData.get_class(param_two).client_code

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
      return true
    end

    check_village_master_race(pclass) && check_village_master_teach_type(pclass)
  end

  private def each_subclass(pc : L2PcInstance, & : Subclass ->)
    pc.subclasses.each_value { |sub| yield sub }
  end

  private def valid_name?(name : String) : Bool
    name.matches?(Config.clan_name_template)
  end

  def self.show_pledge_skill_list(pc : L2PcInstance)
    unless (clan = pc.clan) && pc.clan_leader?
      html = NpcHtmlMessage.new
      html.set_file(pc, "data/html/villagemaster/NotClanLeader.htm")
      pc.send_packet(html)
      pc.action_failed
      return
    end

    skills = SkillTreesData.get_available_pledge_skills(clan)
    asl = AcquireSkillList.new(AcquireSkillType::PLEDGE)

    skills.each do |s|
      asl.add_skill(s.skill_id, s.skill_level, s.skill_level, s.level_up_sp, s.social_class.to_i)
    end

    if skills.size > 0
      if clan.level < 8
        sm = SystemMessage.do_not_have_further_skills_to_learn_s1
        if clan.level < 5
          sm.add_int(5)
        else
          sm.add_int(clan.level &+ 1)
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

  private def dissolve_clan(pc)
    unless (clan = pc.clan) && pc.clan_leader?
      pc.send_packet(SystemMessageId::YOU_ARE_NOT_AUTHORIZED_TO_DO_THAT)
      return
    end

    if clan.ally_id != 0
      pc.send_packet(SystemMessageId::CANNOT_DISPERSE_THE_CLANS_IN_ALLY)
      return
    end

    if clan.at_war?
      pc.send_packet(SystemMessageId::CANNOT_DISSOLVE_WHILE_IN_WAR)
      return
    end

    if clan.castle_id != 0 || clan.hideout_id != 0 || clan.fort_id != 0
      pc.send_packet(SystemMessageId::CANNOT_DISSOLVE_WHILE_OWNING_CLAN_HALL_OR_CASTLE)
      return
    end

    CastleManager.castles.each do |castle|
      if SiegeManager.registered?(clan, castle.residence_id)
        pc.send_packet(SystemMessageId::CANNOT_DISSOLVE_WHILE_IN_SIEGE)
        return
      end
    end

    FortManager.forts.each do |fort|
      if FortSiegeManager.registered?(clan, fort.residence_id)
        pc.send_packet(SystemMessageId::CANNOT_DISSOLVE_WHILE_IN_SIEGE)
        return
      end
    end

    if pc.inside_siege_zone?
      pc.send_packet(SystemMessageId::CANNOT_DISSOLVE_WHILE_IN_SIEGE)
      return
    end

    time = Time.ms

    if clan.dissolving_expiry_time > time
      pc.send_packet(SystemMessageId::DISSOLUTION_IN_PROGRESS)
      return
    end

    clan.dissolving_expiry_time = Time.ms + Time.days_to_ms(Config.alt_clan_dissolve_days)
    clan.update_clan_in_db

    pc.calculate_death_exp_penalty(nil, false)
    ClanTable.schedule_remove_clan(clan.id)
  end

  private def recover_clan(pc)
    unless (clan = pc.clan) && pc.clan_leader?
      pc.send_packet(SystemMessageId::YOU_ARE_NOT_AUTHORIZED_TO_DO_THAT)
      return
    end

    clan.dissolving_expiry_time = 0
    clan.update_clan_in_db
  end

  private def create_subpledge(pc, clan_name, leader_name, pledge_type, min_lvl)
    unless (clan = pc.clan) && pc.clan_leader?
      pc.send_packet(SystemMessageId::YOU_ARE_NOT_AUTHORIZED_TO_DO_THAT)
      return
    end

    if clan.level < min_lvl
      if pledge_type == L2Clan::SUBUNIT_ACADEMY
        pc.send_packet(SystemMessageId::YOU_DO_NOT_MEET_CRITERIA_IN_ORDER_TO_CREATE_A_CLAN_ACADEMY)
      else
        pc.send_packet(SystemMessageId::YOU_DO_NOT_MEET_CRITERIA_IN_ORDER_TO_CREATE_A_MILITARY_UNIT)
      end

      return
    end

    if !valid_name?(clan_name) || clan_name.size < 2
      pc.send_packet(SystemMessageId::CLAN_NAME_INCORRECT)
      return
    end

    if clan_name.size > ClanTable::CLAN_NAME_MAX_LENGTH
      pc.send_packet(SystemMessageId::CLAN_NAME_TOO_LONG)
      return
    end

    ClanTable.clans.each do |c|
      if c.get_subpledge(clan_name)
        if pledge_type == L2Clan::SUBUNIT_ACADEMY
          sm = SystemMessage.s1_already_exists
          sm.add_string(clan_name)
          pc.send_packet(sm)
        else
          pc.send_packet(SystemMessageId::ANOTHER_MILITARY_UNIT_IS_ALREADY_USING_THAT_NAME)
        end

        return
      end
    end

    leader = clan.get_clan_member(leader_name)

    if pledge_type != L2Clan::SUBUNIT_ACADEMY
      if leader && leader.pledge_type != 0
        if pledge_type >= L2Clan::SUBUNIT_KNIGHT1
          pc.send_packet(SystemMessageId::CAPTAIN_OF_ORDER_OF_KNIGHTS_CANNOT_BE_APPOINTED)
        elsif pledge_type >= L2Clan::SUBUNIT_ROYAL1
          pc.send_packet(SystemMessageId::CAPTAIN_OF_ROYAL_GUARD_CANNOT_BE_APPOINTED)
        end

        return
      end
    end

    if pledge_type != L2Clan::SUBUNIT_ACADEMY
      leader_id = leader.not_nil!.l2id
    else
      leader_id = 0
    end

    unless clan.create_subpledge(pc, pledge_type, leader_id, clan_name)
      debug "Subpledge creation failed."
      return
    end

    if pledge_type == L2Clan::SUBUNIT_ACADEMY
      sm = SystemMessage.the_s1s_clan_academy_has_been_created
      sm.add_string(clan.name)
    elsif pledge_type >= L2Clan::SUBUNIT_KNIGHT1
      sm = SystemMessage.the_knights_of_s1_have_been_created
      sm.add_string(clan.name)
    elsif pledge_type >= L2Clan::SUBUNIT_ROYAL1
      sm = SystemMessage.the_royal_guard_of_s1_have_been_created
      sm.add_string(clan.name)
    else
      sm = SystemMessageId::CLAN_CREATED
    end

    pc.send_packet(sm)

    leader = clan.get_clan_member(leader_name).not_nil!

    if pledge_type != L2Clan::SUBUNIT_ACADEMY
      if leader_player = leader.not_nil!.player_instance
        leader_player.pledge_class = L2ClanMember.calculate_pledge_class(leader_player)
        leader_player.send_packet(UserInfo.new(leader_player))
        leader_player.send_packet(ExBrExtraUserInfo.new(leader_player))
      end
    end
  end

  private def rename_subpledge(pc, pledge_type, pledge_name)
    unless (clan = pc.clan) && pc.clan_leader?
      pc.send_packet(SystemMessageId::YOU_ARE_NOT_AUTHORIZED_TO_DO_THAT)
      return
    end

    unless subpledge = clan.get_subpledge(pledge_type)
      pc.send_message("Pledge doesn't exist.")
      return
    end

    if !valid_name?(pledge_name) || pledge_name.size < 2
      pc.send_packet(SystemMessageId::CLAN_NAME_INCORRECT)
      return
    end

    if pledge_name.size > ClanTable::CLAN_NAME_MAX_LENGTH
      pc.send_packet(SystemMessageId::CLAN_NAME_TOO_LONG)
      return
    end

    subpledge.name = pledge_name
    clan.update_subpledge_in_db(subpledge.id)
    clan.broadcast_clan_status
    pc.send_message("Pledge name changed.")
  end

  private def assign_subpledge_leader(pc, clan_name, leader_name)
    unless (clan = pc.clan) && pc.clan_leader?
      pc.send_packet(SystemMessageId::YOU_ARE_NOT_AUTHORIZED_TO_DO_THAT)
      return
    end

    if leader_name.size > 16
      pc.send_packet(SystemMessageId::NAMING_CHARNAME_UP_TO_16CHARS)
      return
    end

    if pc.name == leader_name
      pc.send_packet(SystemMessageId::CAPTAIN_OF_ROYAL_GUARD_CANNOT_BE_APPOINTED)
      return
    end

    subpledge = clan.get_subpledge(clan_name)

    if subpledge.nil? || subpledge.id == L2Clan::SUBUNIT_ACADEMY
      pc.send_packet(SystemMessageId::CLAN_NAME_INCORRECT)
      return
    end

    leader = clan.get_clan_member(leader_name)

    if leader.nil? || leader.pledge_type != 0
      if subpledge.id >= L2Clan::SUBUNIT_KNIGHT1
        pc.send_packet(SystemMessageId::CAPTAIN_OF_ORDER_OF_KNIGHTS_CANNOT_BE_APPOINTED)
      elsif subpledge.id >= L2Clan::SUBUNIT_ROYAL1
        pc.send_packet(SystemMessageId::CAPTAIN_OF_ROYAL_GUARD_CANNOT_BE_APPOINTED)
      end

      return
    end

    subpledge.leader_id = leader.l2id
    clan.update_subpledge_in_db(subpledge.id)

    leader = clan.get_clan_member(leader_name).not_nil!

    if leader_player = leader.player_instance
      leader_player.pledge_class = L2ClanMember.calculate_pledge_class(leader_player)
      leader_player.send_packet(UserInfo.new(leader_player))
      leader_player.send_packet(ExBrExtraUserInfo.new(leader_player))
    end

    clan.broadcast_clan_status
    sm = SystemMessage.c1_has_been_selected_as_captain_of_s2
    sm.add_string(leader_name)
    sm.add_string(clan_name)
    clan.broadcast_to_online_members(sm)
  end
end
