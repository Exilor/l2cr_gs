require "../login_server_packet"
require "../game_server/blowfish_key"
require "../game_server/auth_request"

class Packets::Incoming::InitLS < LoginServerPacket
  include Loggable

  private REVISION = 0x0106

  @protocol = 0
  @key = Bytes.empty

  private def read_impl
    @protocol = d
    key_size = d
    @key = b(key_size)
  end

  private def run_impl
    # debug "Protocol: #{@protocol}"
    unless @protocol == REVISION
      error "Protocol revision mistmatch (LS: #{@protocol}, GS: #{REVISION})."
    end
    # debug "Key: #{@key}"
    client.send_packet(Outgoing::BlowfishKey.new)
    client.send_packet(Outgoing::AuthRequest.new(client))
  end
end
