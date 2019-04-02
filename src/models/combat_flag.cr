class CombatFlag
  include Synchronizable
  include Packets::Outgoing

  @player_id = 0
  @player : L2PcInstance?
  @item_instance : L2ItemInstance?

  def initialize(fort_id : Int32, x : Int32, y : Int32, z : Int32, heading : Int32, item_id : Int32)
    @fort_id = fort_id
    @item_id = item_id
    @location = Location.new(x, y, z, heading)
  end

  def spawn_me
    sync do
      item = ItemTable.create_item("Combat", @item_id, 1, nil, nil)
      item.drop_me(nil, *@location.xyz)
      @item_instance = item
    end
  end

  def unspawn_me
    sync do
      if @player
        drop_it
      end

      @item_instance.try &.decay_me
    end
  end

  def activate(pc : L2PcInstance, item : L2ItemInstance) : Bool
    if pc.mounted?
      pc.send_packet(SystemMessageId::CANNOT_EQUIP_ITEM_DUE_TO_BAD_CONDITION)
      return false
    end

    @player = pc
    @player_id = pc.l2id
    @item_instance = nil

    @item = item
    pc.inventory.equip_item(item)
    sm = SystemMessage.s1_equipped
    sm.add_item_name(item)
    pc.send_packet(sm)

    if Config.force_inventory_update
      pc.send_packet(ItemList.new(pc, false))
    else
      pc.send_packet(InventoryUpdate.added(item))
    end

    pc.broadcast_user_info
    pc.combat_flag_equipped = true

    true
  end

  def drop_it
    unless pc = @player
      raise "No @player"
    end

    unless item = @item
      raise "No @item"
    end

    slot = pc.inventory.get_slot_from_item(item)
    pc.inventory.unequip_item_in_body_slot(slot)
    pc.destroy_item("CombatFlag", item, nil, true)
    @item = nil
    pc.broadcast_user_info
    @player = nil
    @player_id = 0
  end

  def player_l2id : Int32
    @player_id
  end

  def combat_flag_instance : L2ItemInstance?
    @item_instance
  end
end
