class TaskClanLeaderApply < Task
  private NAME = "clanleaderapply"

  def init
    super
    TaskManager.add_unique_task(NAME, TaskType::GLOBAL_TASK, "1", Config.alt_clan_leader_hour_change, "")
  end

  def name : String
    NAME
  end

  def on_time_elapsed(task : ExecutedTask)
    cal = Calendar.new
    if cal.day_of_week == Config.alt_clan_leader_date_change
      ClanTable.clans.each do |clan|
        if clan.new_leader_id != 0
          if m = clan.get_clan_member(clan.new_leader_id)
            clan.set_new_leader(m)
          end
        end
      end

      info "Launched."
    end
  end
end
