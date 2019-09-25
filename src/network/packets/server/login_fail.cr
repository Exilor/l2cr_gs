class Packets::Outgoing::LoginFail < GameServerPacket
  private initializer reason : Int32

  def write_impl
    c 0x0a
    d @reason
  end

  NO_TEXT = new(0)
  SYSTEM_ERROR_LOGIN_LATER = new(1)
  PASSWORD_DOES_NOT_MATCH_THIS_ACCOUNT = new(2)
  PASSWORD_DOES_NOT_MATCH_THIS_ACCOUNT2 = new(3)
  ACCESS_FAILED_TRY_LATER = new(4)
  INCORRECT_ACCOUNT_INFO_CONTACT_CUSTOMER_SUPPORT = new(5)
  ACCESS_FAILED_TRY_LATER2 = new(6)
  ACOUNT_ALREADY_IN_USE = new(7)
  ACCESS_FAILED_TRY_LATER3 = new(8)
  ACCESS_FAILED_TRY_LATER4 = new(9)
  ACCESS_FAILED_TRY_LATER5 = new(10)
end
