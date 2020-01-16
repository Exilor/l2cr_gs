class Packets::Outgoing::ExSubPledgeSkillAdd < GameServerPacket
  initializer type : Int32, id : Int32, lvl : Int32

  private def write_impl
    c 0xfe
    h 0x76

    d @type
    d @id
    d @lvl
  end
end
