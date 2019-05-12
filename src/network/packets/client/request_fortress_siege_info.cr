class Packets::Incoming::RequestFortressSiegeInfo < GameClientPacket
  no_action_request

  private def read_impl
    # no-op
  end

  private def run_impl
    if client = client?
      FortManager.forts.each do |fort|
        if fort.siege.in_progress?
          client.send_packet(ExShowFortressSiegeInfo.new(fort))
        end
      end
    end
  end
end
