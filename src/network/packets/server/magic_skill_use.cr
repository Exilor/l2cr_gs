class Packets::Outgoing::MagicSkillUse < GameServerPacket
  @ground_loc : Location?

  def initialize(char : L2Character, skill_id : Int32, skill_level : Int32, hit_time : Int32, reuse_delay : Int32)
    initialize(char, char, skill_id, skill_level, hit_time, reuse_delay)
  end

  def initialize(char : L2Character, target : L2Character, skill_id : Int32, skill_level : Int32, hit_time : Int32, reuse_delay : Int32)
    @char = char
    @target = target
    @skill_id = skill_id
    @skill_level = skill_level
    @hit_time = hit_time
    @reuse_delay = reuse_delay
    if char.is_a?(L2PcInstance)
      if loc = char.current_skill_world_position
        @ground_loc = loc
      end
    end
  end

  private def write_impl
    c 0x48

    d @char.l2id
    d @target.l2id
    d @skill_id
    d @skill_level
    d @hit_time
    d @reuse_delay
    l @char
    h 0 # unknown
    if loc = @ground_loc
      h 1
      l loc
    else
      h 0
    end

    l @target
  end
end
