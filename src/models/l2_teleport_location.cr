struct L2TeleportLocation
  getter tele_id, x, y, z, price, item_id
  getter? for_noble

  initializer tele_id : Int32, x : Int32, y : Int32, z : Int32,
    price : Int32, item_id : Int32, for_noble : Bool
end
