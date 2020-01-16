require "./abstract_message_packet"

class Packets::Outgoing::SystemMessage < Packets::Outgoing::AbstractMessagePacket
  # Example: SystemMessage.you_have_been_disconnected, SystemMessage.s1
  {% for const in SystemMessageId.constants %}
    def self.{{const.downcase.id}} : self
      self[SystemMessageId::{{const.id}}]
    end
  {% end %}

  # getSystemMessage(int id)
  def self.[](id : Int32) : self
    sm_id = SystemMessageId.get(id)
    self[sm_id]
  end

  # getSystemMessage(SystemMessageId smId)
  def self.[](sm_id : SystemMessageId) : self
    if sm = sm_id.static_system_message
      return sm
    end

    sm = new(sm_id)

    if sm_id.param_count == 0
      sm_id.static_system_message = sm
    end

    sm
  end

  def self.from_string(text : String) : self
    s1.add_string(text)
  end

  private def write_impl
    c 0x62
    super
  end
end
