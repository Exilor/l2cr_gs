module ChatHandler::ChatPartyRoomCommander
  extend self
  extend ChatHandler

  def handle_chat(type, pc, params, text)
    if (party = pc.party) && (cc = party.command_channel)
      if cc.leader == pc
        if pc.chat_banned? && Config.ban_chat_channels.includes?(type)
          pc.send_packet(SystemMessageId::CHATTING_IS_CURRENTLY_PROHIBITED)
          return
        end

        cs = Packets::Outgoing::CreatureSay.new(pc.l2id, type, pc.name, text)
        cc.broadcast_creature_say(cs, pc)
      end
    end
  end

  def chat_type_list
    {15}
  end
end
