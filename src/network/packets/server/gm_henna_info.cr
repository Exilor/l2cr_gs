class Packets::Outgoing::GMHennaInfo < GameServerPacket
  @hennas : Slice(L2Henna?)

  def initialize(pc : L2PcInstance)
    @pc = pc
    @hennas = pc.henna_list
  end

  private def write_impl
    c 0xf0

    c @pc.henna_int
    c @pc.henna_str
    c @pc.henna_con
    c @pc.henna_men
    c @pc.henna_dex
    c @pc.henna_wit
    d 3 # slots. changing it does nothing
    d @hennas.count &.itself
    @hennas.each do |henna|
      if henna
        d henna.dye_id
        d 0x01
      end
    end
  end
end
