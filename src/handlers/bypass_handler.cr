module BypassHandler
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
    handler.commands.each do |cmd|
      HANDLERS[cmd.downcase] = handler
    end
  end

  def self.[](cmd : String) : self?
    if idx = cmd.index(' ')
      cmd = cmd[0, idx]
    end

    HANDLERS[cmd.downcase]?
  end

  abstract def use_bypass(cmd : String, pc : L2PcInstance, target : L2Character) : Bool
  abstract def commands : Enumerable(String)
end

require "./bypass_handlers/*"
