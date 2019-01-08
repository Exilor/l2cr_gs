module ChatHandler::ChatPartyRoomAll
  extend self
  extend ChatHandler

  def handle_chat(type, pc, params, text)
    return unless party = pc.party?
    return unless cc = party.command_channel?

    if pc.chat_banned? && Config.ban_chat_channels.includes?(type)
      pc.send_packet(SystemMessageId::CHATTING_IS_CURRENTLY_PROHIBITED)
      return
    end

    cs = CreatureSay.new(pc.l2id, type, pc.name, text)
    cc.broadcast_creature_say(cs, pc)
  end

  def chat_type_list
    {16}
  end
end
