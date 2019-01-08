class Packets::Outgoing::MagicSkillLaunched < GameServerPacket
  @char_id : Int32

  def initialize(char : L2Character, skill_id : Int32, skill_level : Int32)
    initialize(char, skill_id, skill_level, char)
  end

  def initialize(char : L2Character, skill_id : Int32, skill_level : Int32, target : L2Object)
    initialize(char, skill_id, skill_level, {target.as(L2Object)})
  end

  def initialize(char : L2Character, @skill_id : Int32, @skill_level : Int32, @targets : Enumerable(L2Object))
    @char_id = char.l2id
  end

  def write_impl
    c 0x54

    d @char_id
    d @skill_id
    d @skill_level
    d @targets.size
    @targets.each { |t| d t.l2id }
  end
end
