module ItemHandler
  extend Loggable
  include Loggable
  include Packets::Outgoing

  private HANDLERS = {} of String => self

  def self.load
    {% for const in @type.constants %}
      const = {{const.id}}
      if const.is_a?(self)
        register(const)
      end
    {% end %}
  end

  def self.register(handler : self)
    HANDLERS[handler.simple_name] = handler
  end

  def self.[](item : L2Item?) : self?
    unless item
      debug "No item given."
      return
    end

    if handler_name = item.handler_name
      if handler = HANDLERS[handler_name]?
        return handler
      else
        debug "No handler for #{handler_name.inspect}."
      end
    end

    nil
  end

  abstract def use_item(playable : L2Playable, item : L2ItemInstance, force_use : Bool) : Bool
end

require "./item_handlers/*"
