require "./char_stat"

class NpcStat < CharStat
  def level : UInt8
    active_char.template.level
  end

  def active_char
    super.as(L2Npc)
  end
end
