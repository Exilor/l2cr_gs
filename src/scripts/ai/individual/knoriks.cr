class Scripts::Knoriks < AbstractNpcAI
  # NPC
  private KNORIKS = 22857
  # Skills
  private DARK_WIND = SkillHolder.new(6743) # Dark Wind
  private DARK_STORM = SkillHolder.new(6744) # Dark Storm
  private DARK_BLADE = SkillHolder.new(6747) # Dark Blade
  # Misc
  private SHOUT_FLAG = "SHOUT_FLAG"
  private MAX_CHASE_DIST = 3000

  def initialize
    super(self.class.simple_name, "ai/individual")

    @spawn_count = 0

    add_aggro_range_enter_id(KNORIKS)
    add_skill_see_id(KNORIKS)
    add_teleport_id(KNORIKS)
    add_attack_id(KNORIKS)
    add_spawn_id(KNORIKS)
    start_quest_timer("KNORIKS_SPAWN", 1_800_000, nil, nil)
  end

  def on_adv_event(event, npc, pc)
    case event
    when "CORE_AI"
      if npc
        npc.as(L2Attackable).clear_aggro_list
        npc.disable_core_ai(false)
      end
    when "CHECK_ROUTE"
      WalkingManager.on_spawn(npc.not_nil!)
    when "KNORIKS_SPAWN"
      if @spawn_count < 3
        @spawn_count += 1
        add_spawn(KNORIKS, 140641, 114525, -3755, 0, false, 0)
        add_spawn(KNORIKS, 143789, 110205, -3968, 0, false, 0)
        add_spawn(KNORIKS, 146466, 109789, -3440, 0, false, 0)
        add_spawn(KNORIKS, 145482, 120250, -3944, 0, false, 0)
        start_quest_timer("KNORIKS_SPAWN", 60_000, nil, nil)
      end
    else
      # nothing
    end

    super
  end

  def on_attack(npc, attacker, damage, is_summon)
    most_hated = npc.as(L2Attackable).most_hated
    if most_hated && npc.inside_radius?(attacker, 250, false, false)
      if Rnd.rand(100) < 10 && !npc.casting_now?
        npc.do_cast(Rnd.bool ? DARK_STORM : DARK_BLADE)
      end

      npc.known_list.each_character(200) do |obj|
        if obj.monster?
          if Rnd.rand(100) < 10 && obj.in_combat? && !obj.casting_now?
            obj.do_cast(Rnd.bool ? DARK_STORM : DARK_BLADE)
          end
        end
      end
    end

    if npc.calculate_distance(npc.spawn.location, false, false) > MAX_CHASE_DIST || (npc.z - npc.spawn.z).abs > 450
      npc.disable_core_ai(true)
      npc.tele_to_location(npc.spawn.location)
    end

    super
  end

  def on_skill_see(npc, pc, skill, targets, is_summon)
    if Rnd.rand(100) < 10 && !npc.casting_now? && !npc.inside_radius?(pc, 250, false, false)
      add_skill_cast_desire(npc, pc, DARK_WIND, 1_000_000)
    end

    super
  end

  def on_spawn(npc)
    sp = npc.spawn
    sp.amount = 1
    sp.respawn_delay = 1800
    sp.start_respawn

    super
  end

  def on_aggro_range_enter(npc, pc, is_summon)
    if Rnd.rand(100) < 50 && !npc.variables.get_bool(SHOUT_FLAG, false)
      npc.variables[SHOUT_FLAG] = true
      broadcast_npc_say(npc, Say2::NPC_SHOUT, NpcString::WHOS_THERE_IF_YOU_DISTURB_THE_TEMPER_OF_THE_GREAT_LAND_DRAGON_ANTHARAS_I_WILL_NEVER_FORGIVE_YOU)
    end

    super
  end

  private def on_teleport(npc)
    WalkingManager.cancel_moving(npc)
    start_quest_timer("CORE_AI", 100, npc, nil)
    notify_event("CHECK_ROUTE", npc, nil)
  end
end
