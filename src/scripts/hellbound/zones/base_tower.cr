class Scripts::BaseTower < AbstractNpcAI
  # NPCs
  private GUZEN = 22362
  private KENDAL = 32301
  private BODY_DESTROYER = 22363
  # Skills
  private DEATH_WORD = SkillHolder.new(5256)
  # Misc
  private BODY_DESTROYER_TARGET_LIST = {} of Int32 => L2PcInstance

  def initialize
    super(self.class.simple_name, "hellbound/AI/Zones")

    add_kill_id(GUZEN)
    add_kill_id(BODY_DESTROYER)
    add_first_talk_id(KENDAL)
    add_aggro_range_enter_id(BODY_DESTROYER)
  end

  def on_first_talk(npc, pc)
    class_id = pc.class_id
    if class_id.hell_knight? || class_id.soultaker?
      return "32301-02.htm"
    end

    "32301-01.htm"
  end

  def on_adv_event(event, npc, pc)
    if event.casecmp?("CLOSE")
      DoorData.get_door!(20260004).close_me
    end

    super
  end

  def on_aggro_range_enter(npc, pc, is_summon)
    unless BODY_DESTROYER_TARGET_LIST.has_key?(npc.l2id)
      BODY_DESTROYER_TARGET_LIST[npc.l2id] = pc
      npc.target = pc
      npc.do_simultaneous_cast(DEATH_WORD)
    end

    super
  end

  def on_kill(npc, killer, is_summon)
    case npc.id
    when GUZEN
      # Should Kendal be despawned before Guzen's spawn? Or it will be crowd of Kendal's
      add_spawn(KENDAL, npc.spawn.location, false, npc.spawn.respawn_delay, false)
      DoorData.get_door!(20260003).open_me
      DoorData.get_door!(20260004).open_me
      start_quest_timer("CLOSE", 60_000, npc, nil, false)
    when BODY_DESTROYER
      if pl = BODY_DESTROYER_TARGET_LIST[npc.l2id]?
        if pl.online? && pl.alive?
          pl.stop_skill_effects(true, DEATH_WORD.skill_id)
        end
        BODY_DESTROYER_TARGET_LIST.delete(npc.l2id)
      end
    end

    super
  end
end
