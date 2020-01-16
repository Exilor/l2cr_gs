class Packets::Outgoing::CharDeleteFail < GameServerPacket
  private initializer error : UInt8

  private def write_impl
    c 0x1e
    d @error
  end

  DELETION_FAILED = new(1)
  YOU_MAY_NOT_DELETE_CLAN_MEMBER = new(2)
  CLAN_LEADERS_MAY_NOT_BE_DELETED = new(3)
end
