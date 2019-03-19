class Quests::Q00369_CollectorOfJewels < Quest
  # NPC
  private NELL = 30376
  # Items
  private FLARE_SHARD = 5882
  private FREEZING_SHARD = 5883
  # Misc
  private MIN_LEVEL = 25
  # Mobs
  private MOBS_DROP_CHANCES = {
    20609 => QuestItemHolder.new(FLARE_SHARD, 75, 1),    # salamander_lakin
    20612 => QuestItemHolder.new(FLARE_SHARD, 91, 1),    # salamander_rowin
    20749 => QuestItemHolder.new(FLARE_SHARD, 100, 2),   # death_fire
    20616 => QuestItemHolder.new(FREEZING_SHARD, 81, 1), # undine_lakin
    20619 => QuestItemHolder.new(FREEZING_SHARD, 87, 1), # undine_rowin
    20747 => QuestItemHolder.new(FREEZING_SHARD, 100, 2) # roxide
  }

  def initialize
    super(369, self.class.simple_name, "Collector of Jewels")

    add_start_npc(NELL)
    add_talk_id(NELL)
    add_kill_id(MOBS_DROP_CHANCES.keys)
    register_quest_items(FLARE_SHARD, FREEZING_SHARD)
  end

  def check_party_member(member, npc)
    st = get_quest_state(member, false)
    !!st && (st.memo_state?(1) || st.memo_state?(3))
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    unless st = get_quest_state(pc, false)
      return
    end

    case event
    when "30376-02.htm"
      st.start_quest
      st.memo_state = 1
      html = event
    when "30376-05.html"
      html = event
    when "30376-06.html"
      if st.memo_state?(2)
        st.memo_state = 3
        st.set_cond(3, true)
        html = event
      end
    when "30376-07.html"
      st.exit_quest(true, true)
      html = event
    end

    html
  end

  def on_kill(npc, pc, is_summon)
    item = MOBS_DROP_CHANCES[npc.id]
    if rand(100) < item.chance
      if winner = get_random_party_member(pc, npc)
        st = get_quest_state!(winner, false)
        item_count = st.memo_state?(1) ? 50 : 200
        cond = st.memo_state?(1) ? 2 : 4
        if give_item_randomly(winner, npc, item.id, item.count, item_count, 1.0, true)
          if get_quest_items_count(winner, FLARE_SHARD, FREEZING_SHARD) >= item_count * 2
            st.set_cond(cond)
          end
        end
      end
    end

    super
  end

  def on_talk(npc, pc)
    st = get_quest_state!(pc)

    if st.created?
      html = pc.level >= MIN_LEVEL ? "30376-01.htm" : "30376-03.html"
    elsif st.started?
      case st.memo_state
      when 1
        if get_quest_items_count(pc, FLARE_SHARD, FREEZING_SHARD) >= 100
          give_adena(pc, 31810, true)
          take_items(pc, -1, {FLARE_SHARD, FREEZING_SHARD})
          st.memo_state = 2
          html = "30376-04.html"
        else
          html = "30376-08.html"
        end
      when 2
        html = "30376-09.html"
      when 3
        if get_quest_items_count(pc, FLARE_SHARD, FREEZING_SHARD) >= 400
          give_adena(pc, 84415, true)
          take_items(pc, -1, {FLARE_SHARD, FREEZING_SHARD})
          st.exit_quest(true, true)
          html = "30376-10.html"
        else
          html = "30376-11.html"
        end
      end
    end

    html || get_no_quest_msg(pc)
  end
end
