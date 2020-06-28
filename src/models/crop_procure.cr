class CropProcure < SeedProduction
  getter reward

  def initialize(id : Int32, amount : Int64, reward : Int32, start_amount : Int64, price : Int64)
    super(id, amount, price, start_amount)
    @reward = reward
  end
end
