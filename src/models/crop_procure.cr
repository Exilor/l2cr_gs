class CropProcure < SeedProduction
  def initialize(id : Int32, amount : Int64, @reward_type : Int32, start_amount : Int64, price : Int64)
    super(id, amount, price, start_amount)
  end

  def reward : Int32
    @reward_type
  end
end
