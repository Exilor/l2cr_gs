class TerritoryWard
  include Synchronizable
  include Packets::Outgoing

  getter territory_id
  getter player_id = 0
  getter! player : L2PcInstance?
  property owner_castle_id : Int32
  property! npc : L2Npc?
  property! old_location : Location?
  property! item : L2ItemInstance?

  def initialize(territory_id : Int32, x : Int32, y : Int32, z : Int32, heading : Int32, item_id : Int32, owner_castle_id : Int32, npc : L2Npc?)
    @territory_id = territory_id
    @item_id = item_id
    @owner_castle_id = owner_castle_id
    @npc = npc
    @location = Location.new(x, y, z, heading)
  end

  def spawn_back
    sync do
      if @player
        drop_it
      end

      @npc = TerritoryWarManager.spawn_npc(36491 + @territory_id, old_location)
    end
  end

  def spawn_me
    sync do
      if @player
        drop_it
      end

      @npc = TerritoryWarManager.spawn_npc(36491 + @territory_id, @location)
    end
  end

  def unspawn_me
    sync do
      if @player
        drop_it
      end

      if npc = @npc
        unless npc.decayed?
          npc.delete_me
        end
      end
    end
  end

  def activate(pc : L2PcInstance, item : L2ItemInstance?) : Bool
    if pc.mounted?
      pc.send_packet(SystemMessageId::CANNOT_EQUIP_ITEM_DUE_TO_BAD_CONDITION)
      pc.destroy_item("CombatFlag", item, nil, true)
      spawn_me
      return false
    elsif TerritoryWarManager.get_registered_territory_id(pc) == 0
      pc.send_message("Non participants can't pickup Territory Wards!")
      pc.destroy_item("CombatFlag", item, nil, true)
      spawn_me
      return false
    end

    @player = pc
    @player_id = pc.l2id
    npc = @npc.not_nil!
    @old_location = Location.new(*npc.xyz, npc.heading)
    @npc = nil

    item ||= ItemTable.create_item("Combat", @item_id, 1, nil, nil)
    @item = item

    pc.inventory.equip_item(item)
    sm = SystemMessage.s1_equipped
    sm.add_item_name(item)
    pc.send_packet(sm)

    if !Config.force_inventory_update
      pc.send_packet(InventoryUpdate.added(item))
    else
      pc.send_packet(ItemList.new(pc, false))
    end

    pc.broadcast_user_info
    pc.combat_flag_equipped = true
    pc.send_packet(SystemMessageId::YOU_VE_ACQUIRED_THE_WARD)
    TerritoryWarManager.give_tw_point(pc, @territory_id, 5)

    true
  end

  def drop_it
    player.combat_flag_equipped = false
    slot = player.inventory.get_slot_from_item(item)
    player.inventory.unequip_item_in_body_slot(slot)
    player.destroy_item("CombatFlag", item, nil, true)
    @item = nil
    player.broadcast_user_info
    @location = Location.new(*player.xyz, player.heading)
    @player = nil
    @player_id = 0
  end
end
