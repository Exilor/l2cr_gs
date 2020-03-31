class PunishmentTask
  include Loggable

  private INSERT_QUERY = "INSERT INTO punishments (`key`, `affect`, `type`, `expiration`, `reason`, `punishedBy`) VALUES (?, ?, ?, ?, ?, ?)"
  private UPDATE_QUERY = "UPDATE punishments SET expiration = ? WHERE id = ?"

  @task : Scheduler::DelayedTask?

  getter key : String
  getter affect, type, expiration_time, reason, punished_by
  getter? stored

  def initialize(key : Object, affect : PunishmentAffect, type : PunishmentType, exp_time : Int64, reason : String, punished_by : String)
    initialize(0, key, affect, type, exp_time, reason, punished_by, false)
  end

  def initialize(@id : Int32, key : Object, @affect : PunishmentAffect, @type : PunishmentType, @expiration_time : Int64, @reason : String, @punished_by : String, @stored : Bool)
    @key = key.to_s
  end

  def expired? : Bool
    @expiration_time > 0 && Time.ms > @expiration_time
  end

  def start_punishment
    if expired?
      return
    end

    on_start

    if @expiration_time > 0
      @task = ThreadPoolManager.schedule_general(self, @expiration_time - Time.ms)
    end
  end

  def stop_punishment
    abort_task
    on_end
  end

  private def abort_task
    if task = @task
      if !task.cancelled? && !task.done?
        task.cancel
      end

      @task = nil
    end
  end

  private def on_start
    unless @stored
      begin
        GameDB.exec(
          INSERT_QUERY,
          @key,
          @affect.name,
          @type.name,
          @expiration_time,
          @reason,
          @punished_by
        )

        sql = "SELECT id FROM punishments ORDER BY id DESC LIMIT 1"
        GameDB.query_each(sql) { |rs| @id = rs.read(Int32) }

        @stored = true
      rescue e
        error e
      end
    end

    if handler = PunishmentHandler[@type]
      handler.on_start(self)
    else
      warn "No punishment handler found for type \"#{@type}\"."
    end
  end

  private def on_end
    if @stored
      begin
        GameDB.exec(UPDATE_QUERY, Time.ms, @id)
      rescue e
        error e
      end
    end

    if handler = PunishmentHandler[@type]
      handler.on_end(self)
    else
      warn "No punishment handler found for type \"#{@type}\"."
    end
  end

  def call
    PunishmentManager.stop_punishment(@key, @affect, @type)
  end
end
