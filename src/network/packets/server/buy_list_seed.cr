class Packets::Outgoing::BuyListSeed < GameServerPacket
  @list = [] of SeedProduction

  def initialize(money : Int64, manor_id : Int32)
    @money = money
    @manor_id = manor_id
    CastleManorManager.get_seed_production(manor_id, false).each do |seed|
      if seed.amount > 0 && seed.price > 0
        @list << seed
      end
    end
  end

  private def write_impl
    c 0xe9

    q @money
    d @manor_id

    if @list.empty?
      h 0
    else
      h @list.size
      @list.each do |seed|
        d seed.id
        d seed.id
        d 0
        q seed.amount
        h 0x05 # Custom Type 2
        h 0x00 # Custom Type 1
        h 0x00 # Equipped
        d 0x00 # Body Part
        h 0x00 # Enchant
        h 0x00 # Custom Type
        d 0x00 # Augment
        d -1 # Mana
        d -9999 # Time
        h 0x00 # Element Type
        h 0x00 # Element Power
        6.times { h 0 }
        h 0
        h 0
        h 0
        q seed.price
      end
      @list.clear
    end
  end
end
