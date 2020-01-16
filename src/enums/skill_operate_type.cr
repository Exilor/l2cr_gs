enum SkillOperateType : UInt8
  # Active Skill with "Instant Effect" (for example skills heal/pdam/mdam/cpdam skills).
  A1
  # Active Skill with "Continuous effect + Instant effect" (for example buff/debuff or damage/heal over time skills).
  A2
  # Active Skill with "Instant effect + Continuous effect"
  A3
  # Active Skill with "Instant effect + ?" used for special event herb.
  A4
  # Continuous Active Skill with "instant effect" (instant effect casted by ticks).
  CA1
  # Continuous Active Skill with "continuous effect" (continuous effect casted by ticks).
  CA5
  # Directional Active Skill with "Charge/Rush instant effect".
  DA1
  # Directional Active Skill with "Charge/Rush Continuous effect".
  DA2
  # Passive Skill.
  P
  # Toggle Skill.
  T

  def active? : Bool
    between?(A1, DA2)
  end

  def channeling? : Bool
    ca1? || ca5?
  end

  def continuous? : Bool
    a2? || a4? || da2?
  end

  def fly_type? : Bool
    da1? || da2?
  end

  def self_continuous? : Bool
    a3?
  end

  def passive? : Bool
    p?
  end

  def toggle? : Bool
    t?
  end
end
