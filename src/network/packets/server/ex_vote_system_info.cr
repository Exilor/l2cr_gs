require "../../../models/entity/reco_bonus"

class Packets::Outgoing::ExVoteSystemInfo < GameServerPacket
  @recom_have : Int32
  @recom_left : Int32
  @bonus_time : Int32
  @bonus_type : Int32

  def initialize(pc : L2PcInstance)
    @recom_have = pc.recom_have
    @recom_left = pc.recom_left
    @bonus_time = pc.recom_bonus_time
    @bonus_type = pc.recom_bonus_type
    @bonus_val  = RecoBonus.get_reco_bonus(pc)
  end

  def write_impl
    c 0xfe
    h 0xc9

    d @recom_left
    d @recom_have
    d @bonus_time
    d @bonus_val
    d @bonus_type
  end
end
