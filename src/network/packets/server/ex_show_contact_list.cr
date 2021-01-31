class Packets::Outgoing::ExShowContactList < GameServerPacket
  @contacts : Concurrent::Array(String)

  def initialize(pc : L2PcInstance)
    @contacts = pc.contact_list.contacts
  end

  private def write_impl
    c 0xfe
    h 0xd3

    d @contacts.size
    @contacts.each { |name| s name }
  end
end
