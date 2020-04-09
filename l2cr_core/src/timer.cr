class Timer
  def initialize
    @time = Time.monotonic
  end

  def start
    initialize
  end

  def result(precision : Int = 2) : Float64
    (Time.monotonic - @time).to_f.round(precision)
  end

  def s
    (Time.monotonic - @time).to_i
  end

  def ms
    (Time.monotonic - @time)
  end

  def to_s(io : IO)
    io << result(4)
  end
end
