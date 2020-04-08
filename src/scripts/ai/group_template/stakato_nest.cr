class Scripts::StakatoNest < AbstractNpcAI
  private STAKATO_MOBS = {
    18793, 18794, 18795, 18796, 18797, 18798, 22617, 22618, 22619, 22620,
    22621, 22622, 22623, 22624, 22625, 22626, 22627, 22628, 22629, 22630,
    22631, 22632, 22633, 25667
  }

  private COCOONS = {18793, 18794, 18795, 18796, 18797, 18798}

  private STAKATO_LEADER     = 22625 # Cannibalistic Stakato Leader
  private STAKATO_NURSE      = 22630 # Spike Stakato Nurse
  private STAKATO_NURSE_2    = 22631 # Spike Stakato Nurse (Changed)
  private STAKATO_BABY       = 22632 # Spiked Stakato Baby
  private STAKATO_CAPTAIN    = 22629 # Spiked Stakato Captain
  private STAKATO_FEMALE     = 22620 # Female Spiked Stakato
  private STAKATO_MALE       = 22621 # Male Spiked Stakato
  private STAKATO_MALE_2     = 22622 # Male Spiked Stakato (Changed)
  private STAKATO_GUARD      = 22619 # Spiked Stakato Guard
  private STAKATO_CHIEF      = 25667 # Cannibalistic Stakato Chief
  private GROWTH_ACCELERATOR = 2905  # Growth Accelerator
  private SMALL_COCOON       = 14833 # Small Stakato Cocoon
  private LARGE_COCOON       = 14834 # Large Stakato Cocoon

  private EATING_FOLLOWER_HEAL = SkillHolder.new(4484)

  def initialize
    super(self.class.simple_name, "ai/group_template")
    register_mobs(STAKATO_MOBS)
  end

  def on_attack(npc, attacker, damage, is_summon)
    mob = npc.as(L2MonsterInstance)

    if mob.id == STAKATO_LEADER && Rnd.rand(1000) < 100 && mob.hp_percent < 30
      if follower = check_minion(npc)
        hp = follower.current_hp

        if hp > follower.max_hp * 0.3
          mob.abort_attack
          mob.abort_cast
          mob.heading = Util.calculate_heading_from(mob, follower)
          mob.do_cast(EATING_FOLLOWER_HEAL)
          mob.current_hp += hp
          follower.do_die(follower)
          follower.delete_me
        end
      end
    end

    super
  end

  def on_kill(npc, killer, is_summon)
    case npc.id
    when STAKATO_NURSE
      if monster = check_minion(npc)
        Broadcast.to_self_and_known_players(npc, MagicSkillUse.new(npc, 2046, 1, 1000, 0))
        3.times do |i|
          spawned = add_spawn(STAKATO_CAPTAIN, monster, true)
          add_attack_desire(spawned, killer)
        end
      end
    when STAKATO_BABY
      monster = npc.as(L2MonsterInstance).leader?
      if monster && monster.alive?
        start_quest_timer("nurse_change", 5000, monster, killer)
      end
    when STAKATO_MALE
      if monster = check_minion(npc)
        Broadcast.to_self_and_known_players(npc, MagicSkillUse.new(npc, 2046, 1, 1000, 0))
        3.times do |i|
          spawned = add_spawn(STAKATO_GUARD, monster, true)
          add_attack_desire(spawned, killer)
        end
      end
    when STAKATO_FEMALE
      monster = npc.as(L2MonsterInstance).leader?
      if monster && monster.alive?
        start_quest_timer("male_change", 5000, monster, killer)
      end
    when STAKATO_CHIEF
      if party = killer.party
        party.members.each do |member|
          give_cocoon(member, npc)
        end
      else
        give_cocoon(killer, npc)
      end
    else
      # automatically added
    end


    super
  end

  def on_skill_see(npc, caster, skill, targets, is_summon)
    if COCOONS.includes?(npc.id) && targets.includes?(npc) && skill.id == GROWTH_ACCELERATOR
      npc.do_die(caster)
      spawned = add_spawn(STAKATO_CHIEF, *npc.xyz, Util.calculate_heading_from(npc, caster), false, 0, true)
      add_attack_desire(spawned, caster)
    end

    super
  end

  def on_adv_event(event, npc, pc)
    return unless npc && pc
    return unless npc.alive?

    case event
    when "nurse_change"
      npc_id = STAKATO_NURSE_2
    when "male_change"
      npc_id = STAKATO_MALE_2
    else
      # automatically added
    end


    if npc_id
      npc.spawn.decrease_count(npc)
      npc.delete_me
      spawned = add_spawn(npc_id, *npc.xyz, npc.heading, false, 0, true)
      add_attack_desire(spawned, pc)
    end

    super
  end

  private def check_minion(npc)
    mob = npc.as(L2MonsterInstance)
    if mob.has_minions?
      minions = mob.minion_list.spawned_minions
      if minions && !minions.empty? && minions.first.alive?
        return minions.first
      end
    end

    nil
  end

  private def give_cocoon(pc, npc)
    pc.add_item("StakatoCocoon", Rnd.rand(100) > 80 ? LARGE_COCOON : SMALL_COCOON, 1, npc, true)
  end
end