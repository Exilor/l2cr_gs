require "../../system_message_id"

class Packets::Outgoing::ConfirmDlg < Packets::Outgoing::AbstractMessagePacket
  {% for const in SystemMessageId.constants %}
    def self.{{const.downcase.id}} : self
      new(SystemMessageId::{{const.id}})
    end
  {% end %}

  property time : Int32 = 0
  property requester_id : Int32 = 0

  def self.new(text : String)
    s1.add_string(text)
  end

  def self.new(id : Int32)
    sm_id = SystemMessageId.get_system_message_id(id)
    new(sm_id)
  end

  def write_impl
    c 0xf3

    super
    d @time
    d @requester_id
  end
end
