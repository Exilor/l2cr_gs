class Packets::Incoming::RequestExRqItemLink < GameClientPacket
  @l2id = 0

  def read_impl
    @l2id = d
  end

  def run_impl
    return unless client = client?

    item = L2World.find_object(@l2id)
    if item.is_a?(L2ItemInstance)
      if item.published? # published in Say2
        client.send_packet(ExRpItemLink.new(item))
      else
        if Config.debug
          debug "#{@client} requested item link for item #{@l2id} which isn't published."
        end
      end
    end
  end
end
