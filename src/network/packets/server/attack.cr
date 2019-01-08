class Packets::Outgoing::Attack < GameServerPacket
  @single_hit : Hit?
  @other_hits : Array(Hit)?
  @attacker_id : Int32
  getter? has_soulshot

  def initialize(attacker : L2Character, target : L2Character, @has_soulshot : Bool, @ss_grade : Int32)
    @attacker_id = attacker.l2id
    @attacker_loc = Location.new(attacker)
    @target_loc = Location.new(target)
  end

  def add_hit(target : L2Character, damage : Int32, miss : Bool, crit : Bool, shld : Int)
    hit = Hit.new(target, damage, miss, crit, shld, @has_soulshot, @ss_grade)
    if @single_hit
      if others = @other_hits
        others << hit
      else
        @other_hits = [hit]
      end
    else
      @single_hit = hit
    end
  end

  def has_hits? : Bool
    !!@single_hit
  end

  private def write_hit(hit)
    d hit.target_id
    d hit.damage
    c hit.flags
  end

  def write_impl
    c 0x33

    d @attacker_id
    write_hit(@single_hit.not_nil!)
    l @attacker_loc

    if others = @other_hits
      h others.size
      others.each { |hit| write_hit(hit) }
    else
      h 0
    end

    l @target_loc
  end

  private struct Hit
    private HITFLAG_USESS = 0x10
    private HITFLAG_CRIT  = 0x20
    private HITFLAG_SHLD  = 0x40
    private HITFLAG_MISS  = 0x80

    getter damage
    getter flags : Int32
    getter target_id : Int32

    def initialize(target : L2Object, @damage : Int32, miss : Bool, crit : Bool, shld : Int, soulshot : Bool, ss_grade : Int)
      @target_id = target.l2id
      flags = 0

      flags |= HITFLAG_USESS | ss_grade if soulshot
      flags |= HITFLAG_CRIT if crit
      flags |= HITFLAG_SHLD if shld > 0
      flags |= HITFLAG_MISS if miss

      @flags = flags
    end
  end
end
