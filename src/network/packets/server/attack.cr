require "../../../models/xyz"

class Packets::Outgoing::Attack < GameServerPacket
  @single_hit : Hit?
  @other_hits : Array(Hit)?
  @attacker_id : Int32

  getter? has_soulshot

  def initialize(attacker : L2Character, target : L2Character, has_soulshot : Bool, ss_grade : Int32)
    @has_soulshot = has_soulshot
    @ss_grade = ss_grade
    @attacker_id = attacker.l2id
    @attacker_loc = XYZ.new(attacker)
    @target_loc = XYZ.new(target)
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
    return unless hit
    d hit.target_id
    d hit.damage
    c hit.flags
  end

  private def write_impl
    c 0x33

    d @attacker_id
    write_hit(@single_hit)
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
    private SHOT = 0x10
    private CRIT = 0x20
    private SHLD = 0x40
    private MISS = 0x80

    getter damage, flags : UInt8, target_id : Int32

    def initialize(target : L2Character, damage : Int32, miss : Bool, crit : Bool, shld : Int, soulshot : Bool, ss_grade : Int)
      @damage = damage
      @target_id = target.l2id
      flags = 0u8

      flags |= SHOT | ss_grade if soulshot
      flags |= CRIT if crit
      flags |= SHLD if shld > 0
      flags |= MISS if miss

      @flags = flags
    end
  end
end
