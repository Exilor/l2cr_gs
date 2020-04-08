class Scripts::Q00299_GatherIngredientsForPie < Quest
  # NPCs
  private LARS = 30063
  private BRIGHT = 30466
  private EMILLY = 30620
  # Monsters
  private MONSTERS_CHANCES = {
    20934 => 700, # Wasp Worker
    20935 => 770  # Wasp Leader
  }
  # Items
  private FRUIT_BASKET = 7136
  private AVELLAN_SPICE = 7137
  private HONEY_POUCH = 7138
  # Rewards
  private REWARDS = {
    QuestItemHolder.new(57, 400, 2500), # Adena
    QuestItemHolder.new(1865, 550, 50), # Varnish
    QuestItemHolder.new(1870, 700, 50), # Coal
    QuestItemHolder.new(1869, 850, 50), # Iron Ore
    QuestItemHolder.new(1871, 1000, 50) # Charcoal
  }
  # Misc
  private MIN_LVL = 34

  def initialize
    super(299, self.class.simple_name, "Gather Ingredients for Pie")

    add_start_npc(EMILLY)
    add_talk_id(LARS, BRIGHT, EMILLY)
    add_kill_id(MONSTERS_CHANCES.keys)
    register_quest_items(FRUIT_BASKET, HONEY_POUCH, AVELLAN_SPICE)
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    unless qs = get_quest_state(pc, false)
      return
    end

    case event
    when "30063-02.html"
      if qs.cond?(3)
        give_items(pc, AVELLAN_SPICE, 1)
        qs.set_cond(4, true)
        html = event
      end
    when "30466-02.html"
      if qs.cond?(5)
        give_items(pc, FRUIT_BASKET, 1)
        qs.set_cond(6, true)
        html = event
      end
    when "30620-03.htm"
      if qs.created?
        qs.start_quest
        html = event
      end
    when "30620-06.html"
      if qs.cond?(2) && get_quest_items_count(pc, HONEY_POUCH) >= 100
        take_items(pc, HONEY_POUCH, -1)
        qs.set_cond(3, true)
        html = event
      else
        html = "30620-07.html"
      end
    when "30620-10.html"
      if qs.cond?(4) && has_quest_items?(pc, AVELLAN_SPICE)
        take_items(pc, AVELLAN_SPICE, -1)
        qs.set_cond(5, true)
        html = event
      else
        html = "30620-11.html"
      end
    when "30620-14.html"
      if qs.cond?(6) && has_quest_items?(pc, FRUIT_BASKET)
        take_items(pc, FRUIT_BASKET, -1)
        chance = Rnd.rand(1000)
        REWARDS.each do |holder|
          if holder.chance > chance
            reward_items(pc, holder)
            break
          end
        end
        qs.exit_quest(true, true)
        html = event
      else
        html = "30620-15.html"
      end
    else
      # automatically added
    end


    html
  end

  def on_kill(npc, killer, is_summon)
    if qs = get_random_party_member_state(killer, 1, 3, npc)
      if Rnd.rand(1000) < MONSTERS_CHANCES[npc.id]
        if get_quest_items_count(killer, HONEY_POUCH) < 100
          if give_item_randomly(killer, npc, HONEY_POUCH, 1, 2, 100, 1, true)
            qs.set_cond(2)
          end
        end
      end
    end

    super
  end

  def on_talk(npc, pc)
    qs = get_quest_state!(pc)

    case npc.id
    when LARS
      case qs.cond
      when 3
        html = "30063-01.html"
      when 4
        html = "30063-03.html"
      else
        # automatically added
      end

    when BRIGHT
      case qs.cond
      when 5
        html = "30466-01.html"
      when 6
        html = "30466-03.html"
      else
        # automatically added
      end

    when EMILLY
      case qs.state
      when State::CREATED
        html = pc.level >= MIN_LVL ? "30620-01.htm" : "30620-02.htm"
      when State::STARTED
        case qs.cond
        when 1
          html = "30620-05.html"
        when 2
          if get_quest_items_count(pc, HONEY_POUCH) >= 100
            html = "30620-04.html"
          end
        when 3
          html = "30620-08.html"
        when 4
          if has_quest_items?(pc, AVELLAN_SPICE)
            html = "30620-09.html"
          end
        when 5
          html = "30620-12.html"
        when 6
          if has_quest_items?(pc, FRUIT_BASKET)
            html = "30620-13.html"
          end
        else
          # automatically added
        end

      else
        # automatically added
      end

    else
      # automatically added
    end


    html || get_no_quest_msg(pc)
  end
end