require "../enums/instance_type"

module ActionHandler
  extend Loggable
  include Loggable
  include Packets::Outgoing

  private HANDLERS = EnumMap(InstanceType, self).new

  def self.load
    {% for const in @type.constants %}
      const = {{const.id}}
      if const.is_a?(self)
        register(const)
      end
    {% end %}
  end

  def self.register(handler : self)
    HANDLERS[handler.instance_type] = handler
  end

  def self.[](type : InstanceType) : self?
    temp = type
    handler = nil
    while type
      break if handler = HANDLERS[type]?
      type = type.parent
    end

    unless handler
      warn { "No action handler found for #{temp.inspect}." }
    end

    handler
  end

  abstract def action(pc : L2PcInstance, target : L2Object, interact : Bool) : Bool
  abstract def instance_type : InstanceType
end

require "./action_handlers/*"
