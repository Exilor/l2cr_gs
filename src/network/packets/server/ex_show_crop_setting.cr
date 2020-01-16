class Packets::Outgoing::ExShowCropSetting < GameServerPacket
  @current = {} of Int32 => CropProcure
  @next = {} of Int32 => CropProcure

  def initialize(@manor_id : Int32)
    @seeds = CastleManorManager.get_seeds_for_castle(@manor_id)
    @seeds.each do |seed|
      if cp = CastleManorManager.get_crop_procure(@manor_id, seed.crop_id, false)
        @current[seed.crop_id] = cp
      else
        debug "Crop procure not found."
      end

      if cp = CastleManorManager.get_crop_procure(manor_id, seed.crop_id, true)
        @next[seed.crop_id] = cp
      else
        debug "Crop procure not found."
      end
    end
  end

  private def write_impl
    c 0xfe
    h 0x2b

    d @manor_id
    d @seeds.size

    @seeds.each do |seed|
      d seed.crop_id
      d seed.level
      c 1
      d seed.get_reward(1)
      c 1
      d seed.get_reward(2)
      d seed.crop_limit
      d 0
      d seed.crop_min_price
      d seed.crop_max_price
      if cp = @current[seed.crop_id]?
        q cp.start_amount
        q cp.price
        c cp.reward
      else
        q 0
        q 0
        c 0
      end

      if cp = @next[seed.crop_id]?
        q cp.start_amount
        q cp.price
        c cp.reward
      else
        q 0
        q 0
        c 0
      end
    end

    @next.clear
    @current.clear
  end
end
