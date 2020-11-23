class L2DungeonGatekeeperInstance < L2Npc
  def instance_type : InstanceType
    InstanceType::L2DungeonGatekeeperInstance
  end

  def on_bypass_feedback(pc : L2PcInstance, command : String)
    pc.action_failed

    st = command.split
    actual_cmd = st.shift

    filename = SevenSigns::SEVEN_SIGNS_HTML_PATH
    avarice_owner = SevenSigns.instance.get_seal_owner(SevenSigns::SEAL_AVARICE)
    gnosis_owner = SevenSigns.instance.get_seal_owner(SevenSigns::SEAL_GNOSIS)
    cabal = SevenSigns.instance.get_player_cabal(pc.l2id)
    seal_validation = SevenSigns.instance.seal_validation_period?
    winner = SevenSigns.instance.cabal_highest_score
    dawn = SevenSigns::CABAL_DAWN
    dusk = SevenSigns::CABAL_DUSK
    null = SevenSigns::CABAL_NULL

    case actual_cmd
    when .starts_with?("necro")
      can_port = true

      if seal_validation
        if winner == dawn && (cabal != dawn || avarice_owner != dawn)
          pc.send_packet(SystemMessageId::CAN_BE_USED_BY_DAWN)
          can_port = false
        elsif winner == dusk && (cabal != dusk || avarice_owner != dusk)
          pc.send_packet(SystemMessageId::CAN_BE_USED_BY_DUSK)
          can_port = false
        elsif winner == null && cabal != null
          can_port = true
        elsif cabal == null
          can_port = false
        end
      else
        if cabal == null
          can_port = false
        end
      end

      if can_port
        do_teleport(pc, st.shift.to_i)
        pc.in_7s_dungeon = true
      else
        html = NpcHtmlMessage.new(l2id)
        filename += "necro_no.htm"
        html.set_file(pc, filename)
        pc.send_packet(html)
      end
    when .starts_with?("cata")
      can_port = true

      if seal_validation
        if winner == dawn && (cabal != dawn || gnosis_owner != dawn)
          pc.send_packet(SystemMessageId::CAN_BE_USED_BY_DAWN)
          can_port = false
        elsif winner == dusk && (cabal != dusk || gnosis_owner != dusk)
          pc.send_packet(SystemMessageId::CAN_BE_USED_BY_DUSK)
          can_port = false
        elsif winner == null && cabal != null
          can_port = true
        elsif cabal == null
          can_port = false
        end
      else
        if cabal == SevenSigns::CABAL_NULL
          can_port = false
        end
      end

      if can_port
        do_teleport(pc, st.shift.to_i)
        pc.in_7s_dungeon = true
      else
        html = NpcHtmlMessage.new(l2id)
        filename += "cata_no.htm"
        html.set_file(pc, filename)
        pc.send_packet(html)
      end
    when .starts_with?("exit")
      do_teleport(pc, st.shift.to_i)
      pc.in_7s_dungeon = false
    when .starts_with?("goto")
      do_teleport(pc, st.shift.to_i)
    else
      super
    end
  end

  private def do_teleport(pc : L2PcInstance, val : Int)
    if list = TeleportLocationTable[val]?
      if pc.looks_dead?
        return
      end

      pc.tele_to_location(list.x, list.y, list.z, true)
    else
      warn { "No teleport destination with id #{val}." }
    end

    pc.action_failed
  end

  def get_html_path(npc_id : Int32, val : Int32) : String
    if val == 0
      "data/html/teleporter/#{npc_id}.htm"
    else
      "data/html/teleporter/#{npc_id}-#{val}.htm"
    end
  end
end
