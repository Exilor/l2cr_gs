class Packets::Outgoing::ExShowSeedInfo < GameServerPacket
  @seeds : Array(SeedProduction)?

  def initialize(@manor_id : Int32, next_period : Bool, @hide_buttons : Bool)
    unless next_period && !CastleManorManager.manor_approved?
      @seeds = CastleManorManager.get_seed_production(manor_id, next_period)
    end
  end

  def write_impl
    c 0xfe
    h 0x23

    c @hide_buttons ? 1 : 0
    d @manor_id
    d 0
    unless seeds = @seeds
      d 0
      return
    end
    d seeds.size
    seeds.each do |seed|
      d seed.id
      q seed.amount
      q seed.start_amount
      q seed.price
      if s = CastleManorManager.get_seed(seed.id)
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
