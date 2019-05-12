class Packets::Incoming::RequestItemList < GameClientPacket
  no_action_request

  private def read_impl
    # no-op
  end

  private def run_impl
    if client = @client
      if pc = client.active_char
        unless pc.inventory_disabled?
          send_packet(ItemList.new(pc, true))
        end
      end
    end
  end
end
