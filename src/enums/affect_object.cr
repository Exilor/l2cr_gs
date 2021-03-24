# class AffectObject < EnumClass
#   private WYVERN_ID = 12621
#   private alias AffectProc = L2Character, L2Object -> Bool

#   protected initializer proc : AffectProc

#   def affect?(caster : L2Character, object : L2Object) : Bool
#     @proc.call(caster, object)
#   end

#   add(ALL, AffectProc.new { |caster, object|
#     true
#   })

#   add(CLAN, AffectProc.new { |caster, object|
#     if caster.playable?
#       clan_id = caster.clan_id
#       return false if clan_id == 0
#       return false unless object.is_a?(L2Playable)
#       return clan_id == object.clan_id
#     elsif caster.npc?
#       # L2J TODO
#     end

#     false
#   })

#   add(FRIEND, AffectProc.new { |caster, object|
#     !object.auto_attackable?(caster)
#   })

#   add(HIDDEN_PLACE, AffectProc.new { |caster, object|
#     # L2J TODO
#     false
#   })

#   add(INVISIBLE, AffectProc.new { |caster, object|
#     object.invisible?
#   })

#   add(NONE, AffectProc.new { |caster, object| false })

#   add(NOT_FRIEND, AffectProc.new { |caster, object|
#     object.auto_attackable?(caster)
#   })

#   add(OBJECT_DEAD_NPC_BODY, AffectProc.new { |caster, object|
#     object.is_a?(L2Npc) && object.dead?
#   })

#   add(UNDEAD_REAL_ENEMY, AffectProc.new { |caster, object|
#     object.is_a?(L2Npc) && object.undead?
#   })

#   add(WYVERN_OBJECT, AffectProc.new { |caster, object|
#     object.is_a?(L2Npc) && object.id == WYVERN_ID
#   })
# end


class AffectObject < EnumClass
  private WYVERN_ID = 12621
  private alias AffectProc = L2Character, L2Object -> Bool

  protected initializer proc : AffectProc

  def affect?(caster : L2Character, object : L2Object) : Bool
    @proc.call(caster, object)
  end

  add(ALL, AffectProc.new { |caster, object|
    true
  })

  add(CLAN, AffectProc.new { |caster, object|
    if caster.playable?
      clan_id = caster.clan_id
      next false if clan_id == 0
      next false unless object.is_a?(L2Playable)
      next clan_id == object.clan_id
    elsif caster.npc?
      # L2J TODO
    end

    false
  })

  add(FRIEND, AffectProc.new { |caster, object|
    !object.auto_attackable?(caster)
  })

  add(HIDDEN_PLACE, AffectProc.new { |caster, object|
    # L2J TODO
    false
  })

  add(INVISIBLE, AffectProc.new { |caster, object|
    object.invisible?
  })

  add(NONE, AffectProc.new { |caster, object| false })

  add(NOT_FRIEND, AffectProc.new { |caster, object|
    object.auto_attackable?(caster)
  })

  add(OBJECT_DEAD_NPC_BODY, AffectProc.new { |caster, object|
    object.is_a?(L2Npc) && object.dead?
  })

  add(UNDEAD_REAL_ENEMY, AffectProc.new { |caster, object|
    object.is_a?(L2Npc) && object.undead?
  })

  add(WYVERN_OBJECT, AffectProc.new { |caster, object|
    object.is_a?(L2Npc) && object.id == WYVERN_ID
  })
end
