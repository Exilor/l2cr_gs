require "./item_holder"

class ItemChanceHolder < ItemHolder
  getter chance

  def initialize(id : Int32, @chance : Float64, count : Int64 = 1_i64)
    super(id, count)
  end
end
