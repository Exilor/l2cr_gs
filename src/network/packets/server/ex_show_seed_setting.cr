class Packets::Outgoing::ExShowSeedSetting < GameServerPacket
  @current = {} of Int32 => SeedProduction
  @next = {} of Int32 => SeedProduction

  def initialize(@manor_id : Int32)
    @seeds = CastleManorManager.get_seeds_for_castle(@manor_id)
    @seeds.each do |seed|
      if sp = CastleManorManager.get_seed_product(@manor_id, seed.seed_id, false)
        @current[seed.seed_id] = sp
      end

      if sp = CastleManorManager.get_seed_product(@manor_id, seed.seed_id, true)
        @next[seed.seed_id] = sp
      end
    end
  end

  private def write_impl
    c 0xfe
    h 0x26

    d @manor_id
    d @seeds.size

    @seeds.each do |seed|
      d seed.seed_id
      d seed.level
      c 1
      d seed.get_reward(1)
      c 1
      d seed.get_reward(2)
      d seed.seed_limit
      d seed.seed_reference_price
      d seed.seed_min_price
      d seed.seed_max_price

      if sp = @current[seed.seed_id]?
        q sp.start_amount
        q sp.price
      else
        q 0
        q 0
      end

      if sp = @next[seed.seed_id]?
        q sp.start_amount
        q sp.price
      else
        q 0
        q 0
      end
    end

    @current.clear
    @next.clear
  end
end
