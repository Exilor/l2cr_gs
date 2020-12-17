class Packets::Outgoing::ExReplySentPost < Packets::Outgoing::AbstractItemPacket
  @items : Interfaces::Array(L2ItemInstance)?

  def initialize(msg : Message)
    @msg = msg
    if msg.has_attachments?
      attachments = msg.attachments!
      if attachments && attachments.size > 0
        @items = attachments.items
      else
        warn "Message with id #{msg.id} has attachments but the ItemContainer is empty."
      end
    end
  end

  private def write_impl
    c 0xfe
    h 0xad

    d @msg.id
    d @msg.locked? ? 1 : 0
    s @msg.receiver_name
    s @msg.subject
    s @msg.content

    items = @items

    if items && items.size > 0
      d items.size
      items.each do |item|
        write_item(item)
        d item.l2id
      end
      q @msg.req_adena
      d @msg.send_by_system
    else
      d 0
      q @msg.req_adena
    end
  end
end
