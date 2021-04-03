class AffectScope < EnumClass
  private alias AffectProc = L2Character, L2Character, Skill -> Array(L2Object)?
  private NO_TARGETS = [] of L2Object

  protected initializer proc : AffectProc

  def get_affected_targets(caster : L2Character, target : L2Character, skill : Skill) : Array(L2Object)
    @proc.call(caster, target, skill) || NO_TARGETS
  end

  add(BALAKAS_SCOPE, AffectProc.new { |caster, target, skill|
    # L2J TODO
  })

  add(DEAD_PLEDGE, AffectProc.new { |caster, target, skill|
    unless caster.playable? && (pc = caster.acting_player)
      return
    end

    if pc.clan_id == 0
      return
    end

    affect_limit = skill.affect_limit
    affect_object = skill.affect_object
    targets = Array(L2Object).new(affect_limit)

    L2World.get_visible_objects(target, skill.affect_range) do |object|
      if affect_limit > 0 && targets.size >= affect_limit
        break
      end

      unless object.playable? && (target_pc = object.acting_player)
        next
      end

      if pc.clan_id != target_pc.clan_id
        next
      end

      unless affect_object.affect?(caster, target_pc)
        next
      end

      targets << target_pc
    end

    targets
  })

  add(FAN, AffectProc.new { |caster, target, skill|
    # L2J TODO
  })

  add(NONE, AffectProc.new { |caster, target, skill|
    # return nil
  })

  add(PARTY, AffectProc.new { |caster, target, skill|
    affect_range = skill.affect_range
    targets = Array(L2Object).new(affect_range) # affect *range* as initial size?

    if party = caster.party
      party.members.each do |m|
        if TargetHandler.add_character(caster, m, affect_range, false)
          targets << m
        end
        if smn = TargetHandler.add_summon(caster, m, affect_range, false)
          targets << smn
        end
      end
    else
      if pc = caster.acting_player
        if TargetHandler.add_character(caster, pc, affect_range, false)
          targets << pc
        end

        if smn = TargetHandler.add_summon(caster, pc, affect_range, false)
          targets << smn
        end
      end
    end

    targets
  })

  add(PARTY_PLEDGE, AffectProc.new { |caster, target, skill|
    party = PARTY.get_affected_targets(caster, target, skill)
    pledge = PLEDGE.get_affected_targets(caster, target, skill)
    (party && pledge) ? (party + pledge) : (party || pledge)
  })

  add(PLEDGE, AffectProc.new { |caster, target, skill|
    affect_range = skill.affect_range
    affect_limit = skill.affect_limit
    targets = Array(L2Object).new(affect_limit)

    if caster.player?
      if clan = caster.clan
        clan.members.each do |clan_member|
          if affect_limit > 0 && targets.size >= affect_limit
            break
          end

          unless m = clan_member.player_instance
            next
          end

          # L2J TODO: Handle Duel.
          # L2J TODO: Handle PVP.
          # L2J TODO: Handle TVT.

          if TargetHandler.add_character(caster, m, affect_range, false)
            targets << m
          end

          if smn = TargetHandler.add_summon(caster, m, affect_range, false)
            targets << smn
          end
        end
      else
        if pc = caster.acting_player
          if TargetHandler.add_character(caster, pc, affect_range, false)
            targets << pc
          end

          if smn = TargetHandler.add_summon(caster, pc, affect_range, false)
            targets << smn
          end
        end
      end
    elsif npc = caster.as?(L2Npc)
      targets << npc

      unless (clans = npc.template.clans) && !clans.empty?
        return targets
      end

      npc.known_list.get_known_characters_in_radius(affect_range) do |char|
        if affect_limit > 0 && targets.size >= affect_limit
          break
        end

        next unless char.is_a?(L2Npc)
        next unless npc.in_my_clan?(char)

        targets << char
      end
    end

    targets
  })

  add(POINT_BLANK, AffectProc.new { |caster, target, skill|
    affect_limit = skill.affect_limit
    affect_object = skill.affect_object
    targets = Array(L2Object).new(affect_limit)

    caster.known_list.get_known_characters_in_radius(skill.affect_range) do |char|
      break if affect_limit > 0 && targets.size >= affect_limit
      next unless affect_object.affect?(caster, char)
      targets << char
    end

    targets
  })

  add(RANGE, AffectProc.new { |caster, target, skill|
    affect_limit = skill.affect_limit
    targets = Array(L2Object).new(affect_limit)

    L2World.get_visible_objects(target, skill.affect_range) do |obj|
      break if affect_limit > 0 && targets.size >= affect_limit
      next unless obj.is_a?(L2Character) && obj.alive?
      targets << obj
    end

    targets
  })

  add(RANGE_SORT_BY_HP, AffectProc.new { |caster, target, skill|
    # if targets = RANGE.get_affected_targets(caster, target, skill)
    #   targets.sort_by! &.as(L2Character).hp_percent
    # end

    ret = [] of L2Character
    L2World.get_visible_objects(target, skill.affect_range) do |obj|
      if obj.is_a?(L2Character)
        if obj.alive? && skill.bad? == obj.auto_attackable?(caster)
          ret << obj
        end
      end
    end
    ret << caster unless skill.bad?
    ret << target if skill.bad? == target.auto_attackable?(caster)
    ret.sort! { |a, b| a.hp_percent <=> b.hp_percent }
    if skill.affect_limit > 0
      ret = ret.first(skill.affect_limit)
    end

    ret.unsafe_as(Array(L2Object))
  })

  add(RING_RANGE, AffectProc.new { |caster, target, skill|
    # L2J TODO
  })

  add(SINGLE, AffectProc.new { |caster, target, skill|
    if skill.affect_object.affect?(caster, target)
      [target] of L2Object
    end
  })

  add(SQUARE, AffectProc.new { |caster, target, skill|
    # L2J TODO
  })

  add(SQUARE_PB, AffectProc.new { |caster, target, skill|
    # L2J TODO
  })

  add(STATIC_OBJECT_SCOPE, AffectProc.new { |caster, target, skill|
    # L2J TODO
  })

  add(WYVERN_SCOPE, AffectProc.new { |caster, target, skill|
    # L2J TODO
  })
