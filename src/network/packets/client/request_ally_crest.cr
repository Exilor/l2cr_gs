class Packets::Incoming::RequestAllyCrest < GameClientPacket
  no_action_request

  @crest_id = 0

  def read_impl
    @crest_id = d
  end

  def run_impl
    send_packet(AllyCrest.new(@crest_id))
  end
end
