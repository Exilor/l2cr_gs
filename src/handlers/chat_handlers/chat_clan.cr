module ChatHandler::ChatClan
  extend self
  extend ChatHandler

  def handle_chat(type, pc, params, text)
    if clan = pc.clan?
      if pc.chat_banned? && Config.ban_chat_channels.includes?(type)
        pc.send_packet(SystemMessageId::CHATTING_IS_CURRENTLY_PROHIBITED)
        return
      end

      cs = Packets::Outgoing::CreatureSay.new(pc.l2id, type, pc.name, text)
      clan.broadcast_cs_to_online_members(cs, pc)
    end
  end

  def chat_type_list
    {4}
  end
end
