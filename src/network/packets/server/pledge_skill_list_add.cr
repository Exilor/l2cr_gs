class Packets::Outgoing::PledgeSkillListAdd < GameServerPacket
  initializer id : Int32, lvl : Int32

  private def write_impl
    c 0xfe
    h 0x3b

    d @id
    d @lvl
  end
end
