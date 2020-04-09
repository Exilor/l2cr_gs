struct Time
  def self.now : self
    local
  end

  def self.s : Int64
    now.to_unix
  end

  def self.ms : Int64
    now.to_unix_ms
  end

  def self.ns : Int64
    s, n = Crystal::System::Time.monotonic
    (s * 1_000_000_000) + n
  end

  def self.days_to_ms(days : Number)
    days.to_i64 * 24 * 60 * 60 * 1000
  end

  def self.ms_to_days(ms : Number)
    ms.fdiv(24) / 60 / 60 / 1000
  end

  def self.ms_to_mins(ms : Number)
    ms.fdiv(1000) / 60
  end

  def self.mins_to_ms(mins : Number)
    mins.to_i64 * 1000 * 60
  end

  def self.ms_to_ns(ms : Number)
    ms.to_i64 * 1_000_000
  end

  def self.ns_to_ms(ns : Number)
    ns.to_i64 / 1_000_000
  end

  def self.s_to_ms(s : Number)
    s.to_i64 * 1000
  end

  def self.ms_to_s(ms : Number)
    ms.fdiv(1000)
  end

  def self.hours_to_ms(h : Number)
    h.to_i64 * 3_600_000
  end

  def self.from_ms(ms : Number)
    unix_ms(ms)
  end

  def self.from_s(s : Number)
    unix(s)
  end

  def s : Int64
    to_unix
  end

  def ms : Int64
    to_unix_ms
  end

  def before?(other : self) : Bool
    self < other
  end

  def after?(other : self) : Bool
    self > other
  end
end
