class Packets::Outgoing::Snoop < GameServerPacket
  initializer convo_id : Int32, name : String, type : Int32, speaker : String,
    msg : String

  private def write_impl
    c 0xdb

    d @convo_id
    s @name
    d 0
    d @type
    s @speaker
    s @msg
  end
end
