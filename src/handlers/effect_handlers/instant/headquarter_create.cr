class EffectHandler::HeadquarterCreate < AbstractEffect
  private HQ_NPC_ID = 335062

  @advanced : Bool

  def initialize(attach_cond, apply_cond, set, params)
    super
    @advanced = params.get_bool("isAdvanced", false)
  end

  def instant? : Bool
    true
  end

  def on_start(info)
    return unless pc = info.effector.acting_player
    return unless clan = pc.clan
    return unless pc.clan_leader?

    flag = L2SiegeFlagInstance.new(pc, NpcData[HQ_NPC_ID], @advanced, false)
    flag.title = clan.name
    flag.heal!
    flag.heading = pc.heading
    flag.spawn_me(pc.x, pc.y, pc.z + 50)

    if castle = CastleManager.get_castle(pc)
      castle.siege.get_flag(pc.clan).not_nil! << flag
    elsif fort = FortManager.get_fort(pc)
      fort.siege.get_flag(pc.clan).not_nil! << flag
    else
      ClanHallSiegeManager.get_nearby_clan_hall(pc).not_nil!.siege.get_flag(pc.clan).not_nil! << flag
    end
  end
end
