module BypassHandler::SupportMagic
  extend self
  extend BypassHandler

  # Buffs
  private HASTE_1 = SkillHolder.new(4327)
  private HASTE_2 = SkillHolder.new(5632)
  private CUBIC   = SkillHolder.new(4338)
  private FIGHTER_BUFFS = {
    SkillHolder.new(4322), # Wind Walk
    SkillHolder.new(4323), # Shield
    SkillHolder.new(5637), # Magic Barrier
    SkillHolder.new(4324), # Bless the Body
    SkillHolder.new(4325), # Vampiric Rage
    SkillHolder.new(4326)  # Regeneration
  }
  private MAGE_BUFFS = {
    SkillHolder.new(4322), # Wind Walk
    SkillHolder.new(4323), # Shield
    SkillHolder.new(5637), # Magic Barrier
    SkillHolder.new(4328), # Bless the Soul
    SkillHolder.new(4329), # Acumen
    SkillHolder.new(4330), # Concentration
    SkillHolder.new(4331)  # Empower
  }

  private SUMMON_BUFFS = FIGHTER_BUFFS + {
    MAGE_BUFFS[3],
    MAGE_BUFFS[4],
    MAGE_BUFFS[5],
    MAGE_BUFFS[6]
  }

  # Levels
  private LOWEST_LEVEL  = 6
  private HIGHEST_LEVEL = 75
  private CUBIC_LOWEST  = 16
  private CUBIC_HIGHEST = 34
  private HASTE_LEVEL_2 = 40

  def use_bypass(command : String, pc : L2PcInstance, target : L2Character?) : Bool
    return false unless target.is_a?(L2Npc)
    return false if pc.cursed_weapon_equipped?

    if command.casecmp?(commands[1])
      make_support_magic(pc, target, true)
    elsif command.casecmp?(commands[0])
      make_support_magic(pc, target, false)
    end

    true
  end

  private def make_support_magic(pc, npc, summon)
    level = pc.level

    if summon && !pc.has_servitor?
      npc.show_chat_window(pc, "data/html/default/SupportMagicNoSummon.htm")
      return
    elsif level > HIGHEST_LEVEL
      npc.show_chat_window(pc, "data/html/default/SupportMagicHighLevel.htm")
      return
    elsif level < LOWEST_LEVEL
      npc.show_chat_window(pc, "data/html/default/SupportMagicLowLevel.htm")
      return
    elsif pc.class_id.level == 3
      pc.send_message("Only adventurers who have not completed their 3rd class transfer may receive these buffs.")
      return
    end

    if summon
      npc.target = pc.summon
      SUMMON_BUFFS.each { |sh| npc.do_cast(sh) }

      if level >= HASTE_LEVEL_2
        npc.do_cast(HASTE_2)
      else
        npc.do_cast(HASTE_1)
      end
    else
      npc.target = pc

      if pc.in_category?(CategoryType::BEGINNER_MAGE)
        MAGE_BUFFS.each { |sh| npc.do_cast(sh) }
      else
        FIGHTER_BUFFS.each { |sh| npc.do_cast(sh) }

        if level >= HASTE_LEVEL_2
          npc.do_cast(HASTE_2)
        else
          npc.do_cast(HASTE_1)
        end
      end

      if level.between?(CUBIC_LOWEST, CUBIC_HIGHEST)
        pc.do_simultaneous_cast(CUBIC)
      end
    end
  end

  def commands : Enumerable(String)
    {"supportmagic", "supportmagicservitor"}
  end
end
