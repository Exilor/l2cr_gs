enum PrivateStoreType : UInt8
  NONE
  SELL
  SELL_MANAGE
  BUY
  BUY_MANAGE
  MANUFACTURE
  PACKAGE_SELL = 8

  def id
    to_i
  end
end
