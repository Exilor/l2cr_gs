enum ItemAuctionState : UInt8
  CREATED
  STARTED
  FINISHED

  def state_id : Int8
    to_i8
  end

  def self.state_for_state_id(state_id : Int) : self?
    from_value?(state_id)
  end
end
