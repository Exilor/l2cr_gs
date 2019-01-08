module GameDB
  module PremiumItemDAOMySQLImpl
    extend self
    extend PremiumItemDAO
    extend Loggable

    private GET_PREMIUM_ITEMS = "SELECT itemNum, itemId, itemCount, itemSender FROM character_premium_items WHERE charId=?"

    def load(pc : L2PcInstance)
      GameDB.each(GET_PREMIUM_ITEMS, pc.l2id) do |rs|
        item_num = rs.get_i32("itemNum")
        item_id = rs.get_i32("itemId")
        item_count = rs.get_i64("itemCount")
        item_sender = rs.get_string("itemSender")
        item = L2PremiumItem.new(item_id, item_count, item_sender)
        pc.premium_item_list[item_num] = item
      end
    rescue e
      error e
    end

    def update(pc : L2PcInstance, item_num : Int32, new_count : Int64)
      sql = "UPDATE character_premium_items SET itemCount=? WHERE charId=? AND itemNum=?"
      GameDB.exec(sql, new_count, pc.l2id, item_num)
    rescue e
      error e
    end

    def delete(pc : L2PcInstance, item_num : Int32)
      sql = "DELETE FROM character_premium_items WHERE charId=? AND itemNum=?"
      GameDB.exec(sql, pc.l2id, item_num)
    rescue e
      error e
    end
  end
end
