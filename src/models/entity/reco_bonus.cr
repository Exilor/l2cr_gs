module RecoBonus
  extend self

  private RECO_BONUS = {
    {25, 50, 50, 50, 50, 50, 50, 50, 50},
    {16, 33, 50, 50, 50, 50, 50, 50, 50, 50},
    {12, 25, 37, 50, 50, 50, 50, 50, 50, 50},
    {10, 20, 30, 40, 50, 50, 50, 50, 50, 50},
    {8,  16, 25, 33, 41, 50, 50, 50, 50, 50},
    {7,  14, 21, 28, 35, 42, 50, 50, 50, 50},
    {6,  12, 18, 25, 31, 37, 43, 50, 50, 50},
    {5,  11, 16, 22, 27, 33, 38, 44, 50, 50},
    {5,  10, 15, 20, 25, 30, 35, 40, 45, 50}
  }

  def get_reco_bonus(pc : L2PcInstance?) : Int32
    if pc && pc.online?
      if pc.recom_have != 0
        if pc.recom_bonus_time > 0
          lvl = pc.level / 10
          exp = (Math.min(pc.recom_have, 100) - 1) / 10
          return RECO_BONUS[lvl][exp]
        end
      end
    end

    0
  end

  def get_reco_multiplier(pc : L2PcInstance) : Float64
    bonus = get_reco_bonus(pc)
    bonus > 0 ? 1.0 + (bonus / 100) : 1.0
  end
end
