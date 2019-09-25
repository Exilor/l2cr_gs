module PunishmentHandler
  include Loggable
  include Packets::Outgoing

  private HANDLERS = EnumMap(PunishmentType, self).new

  def self.load
    {% for const in @type.constants %}
      const = {{const.id}}
      if const.is_a?(self)
        register(const)
      end
    {% end %}
  end

  def self.register(handler : self)
    HANDLERS[handler.type] = handler
  end

  def self.[](val : PunishmentType) : self?
    HANDLERS[val]?
  end

  # abstract def on_start(task : PunishmentTask)
  # abstract def on_end(task : PunishmentTask)
  # abstract def type : PunishmentType
end

require "./punishment_handlers/*"
