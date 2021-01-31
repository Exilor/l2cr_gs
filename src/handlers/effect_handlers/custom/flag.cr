class EffectHandler::Flag < AbstractEffect
  def can_start?(info : BuffInfo) : Bool
    info.effected.is_a?(L2PcInstance)
  end

  def on_exit(info : BuffInfo)
    info.effected.update_pvp_flag(0)
  end

  def on_start(info : BuffInfo)
    info.effected.update_pvp_flag(1)
  end
end
