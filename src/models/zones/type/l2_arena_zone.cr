class L2ArenaZone < L2ZoneType
  def on_enter(char)
    if char.is_a?(L2PcInstance) && !char.inside_pvp_zone?
      char.send_packet(SystemMessageId::ENTERED_COMBAT_ZONE)
    end

    char.inside_pvp_zone = true
  end

  def on_exit(char)
    if char.is_a?(L2PcInstance) && !char.inside_pvp_zone?
      char.send_packet(SystemMessageId::LEFT_COMBAT_ZONE)
    end

    char.inside_pvp_zone = false
  end
end
