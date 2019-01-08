class Packets::Outgoing::ChangeMoveType < GameServerPacket
  WALK = 0
  RUN = 1

  @char_id : Int32
  @running : Bool

  def initialize(char : L2Character)
    @char_id = char.l2id
    @running = char.running?
  end

  def write_impl
    c 0x28

    d @char_id
    d @running ? RUN : WALK
    d 0
  end
end
