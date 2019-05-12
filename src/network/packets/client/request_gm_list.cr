class Packets::Incoming::RequestGmList < GameClientPacket
  private def read_impl
    # no-op
  end

  private def run_impl
    if pc = active_char
      AdminData.send_list_to_player(pc)
    end
  end
end