end

# class AffectScope < EnumClass
#   private alias AffectProc = L2Character, L2Character, Skill -> Array(L2Object)?
#   private NO_TARGETS = [] of L2Object

#   protected initializer proc : AffectProc

#   def get_affected_targets(caster : L2Character, target : L2Character, skill : Skill) : Array(L2Object)
#     @proc.call(caster, target, skill) || NO_TARGETS
#   end

#   add(BALAKAS_SCOPE, AffectProc.new { |caster, target, skill|
#     # L2J TODO
#   })

#   add(DEAD_PLEDGE, AffectProc.new { |caster, target, skill|
#     unless caster.playable? && (pc = caster.acting_player)
#       next
#     end

#     if pc.clan_id == 0
#       next
#     end

#     affect_limit = skill.affect_limit
#     affect_object = skill.affect_object
#     targets = Array(L2Object).new(affect_limit)

#     L2World.get_visible_objects(target, skill.affect_range) do |object|
#       if affect_limit > 0 && targets.size >= affect_limit
#         break
#       end

#       unless object.playable? && (target_pc = object.acting_player)
#         next
#       end

#       if pc.clan_id != target_pc.clan_id
#         next
#       end

#       unless affect_object.affect?(caster, target_pc)
#         next
#       end

#       targets << target_pc
#     end

#     targets
#   })

#   add(FAN, AffectProc.new { |caster, target, skill|
#     # L2J TODO
#   })

#   add(NONE, AffectProc.new { |caster, target, skill|
#     # return nil
#   })

#   add(PARTY, AffectProc.new { |caster, target, skill|
#     affect_range = skill.affect_range
#     targets = Array(L2Object).new(affect_range) # affect *range* as initial size?

#     if party = caster.party
#       party.members.each do |m|
#         if TargetHandler.add_character(caster, m, affect_range, false)
#           targets << m
#         end
#         if smn = TargetHandler.add_summon(caster, m, affect_range, false)
#           targets << smn
#         end
#       end
#     else
#       if pc = caster.acting_player
#         if TargetHandler.add_character(caster, pc, affect_range, false)
#           targets << pc
#         end

#         if smn = TargetHandler.add_summon(caster, pc, affect_range, false)
#           targets << smn
#         end
#       end
#     end

#     targets
#   })

