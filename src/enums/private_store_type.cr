enum PrivateStoreType : UInt8
  NONE
  SELL
  SELL_MANAGE
  BUY
  BUY_MANAGE
  MANUFACTURE
  PACKAGE_SELL = 8

  def id : Int32
    to_i
  end
end
