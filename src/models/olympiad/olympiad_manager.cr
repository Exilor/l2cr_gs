module OlympiadManager
  extend self
  include Packets::Outgoing

  private NON_CLASS_BASED_REGISTERS = Concurrent::Array(Int32).new
  private CLASS_BASED_REGISTERS = Concurrent::Map(Int32, Interfaces::Array(Int32)).new
  private TEAMS_BASED_REGISTERS = Concurrent::Array(Interfaces::Array(Int32)).new

  def registered_non_class_based : Interfaces::Array(Int32)
    NON_CLASS_BASED_REGISTERS
  end

  def registered_class_based : Interfaces::Map(Int32, Interfaces::Array(Int32))
    CLASS_BASED_REGISTERS
  end

  def registered_teams_based : Interfaces::Array(Interfaces::Array(Int32))
    TEAMS_BASED_REGISTERS
  end

  def enough_registered_classed : Array(Interfaces::Array(Int32))?
    ret = nil
    CLASS_BASED_REGISTERS.each_value do |class_list|
      if class_list.size >= Config.alt_oly_classed
        (ret ||= [] of Interfaces::Array(Int32)) << class_list
      end
    end
    ret
  end

  def enough_registered_non_classed? : Bool
    NON_CLASS_BASED_REGISTERS.size >= Config.alt_oly_classed
  end

  def enough_registered_teams? : Bool
    TEAMS_BASED_REGISTERS.size >= Config.alt_oly_teams
  end

  def clear_registered
    NON_CLASS_BASED_REGISTERS.clear
    CLASS_BASED_REGISTERS.clear
    TEAMS_BASED_REGISTERS.clear
    AntiFeedManager.clear(AntiFeedManager::OLYMPIAD_ID)
  end

  def registered?(pc : L2PcInstance) : Bool
    registered?(pc, pc, false)
  end

  private def registered?(noble : L2PcInstance, pc : L2PcInstance, show_msg : Bool) : Bool
    l2id = noble.l2id

    TEAMS_BASED_REGISTERS.each do |team|
      if team.includes?(l2id)
        if show_msg
          sm = SystemMessage.c1_is_already_registered_non_class_limited_event_teams
          sm.add_pc_name(noble)
          pc.send_packet(sm)
        end

        return true
      end
    end

    if NON_CLASS_BASED_REGISTERS.includes?(l2id)
      if show_msg
        sm = SystemMessage.c1_is_already_registered_on_the_non_class_limited_match_waiting_list
        sm.add_pc_name(noble)
        pc.send_packet(sm)
      end

      return true
    end

    classed = CLASS_BASED_REGISTERS[noble.base_class]?
    if classed && classed.includes?(l2id)
      if show_msg
        sm = SystemMessage.c1_is_already_registered_on_the_class_match_waiting_list
        sm.add_pc_name(noble)
        pc.send_packet(sm)
      end

      return true
    end

    false
  end

  def registered_in_comp?(pc : L2PcInstance) : Bool
    registered?(pc, pc, false) || in_competition?(pc, pc, false)
  end

  private def in_competition?(noble : L2PcInstance, pc : L2PcInstance, show_msg : Bool) : Bool
    unless Olympiad.in_comp_period?
      return false
    end

    OlympiadGameManager.number_of_stadiums.downto(0) do |i|
      unless game = OlympiadGameManager.get_olympiad_task(i).not_nil!.game
        next
      end

      if game.contains_participant?(noble.l2id)
        unless show_msg
          return true
        end

        case game.type
        when CompetitionType::CLASSED
          sm = SystemMessage.c1_is_already_registered_on_the_class_match_waiting_list
          sm.add_pc_name(noble)
          pc.send_packet(sm)
        when CompetitionType::NON_CLASSED
          sm = SystemMessage.c1_is_already_registered_on_the_non_class_limited_match_waiting_list
          sm.add_pc_name(noble)
          pc.send_packet(sm)
        when CompetitionType::TEAMS
          sm = SystemMessage.c1_is_already_registered_non_class_limited_event_teams
          sm.add_pc_name(noble)
          pc.send_packet(sm)
        else
          # [automatically added else]
        end


        return true
      end
    end

    false
  end

  def register_noble(pc : L2PcInstance, type : CompetitionType) : Bool
    unless Olympiad.in_comp_period?
      pc.send_packet(SystemMessageId::THE_OLYMPIAD_GAME_IS_NOT_CURRENTLY_IN_PROGRESS)
      return false
    end

    if Olympiad.instance.millis_to_comp_end < 600_000
      pc.send_packet(SystemMessageId::GAME_REQUEST_CANNOT_BE_MADE)
      return false
    end

    char_id = pc.l2id

    if Olympiad.instance.get_remaining_weekly_matches(char_id) < 1
      pc.send_packet(SystemMessageId::MAX_OLY_WEEKLY_MATCHES_REACHED)
      return false
    end

    case type
    when CompetitionType::CLASSED
      unless check_noble(pc, pc)
        return false
      end

      if Olympiad.instance.get_remaining_weekly_matches_classed(char_id) < 1
        pc.send_packet(SystemMessageId::MAX_OLY_WEEKLY_MATCHES_REACHED_60_NON_CLASSED_30_CLASSED_10_TEAM)
        return false
      end

      if classed = CLASS_BASED_REGISTERS[pc.base_class]?
        classed << char_id
      else
        classed = Concurrent::Array(Int32).new
        classed << char_id
        CLASS_BASED_REGISTERS[pc.base_class] = classed

        pc.send_packet(SystemMessageId::YOU_HAVE_BEEN_REGISTERED_IN_A_WAITING_LIST_OF_CLASSIFIED_GAMES)
      end
    when CompetitionType::NON_CLASSED
      unless check_noble(pc, pc)
        return false
      end

      if Olympiad.instance.get_remaining_weekly_matches_non_classed(char_id) < 1
        pc.send_packet(SystemMessageId::MAX_OLY_WEEKLY_MATCHES_REACHED_60_NON_CLASSED_30_CLASSED_10_TEAM)
        return false
      end

      NON_CLASS_BASED_REGISTERS << char_id
      pc.send_packet(SystemMessageId::YOU_HAVE_BEEN_REGISTERED_IN_A_WAITING_LIST_OF_NO_CLASS_GAMES)
    when CompetitionType::TEAMS
      party = pc.party
      if party.nil? || party.size != 3
        pc.send_packet(SystemMessageId::PARTY_REQUIREMENTS_NOT_MET)
        return false
      end

      unless party.leader?(pc)
        pc.send_packet(SystemMessageId::ONLY_PARTY_LEADER_CAN_REQUEST_TEAM_MATCH)
        return false
      end

      team_points = 0
      team = Array.new(party.size, 0)
      party.members.each do |noble|
        unless check_noble(noble, pc)
          if Config.dualbox_check_max_olympiad_participants_per_ip > 0
            party.members.each do |unreg|
              if unreg == noble
                break
              end

              AntiFeedManager.remove_player(AntiFeedManager::OLYMPIAD_ID, unreg)
            end
          end

          return false
        end

        if Olympiad.instance.get_remaining_weekly_matches_team(noble.l2id) < 0
          pc.send_packet(SystemMessageId::MAX_OLY_WEEKLY_MATCHES_REACHED_60_NON_CLASSED_30_CLASSED_10_TEAM)
          return false
        end

        team << noble.l2id
        team_points += Olympiad.instance.get_noble_points(noble.l2id)
      end

      # L2J TODO: replace with retail message
      if team_points < 10
        pc.send_message("Your team must have at least 10 points in total.")
        if Config.dualbox_check_max_olympiad_participants_per_ip > 0
          party.members.each do |unreg|
            AntiFeedManager.remove_player(AntiFeedManager::OLYMPIAD_ID, unreg)
          end
        end

        return false
      end

      party.broadcast_packet(SystemMessage.you_have_registered_in_a_waiting_list_of_team_games)
      TEAMS_BASED_REGISTERS << team
    else
      # [automatically added else]
    end


    true
  end

  def unregister_noble(noble : L2PcInstance) : Bool
    unless Olympiad.in_comp_period?
      noble.send_packet(SystemMessageId::THE_OLYMPIAD_GAME_IS_NOT_CURRENTLY_IN_PROGRESS)
      return false
    end

    unless noble.noble?
      sm = SystemMessage.c1_does_not_meet_requirements_only_nobless_can_participate_in_the_olympiad
      sm.add_string(noble.name)
      noble.send_packet(sm)
      return false
    end

    unless registered?(noble, noble, false)
      noble.send_packet(SystemMessageId::YOU_HAVE_NOT_BEEN_REGISTERED_IN_A_WAITING_LIST_OF_A_GAME)
      return false
    end

    if in_competition?(noble, noble, false)
      return false
    end

    l2id = noble.l2id

    if NON_CLASS_BASED_REGISTERS.delete_first(l2id)
      if Config.dualbox_check_max_olympiad_participants_per_ip > 0
        AntiFeedManager.remove_player(AntiFeedManager::OLYMPIAD_ID, noble)
      end

      noble.send_packet(SystemMessageId::YOU_HAVE_BEEN_DELETED_FROM_THE_WAITING_LIST_OF_A_GAME)
      return true
    end

    classed = CLASS_BASED_REGISTERS[noble.base_class]?
    if classed && classed.delete_first(l2id)
      CLASS_BASED_REGISTERS[noble.base_class] = classed
      if Config.dualbox_check_max_olympiad_participants_per_ip > 0
        AntiFeedManager.remove_player(AntiFeedManager::OLYMPIAD_ID, noble)
      end

      noble.send_packet(SystemMessageId::YOU_HAVE_BEEN_DELETED_FROM_THE_WAITING_LIST_OF_A_GAME)
      return true
    end

    TEAMS_BASED_REGISTERS.each do |team|
      if team.includes?(l2id)
        TEAMS_BASED_REGISTERS.delete_first(team)
        ThreadPoolManager.execute_general(AnnounceUnregToTeam.new(team))
        return true
      end
    end

    false
  end

  def remove_disconnected_competitor(pc : L2PcInstance)
    task = OlympiadGameManager.get_olympiad_task(pc.olympiad_game_id)
    if task && task.game_started?
      task.game.handle_disconnect(pc)
    end

    l2id = pc.l2id

    if NON_CLASS_BASED_REGISTERS.delete_first(l2id)
      return
    end

    classed = CLASS_BASED_REGISTERS[pc.base_class]?
    if classed && classed.delete_first(l2id)
      return
    end

    TEAMS_BASED_REGISTERS.each do |team|
      if team.includes?(l2id)
        TEAMS_BASED_REGISTERS.delete_first(team)
        ThreadPoolManager.execute_general(AnnounceUnregToTeam.new(team))
        return
      end
    end
  end

  private def check_noble(noble : L2PcInstance, pc : L2PcInstance) : Bool
    unless noble.noble?
      sm = SystemMessage.c1_does_not_meet_requirements_only_nobless_can_participate_in_the_olympiad
      sm.add_pc_name(noble)
      pc.send_packet(sm)
      return false
    end

    if noble.subclass_active?
      sm = SystemMessage.c1_cant_join_the_olympiad_with_a_sub_class_character
      sm.add_pc_name(noble)
      pc.send_packet(sm)
      return false
    end

    if noble.cursed_weapon_equipped?
      sm = SystemMessage.c1_cannot_join_olympiad_possessing_s2
      sm.add_pc_name(noble)
      sm.add_item_name(noble.cursed_weapon_equipped_id)
      pc.send_packet(sm)
      return false
    end

    unless noble.inventory_under_90?(true)
      sm = SystemMessage.c1_cannot_participate_in_olympiad_inventory_slot_exceeds_80_percent
      sm.add_pc_name(noble)
      pc.send_packet(sm)
      return false
    end

    char_id = noble.l2id

    if noble.on_event?
      pc.send_message("You can't join olympiad while participating on TvT Event.")
      return false
    end

    if registered?(noble, pc, true)
      return false
    end

    if in_competition?(noble, pc, true)
      return false
    end

    unless Olympiad.get_noble_stats(char_id)
      dat = StatsSet.new
      dat[Olympiad::CLASS_ID] = noble.base_class
      dat[Olympiad::CHAR_NAME] = noble.name
      dat[Olympiad::POINTS] = Olympiad.default_points
      dat[Olympiad::COMP_DONE] = 0
      dat[Olympiad::COMP_WON] = 0
      dat[Olympiad::COMP_LOST] = 0
      dat[Olympiad::COMP_DRAWN] = 0
      dat[Olympiad::COMP_DONE_WEEK] = 0
      dat[Olympiad::COMP_DONE_WEEK_CLASSED] = 0
      dat[Olympiad::COMP_DONE_WEEK_NON_CLASSED] = 0
      dat[Olympiad::COMP_DONE_WEEK_TEAM] = 0
      dat["to_save"] = true
      Olympiad.add_noble_stats(char_id, dat)
    end

    if Olympiad.instance.get_noble_points(char_id) <= 0
      html = NpcHtmlMessage.new(pc.last_html_action_origin_id)
      html.set_file(pc, "data/html/olympiad/noble_nopoints1.htm")
      html["%objectId%"] = noble.last_html_action_origin_id
      pc.send_packet(html)
      return false
    end

    if Config.dualbox_check_max_olympiad_participants_per_ip > 0 &&
      unless AntiFeedManager.try_add_player(AntiFeedManager::OLYMPIAD_ID, noble, Config.dualbox_check_max_olympiad_participants_per_ip)
        html = NpcHtmlMessage.new(pc.last_html_action_origin_id)
        html.set_file(pc, "data/html/mods/OlympiadIPRestriction.htm")
        html["%max%"] = AntiFeedManager.get_limit(pc, Config.dualbox_check_max_olympiad_participants_per_ip)
        pc.send_packet(html)
        return false
      end
    end

    true
  end

  def count_opponents : Int32
    NON_CLASS_BASED_REGISTERS.size +
    CLASS_BASED_REGISTERS.size +
    TEAMS_BASED_REGISTERS.size
  end

  private struct AnnounceUnregToTeam
    initializer team : Interfaces::Array(Int32)

    def call
      sm = SystemMessage.you_have_been_deleted_from_the_waiting_list_of_a_game
      @team.each do |l2id|
        if pc = L2World.get_player(l2id)
          pc.send_packet(sm)
          if Config.dualbox_check_max_olympiad_participants_per_ip > 0
            AntiFeedManager.remove_player(AntiFeedManager::OLYMPIAD_ID, pc)
          end
        end
      end
    end
  end
end
