module OlympiadManager
  extend self

  private NON_CLASS_BASED_REGISTERS = [] of Int32
  private CLASS_BASED_REGISTERS = {} of Hash(Int32, Array(Int32))
  private TEAMS_BASED_REGISTERS = [] of Array(Int32)

  def registered_non_class_based : Array(Int32)
    NON_CLASS_BASED_REGISTERS
  end

  def registered_class_based : Hash(Int32, Array(Int32))
    CLASS_BASED_REGISTERS
  end

  def registered_teams_based : Array(Array(Int32))
    TEAMS_BASED_REGISTERS
  end

  def enough_registered_classed : Array(Array(Int32))?
    ret = nil
    CLASS_BASED_REGISTERS.each_value do |class_list|
      if class_list.size >= Config.alt_oly_classed
        (ret ||= [] of Array(Int32)).concat(class_list)
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
  end
end
