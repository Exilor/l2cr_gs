# class Packets::Outgoing::RelationChanged < GameServerPacket
#   PARTY1 = 0x00001 # party member
#   PARTY2 = 0x00002 # party member
#   PARTY3 = 0x00004 # party member
#   PARTY4 = 0x00008 # party member
#   PARTYLEADER = 0x00010 # true if is party leader
#   HAS_PARTY = 0x00020 # true if is in party
#   CLAN_MEMBER = 0x00040 # true if is in clan
#   LEADER = 0x00080 # true if is clan leader
#   CLAN_MATE = 0x00100 # true if is in same clan
#   INSIEGE = 0x00200 # true if in siege
#   ATTACKER = 0x00400 # true when attacker
#   ALLY = 0x00800 # blue siege icon, cannot have if red
#   ENEMY = 0x01000 # true when red icon, doesn't matter with blue
#   MUTUAL_WAR = 0x04000 # double fist
#   ONE_SIDED_WAR = 0x08000 # single fist
#   ALLY_MEMBER = 0x10000 # clan is in alliance
#   TERRITORY_WAR = 0x80000 # show Territory War icon

#   private struct Relation
#     property l2id = 0
#     property relation = 0
#     property? auto_attackable = false
#     property karma = 0
#     property pvp_flag = 0
#   end

#   @single : Relation?
#   @multi : Array(Relation)?

#   def initialize
#     @multi = [] of Relation
#   end

#   def initialize(pc : L2Playable, relation : Int32, auto_attackable : Bool)
#     add_relation(pc, relation, auto_attackable)
#     @invisible = pc.invisible?
#   end

#   def add_relation(pc : L2Playable, relation : Int32, auto_attackable : Bool)
#     single = Relation.new
#     single.l2id = pc.l2id
#     single.relation = relation
#     single.auto_attackable = auto_attackable
#     single.karma = pc.karma
#     single.pvp_flag = pc.pvp_flag.to_i32
#     @single = single
#   end

#   private def write_relation(r)
#     d r.l2id
#     d r.relation
#     d r.auto_attackable? ? 1 : 0
#     d r.karma
#     d r.pvp_flag
#   end

#   private def write_impl
#     c 0xce

#     if single = @single
#       d 1
#       write_relation(single)
#     elsif multi = @multi
#       d multi.size
#       multi.each { |r| write_relation(r) }
#     else
#       raise "This RelationChanged packet contains no relations"
#     end
#   end
# end

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

  private record Relation, l2id : Int32, relation : Int32,
    auto_attackable : Bool, karma : Int32, pvp_flag : Int8

  @single : Relation?
  @multi : Array(Relation)?

  def initialize(pl : L2Playable, relation : Int32, auto_attackable : Bool)
    add_relation_impl(pl, relation, auto_attackable)
    self.invisible = pl.invisible?
  end

  def add_relation(pl : L2Playable, relation : Int32, auto_attackable : Bool)
    if pl.invisible?
      raise "Cannot add invisible playable to multi relation packet"
    end

    add_relation_impl(pl, relation, auto_attackable)
    self
  end

  private def add_relation_impl(pl, relation, auto_attackable)
    r = Relation.new(pl.l2id, relation, auto_attackable, pl.karma, pl.pvp_flag)

    if single = @single
      @multi = [single, r]
      @single = nil
    elsif multi = @multi
      multi << r
    else
      @single = r
    end
  end

  private def write_relation(r)
    d r.l2id
    d r.relation
    d r.auto_attackable ? 1 : 0
    d r.karma
    d r.pvp_flag
  end

  private def write_impl
    c 0xce

    if single = @single
      d 1
      write_relation(single)
    elsif multi = @multi
      d multi.size
      multi.each { |r| write_relation(r) }
    else
      raise "This RelationChanged packet contains no relations"
    end
  end
end
