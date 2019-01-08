class Packets::Outgoing::PledgeShowMemberListAdd < GameServerPacket
  @name : String
  @lvl : Int32
  @pledge_type : Int32
  @is_online : Int32
  @class_id : Int32

  def initialize(pc : L2PcInstance | L2ClanMember)
    @name = pc.name
    @lvl = pc.level
    @pledge_type = pc.pledge_type
    @is_online = pc.online? ? pc.l2id : 0
    if pc.is_a?(L2PcInstance)
      @class_id = pc.class_id.to_i
    else
      @class_id = pc.class_id
    end
  end

  def write_impl
    c 0x5c

    s @name
    d @lvl
    d @class_id
    d 0
    d 1
    d @is_online
    d @pledge_type
  end
end
