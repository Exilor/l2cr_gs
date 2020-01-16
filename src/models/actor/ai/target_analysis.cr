class TargetAnalysis
  getter character : L2Character?
  getter? mage = false
  getter? balanced = false
  getter? archer = false
  getter? fighter = false
  getter? cancelled = false
  getter? slower = false
  getter? magic_resistant = false

  initializer actor : L2Character

  def update(target : L2Character?)
    # update status once in 4 seconds
    if target == @character && Rnd.rand(100) > 25
      return
    end
    @character = target
    unless target
      return
    end
    @mage = false
    @balanced = false
    @archer = false
    @fighter = false
    @cancelled = false

    if target.get_m_atk(nil, nil) > 1.5 * target.get_p_atk(nil)
      @mage = true
    elsif target.get_p_atk(nil) * 0.8 < target.get_m_atk(nil, nil) || target.get_m_atk(nil, nil) * 0.8 > target.get_p_atk(nil)
      @balanced = true
    else
      weapon = target.active_weapon_item
      if weapon && (weapon.item_type == WeaponType::BOW || weapon.item_type == WeaponType::CROSSBOW)
        @archer = true
      else
        @fighter = true
      end
    end
    if target.run_speed < @actor.run_speed - 3
      @slower = true
    else
      @slower = false
    end
    if target.get_m_def(nil, nil) * 1.2 > @actor.get_m_atk(nil, nil)
      @magic_resistant = true
    else
      @magic_resistant = false
    end
    if target.buff_count < 4
      @cancelled = true
    end
  end
end
