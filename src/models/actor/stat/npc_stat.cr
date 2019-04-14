require "./char_stat"

class NpcStat < CharStat
  def level : Int32
    active_char.template.level.to_i32
  end

  def active_char
    super.as(L2Npc)
  end
end
