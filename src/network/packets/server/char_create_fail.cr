class Packets::Outgoing::CharCreateFail < GameServerPacket
  private initializer error : UInt8

  private def write_impl
    c 0x10
    d @error
  end

  CREATION_FAILED     = new(0)
  TOO_MANY_CHARACTERS = new(1)
  NAME_ALREADY_EXISTS = new(2)
  REASON_16_ENG_CHARS = new(3)
  INCORRECT_NAME      = new(4)
  CREATE_NOW_ALLOWED  = new(5)
  CHOOSE_ANOTHER_SVR  = new(6)
end
