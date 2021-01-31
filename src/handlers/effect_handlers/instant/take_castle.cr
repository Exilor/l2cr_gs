class EffectHandler::TakeCastle < AbstractEffect
  def instant? : Bool
    true
  end

  def on_start(info : BuffInfo)
    return unless pc = info.effector.as?(L2PcInstance)
    return unless clan = pc.clan
    CastleManager.get_castle(pc).not_nil!.engrave(clan, info.effected)
  end
end
