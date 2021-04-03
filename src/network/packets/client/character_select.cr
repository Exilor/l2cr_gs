class Packets::Incoming::CharacterSelect < GameClientPacket
  @slot = 0

  private def read_impl
    @slot = d
    # @unk1 = h
    # @unk2 = d
    # @unk3 = d
    # @unk4 = d
  end

  private def run_impl
    unless flood_protectors.character_select.try_perform_action("CharacterSelect")
      return
    end

    if SecondaryAuthData.enabled? && !client.secondary_auth.authed?
      client.secondary_auth.open_dialog
      return
    end

    client.active_char_lock.synchronize do
      unless client.active_char
        return unless cip = client.get_char_selection(@slot)

        if PunishmentManager.has_punishment?(cip.l2id, PunishmentAffect::CHARACTER, PunishmentType::BAN) || PunishmentManager.has_punishment?(client.account_name, PunishmentAffect::ACCOUNT, PunishmentType::BAN) || PunishmentManager.has_punishment?(client.connection.ip, PunishmentAffect::IP, PunishmentType::BAN)
          client.close(ServerClose::STATIC_PACKET)
        end

        if cip.access_level < 0
          debug { "Access level (#{cip.access_level}) forbids character selection." }
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

        unless pc = client.load_char_from_disk(@slot)
          error "Char couldn't be loaded from disk."
          return
        end

        L2World.add_player_to_world(pc)
        CharNameTable.add_name(pc)

        pc.client = client
        client.active_char = pc
        pc.set_online_status(true, true)

        evt = OnPlayerSelect.new(pc, pc.l2id, pc.name, client)
        term = EventDispatcher.notify(evt, Containers::PLAYERS, TerminateReturn)
        if term && term.terminate
          pc.delete_me
          return
        end

        send_packet(SSQInfo.new)

        client.state = GameClient::State::JOINING
        send_packet(CharSelected.new(pc, client.session_id.play_ok_1))

        Logs[:accounting].info { "Client #{client} logged in." }
      end
    end
  end
end
