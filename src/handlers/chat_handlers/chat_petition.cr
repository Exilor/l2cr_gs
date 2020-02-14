module ChatHandler::ChatPetition
  extend self
  extend ChatHandler

  def handle_chat(type, pc, params, text)
    if pc.chat_banned? && Config.ban_chat_channels.includes?(type)
      pc.send_packet(SystemMessageId::CHATTING_IS_CURRENTLY_PROHIBITED)
      return
    end

    unless PetitionManager.player_in_consultation?(pc)
      pc.send_packet(SystemMessageId::YOU_ARE_NOT_IN_PETITION_CHAT)
      return
    end

    PetitionManager.send_active_petition_message(pc, text)
  end

  def chat_type_list
    {6, 7}
  end
end
