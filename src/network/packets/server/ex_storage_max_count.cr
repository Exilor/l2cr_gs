class Packets::Outgoing::ExStorageMaxCount < GameServerPacket
  @inventory : Int32
  @warehouse : Int32
  @private_sell : Int32
  @private_buy : Int32
  @clan : Int32
  @recipe_d : Int32
  @recipe : Int32
  @inventory_extra_slots : Int32
  @inventory_quest_items : Int32

  def initialize(pc : L2PcInstance)
    @inventory = pc.inventory_limit
    @warehouse = pc.warehouse_limit
    @private_sell = pc.private_sell_store_limit
    @private_buy = pc.private_buy_store_limit
    @clan = Config.warehouse_slots_clan
    @recipe_d = pc.dwarf_recipe_limit
    @recipe = pc.common_recipe_limit
    @inventory_extra_slots = pc.calc_stat(Stats::INV_LIM, 0).to_i
    @inventory_quest_items = Config.inventory_maximum_quest_items
  end

  private def write_impl
    c 0xfe
    h 0x2f

    d @inventory
    d @warehouse
    d @clan
    d @private_sell
    d @private_buy
    d @recipe_d
    d @recipe
    d @inventory_extra_slots
    d @inventory_quest_items
  end
end
