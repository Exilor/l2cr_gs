struct PvPFlagTask
  initializer pc : L2PcInstance

  def call
    time = Time.ms
    if time > @pc.pvp_flag_lasts
      @pc.stop_pvp_flag
    elsif time > @pc.pvp_flag_lasts - 20_000
      @pc.update_pvp_flag(2)
    else
      @pc.update_pvp_flag(1)
    end
  end
end
