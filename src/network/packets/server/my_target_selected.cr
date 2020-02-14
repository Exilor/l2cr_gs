class Packets::Outgoing::MyTargetSelected < GameServerPacket
  @target_id : Int32
  @color : Int32

  def initialize(pc : L2PcInstance, target : L2Character)
    if target.is_a?(L2ControllableAirShipInstance)
      @target_id = target.helm_l2id
    else
      @target_id = target.l2id
    end
    @color = target.auto_attackable?(pc) ? pc.level - target.level : 0
  end

  private def write_impl
    c 0xb9

    d @target_id
    h @color
    d 0x00
  end
end
