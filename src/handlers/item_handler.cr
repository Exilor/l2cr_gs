module ItemHandler
  extend Loggable
  include Loggable
  include Packets::Outgoing

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
    return unless item

    if handler_name = item.handler_name
      if handler = HANDLERS[handler_name]?
        return handler
      end
    end

    nil
  end

  # abstract def use_item(playable : L2Playable, item : L2ItemInstance, force_use : Bool) : Bool
end

require "./item_handlers/*"
