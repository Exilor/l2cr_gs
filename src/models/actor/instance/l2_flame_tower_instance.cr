class L2FlameTowerInstance < L2Tower
  @zone_list : Array(Int32)?

  setter upgrade_level : Int32 = 0

  def do_die(killer : L2Character?) : Bool
    enable_zones(false)
    super
  end

  def delete_me
    enable_zones(false)
    super
  end

  def enable_zones(state : Bool)
    return unless list = @zone_list
    return unless @upgrade_level == 0

    (@upgrade_level * 2).times do |i|
      if zone = ZoneManager.get_zone_by_id(list[i])
        zone.enabled = state
      end
    end
  end

  def instance_type : InstanceType
    InstanceType::L2FlameTowerInstance
  end

  def zone_list=(@zone_list : Array(Int32)?)
    enable_zones(true)
  end
end
