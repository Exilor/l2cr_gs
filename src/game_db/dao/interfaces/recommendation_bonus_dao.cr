module GameDB
  module RecommendationBonusDAO
    include Loggable

    abstract def load(pc : L2PcInstance) : Int64
    abstract def insert(pc : L2PcInstance, reco_task_end : Int64)
  end
end
