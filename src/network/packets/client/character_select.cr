class Packets::Incoming::CharacterSelect < GameClientPacket
  @slot = 0

  def read_impl
    @slot = d
    # @unk1 = h
    # @unk2 = d
    # @unk3 = d
    # @unk4 = d
  end

  def run_impl
    unless flood_protectors.character_select.try_perform_action("CharacterSelect")
      debug "Flood detected."
      return
    end

    # secondary auth check

    client.active_char_lock.synchronize do
      unless client.active_char
        return unless cip = client.get_char_selection(@slot)

        # ban check

        if cip.access_level < 0
          debug "Access level forbids character selection #{cip.access_level}."
          client.close(ServerClose::STATIC_PACKET)
          return
        end

        if Config.dualbox_check_max_players_per_ip > 0
          unless AntiFeedManager.try_add_client(AntiFeedManager::GAME_ID, client, Config.dualbox_check_max_players_per_ip)
            msg = NpcHtmlMessage.new
            msg.set_file(cip.html_prefix, "data/html/mods/IPRestriction.htm")
            msg["%max%"] = AntiFeedManager.get_limit(client, Config.dualbox_check_max_players_per_ip)
            client.send_packet(msg)
            return
          end
        end

        debug "Selected slot #{@slot}."
        if pc = client.load_char_from_disk(@slot)
          debug "#{pc} loaded from disk."
        else
          error "Char couldn't be loaded from disk."
          return
        end

        L2World.add_player_to_world(pc)
        CharNameTable.add_name(pc)

        pc.client = client
        client.active_char = pc
        pc.set_online_status(true, true)

        evt = OnPlayerSelect.new(pc, pc.l2id, pc.name, client)
        container, ret = Containers::PLAYERS, TerminateReturn
        if term = EventDispatcher.notify(evt, container, ret)
          pc.delete_me
          return
        end

        send_packet(SSQInfo.new)

        client.state = GameClient::State::IN_GAME
        send_packet(CharSelected.new(pc, client.session_id.play_ok_1))
      end
    end
  end
end
