class Packets::Incoming::KickPlayer < MMO::IncomingPacket(LoginServerClient)
  include Loggable

  @account = ""

  def read
    @account = s
  end

  def run
    client.do_kick_player(@account)
  end
end
