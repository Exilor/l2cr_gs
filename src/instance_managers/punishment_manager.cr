require "../models/punishment/punishment_type"
require "../models/punishment/punishment_affect"
require "../models/holders/punishment_holder"

module PunishmentManager
  extend self
  include Loggable

  private TASKS = EnumMap(PunishmentAffect, PunishmentHolder).new

  def load
    PunishmentAffect.each do |affect|
      TASKS[affect] = PunishmentHolder.new
    end

    initiated = 0
    expired = 0
    time = Time.ms

    GameDB.each("SELECT * FROM punishments") do |rs|
      id = rs.get_i32(:"id")
      key = rs.get_string(:"key")
      affect = PunishmentAffect.parse?(rs.get_string(:"affect"))
      type = PunishmentType.parse?(rs.get_string(:"type"))
      exp_time = rs.get_i64(:"expiration")
      reason = rs.get_string(:"reason")
      punished_by = rs.get_string(:"punishedBy")

      if type && affect
        if exp_time > 0 && time > exp_time
          expired &+= 1
        else
          initiated &+= 1

          task = PunishmentTask.new(id, key, affect, type, exp_time, reason, punished_by, true)
          TASKS[affect].add_punishment(task)
        end
      end
    end

    info { "Loaded #{initiated} active and #{expired} expired punishments." }
  end

  def start_punishment(task : PunishmentTask)
    TASKS[task.affect].add_punishment(task)
  end

  def stop_punishment(key : Object, affect : PunishmentAffect, type : PunishmentType)
    if task = get_punishment(key, affect, type)
      TASKS[affect].stop_punishment(task)
    end
  end

  def has_punishment?(key : Object, affect : PunishmentAffect, type : PunishmentType) : Bool
    holder = TASKS[affect]
    holder.has_punishment?(key.to_s, type)
  end

  def get_punishment_expiration(key : Object, affect : PunishmentAffect, type : PunishmentType) : Int64
    get_punishment(key, affect, type).try &.expiration_time || 0i64
  end

  def get_punishment(key : Object, affect : PunishmentAffect, type : PunishmentType) : PunishmentTask?
    TASKS[affect].get_punishment(key.to_s, type)
  end
end
