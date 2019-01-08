class L2NoLandingZone < L2ZoneType
  @dismount_delay = 5

  def set_parameter(name, value)
    if name == "dismountDelay"
      @dismount_delay = value.to_i
    else
      super
    end
  end

  def on_enter(char)
    if char.is_a?(L2PcInstance)
      char.inside_no_landing_zone = true

      if char.mount_type.wyvern?
        char.send_packet(SystemMessageId::AREA_CANNOT_BE_ENTERED_WHILE_MOUNTED_WYVERN)
        char.entered_no_landing(@dismount_delay)
      end
    end
  end

  def on_exit(char)
    if char.is_a?(L2PcInstance)
      char.inside_no_landing_zone = false

      if char.mount_type.wyvern?
        char.exited_no_landing
      end
    end
  end
end
