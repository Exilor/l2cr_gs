class EffectHandler::Escape < AbstractEffect
  @escape_type : TeleportWhereType?

  def initialize(attach_cond : Condition?, apply_cond : Condition?, set : StatsSet, params : StatsSet)
    super
    @escape_type = params.get_enum("escapeType", TeleportWhereType, nil)
  end

  def effect_type : EffectType
    EffectType::TELEPORT
  end

  def instant? : Bool
    true
  end

  def on_start(info : BuffInfo)
    return unless escape_type = @escape_type
    char = info.effected
    loc = MapRegionManager.get_tele_to_location(char, escape_type)
    char.tele_to_location(loc, true)
    char.acting_player.not_nil!.in_7s_dungeon = false
    char.instance_id = 0
  end
end
