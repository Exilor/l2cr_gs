require "./char_stat"

class StaticObjectStat < CharStat
  def level : Int32
    active_char.level.to_i32
  end

  def active_char : L2StaticObjectInstance
    super.as(L2StaticObjectInstance)
  end
end
