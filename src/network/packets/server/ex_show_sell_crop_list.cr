class Packets::Outgoing::ExShowSellCropList < GameServerPacket
  @crop_items = {} of Int32 => L2ItemInstance
  @castle_crops = {} of Int32 => CropProcure

  def initialize(inventory : PcInventory, @manor_id : Int32)
    CastleManorManager.crop_ids.each do |crop_id|
      if item = inventory.get_item_by_item_id(crop_id)
        @crop_items[crop_id] = item
      end
    end

    CastleManorManager.get_crop_procure(@manor_id, false).each do |crop|
      if @crop_items.has_key?(crop.id) && crop.amount > 0
        @castle_crops[crop.id] = crop
      end
    end
  end

  def write_impl
    c 0xfe
    h 0x2c

    d @manor_id
    d @crop_items.size

    @crop_items.each_value do |item|
      seed = CastleManorManager.get_seed_by_crop(item.id).not_nil!
      d item.l2id
      d item.id
      d seed.level
      c 1
      d seed.get_reward(1)
      c 1
      d seed.get_reward(2)
      if crop = @castle_crops[item.id]?
        d @manor_id
        q crop.amount
        q crop.price
        c crop.reward
      else
        d 0xFFFFFFFF
        q 0
        q 0
        c 0
      end
      q item.count
    end
  end
end
