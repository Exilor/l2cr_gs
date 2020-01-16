require "./item_holder"

class UniqueItemHolder < ItemHolder
  getter l2id

  def initialize(id : Int32, @l2id : Int32, count : Int64 = 1i64)
    super(id, count)
  end
end
