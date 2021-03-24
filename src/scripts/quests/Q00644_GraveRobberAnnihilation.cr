class Scripts::Q00644_GraveRobberAnnihilation < Quest
  # NPC
  private KARUDA = 32017
  # Item
  private ORC_GOODS = 8088
  # Misc
  private MIN_LVL = 20
  private ORC_GOODS_REQUIRED_COUNT = 120
  # Monsters
  private MONSTER_DROP_CHANCES = {
    22003 => 0.714, # Grave Robber Scout
    22004 => 0.841, # Grave Robber Lookout
    22005 => 0.778, # Grave Robber Ranger
    22006 => 0.746, # Grave Robber Guard
    22008 => 0.810  # Grave Robber Fighter
  }
  # Rewards
  private REWARDS = {
    "varnish" => ItemHolder.new(1865, 30), # Varnish
    "animalskin" => ItemHolder.new(1867, 40), # Animal Skin
    "animalbone" => ItemHolder.new(1872, 40), # Animal Bone
    "charcoal" => ItemHolder.new(1871, 30), # Charcoal
    "coal" => ItemHolder.new(1870, 30), # Coal
    "ironore" => ItemHolder.new(1869, 30) # Iron Ore
  }

  def initialize
    super(644, self.class.simple_name, "Grave Robber Annihilation")

    add_start_npc(KARUDA)
    add_talk_id(KARUDA)
    add_kill_id(MONSTER_DROP_CHANCES.keys)
    register_quest_items(ORC_GOODS)
  end

  def on_adv_event(event, npc, pc)
    return unless pc && (st = get_quest_state(pc, false))

    case event
    when "32017-03.htm"
      if st.created?
        st.start_quest
        html = event
      end
    when "32017-06.html"
      if st.cond?(2) && st.get_quest_items_count(ORC_GOODS) >= ORC_GOODS_REQUIRED_COUNT
        html = event
      end
    when "varnish", "animalskin", "animalbone", "charcoal", "coal", "ironore"
      if st.cond?(2)
        reward = REWARDS[event]
        st.reward_items(reward.id, reward.count)
        st.exit_quest(true, true)
        html = "32017-07.html"
      end
    end

    html
  end

  def on_kill(npc, killer, is_summon)
    qs = get_random_party_member_state(killer, 1, 3, npc)
    if qs && qs.give_item_randomly(npc, ORC_GOODS, 1, ORC_GOODS_REQUIRED_COUNT, MONSTER_DROP_CHANCES[npc.id], true)
      qs.set_cond(2, true)
    end

    super
  end

  def on_talk(npc, pc)
    st = get_quest_state!(pc)

    case st.state
    when State::CREATED
      html = pc.level >= MIN_LVL ? "32017-01.htm" : "32017-02.htm"
    when State::STARTED
      if st.cond?(2) && st.get_quest_items_count(ORC_GOODS) >= ORC_GOODS_REQUIRED_COUNT
        html = "32017-04.html"
      else
        html = "32017-05.html"
      end
    end

    html || get_no_quest_msg(pc)
  end
end
