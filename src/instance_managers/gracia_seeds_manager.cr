module GraciaSeedsManager
  extend self
  include Loggable

  ENERGY_SEEDS = "EnergySeeds"

  private SOITYPE = 2i8
  private SOATYPE = 3i8
  private SODTYPE = 1i8

  private SOD_LAST_STATE_CHANGE_DATE = Calendar.new

  class_getter sod_tiat_killed = 0
  class_getter sod_state = 1

  def load
    load_data
    handle_sod_stages
  end

  def save_data(seed_type : Int8)
    case seed_type
    when SODTYPE
      # Seed of Destruction
      GlobalVariablesManager.instance["SoDState"] = @@sod_state
      GlobalVariablesManager.instance["SoDTiatKilled"] = @@sod_tiat_killed
      GlobalVariablesManager.instance["SoDLSCDate"] = SOD_LAST_STATE_CHANGE_DATE.ms
    when SOITYPE
      # Seed of Infinity
    when SOATYPE
      # Seed of Annihilation
    else
      error { "Unknown seed type #{seed_type}." }
    end
  end

  def load_data
    if GlobalVariablesManager.instance.has_key?("SoDState")
      @@sod_state = GlobalVariablesManager.instance.get_i32("SoDState")
      @@sod_tiat_killed = GlobalVariablesManager.instance.get_i32("SoDTiatKilled", @@sod_tiat_killed)
      SOD_LAST_STATE_CHANGE_DATE.ms = GlobalVariablesManager.instance.get_i64("SoDLSCDate")
    else
      save_data(SODTYPE)
    end
  end

  private def handle_sod_stages
    case @@sod_state
    when 1
      # Tiat needs to be killed more times
    when 2
      time_past = Time.ms - SOD_LAST_STATE_CHANGE_DATE.ms
      if time_past >= Config.sod_stage_2_length
        set_sod_state(1, true)
      else
        task = UpdateSoDStateTask.new(self)
        ThreadPoolManager.schedule_effect(task, Config.sod_stage_2_length - time_past)
      end
    when 3
      # L2J TODO
      set_sod_state(1, true)
    else
      warn { "Unknown Seed of Destruction state #{@@sod_state}." }
    end
  end

  def update_sod_state
    unless quest = QuestManager.get_quest(ENERGY_SEEDS)
      warn "Missing EnergySeeds quest."
      return
    end

    quest.notify_event("StopSoDAi", nil, nil)
  end

  def increase_sod_tiat_killed
    if @@sod_state == 1
      @@sod_tiat_killed &+= 1
      if @@sod_tiat_killed >= Config.sod_tiat_kill_count
        set_sod_state(2, false)
      end
      save_data(SODTYPE)
      if quest = QuestManager.get_quest(ENERGY_SEEDS)
        quest.notify_event("StartSoDAi", nil, nil)
      else
        warn "Missing EnergySeeds quest."
      end
    end
  end

  def set_sod_state(value : Int32, save : Bool)
    info { "New Seed of Destruction state: #{value}." }
    SOD_LAST_STATE_CHANGE_DATE.ms = Time.ms
    @@sod_state = value

    if @@sod_state == 1
      @@sod_tiat_killed = 0
    end

    handle_sod_stages

    if save
      save_data(SODTYPE)
    end
  end

  def sod_time_for_next_state_change : Int64
    case @@sod_state
    when 1
      -1i64
    when 2
      (SOD_LAST_STATE_CHANGE_DATE.ms + Config.sod_stage_2_length) - Time.ms
    when 3
      # not implemented
      -1i64
    else
      # should never happen
      -1i64
    end
  end

  def sod_last_state_change_date : Calendar
    SOD_LAST_STATE_CHANGE_DATE
  end

  private struct UpdateSoDStateTask
    initializer gsm : GraciaSeedsManager

    def call
      @gsm.set_sod_state(1, true)
      @gsm.update_sod_state
    end
  end
end
