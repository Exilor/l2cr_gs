require "../enums/instance_type"

module ActionShiftHandler
  include Packets::Outgoing

  private HANDLERS = EnumMap(InstanceType, self).new

  def self.load
    {% for const in @type.constants %}
      obj = {{const.id}}
      if obj.is_a?(self)
        register(obj)
      end
    {% end %}
  end

  def self.register(handler : self)
    HANDLERS[handler.instance_type] = handler
  end

  def self.[](type : InstanceType) : self?
    handler = nil
    while type
      break if handler = HANDLERS[type]?
      type = type.parent
    end
    handler
  end

  abstract def action(pc : L2PcInstance, target : L2Object, interact : Bool) : Bool
  abstract def instance_type : InstanceType
end

require "./action_shift_handlers/*"
