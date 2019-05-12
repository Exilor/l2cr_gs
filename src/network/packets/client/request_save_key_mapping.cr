class Packets::Incoming::RequestSaveKeyMapping < GameClientPacket
  @key_map = {} of Int32 => Array(ActionKey)
  @cat_map = {} of Int32 => Array(Int32)

  private def read_impl
    category = 0

    q # unknown

    tab_num = d
    tab_num.times do |i|
      cmd1_size = c
      cmd1_size.times do |j|
        UIData.add_category(@cat_map, category, c)
      end

      category += 1

      cmd2_size = c
      cmd2_size.times do |j|
        UIData.add_category(@cat_map, category, c)
      end

      category += 1

      cmd_size = d
      cmd_size.times do |j|
        cmd = d
        key = d
        tg_key1 = d
        tg_key2 = d
        show = d
        ak = ActionKey.new(i, cmd, key, tg_key1, tg_key2, show)
        UIData.add_key(@key_map, i, ak)
      end
    end

    q # unknown
  end

  private def run_impl
    return unless pc = active_char

    if !Config.store_ui_settings || !client.state.in_game?
      return
    end

    pc.ui_settings.store_all(@cat_map, @key_map)
  end
end
