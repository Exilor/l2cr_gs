require "../login_server_packet"

class Packets::Incoming::ChangePasswordResponse < LoginServerPacket
  @player_name = ""
  @message = ""

  private def read_impl
    @player_name = s
    @message = s
  end

  private def run_impl
    if pc = L2World.get_player(@player_name)
      pc.send_message(@message)
    end
  end
end
