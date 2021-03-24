module ChatHandler::ChatPartyMatchRoom
  extend self
  extend ChatHandler

  def handle_chat(type : Int32, pc : L2PcInstance, target : String?, text : String)
    return unless pc.in_party_match_room?
    return unless room = PartyMatchRoomList.get_player_room(pc)

    if pc.chat_banned? && Config.ban_chat_channels.includes?(type)
      pc.send_packet(SystemMessageId::CHATTING_IS_CURRENTLY_PROHIBITED)
      return
    end

    cs = CreatureSay.new(pc.l2id, type, pc.name, text)
    room.party_members.each &.send_packet(cs)
  end

  def chat_type_list : Enumerable(Int32)
    {14}
  end
end
