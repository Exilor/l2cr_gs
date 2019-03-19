class Quests::Q00380_BringOutTheFlavorOfIngredients < Quest
  # NPC
  private ROLLAND = 30069
  # Items
  private ANTIDOTE = 1831
  private RITRON_FRUIT = 5895
  private MOON_FLOWER = 5896
  private LEECH_FLUIDS = 5897
  # Monsters
  private MONSTER_CHANCES = {
    20205 => ItemChanceHolder.new(RITRON_FRUIT, 0.1, 4), # Dire Wolf
    20206 => ItemChanceHolder.new(MOON_FLOWER, 0.5, 20), # Kadif Werewolf
    20225 => ItemChanceHolder.new(LEECH_FLUIDS, 0.5, 10) # Giant Mist Leech
  }
  # Rewards
  private RITRON_RECIPE = 5959
  private RITRON_DESSERT = 5960
  # Misc
  private MIN_LVL = 24

  def initialize
    super(380, self.class.simple_name, "Bring Out the Flavor of Ingredients!")

    add_start_npc(ROLLAND)
    add_talk_id(ROLLAND)
    add_kill_id(MONSTER_CHANCES.keys)
    register_quest_items(RITRON_FRUIT, MOON_FLOWER, LEECH_FLUIDS)
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    if qs = get_quest_state(pc, false)
      case event
      when "30069-03.htm", "30069-04.htm", "30069-06.html"
        html = event
      when "30069-05.htm"
        if qs.created?
          qs.start_quest
          html = event
        end
      when "30069-13.html"
        if qs.cond?(9)
          reward_items(pc, RITRON_RECIPE, 1)
          qs.exit_quest(true, true)
          html = event
        end
      end
    end

    html
  end

  def on_talk(npc, pc)
    qs = get_quest_state!(pc)

    case qs.state
    when State::CREATED
      html = pc.level >= MIN_LVL ? "30069-02.htm" : "30069-01.htm"
    when State::STARTED
      case qs.cond
      when 1..4
        if get_quest_items_count(pc, ANTIDOTE) >= 2 && get_quest_items_count(pc, RITRON_FRUIT) >= 4 && get_quest_items_count(pc, MOON_FLOWER) >= 20 && get_quest_items_count(pc, LEECH_FLUIDS) >= 10
          take_items(pc, ANTIDOTE, 2)
          take_items(pc, -1, {RITRON_FRUIT, MOON_FLOWER, LEECH_FLUIDS})
          qs.set_cond(5, true)
          html = "30069-08.html"
        else
          html = "30069-07.html"
        end
      when 5
        qs.set_cond(6, true)
        html = "30069-09.html"
      when 6
        qs.set_cond(7, true)
        html = "30069-10.html"
      when 7
        qs.set_cond(8, true)
        html = "30069-11.html"
      when 8
        reward_items(pc, RITRON_DESSERT, 1)
        if rand(100) < 56
          html = "30069-15.html"
          qs.exit_quest(true, true)
        else
          qs.set_cond(9, true)
          html = "30069-12.html"
        end
      when 9
        html = "30069-12.html"
      end
    when State::COMPLETED
      html = get_already_completed_msg(pc)
    end

    html || get_no_quest_msg(pc)
  end

  def on_kill(npc, killer, is_summon)
    qs = get_random_party_member_state(killer, -1, 3, npc)
    if qs && qs.cond < 4
      item = MONSTER_CHANCES[npc.id]
      if give_item_randomly(qs.player, npc, item.id, 1, item.count, item.chance, true)
        qs.set_cond(qs.cond + 1, true)
      end
    end

    super
  end
end
