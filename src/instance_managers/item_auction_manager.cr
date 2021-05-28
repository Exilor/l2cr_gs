require "../models/item_auction/item_auction_instance"

module ItemAuctionManager
  extend self
  extend XMLReader

  private MANAGER_INSTANCES = {} of Int32 => ItemAuctionInstance
  private AUCTION_IDS = Atomic(Int32).new(1)

  def load
    unless Config.alt_item_auction_enabled
      info "Disabled by config."
      return
    end

    begin
      sql = "SELECT auctionId FROM item_auction ORDER BY auctionId DESC LIMIT 0, 1"
      GameDB.query_each(sql) do |rs|
        AUCTION_IDS.set(rs.read(Int32) + 1)
      end
    rescue e
      error e
    end

    parse_datapack_file("ItemAuctions.xml")

    info { "Loaded #{MANAGER_INSTANCES.size} manager instances." }
  end

  def shutdown
    MANAGER_INSTANCES.each_value &.shutdown
  end

  def get_manager_instance(instance_id : Int32) : ItemAuctionInstance?
    MANAGER_INSTANCES[instance_id]?
  end

  def next_auction_id : Int32
    AUCTION_IDS.add(1) + 1
  end

  def delete_auction(auction_id : Int32)
    sql = "DELETE FROM item_auction WHERE auctionId=?"
    GameDB.exec(sql, auction_id)

    sql = "DELETE FROM item_auction_bid WHERE auctionId=?"
    GameDB.exec(sql, auction_id)
  rescue e
    error e
  end

  private def parse_document(doc : XML::Node, file : File)
    find_element(doc, "list") do |list|
      find_element(list, "instance") do |nb|
        instance_id = parse_int(nb, "id")
        if MANAGER_INSTANCES.has_key?(instance_id)
          raise "Duplicate instance id #{instance_id}"
        end

        instance = ItemAuctionInstance.new(instance_id, AUCTION_IDS, nb)
        MANAGER_INSTANCES[instance_id] = instance
      end
    end
  end
end
