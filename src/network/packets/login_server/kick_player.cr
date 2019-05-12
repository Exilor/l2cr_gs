require "../login_server_packet"

class Packets::Incoming::KickPlayer < LoginServerPacket
  include Loggable

  @account = ""

  private def read_impl
    @account = s
  end

  private def run_impl
    client.do_kick_player(@account)
  end
end
