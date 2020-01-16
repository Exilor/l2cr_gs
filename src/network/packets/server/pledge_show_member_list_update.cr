class Packets::Outgoing::PledgeShowMemberListUpdate < GameServerPacket
  @class_id : Int32
  @race : Int32
  @sex : Int32
  @name : String
  @level : Int32
  @is_online : Bool
  @l2id : Int32
  @pledge_type : Int32
  @has_sponsor : Int32

  def initialize(pc : L2PcInstance)
    @class_id = pc.class_id.to_i
    @race = pc.race.to_i
    @sex = pc.appearance.sex ? 1 : 0
    @name = pc.name
    @level = pc.level
    @is_online = pc.online?
    @l2id = pc.l2id
    @pledge_type = pc.pledge_type
    if @pledge_type == L2Clan::SUBUNIT_ACADEMY
      @has_sponsor = pc.sponsor != 0 ? 1 : 0
    else
      @has_sponsor = 0
    end
  end

  def initialize(member : L2ClanMember)
    @class_id = member.class_id
    @race = member.race_ordinal
    @sex = member.sex ? 1 : 0
    @name = member.name
    @level = member.level
    @is_online = member.online?
    @l2id = member.l2id
    @pledge_type = member.pledge_type
    if @pledge_type == L2Clan::SUBUNIT_ACADEMY
      @has_sponsor = member.sponsor != 0 ? 1 : 0
    else
      @has_sponsor = 0
    end
  end

  private def write_impl
    c 0x5b

    s @name
    d @level
    d @class_id
    d @sex
    d @race
    if @is_online
      d @l2id
      d @pledge_type
    else
      q 0
    end
    d @has_sponsor
  end
end
