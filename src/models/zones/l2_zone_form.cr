abstract struct L2ZoneForm
  private STEP = 10

  abstract def inside_zone?(x : Int32, y : Int32, z : Int32) : Bool
  abstract def intersects_rectangle?(x1 : Int32, x2 : Int32, y1 : Int32, y2 : Int32) : Bool
  abstract def get_distance_to_zone(x : Int32, y : Int32) : Float64
  abstract def low_z : Int32
  abstract def high_z : Int32
  abstract def visualize_zone(z : Int32)
  abstract def random_point : {Int32, Int32, Int32}

  private def drop_debug_item(item_id : Int32, num : Int, x : Int32, y : Int32, z : Int32)
    item = L2ItemInstance.new(IdFactory.next, item_id)
    item.count = num.to_i64
    item.spawn_me(x, y, z + 5)
    # debug "Spawning #{item} at #{item.location}"
    ZoneManager.debug_items << item
  end
end
