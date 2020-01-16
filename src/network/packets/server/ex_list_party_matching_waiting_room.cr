class Packets::Outgoing::ExListPartyMatchingWaitingRoom < GameServerPacket
  initializer pc : L2PcInstance, min_lvl : Int32, max_lvl : Int32, mode : Int32

  private def write_impl
    c 0xfe
    h 0x36

    if @mode == 0
      q 0
      return
    end

    members = [] of L2PcInstance

    PartyMatchWaitingList.players.each do |char|
      next if char == @pc

      if !char.party_waiting?
        PartyMatchWaitingList.remove_player(char)
        next
      elsif char.level < @min_lvl || char.level > @max_lvl
        next
      end

      members << char
    end

    d 0x01
    d members.size
    members.each do |m|
      s m.name
      d m.active_class
      d m.level
    end
  end
end
