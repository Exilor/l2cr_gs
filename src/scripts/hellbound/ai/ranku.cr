class Scripts::Ranku < AbstractNpcAI
  # NPCs
  private RANKU = 25542
  private MINION = 32305
  private MINION_2 = 25543
  # Misc
  private TRACKING_SET = Set(Int32).new

  def initialize
    super(self.class.simple_name, "hellbound/AI")

    add_attack_id(RANKU)
    add_kill_id(RANKU, MINION)
  end

  def on_adv_event(event, npc, player)
    if npc && npc.id == RANKU && npc.alive? && event.casecmp?("checkup")
      npc.as(L2MonsterInstance).minion_list.spawned_minions.each do |minion|
        if minion && minion.alive? && TRACKING_SET.includes?(minion.l2id)
          players = minion.known_list.known_players.values
          if players.empty?
            warn "#{minion}'s known list contains no players."
            next
          end
          killer = players.sample
          minion.reduce_current_hp(minion.max_hp.fdiv(100), killer, nil)
        end
      end
      start_quest_timer("checkup", 1000, npc, nil)
    end

    super
  end

  def on_attack(npc, attacker, damage, is_summon, skill)
    if npc.id == RANKU
      npc.as(L2MonsterInstance).minion_list.spawned_minions.each do |minion|
        if minion && minion.alive? && !TRACKING_SET.includes?(minion.l2id)
          broadcast_npc_say(minion, Say2::NPC_ALL, NpcString::DONT_KILL_ME_PLEASE_SOMETHINGS_STRANGLING_ME)
          start_quest_timer("checkup", 1000, npc, nil)
          TRACKING_SET << minion.l2id
        end
      end
    end

    super
  end

  def on_kill(npc, killer, is_summon)
    if npc.id == MINION
      TRACKING_SET.delete(npc.l2id)

      master = npc.as(L2MonsterInstance).leader?
      if master && master.alive?
        minion2 = MinionList.spawn_minion(master, MINION_2).not_nil!
        minion2.tele_to_location(npc.location)
      end
    elsif npc.id == RANKU
      npc.as(L2MonsterInstance).minion_list.spawned_minions.each do |minion|
        TRACKING_SET.delete(minion.l2id)
      end
    end

    super
  end
end
