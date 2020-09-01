class Packets::Outgoing::ReplyCharacters < MMO::OutgoingPacket(LoginServerThread)
  initializer account : String, chars : Int32, to_delete : Array(Int64)

  def write
    c 0x08

    s @account
    c @chars
    c @to_delete.size
    @to_delete.each do |time|
      q time
    end
  end
end
