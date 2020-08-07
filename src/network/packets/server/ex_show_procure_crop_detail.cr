class Packets::Outgoing::ExShowProcureCropDetail < GameServerPacket
  @castle_crops = {} of Int32 => CropProcure

  def initialize(crop_id : Int32)
    @crop_id = crop_id
    CastleManager.castles.each do |c|
      crop_item = CastleManorManager.get_crop_procure(c.residence_id, crop_id, false)
      if crop_item && crop_item.amount > 0
        @castle_crops[c.residence_id] = crop_item
      end
    end
  end

  private def write_impl
    c 0xfe
    h 0x78

    d @crop_id
    d @castle_crops.size
    @castle_crops.each do |key, crop|
      d key
      q crop.amount
      q crop.price
      c crop.reward
    end
  end
end
