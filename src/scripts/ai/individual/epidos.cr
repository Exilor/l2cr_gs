class Scripts::Epidos < AbstractNpcAI
  private EPIDOSES = {
    25609,
    25610,
    25611,
    25612
  }

  private MINIONS = {
    25605,
    25606,
    25607,
    25608
  }

  private MINIONS_COUNT = {
    3,
    6,
    11
  }

  private LAST_HP = Concurrent::Map(Int32, Float64).new

  def initialize
    super(self.class.simple_name, "ai/individual")

    add_kill_id(EPIDOSES)
    add_spawn_id(EPIDOSES)
  end

  def on_adv_event(event, npc, pc)
    npc = npc.not_nil!

    if event.casecmp?("check_minions")
      if Rnd.rand(1000) > 250 && (hp = LAST_HP[npc.l2id]?)
        hp_decrease_percent = (((hp - npc.current_hp) * 100) / npc.max_hp).to_i
        minions_count = 0
        spawned_minions = npc.as(L2MonsterInstance).minion_list.count_spawned_minions

        if hp_decrease_percent > 5 && hp_decrease_percent <= 15 && spawned_minions <= 9
          minions_count = MINIONS_COUNT[0]
        elsif ((hp_decrease_percent > 1 && hp_decrease_percent <= 5) || (hp_decrease_percent > 15 && hp_decrease_percent <= 30)) && spawned_minions <= 6
          minions_count = MINIONS_COUNT[1]
        elsif spawned_minions == 0
          minions_count = MINIONS_COUNT[2]
        end

        minions_count.times do |i|
          MinionList.spawn_minion(npc.as(L2MonsterInstance), MINIONS[EPIDOSES.bsearch(npc.id)])
        end

        LAST_HP[npc.l2id] = npc.current_hp
      end

      start_quest_timer("check_minions", 10000, npc, nil)
    elsif event.casecmp?("check_idle")
      if npc.intention.active?
        npc.delete_me
      else
        start_quest_timer("check_idle", 600000, npc, nil)
      end
    end

    nil
  end

  def on_kill(npc, killer, is_summon)
    if npc.inside_radius?(-45474, 247450, -13994, 2000, true, false)
      add_spawn(32376, -45482, 246277, -14184, 0, false, 0, false)
    end

    LAST_HP.delete(npc.l2id)

    super
  end

  def on_spawn(npc)
    start_quest_timer("check_minions", 10000, npc, nil)
    start_quest_timer("check_idle", 600000, npc, nil)
    LAST_HP[npc.l2id] = npc.max_hp.to_f

    super
  end
end
