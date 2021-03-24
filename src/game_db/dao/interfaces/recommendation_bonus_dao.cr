module GameDB
  module RecommendationBonusDAO
    macro extended
      include Loggable
    end

    abstract def load(pc : L2PcInstance) : Int64
    abstract def insert(pc : L2PcInstance, reco_task_end : Int64)
  end
end
