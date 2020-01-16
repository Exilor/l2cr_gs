class Packets::Outgoing::ExReplyReceivedPost < Packets::Outgoing::AbstractItemPacket
  @items : IArray(L2ItemInstance)?

  def initialize(@msg : Message)
    if msg.has_attachments?
      attachments = msg.attachments
      if attachments && attachments.size > 0
        @items = attachments.items
      else
        warn "Message with ID #{msg.id} has attachments but the ItemContainer is empty."
      end
    end
  end

  private def write_impl
    c 0xfe
    h 0xab

    d @msg.id
    d @msg.locked? ? 1 : 0
    d 0
    s @msg.sender_name
    s @msg.subject
    s @msg.content

    items = @items

    if items && !items.empty?
      d items.size
      items.each do |item|
        write_item(item)
        d item.l2id
      end
    else
      d 0
    end

    q @msg.req_adena
    d @msg.has_attachments? ? 1 : 0
    d @msg.send_by_system
  end
end
