class Packets::Incoming::RequestChangeNicknameColor < GameClientPacket
  private COLORS = {
    0x9393FF, # Pink
    0x7C49FC, # Rose Pink
    0x97F8FC, # Lemon Yellow
    0xFA9AEE, # Lilac
    0xFF5D93, # Cobalt Violet
    0x00FCA0, # Mint Green
    0xA0A601, # Peacock Green
    0x7898AF, # Yellow Ochre
    0x486295, # Chocolate
    0x999999  # Silver
  }

  @color_num = 0
  @title = ""
  @item_l2id = 0

  private def read_impl
    @color_num = d
    @title = s
    @item_l2id = d
  end

  private def run_impl
    return unless pc = active_char

    if @color_num < 0 || @color_num >= COLORS.size
      return
    end

    unless item = pc.inventory.get_item_by_l2id(@item_l2id)
      return
    end

    if item.etc_item.nil? || item.etc_item!.handler_name.nil?
      return
    end

    if pc.destroy_item("Consume", item, 1, nil, true)
      pc.title = @title
      pc.appearance.title_color = COLORS[@color_num]
      pc.broadcast_user_info
    end
  end
end
