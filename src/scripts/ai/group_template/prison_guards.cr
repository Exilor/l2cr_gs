class Scripts::PrisonGuards < AbstractNpcAI
  # NPCs
  private GUARD_HEAD = 18367 # Prison Guard
  private GUARD = 18368 # Prison Guard
  # Item
  private STAMP = 10013 # Race Stamp
  # Skills
  private TIMER = 5239 # Event Timer
  private STONE = SkillHolder.new(4578) # Petrification
  private SILENCE = SkillHolder.new(4098, 9) # Silence

  def initialize
    super(self.class.simple_name, "ai/group_template")

    add_attack_id(GUARD_HEAD, GUARD)
    add_spawn_id(GUARD_HEAD, GUARD)
    add_npc_hate_id(GUARD)
    add_skill_see_id(GUARD)
    add_spell_finished_id(GUARD_HEAD, GUARD)
  end

  def on_adv_event(event, npc, player)
    if event == "CLEAR_STATUS"
      npc.not_nil!.script_value = 0
    elsif event == "CHECK_HOME"
      npc = npc.not_nil!
      if npc.calculate_distance(npc.spawn.location, false, false) > 10
        if !npc.in_combat? && npc.alive?
          npc.tele_to_location(npc.spawn.location)
        end
      end
      start_quest_timer("CHECK_HOME", 30000, npc, nil)
    end

    super
  end

  def on_attack(npc, pc, damage, is_summon)
    if npc.id == GUARD_HEAD
      if pc.affected_by_skill?(TIMER)
        if Rnd.rand(100) < 10 && npc.calculate_distance(pc, true, false) < 100
          if get_quest_items_count(pc, STAMP) <= 3 && npc.script_value?(0)
            give_items(pc, STAMP, 1)
            npc.script_value = 1
            start_quest_timer("CLEAR_STATUS", 600000, npc, nil)
          end
        end
      else
        npc.target = pc
        npc.do_cast(STONE)
        broadcast_npc_say(npc, Say2::ALL, NpcString::ITS_NOT_EASY_TO_OBTAIN)
      end
    else
      unless pc.affected_by_skill?(TIMER)
        if npc.calculate_distance(npc.spawn.location, false, false) < 2000
          npc.target = pc
          npc.do_cast(STONE)
          broadcast_npc_say(npc, Say2::ALL, NpcString::YOURE_OUT_OF_YOUR_MIND_COMING_HERE)
        end
      end
    end

    super
  end

  def on_skill_see(npc, caster, skill, targets, is_summon)
    unless caster.affected_by_skill?(TIMER)
      npc.target = caster
      npc.do_cast(SILENCE)
    end

    super
  end

  def on_spell_finished(npc, player, skill)
    if skill == SILENCE.skill || skill == STONE.skill
      npc.as(L2Attackable).clear_aggro_list
      npc.target = npc
    end

    super
  end

  def on_npc_hate(mob, player, is_summon)
    player.affected_by_skill?(TIMER)
  end

  def on_spawn(npc)
    if npc.id == GUARD_HEAD
      npc.immobilized = true
      npc.invul = true
    else
      npc.no_random_walk = true
      cancel_quest_timer("CHECK_HOME", npc, nil)
      start_quest_timer("CHECK_HOME", 30000, npc, nil)
    end

    super
  end
end
