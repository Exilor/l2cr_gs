module ItemHandler::Book
  extend self
  extend ItemHandler

  def use_item(playable, item, force)
    unless playable.is_a?(L2PcInstance)
      playable.send_packet(SystemMessageId::ITEM_NOT_FOR_PETS)
      return false
    end

    item_id = item.id

    file_name = "data/html/help/#{item_id}.htm"
    reply = NpcHtmlMessage.new(0, item_id)

    if content = HtmCache.get_htm(playable, file_name)
      reply.html = content
    else
      reply.html = "<html><body>My Text is missing:<br>#{file_name}</body></html>"
    end

    playable.send_packet(reply)
    playable.action_failed

    true
  end
end
