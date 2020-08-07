class Packets::Incoming::RequestDismissPartyRoom < GameClientPacket
  @room_id = 0

  private def read_impl
    @room_id = d
    # @data2 = d # unused
  end

  private def run_impl
    return unless active_char

    if room = PartyMatchRoomList.get_room(@room_id)
      PartyMatchRoomList.delete_room(@room_id)
    else
      warn { "Room with id #{@room_id} not found." }
    end
  end
end
