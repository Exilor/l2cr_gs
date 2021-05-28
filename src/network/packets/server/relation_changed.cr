class Packets::Outgoing::RelationChanged < GameServerPacket
  PARTY1 = 0x00001 # party member
  PARTY2 = 0x00002 # party member
  PARTY3 = 0x00004 # party member
  PARTY4 = 0x00008 # party member
  PARTYLEADER = 0x00010 # true if is party leader
  HAS_PARTY = 0x00020 # true if is in party
  CLAN_MEMBER = 0x00040 # true if is in clan
  LEADER = 0x00080 # true if is clan leader
  CLAN_MATE = 0x00100 # true if is in same clan
  INSIEGE = 0x00200 # true if in siege
  ATTACKER = 0x00400 # true when attacker
  ALLY = 0x00800 # blue siege icon, cannot have if red
  ENEMY = 0x01000 # true when red icon, doesn't matter with blue
  MUTUAL_WAR = 0x04000 # double fist
  ONE_SIDED_WAR = 0x08000 # single fist
  ALLY_MEMBER = 0x10000 # clan is in alliance
  TERRITORY_WAR = 0x80000 # show Territory War icon

  @l2id : Int32
  @relation : Int32
  @auto_attackable : Bool
  @karma : Int32
  @pvp_flag : Int8

  def initialize(pl : L2Playable, relation : Int32, auto_attackable : Bool)
    @l2id = pl.l2id
    @relation = relation
    @auto_attackable = auto_attackable
    @karma = pl.karma
    @pvp_flag = pl.pvp_flag
    self.invisible = pl.invisible?
  end

  private def write_impl
    c 0xce

    d 1
    d @l2id
    d @relation
    d @auto_attackable ? 1 : 0
    d @karma
    d @pvp_flag
  end
end
