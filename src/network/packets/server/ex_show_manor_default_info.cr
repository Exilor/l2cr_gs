class Packets::Outgoing::ExShowManorDefaultInfo < GameServerPacket
  def initialize(@hide_buttons : Bool)
    @crops = CastleManorManager.crops
  end

  def write_impl
    c 0xfe
    h 0x25

    c @hide_buttons ? 1 : 0
    d @crops.size
    @crops.each do |crop|
      d crop.crop_id
      d crop.level
      d crop.seed_reference_price
      d crop.crop_reference_price
      c 1
      d crop.get_reward(1)
      c 1
      d crop.get_reward(2)
    end
  end
end
