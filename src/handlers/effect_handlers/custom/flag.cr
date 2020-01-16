class EffectHandler::Flag < AbstractEffect
  def can_start?(info)
    info.effected?.is_a?(L2PcInstance)
  end

  def on_exit(info)
    info.effected.update_pvp_flag(0)
  end

  def on_start(info)
    info.effected.update_pvp_flag(1)
  end
end
