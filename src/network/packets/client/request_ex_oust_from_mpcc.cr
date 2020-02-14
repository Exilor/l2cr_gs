class Packets::Incoming::RequestExOustFromMPCC < GameClientPacket
  @name = ""

  private def read_impl
    @name = s
  end

  private def run_impl
    return unless pc = active_char
    if target = L2World.get_player(@name)
      if (party = pc.party) && (target_party = target.party)
        if (cc = party.command_channel) && (target_cc = target_party.command_channel)
          if cc.leader == pc && cc == target_cc
            if pc == target
              return
            end

            target_cc.remove_party(target_party)

            target_party.broadcast_packet(SystemMessage.dismissed_from_command_channel)

            if party.in_command_channel?
              sm = SystemMessage.c1_party_dismissed_from_command_channel
              sm.add_string(target_party.leader.name)
              cc.broadcast_packet(sm)
            end
          end
        end
      end
    end


    pc.send_packet(SystemMessageId::TARGET_CANT_FOUND)
  end
end
