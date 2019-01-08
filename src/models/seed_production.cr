class SeedProduction
  getter id, price, start_amount

  def initialize(@id : Int32, amount : Int64, @price : Int64, @start_amount : Int64)
    @amount = Atomic(Int64).new(amount)
  end

  def amount : Int64
    @amount.get
  end

  def amount=(amount : Int64)
    @amount.set(amount)
  end

  def decrease_amount(val : Int64)
    loop do
      current = @amount.get
      _next = current - val
      if _next < 0
        return false
      end

      break if @amount.compare_and_set(current, _next)[1]
    end

    true
  end
end
