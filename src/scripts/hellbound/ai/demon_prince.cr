class Scripts::DemonPrince < AbstractNpcAI
  # NPCs
  private DEMON_PRINCE = 25540
  private FIEND = 25541
  # Skills
  private UD = SkillHolder.new(5044, 2)
  private AOE = {
    SkillHolder.new(5376, 4),
    SkillHolder.new(5376, 5),
    SkillHolder.new(5376, 6)
  }

  private ATTACK_STATE = {} of Int32 => Bool

  def initialize
    super(self.class.simple_name, "hellbound/AI")

    add_attack_id(DEMON_PRINCE)
    add_kill_id(DEMON_PRINCE)
    add_spawn_id(FIEND)
  end

  def on_adv_event(event, npc, player)
    if event.casecmp?("cast") && npc && npc.id == FIEND && npc.alive?
      npc.do_cast(AOE.sample(random: Rnd))
    end

    super
  end

  def on_attack(npc, attacker, damage, is_summon, skill)
    if npc.alive?
      if !ATTACK_STATE.has_key?(npc.l2id) && npc.hp_percent < 50
        npc.do_cast(UD)
        spawn_minions(npc)
        ATTACK_STATE[npc.l2id] = false
      elsif npc.hp_percent < 10 && ATTACK_STATE.has_key?(npc.l2id)
        unless ATTACK_STATE[npc.l2id]
          npc.do_cast(UD)
          spawn_minions(npc)
          ATTACK_STATE[npc.l2id] = true
        end
      end

      if Rnd.rand(1000) < 10
        spawn_minions(npc)
      end
    end

    super
  end

  def on_kill(npc, killer, is_summon)
    ATTACK_STATE.delete(npc.l2id)
    super
  end

  def on_spawn(npc)
    if npc.id == FIEND
      start_quest_timer("cast", 15_000, npc, nil)
    end

    super
  end

  private def spawn_minions(master)
    if master && master.alive?
      instance_id = master.instance_id
      x, y, z = master.xyz
      add_spawn(FIEND, x + 200,       y, z, 0, false, 0, false, instance_id)
      add_spawn(FIEND, x - 200,       y, z, 0, false, 0, false, instance_id)
      add_spawn(FIEND, x - 100, y - 140, z, 0, false, 0, false, instance_id)
      add_spawn(FIEND, x - 100, y + 140, z, 0, false, 0, false, instance_id)
      add_spawn(FIEND, x + 100, y - 140, z, 0, false, 0, false, instance_id)
      add_spawn(FIEND, x + 100, y + 140, z, 0, false, 0, false, instance_id)
    end
  end
end
