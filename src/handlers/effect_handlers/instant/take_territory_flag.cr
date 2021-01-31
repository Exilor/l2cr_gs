class EffectHandler::TakeTerritoryFlag < AbstractEffect
  private FLAG_NPC_ID = 35062

  def instant? : Bool
    true
  end

  def on_start(info : BuffInfo)
    return unless pc = info.effector.acting_player
    return unless clan = pc.clan
    return unless pc.clan_leader?
    return unless TerritoryWarManager.tw_in_progress?

    flag = L2SiegeFlagInstance.new(pc, NpcData[FLAG_NPC_ID], false, false)
    flag.title = clan.name
    flag.heal!
    flag.heading = pc.heading
    flag.spawn_me(pc.x, pc.y, pc.z + 50)
    TerritoryWarManager.add_clan_flag(clan, flag)
  end
end
