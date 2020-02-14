class L2PremiumItem
  getter_initializer item_id : Int32, count : Int64, sender : String

  def update_count(new_count : Int64)
    @count = new_count
  end
end
