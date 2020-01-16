class DamageDoneInfo
  getter damage = 0

  getter_initializer attacker : L2PcInstance

  def_equals_and_hash attacker

  def add_damage(damage : Int32)
    @damage += damage
  end
end
