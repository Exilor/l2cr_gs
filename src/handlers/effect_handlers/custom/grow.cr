class EffectHandler::Grow < AbstractEffect
  def effect_type : EffectType
    EffectType::BUFF
  end

  def on_start(info)
    if npc = info.effected.as?(L2Npc)
      npc.collision_radius = npc.template.collision_radius_grown
    end
  end

  def on_exit(info)
    if npc = info.effected.as?(L2Npc)
      npc.collision_radius = npc.template.f_collision_radius
    end
  end
end
