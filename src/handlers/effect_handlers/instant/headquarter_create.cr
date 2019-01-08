class EffectHandler::HeadquarterCreate < AbstractEffect
  private HQ_NPC_ID = 335062

  @advanced : Bool

  def initialize(attach_cond, apply_cond, set, params)
    super
    @advanced = params.get_bool("isAdanced", false)
  end

  def instant?
    true
  end

  def on_start(info)
    pc = info.effector.acting_player
    unless pc.clan_leader?
      return
    end

    flag = L2SiegeFlagInstance.new(pc, NpcData[HQ_NPC_ID], @advanced, false)
    flag.title = pc.clan.name
    flag.heal!
    flag.heading = pc.heading
    flag.spawn_me(pc.x, pc.y, pc.z + 50)

    if castle = CastleManager.get_castle(pc)
      castle.siege.get_flag(pc.clan).not_nil! << flag
    elsif fort = FortManager.get_fort(pc)
      fort.siege.get_flag(pc.clan).not_nil! << flag
    else
      CHSiegeManager.get_nearby_clan_hall!(pc).siege.get_flag(pc.clan).not_nil! << flag
    end
  end
end
