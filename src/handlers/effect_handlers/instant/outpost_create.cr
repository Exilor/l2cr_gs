class EffectHandler::OutpostCreate < AbstractEffect
  private HQ_NPC_ID = 36590

  def instant?
    true
  end

  def on_start(info)
    pc = info.effector.acting_player

    unless pc.clan_leader?
      return
    end

    unless TerritoryWarManager.tw_in_progress?
      return
    end

    flag = L2SiegeFlagInstance.new(pc, NpcData[HQ_NPC_ID], true, true)
    flag.title = pc.clan.name
    flag.heal!
    flag.heading = pc.heading
    flag.spawn_me(pc.x, pc.y, pc.z + 50)
    TerritoryWarManager.set_hq_for_clan(pc.clan, flag)
  end
end
