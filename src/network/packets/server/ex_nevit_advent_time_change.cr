class Packets::Outgoing::ExNevitAdventTimeChange < GameServerPacket
  @time : Int32

  def initialize(time : Int32)
    @time = Math.max(time, 240_000)
  end

  def write_impl
    c 0xfe
    h 0xe1

    c @time < 1 ? 0 : 1
    d @time
  end
end
