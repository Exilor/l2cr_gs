require "./playable_stat"

class SummonStat < PlayableStat
  def active_char
    super.as(L2Summon)
  end
end
