class ItemAuctionState < EnumClass
  add(CREATED)
  add(STARTED)
  add(FINISHED)

  def state_id : Int8
    to_i8
  end

  def self.state_for_state_id(state_id : Int) : self?
    find { |m| m.to_i == state_id }
  end
end
