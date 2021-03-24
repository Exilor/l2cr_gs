module VoicedCommandHandler
  macro extended
    include Loggable
  end
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
    handler.commands.each { |cmd| HANDLERS[cmd] = handler }
  end

  def self.[](cmd : String) : self?
    if idx = cmd.index(' ')
      cmd = cmd[0, idx]
    end

    HANDLERS[cmd]?
  end

  abstract def commands : Enumerable(String)
  abstract def use_voiced_command(cmd : String, pc : L2PcInstance, params : String) : Bool
end

require "./voiced_command_handlers/*"
