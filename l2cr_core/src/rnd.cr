module Rnd
  extend self

  {% for name in %w(i8 i16 i32 i64 u8 u16 u32 u64 f32 f64) %}
    {% prefix = name.starts_with?('i') ? "Int".id : (name.starts_with?('u') ? "UInt".id : "Float".id) %}
    {% type = "#{prefix}#{name[1..-1].id}".id %}

    def {{name.id}} : {{type}}
      Random::Secure.rand({{type}}::MIN..{{type}}::MAX)
    end
  {% end %}

  def bool : Bool
    Random::Secure.next_bool
  end

  def bytes(size : Int) : Bytes
    Random::Secure.random_bytes(size)
  end

  def rand(range : Range)
    Random::Secure.rand(range)
  end

  def rand(n : Number)
    n.zero? ? n : Random::Secure.rand(n)
  end

  def rand : Float64
    Random::Secure.rand
  end

  private class RandomGaussian
    @valid = false
    @next = 0.0

    def initialize(@mean : Float64, @stddev : Float64, @rand_helper : -> Float64)
    end

    def rand
      if @valid
        @valid = false
        return @next
      end

      @valid = true
      x, y = gaussian(@mean, @stddev, @rand_helper)
      @next = y
      x
    end

    private def gaussian(mean, stddev, rand)
      theta = 2 * Math::PI * rand.call
      rho = Math.sqrt(-2 * Math.log(1 - rand.call))
      scale = stddev * rho
      x = mean + scale * Math.cos(theta)
      y = mean + scale * Math.sin(theta)
      {x, y}
    end
  end

  private GAUSSIAN = RandomGaussian.new(0.0, 1.0, ->Random::Secure.rand)

  def gaussian : Float64
    GAUSSIAN.rand
  end
end
