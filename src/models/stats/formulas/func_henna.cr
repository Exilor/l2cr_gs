class FuncHenna < AbstractFunction
  def calc(effector, effected, skill, value)
    return value unless pc = effector.acting_player?

    case @stat
    when .stat_str? then pc.henna_str
    when .stat_dex? then pc.henna_dex
    when .stat_con? then pc.henna_con
    when .stat_int? then pc.henna_int
    when .stat_wit? then pc.henna_wit
    else pc.henna_men
    end + value
  end

  STR = new(Stats::STAT_STR)
  DEX = new(Stats::STAT_DEX)
  CON = new(Stats::STAT_CON)
  INT = new(Stats::STAT_INT)
  WIT = new(Stats::STAT_WIT)
  MEN = new(Stats::STAT_MEN)
end
