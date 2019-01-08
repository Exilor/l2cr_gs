class EffectHandler::TakeTerritoryFlag < AbstractEffect
  private FLAG_NPC_ID = 35062

  def instant?
    true
  end

  def on_start(info)
    pc = info.effector.acting_player
    return unless pc.clan_leader?
    return unless TerritoryWarManager.tw_in_progress?

    flag = L2SiegeFlagInstance.new(pc, NpcData[FLAG_NPC_ID], false, false)
    flag.title = pc.clan.name
    flag.heal!
    flag.heading = pc.heading
    flag.spawn_me(pc.x, pc.y, pc.z + 50)
    TerritoryWarManager.add_clan_flag(pc.clan, flag)
  end
end
