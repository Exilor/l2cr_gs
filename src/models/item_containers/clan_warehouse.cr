require "./warehouse"

class ClanWarehouse < Warehouse
  initializer clan : L2Clan

  def name : String
    "ClanWarehouse"
  end

  def owner? : L2PcInstance?
    @clan.leader.player_instance
  end

  def owner_id : Int32
    @clan.id
  end

  def base_location : ItemLocation
    ItemLocation::CLANWH
  end

  def location_id : String
    "0"
  end

  def get_location_id(arg) : Int32
    0
  end

  def location_id=(arg)
    # no-op
  end

  def validate_capacity(slots : Int) : Bool
    @items.size + slots <= Config.warehouse_slots_clan
  end

  def add_item(process : String?, item_id : Int32, count : Int64, enchant_level : Int32, actor : L2PcInstance?, reference) : L2ItemInstance?
    unless item = super
      raise "Expected super to not return nil"
    end

    OnPlayerClanWHItemAdd.new(process, actor, item, self).async(item.template)

    item
  end

  def add_item(process : String?, item : L2ItemInstance, actor : L2PcInstance?, reference) : L2ItemInstance?
    OnPlayerClanWHItemAdd.new(process, actor, item, self).async(item.template)
    super
  end

  def destroy_item(process : String?, item : L2ItemInstance, count : Int64, actor : L2PcInstance?, reference) : L2ItemInstance?
    OnPlayerClanWHItemDestroy.new(process, actor, item, count, self).async(item.template)
    super
  end

  def transfer_item(process : String?, l2id : Int32, count : Int64, target : ItemContainer, actor : L2PcInstance?, reference) : L2ItemInstance?
    unless item = get_item_by_l2id(l2id)
      raise "Expected get_item_by_l2id(l2id: #{l2id}) to not return nil"
    end
    OnPlayerClanWHItemTransfer.new(process, actor, item, count, target).async(item.template)
    super
  end
end
