module GameDB
  module RecommendationBonusDAOMySQLImpl
    extend self
    extend RecommendationBonusDAO

    private SELECT = "SELECT rec_have,rec_left,time_left FROM character_reco_bonus WHERE charId=? LIMIT 1"
    private INSERT = "INSERT INTO character_reco_bonus (charId,rec_have,rec_left,time_left) VALUES (?,?,?,?) ON DUPLICATE KEY UPDATE rec_have=?, rec_left=?, time_left=?"

    def load(pc : L2PcInstance) : Int64
      time_left = 3_600_000_i64

      begin
        GameDB.each(SELECT, pc.l2id) do |rs|
          pc.recom_have = rs.get_i32(:"rec_have")
          pc.recom_left = rs.get_i32(:"rec_left")
          time_left = rs.get_i64(:"time_left")
        end
      rescue e
        error e
      end

      time_left
    end

    def insert(pc : L2PcInstance, reco_task_end : Int64)
      GameDB.exec(
        INSERT,
        pc.l2id,
        pc.recom_have,
        pc.recom_left,
        reco_task_end,
        pc.recom_have,
        pc.recom_left,
        reco_task_end
      )
    rescue e
      error e
    end
  end
end