#   add(PARTY_PLEDGE, AffectProc.new { |caster, target, skill|
#     party = PARTY.get_affected_targets(caster, target, skill)
#     pledge = PLEDGE.get_affected_targets(caster, target, skill)
#     (party && pledge) ? (party + pledge) : (party || pledge)
#   })

#   add(PLEDGE, AffectProc.new { |caster, target, skill|
#     affect_range = skill.affect_range
#     affect_limit = skill.affect_limit
#     targets = Array(L2Object).new(affect_limit)

#     if caster.player?
#       if clan = caster.clan
#         clan.members.each do |clan_member|
#           if affect_limit > 0 && targets.size >= affect_limit
#             break
#           end

#           unless m = clan_member.player_instance
#             next
#           end

#           # L2J TODO: Handle Duel.
#           # L2J TODO: Handle PVP.
#           # L2J TODO: Handle TVT.

#           if TargetHandler.add_character(caster, m, affect_range, false)
#             targets << m
#           end

#           if smn = TargetHandler.add_summon(caster, m, affect_range, false)
#             targets << smn
#           end
#         end
#       else
#         if pc = caster.acting_player
#           if TargetHandler.add_character(caster, pc, affect_range, false)
#             targets << pc
#           end

#           if smn = TargetHandler.add_summon(caster, pc, affect_range, false)
#             targets << smn
#           end
#         end
#       end
#     elsif npc = caster.as?(L2Npc)
#       targets << npc

#       unless (clans = npc.template.clans) && !clans.empty?
#         next targets
#       end

#       npc.known_list.get_known_characters_in_radius(affect_range) do |char|
#         if affect_limit > 0 && targets.size >= affect_limit
#           break
#         end

#         next unless char.is_a?(L2Npc)
#         next unless npc.in_my_clan?(char)

#         targets << char
#       end
#     end

#     targets
#   })

#   add(POINT_BLANK, AffectProc.new { |caster, target, skill|
#     affect_limit = skill.affect_limit
#     affect_object = skill.affect_object
#     targets = Array(L2Object).new(affect_limit)

#     caster.known_list.get_known_characters_in_radius(skill.affect_range) do |char|
#       break if affect_limit > 0 && targets.size >= affect_limit
#       next unless affect_object.affect?(caster, char)
#       targets << char
#     end

#     targets
#   })

#   add(RANGE, AffectProc.new { |caster, target, skill|
#     affect_limit = skill.affect_limit
#     targets = Array(L2Object).new(affect_limit)

#     L2World.get_visible_objects(target, skill.affect_range) do |obj|
#       break if affect_limit > 0 && targets.size >= affect_limit
#       next unless obj.is_a?(L2Character) && obj.alive?
#       targets << obj
#     end

#     targets
#   })

#   add(RANGE_SORT_BY_HP, AffectProc.new { |caster, target, skill|
#     # if targets = RANGE.get_affected_targets(caster, target, skill)
#     #   targets.sort_by! &.as(L2Character).hp_percent
#     # end

#     ret = [] of L2Character
#     L2World.get_visible_objects(target, skill.affect_range) do |obj|
#       if obj.is_a?(L2Character)
#         if obj.alive? && skill.bad? == obj.auto_attackable?(caster)
#           ret << obj
#         end
#       end
#     end
#     ret << caster unless skill.bad?
#     ret << target if skill.bad? == target.auto_attackable?(caster)
#     ret.sort! { |a, b| a.hp_percent <=> b.hp_percent }
#     if skill.affect_limit > 0
#       ret = ret.first(skill.affect_limit)
#     end

#     ret.unsafe_as(Array(L2Object))
#   })

#   add(RING_RANGE, AffectProc.new { |caster, target, skill|
#     # L2J TODO
#   })

#   add(SINGLE, AffectProc.new { |caster, target, skill|
#     if skill.affect_object.affect?(caster, target)
#       [target] of L2Object
#     end
#   })

#   add(SQUARE, AffectProc.new { |caster, target, skill|
#     # L2J TODO
#   })

#   add(SQUARE_PB, AffectProc.new { |caster, target, skill|
#     # L2J TODO
#   })

#   add(STATIC_OBJECT_SCOPE, AffectProc.new { |caster, target, skill|
#     # L2J TODO
#   })

#   add(WYVERN_SCOPE, AffectProc.new { |caster, target, skill|
#     # L2J TODO
#   })
# end
