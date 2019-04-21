class TaskRaidPointsReset < Task
  private NAME = "raid_points_reset"

  def name : String
    NAME
  end

  def on_time_elapsed(task : ExecutedTask)
    unless Time.now.monday?
      return
    end

    info "Launched."

    rank_list = RaidBossPointsManager.rank_list
    ClanTable.clans.each do |c|
      rank_list.each do |player_id, points|
        if points <= 100 && c.member?(player_id)
          case points
          when 1
            reputation = Config.raid_ranking_1st
          when 2
            reputation = Config.raid_ranking_2nd
          when 3
            reputation = Config.raid_ranking_3rd
          when 4
            reputation = Config.raid_ranking_4th
          when 5
            reputation = Config.raid_ranking_5th
          when 6
            reputation = Config.raid_ranking_6th
          when 7
            reputation = Config.raid_ranking_7th
          when 8
            reputation = Config.raid_ranking_8th
          when 9
            reputation = Config.raid_ranking_9th
          when 10
            reputation = Config.raid_ranking_10th
          else
            if points <= 50
              reputation = Config.raid_ranking_up_to_50th
            else
              reputation = Config.raid_ranking_up_to_100th
            end
          end

          c.add_reputation_score(reputation, true)
        end
      end
    end

    RaidBossPointsManager.clean_up
  end

  def init
    super
    TaskManager.add_unique_task(NAME, TaskType::GLOBAL_TASK, "1", "00:10:00", "")
  end
end
