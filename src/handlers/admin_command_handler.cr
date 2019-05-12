module AdminCommandHandler
  include Loggable

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
    handler.commands.each { |cmd| HANDLERS[cmd] = handler }
  end

  def self.[](cmd : String) : self?
    if idx = cmd.index(' ')
      cmd = cmd[0, idx]
    end

    HANDLERS[cmd]?
  end

  abstract def commands : Enumerable(String)
end

require "./admin_command_handlers/*"
