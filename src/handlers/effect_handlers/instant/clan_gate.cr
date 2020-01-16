class EffectHandler::ClanGate < AbstractEffect
  def on_start(info)
    if pc = info.effected.as?(L2PcInstance)
      if clan = pc.clan
        sm = SystemMessage.court_magician_created_portal
        clan.broadcast_to_other_online_members(sm, pc)
      end
    end
  end
end
