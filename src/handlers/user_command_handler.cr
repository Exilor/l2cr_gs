module UserCommandHandler
  include Loggable

  private HANDLERS = {} of Int32 => self

  def self.load
    {% for const in @type.constants %}
      obj = {{const.id}}
      if obj.is_a?(self)
        register(obj)
      end
    {% end %}
  end

  def self.register(handler : self)
    handler.commands.each { |cmd| HANDLERS[cmd] = handler }
  end

  def self.[](cmd : Int) : self?
    HANDLERS[cmd]?
  end

  # abstract def use_user_command(id : Int32, pc : L2PcInstance) : Bool
  # abstract def commands : Enumerable(Int32)
end

require "./user_command_handlers/*"
