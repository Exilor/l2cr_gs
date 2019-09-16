struct HitTask
  initializer char: L2Character, target: L2Character, damage: Int32, crit: Bool,
    miss: Bool, ss: Bool, shld: Int8

  def call
    @char.on_hit_timer(@target, @damage, @crit, @miss, @ss, @shld)
  end
end
