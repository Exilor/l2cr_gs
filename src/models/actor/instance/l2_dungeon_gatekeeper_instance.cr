class L2DungeonGatekeeperInstance < L2Npc
  def instance_type
    InstanceType::L2DungeonGatekeeperInstance
  end

  def on_bypass_feedback(pc : L2PcInstance, cmd : String)
    pc.action_failed

    st = cmd.split
    actual_cmd = st.shift

    filename = SevenSigns::SEVEN_SIGNS_HTML_PATH
    seal_avarice_owner = SevenSigns.get_seal_owner(SevenSigns::SEAL_AVARICE)
    seal_gnosis_owner = SevenSigns.get_seal_owner(SevenSigns::SEAL_GNOSIS)
    player_cabal = SevenSigns.get_player_cabal(pc.l2id)
    seal_validation = SevenSigns.seal_validation_period?
    comp_winner = SevenSigns.cabal_highest_score

    case actual_cmd
    when .starts_with?("necro")
      can_port = true

      if seal_validation
        if comp_winner == SevenSigns::CABAL_DAWN && (player_cabal != SevenSigns::CABAL_DAWN || seal_avarice_owner != SevenSigns::CABAL_DAWN)
          pc.send_packet(SystemMessageId::CAN_BE_USED_BY_DAWN)
          can_port = false
        elsif comp_winner == SevenSigns::CABAL_DUSK && (player_cabal != SevenSigns::CABAL_DUSK || seal_avarice_owner != SevenSigns::CABAL_DUSK)
          pc.send_packet(SystemMessageId::CAN_BE_USED_BY_DUSK)
          can_port = false
        elsif comp_winner == SevenSigns::CABAL_NULL && player_cabal != SevenSigns::CABAL_NULL
          can_port = true
        elsif player_cabal == SevenSigns::CABAL_NULL
          can_port = false
        end
      else
        if player_cabal == SevenSigns::CABAL_NULL
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
        if comp_winner == SevenSigns::CABAL_DAWN && (player_cabal != SevenSigns::CABAL_DAWN || seal_gnosis_owner != SevenSigns::CABAL_DAWN)
          pc.send_packet(SystemMessageId::CAN_BE_USED_BY_DAWN)
          can_port = false
        elsif comp_winner == SevenSigns::CABAL_DUSK && (player_cabal != SevenSigns::CABAL_DUSK || seal_gnosis_owner != SevenSigns::CABAL_DUSK)
          pc.send_packet(SystemMessageId::CAN_BE_USED_BY_DUSK)
          can_port = false
        elsif comp_winner == SevenSigns::CABAL_NULL && player_cabal != SevenSigns::CABAL_NULL
          can_port = true
        elsif player_cabal == SevenSigns::CABAL_NULL
          can_port = false
        end
      else
        if player_cabal == SevenSigns::CABAL_NULL
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
      warn "No teleport destination with id #{val}."
    end

    pc.action_failed
  end

  def get_html_path(npc_id : Int, val : Int) : String
    if val == 0
      "data/html/teleporter/#{npc_id}.htm"
    else
      "data/html/teleporter/#{npc_id}-#{val}.htm"
    end
  end
end
