class Packets::Incoming::RequestPledgeCrest < GameClientPacket
  no_action_request

  @crest_id = 0

  private def read_impl
    @crest_id = d
  end

  private def run_impl
    send_packet(PledgeCrest.new(@crest_id))
  end
end
