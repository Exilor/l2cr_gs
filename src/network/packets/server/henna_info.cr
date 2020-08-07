class Packets::Outgoing::HennaInfo < GameServerPacket
  @hennas = [] of L2Henna

  def initialize(pc : L2PcInstance)
    @pc = pc
    pc.henna_list.each do |henna|
      if henna
        @hennas << henna
      end
    end
  end

  private def write_impl
    c 0xe5

    c @pc.henna_int
    c @pc.henna_str
    c @pc.henna_con
    c @pc.henna_men
    c @pc.henna_dex
    c @pc.henna_wit
    d 3 # slots. changing it does nothing
    d @hennas.size
    @hennas.each do |henna|
      d henna.dye_id
      d 0x01
    end
  end
end
