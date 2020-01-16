class Packets::Outgoing::ExShowCropInfo < GameServerPacket
  @crops : Array(CropProcure)?

  def initialize(@manor_id : Int32, next_period : Bool, @hide_buttons : Bool)
    unless next_period && !CastleManorManager.manor_approved?
      @crops = CastleManorManager.get_crop_procure(manor_id, next_period)
    end
  end

  private def write_impl
    c 0xfe
    h 0x24

    c @hide_buttons ? 1 : 0
    d @manor_id
    d 0
    unless crops = @crops
      d 0
      return
    end
    d crops.size
    crops.each do |crop|
      d crop.id
      q crop.amount
      q crop.start_amount
      q crop.price
      c crop.reward
      if s = CastleManorManager.get_seed_by_crop(crop.id)
        d s.level
        c 1
        d s.get_reward(1)
        c 1
        d s.get_reward(2)
      else
        d 0
        c 1
        d 0
        c 1
        d 0
      end
    end
  end
end
