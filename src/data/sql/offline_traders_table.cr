module OfflineTradersTable
  extend self
  extend Loggable

  private SAVE_OFFLINE_STATUS = "INSERT INTO character_offline_trade (`charId`,`time`,`type`,`title`) VALUES (?,?,?,?)"
  private SAVE_ITEMS = "INSERT INTO character_offline_trade_items (`charId`,`item`,`count`,`price`) VALUES (?,?,?,?)"
  private CLEAR_OFFLINE_TABLE = "DELETE FROM character_offline_trade"
  private CLEAR_OFFLINE_TABLE_ITEMS = "DELETE FROM character_offline_trade_items"
  private LOAD_OFFLINE_STATUS = "SELECT * FROM character_offline_trade"
  private LOAD_OFFLINE_ITEMS = "SELECT * FROM character_offline_trade_items WHERE charId = ?"

  def store_offliners
    begin
      GameDB.exec(CLEAR_OFFLINE_TABLE)
    rescue e
      error e
    end

    begin
      GameDB.exec(CLEAR_OFFLINE_TABLE_ITEMS)
    rescue e
      error e
    end

    L2World.players.each do |pc|
      begin
        if !pc.private_store_type.none? && pc.in_offline_mode?
          case pc.private_store_type
          when .buy?
            unless Config.offline_trade_enable
              next
            end

            title = pc.buy_list.title

            pc.buy_list.items.each do |i|
              GameDB.exec(SAVE_ITEMS, pc.l2id, i.item.id, i.count, i.price)
            end
          when .sell?, .package_sell?
            unless Config.offline_trade_enable
              next
            end

            title = pc.sell_list.title

            pc.sell_list.items.each do |i|
              GameDB.exec(SAVE_ITEMS, pc.l2id, i.l2id, i.count, i.price)
            end
          when .manufacture?
            unless Config.offline_craft_enable
              next
            end

            title = pc.store_name

            pc.manufacture_items.each_value do |i|
              GameDB.exec(SAVE_ITEMS, pc.l2id, i.recipe_id, 0, i.cost)
            end
          end

          GameDB.exec(
            SAVE_OFFLINE_STATUS,
            pc.l2id,
            pc.offline_start_time,
            pc.private_store_type.id,
            title
          )
        end
      rescue e
        error e
      end
    end

    info "Offline traders stored."
  end

  def restore_offline_traders
    debug "Loading offline traders..."

    n_traders = 0

    GameDB.each(LOAD_OFFLINE_STATUS) do |rs|
      time = rs.get_i64("time")

      if Config.offline_max_days > 0
        cal = Calendar.new
        cal.ms = time
        cal.add(Config.offline_max_days.days)
        if cal.ms <= Time.ms
          next
        end
      end

      type_id = rs.get_i32("type")
      unless type = PrivateStoreType[type_id]?
        warn { "PrivateStoreType with id #{type_id} does not exist." }
        next
      end

      if type.none?
        next
      end

      pc = nil

      begin
        client = GameClient.new(nil)
        client.detached = true
        char_id = rs.get_i32("charId")
        unless pc = L2PcInstance.load(char_id)
          raise "No player with charId #{char_id} found in database."
        end
        client.active_char = pc
        pc.set_online_status(true, false)
        client.account_name = pc.account_name_player
        L2World.add_player_to_world(pc)
        client.state = GameClient::State::IN_GAME
        pc.client = client
        pc.offline_start_time = time
        pc.spawn_me(*pc.xyz)
        LoginServerClient.add_game_server_login(pc.account_name, client)
        begin
          case type
          when .buy?
            GameDB.each(LOAD_OFFLINE_ITEMS, pc.l2id) do |items|
              arg1, arg2, arg3 = items.get_i32(2), items.get_i64(3), items.get_i64(4)
              unless pc.buy_list.add_item_by_item_id(arg1, arg2, arg3)
                raise "add_item_by_item_id(#{arg1}, #{arg2}, #{arg3}) returned nil."
              end
            end

            pc.buy_list.title = rs.get_string("title")
          when .sell?, .package_sell?
            GameDB.each(LOAD_OFFLINE_ITEMS, pc.l2id) do |items|
              arg1, arg2, arg3 = items.get_i32(2), items.get_i64(3), items.get_i64(4)
              unless pc.sell_list.add_item(arg1, arg2, arg3)
                raise "add_item_by_item_id(#{arg1}, #{arg2}, #{arg3}) returned nil."
              end
            end

            pc.sell_list.title = rs.get_string("title")
            pc.sell_list.packaged = type.package_sell?
          when .manufacture?
            GameDB.each(LOAD_OFFLINE_ITEMS, pc.l2id) do |items|
              arg1, arg2 = items.get_i32(2), items.get_i64(4)
              pc.manufacture_items[arg1] = L2ManufactureItem.new(arg1, arg2)
            end

            pc.store_name = rs.get_string("title")
          end
        rescue e
        end

        pc.sit_down

        if Config.offline_set_name_color
          pc.appearance.name_color = Config.offline_name_color
        end

        pc.private_store_type = type
        pc.set_online_status(true, true)
        pc.restore_effects
        pc.broadcast_user_info
        n_traders += 1
      rescue e
        error e
        if pc
          pc.delete_me
        end
      end
    end

    GameDB.exec(CLEAR_OFFLINE_TABLE)
    GameDB.exec(CLEAR_OFFLINE_TABLE_ITEMS)
  rescue e
    error e
  end
end
