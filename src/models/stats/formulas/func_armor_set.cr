class FuncArmorSet < AbstractFunction
  def calc(effector, effected, skill, value)
    return value unless pc = effector.acting_player
    return value unless chest = pc.chest_armor_instance
    return value unless set = ArmorSetsData[chest.id]
    return value unless set.contains_all?(pc)

    case @stat
    when .stat_str?
      set.str
    when .stat_dex?
      set.dex
    when .stat_con?
      set.con
    when .stat_int?
      set.int
    when .stat_wit?
      set.wit
    else
      set.men
    end + value
  end

  STR = new(Stats::STAT_STR)
  DEX = new(Stats::STAT_DEX)
  CON = new(Stats::STAT_CON)
  INT = new(Stats::STAT_INT)
  WIT = new(Stats::STAT_WIT)
  MEN = new(Stats::STAT_MEN)
end
