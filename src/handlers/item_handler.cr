module ItemHandler
  include Packets::Outgoing

  macro extended
    include Loggable
  end

  private HANDLERS = {} of String => self

  def self.load
    {% for const in @type.constants %}
      obj = {{const.id}}
      if obj.is_a?(self)
        register(obj)
      end
    {% end %}
  end

  def self.register(handler : self)
    HANDLERS[handler.simple_name] = handler
  end

  def self.[](item : L2Item?) : self?
    if name = item.try &.handler_name
      HANDLERS[name]?
    end
  end

  abstract def use_item(playable : L2Playable, item : L2ItemInstance, force_use : Bool) : Bool
end

require "./item_handlers/*"
