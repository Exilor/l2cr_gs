module ChatHandler::ChatHeroVoice
  extend self
  extend ChatHandler

  def handle_chat(type : Int32, pc : L2PcInstance, target : String?, text : String)
    if pc.hero? || pc.override_chat_conditions?
      if pc.chat_banned? && Config.ban_chat_channels.includes?(type)
        pc.send_packet(SystemMessageId::CHATTING_IS_CURRENTLY_PROHIBITED)
        return
      end

      unless pc.flood_protectors.hero_voice.try_perform_action("hero voice")
        pc.send_message("Action failed. Heroes are only able to speak in the global channel once every 10 seconds.")
        return
      end

      cs = Packets::Outgoing::CreatureSay.new(pc.l2id, type, pc.name, text)
      L2World.players.each do |player|
        unless BlockList.blocked?(player, pc)
          player.send_packet(cs)
        end
      end
    end
  end

  def chat_type_list : Enumerable(Int32)
    {17}
  end
end
