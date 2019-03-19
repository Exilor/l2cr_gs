module ItemHandler::Bypass
  extend self
  extend ItemHandler

  def use_item(playable, item, force) : Bool
    return false unless pc = playable.as?(L2PcInstance)

    item_id = item.id
    file_name = "data/html/item/#{item_id}.htm"
    content = HtmCache.get_htm(pc, file_name)
    html = Packets::Outgoing::NpcHtmlMessage.new(0, item_id)

    if content
      html.html = content
      html["%itemId%"] = item.l2id
    else
      html.html = "<html><body>My Text is missing:<br>#{file_name}</body></html>"
    end

    pc.send_packet(html)

    true
  end
end
