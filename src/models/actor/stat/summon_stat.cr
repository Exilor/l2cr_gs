require "./playable_stat"

class SummonStat < PlayableStat
  def active_char : L2Summon
    super.as(L2Summon)
  end
end
