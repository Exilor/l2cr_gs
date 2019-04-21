require "./olympiad_game_task"
require "./olympiad_manager"
require "./olympiad_game_teams"
require "./olympiad_game_classed"
require "./olympiad_game_non_classed"

module OlympiadGameManager
  extend self
  extend Runnable
  extend Loggable

  private TASKS = [] of OlympiadGameTask

  class_getter? battle_started = false

  def load
    unless zones = ZoneManager.get_all_zones(L2OlympiadStadiumZone)
      raise "No olympiad stadium zones defined (nil)"
    end

    if zones.empty?
      raise "No olympiad stadium zones defined (empty)"
    end

    zones.each do |zone|
      TASKS << OlympiadGameTask.new(zone)
    end

    info { "Loaded #{TASKS.size} stadiums." }
  end

  def start_battle
    @@battle_started = true
  end

  def run
    if Olympiad.instance.olympiad_end?
      return
    end

    if Olympiad.instance.in_comp_period?
      ready_classed = OlympiadManager.enough_registered_classed
      ready_non_classed = OlympiadManager.enough_registered_non_classed?
      ready_teams = OlympiadManager.enough_registered_teams?

      if ready_classed || ready_non_classed  || ready_teams
        TASKS.each_with_index do |task, i|
          task.sync do
            unless task.running?
              if (ready_classed || ready_teams) && i % 2 == 0
                if ready_teams && i % 4 == 0
                  new_game = OlympiadGameTeams.create_game(i, OlympiadManager.registered_teams_based)
                  if new_game
                    task.attach_game(new_game)
                    next
                  end
                  ready_teams = false
                end

                if ready_classed
                  new_game = OlympiadGameClassed.create_game(i, ready_classed)
                  if new_game
                    task.attach_game(new_game)
                    next
                  end
                  ready_classed = nil
                end
              end

              if ready_non_classed
                new_game = OlympiadGameNonClassed.create_game(i, OlympiadManager.registered_non_class_based)
                if new_game
                  task.attach_game(new_game)
                  next
                end
                ready_non_classed = false
              end
            end
          end

          if ready_classed.nil? && !ready_non_classed && !ready_teams
            break
          end
        end
      end
    else
      if all_tasks_finished?
        OlympiadManager.clear_registered
        @@battle_started = false
        info { "All current games finished." }
      end
    end
  end

  def all_tasks_finished? : Bool
    TASKS.none? { |task| task.running? }
  end

  def get_olympiad_task(id : Int32) : OlympiadGameTask?
    if id < 0 || id >= TASKS.size
      return
    end

    TASKS.unsafe_fetch(id)
  end

  def get_olympiad_task!(id : Int32) : OlympiadGameTask
    unless task = get_olympiad_task(id)
      raise "No olympiad task found with id #{id}"
    end

    task
  end

  def number_of_stadiums : Int32
    TASKS.size
  end

  def notify_competitor_damage(pc : L2PcInstance, damage : Int32)
    id = pc.olympiad_game_id
    if id < 0 || id >= TASKS.size
      return
    end

    if game = TASKS.unsafe_fetch(id).game # AbstractOlympiadGame
      game.add_damage(pc, damage)
    end
  end
end
