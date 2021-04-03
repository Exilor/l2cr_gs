require "../punishment/punishment_type"
require "../punishment/punishment_task"

struct PunishmentHolder
  @holder = Concurrent::Map(String, Concurrent::Map(PunishmentType, PunishmentTask)).new

  def add_punishment(task : PunishmentTask)
    unless task.expired?
      key = task.key.to_s
      val = @holder.store_if_absent(key) do
        Concurrent::Map(PunishmentType, PunishmentTask).new
      end
      val[task.type] = task
    end
  end

  def stop_punishment(task : PunishmentTask)
    key = task.key.to_s
    if punishments = @holder[key]?
      task.stop_punishment
      punishments.delete(key)
      if punishments.empty?
        @holder.delete(key)
      end
    end
  end

  def has_punishment?(key : String, type : PunishmentType) : Bool
    !!get_punishment(key, type)
  end

  def get_punishment(key : String, type : PunishmentType) : PunishmentTask?
    @holder.dig?(key, type)
  end
end
