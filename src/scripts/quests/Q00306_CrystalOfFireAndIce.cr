class Scripts::Q00306_CrystalOfFireAndIce < Quest
  # NPC
  private KATERINA = 30004
  # Items
  private FLAME_SHARD = 1020
  private ICE_SHARD = 1021
  # Misc
  private MIN_LEVEL = 17
  # Monsters
  private UNDINE_NOBLE = 20115
  private MONSTER_DROPS = {
    20109 => ItemHolder.new(FLAME_SHARD, 925),     # Salamander
    20110 => ItemHolder.new(ICE_SHARD, 900),       # Undine
    20112 => ItemHolder.new(FLAME_SHARD, 900),     # Salamander Elder
    20113 => ItemHolder.new(ICE_SHARD, 925),       # Undine Elder
    20114 => ItemHolder.new(FLAME_SHARD, 925),     # Salamander Noble
    UNDINE_NOBLE => ItemHolder.new(ICE_SHARD, 950) # Undine Noble
  }

  def initialize
    super(306, self.class.simple_name, "Crystals of Fire and Ice")

    add_start_npc(KATERINA)
    add_talk_id(KATERINA)
    add_kill_id(MONSTER_DROPS.keys)
    register_quest_items(FLAME_SHARD, ICE_SHARD)
  end

  def on_adv_event(event, npc, pc)
    return unless pc && (st = get_quest_state(pc, false))

    case event
    when "30004-04.htm"
      if st.created?
        st.start_quest
        html = event
      end
    when "30004-08.html"
      st.exit_quest(true, true)
      html = event
    when "30004-09.html"
      html = event
    end


    html
  end

  def on_kill(npc, killer, is_summon)
    if npc.id == UNDINE_NOBLE # Undine Noble gives quest drops only for the killer
      qs = get_quest_state(killer, false)
      if qs && qs.started?
        give_kill_reward(killer, npc)
      end
    else
      if qs = get_random_party_member_state(killer, -1, 3, npc)
        give_kill_reward(qs.player, npc)
      end
    end

    super
  end

  def on_talk(npc, pc)
    st = get_quest_state!(pc)

    case st.state
    when State::CREATED
      html = pc.level >= MIN_LEVEL ? "30004-03.htm" : "30004-02.htm"
    when State::STARTED
      if has_at_least_one_quest_item?(pc, registered_item_ids)
        flame = st.get_quest_items_count(FLAME_SHARD)
        ice = st.get_quest_items_count(ICE_SHARD)
        st.give_adena(((flame &* 40) &+ (ice &* 40) &+ (flame &+ ice >= 10 ? 5000 : 0)), true)
        take_items(pc, -1, registered_item_ids)
        html = "30004-07.html"
      else
        html = "30004-05.html"
      end
    end

    html || get_no_quest_msg(pc)
  end

  private def give_kill_reward(pc, npc)
    if Util.in_range?(1500, npc, pc, false)
      item = MONSTER_DROPS[npc.id]
      give_item_randomly(pc, npc, item.id, 1, 0, 1000.0 / item.count, true)
    end
  end
end
