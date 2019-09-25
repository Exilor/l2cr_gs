module ChatHandler
  include Loggable

  private alias CreatureSay = Packets::Outgoing::CreatureSay

  private HANDLERS = {} of Int32 => self

  def self.load
    {% for const in @type.constants %}
      const = {{const.id}}
      if const.is_a?(self)
        register(const)
      end
    {% end %}
  end

  def self.register(handler : self)
    handler.chat_type_list.each do |id|
      HANDLERS[id] = handler
    end
  end

  def self.[](chat_type : Int32) : self?
    HANDLERS[chat_type]?
  end

  # abstract def handle_chat(type : Int32, pc : L2PcInstance, target : String, text : String)
  # abstract def chat_type_list : Enumerable(Int32)
end

require "./chat_handlers/*"
