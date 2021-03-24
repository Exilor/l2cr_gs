module ChatHandler::ChatBattlefield
  extend self
  extend ChatHandler

  def handle_chat(type : Int32, pc : L2PcInstance, target : String?, text : String)
    if TerritoryWarManager.tw_channel_open? && pc.siege_side > 0
      if pc.chat_banned? && Config.ban_chat_channels.includes?(type)
        pc.send_packet(SystemMessageId::CHATTING_IS_CURRENTLY_PROHIBITED)
        return
      end

      cs = Packets::Outgoing::CreatureSay.new(pc.l2id, type, pc.name, text)
      L2World.players.each do |player|
        if player.siege_side == pc.siege_side
          player.send_packet(cs)
        end
      end
    end
  end

  def chat_type_list : Enumerable(Int32)
    {20}
  end
end
