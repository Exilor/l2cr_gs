class ItemRequest
  getter l2id, price, item_id = 0
  property count : Int64

  initializer l2id : Int32, count : Int64, price : Int64
  initializer l2id : Int32, item_id : Int32, count : Int64, price : Int64

  def_equals_and_hash @l2id
end
