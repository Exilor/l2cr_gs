class Packets::Outgoing::ExBrExtraUserInfo < GameServerPacket
  @id : Int32
  @effects : Int32

  def initialize(pc : L2PcInstance)
    @id = pc.l2id
    @effects = pc.abnormal_visual_effects_event
    @lecture_mark = 0 # L2J TODO
    @invisible = pc.invisible?
  end

  def write_impl
    c 0xfe
    h 0xda

    d @id
    d @effects
    c @lecture_mark
  end
end
