class EffectHandler::Escape < AbstractEffect
  @escape_type : TeleportWhereType?

  def initialize(attach_cond, apply_cond, set, params)
    super
    @escape_type = params.get_enum("escapeType", TeleportWhereType, nil)
  end

  def effect_type
    L2EffectType::TELEPORT
  end

  def instant?
    true
  end

  def on_start(info)
    return unless escape_type = @escape_type
    char = info.effected
    loc = MapRegionManager.get_tele_to_location(char, escape_type)
    char.tele_to_location(loc, true)
    char.acting_player.in_7s_dungeon = false
    char.instance_id = 0
  end
end
