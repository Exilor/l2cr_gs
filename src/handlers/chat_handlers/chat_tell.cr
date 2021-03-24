module ChatHandler::ChatTell
  extend self
  extend ChatHandler

  def handle_chat(type : Int32, pc : L2PcInstance, params : String?, text : String)
    if pc.chat_banned? && Config.ban_chat_channels.includes?(type)
      pc.send_packet(SystemMessageId::CHATTING_IS_CURRENTLY_PROHIBITED)
      return
    end

    if Config.jail_disable_chat && pc.jailed? && !pc.override_chat_conditions?
      pc.send_packet(SystemMessageId::CHATTING_PROHIBITED)
      return
    end

    return unless params

    receiver = L2World.get_player(params)

    if receiver && !receiver.silence_mode?(pc.l2id)
      if Config.jail_disable_chat && receiver.jailed? && !pc.override_chat_conditions?
        pc.send_message(receiver.name + " is in jail.")
        return
      end

      if receiver.chat_banned?
        pc.send_packet(SystemMessageId::THE_PERSON_IS_IN_MESSAGE_REFUSAL_MODE)
        return
      end

      client = receiver.client

      if client.nil? || client.detached?
        pc.send_message(receiver.name + " is in offline mode.")
        return
      end

      if BlockList.blocked?(receiver, pc)
        pc.send_packet(SystemMessageId::THE_PERSON_IS_IN_MESSAGE_REFUSAL_MODE)
      else
        if Config.silence_mode_exclude && pc.silence_mode?
          pc.add_silence_mode_excluded(receiver.l2id)
        end

        cs = Packets::Outgoing::CreatureSay.new(pc.l2id, type, pc.name, text)
        receiver.send_packet(cs)
        cs = Packets::Outgoing::CreatureSay.new(pc.l2id, type, "->" + receiver.name, text)
        pc.send_packet(cs)
      end
    else
      pc.send_packet(SystemMessageId::TARGET_IS_NOT_FOUND_IN_THE_GAME)
    end
  end

  def chat_type_list : Enumerable(Int32)
    {2}
  end
end
