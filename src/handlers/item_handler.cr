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
    # debug "Registering #{handler}."
    HANDLERS[handler.simple_name] = handler
  end

  def self.[](item : L2Item?) : self?
    unless item
      warn "No item given."
      return
    end

    if handler_name = item.handler_name
      if handler = HANDLERS[handler_name]?
        handler
      else
        warn "No handler for #{handler_name.inspect}."
        nil
      end
    else
      debug item
      debug item.handler_name.inspect
    end
  end

  abstract def use_item(playable : L2Playable, item : L2ItemInstance, force_use : Bool) : Bool
end

require "./item_handlers/*"
