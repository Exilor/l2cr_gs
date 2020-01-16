class EffectHandler::OutpostCreate < AbstractEffect
  private HQ_NPC_ID = 36590

  def instant? : Bool
    true
  end

  def on_start(info)
    return unless pc = info.effector.acting_player
    return unless clan = pc.clan
    return unless pc.clan_leader?

    unless TerritoryWarManager.tw_in_progress?
      return
    end

    flag = L2SiegeFlagInstance.new(pc, NpcData[HQ_NPC_ID], true, true)
    flag.title = clan.name
    flag.heal!
    flag.heading = pc.heading
    flag.spawn_me(pc.x, pc.y, pc.z + 50)
    TerritoryWarManager.set_hq_for_clan(clan, flag)
  end
end
