require "../../models/buy_list/l2_buy_list"

module BuyListData
  extend self
  extend XMLReader

  private BUY_LISTS = {} of Int32 => L2BuyList

  def load
    timer = Timer.new
    BUY_LISTS.clear

    parse_datapack_directory("buylists")
    if Config.custom_buylist_load
      parse_datapack_directory("buylists/custom")
    end

    load_from_db

    info { "Loaded #{BUY_LISTS.size} buy lists in #{timer.result} s." }
  end

  private def load_from_db
    sql = "SELECT * FROM `buylists`"
    GameDB.each(sql) do |rs|
      list_id = rs.get_i32("buylist_id")
      item_id = rs.get_i32("item_id")
      count = rs.get_i64("count")
      next_restock_time = rs.get_i64("next_restock_time")
      unless buy_list = get_buy_list(list_id)
        warn { "BuyList with id #{list_id} found in database but not loaded from xml." }
        next
      end
      unless product = buy_list.get_product_by_item_id(item_id)
        warn { "Item id #{item_id} found in database but not loaded from xml." }
        next
      end

      if count < product.max_count
        product.count = count
        product.restart_restock_task(next_restock_time)
      end
    end
  rescue e
    error e
  end

  private def parse_document(doc, file)
    buy_list_id = File.basename(file.path, ".xml")
    return unless buy_list_id.num?
    buy_list_id = buy_list_id.to_i

    doc.find_element("list") do |node|
      buy_list = L2BuyList.new(buy_list_id)

      node.each_element do |list_node|
        case list_node.name.casecmp
        when "item"
          item_id       = list_node["id"]?.try &.to_i || -1
          price         = list_node["price"]?.try &.to_i64 || -1i64
          restock_delay = list_node["restock_delay"]?.try &.to_i64 || -1i64
          count         = list_node["count"]?.try &.to_i64 || -1i64

          if item = ItemTable[item_id]?
            pr = Product.new(buy_list.list_id, item, price, restock_delay, count)
            buy_list.add_product(pr)
          else
            warn { "Item with ID #{item_id} not found." }
          end
        when "npcs"
          list_node.each_element do |npcs_node|
            buy_list.add_allowed_npc(npcs_node.text.to_i)
          end
        end
      end

      BUY_LISTS[buy_list.list_id] = buy_list
    end
  end

  def get_buy_list(id : Int32) : L2BuyList?
    BUY_LISTS[id]?
  end
end
