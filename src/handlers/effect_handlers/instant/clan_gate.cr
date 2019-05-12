class EffectHandler::ClanGate < AbstractEffect
  def on_start(info)
    if info.effected.player?
      pc = info.effected.acting_player
      if clan = pc.clan?
        sm = SystemMessage.court_magician_created_portal
        clan.broadcast_to_other_online_members(sm, pc)
      end
    end
  end
end
