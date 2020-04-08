class Scripts::Q00276_TotemOfTheHestui < Quest
  # Npc
  private TANAPI = 30571
  # Items
  private KASHA_PARASITE = 1480
  private KASHA_CRYSTAL = 1481
  # Monsters
  private KASHA_BEAR = 20479
  private KASHA_BEAR_TOTEM = 27044
  # Rewards
  private REWARDS = [29, 1500]
  # Misc
  private SPAWN_CHANCES = {
    ItemHolder.new(79, 100),
    ItemHolder.new(69, 20),
    ItemHolder.new(59, 15),
    ItemHolder.new(49, 10),
    ItemHolder.new(39, 2)
  }

  private MIN_LVL = 15

  def initialize
    super(276, self.class.simple_name, "Totem of the Hestui")

    add_start_npc(TANAPI)
    add_talk_id(TANAPI)
    add_kill_id(KASHA_BEAR, KASHA_BEAR_TOTEM)
    register_quest_items(KASHA_PARASITE, KASHA_CRYSTAL)
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    return unless st = get_quest_state(pc, false)

    if event == "30571-03.htm"
      st.start_quest
      event
    end
  end

  def on_kill(npc, killer, is_summon)
    st = get_quest_state(killer, false)
    if st && st.cond?(1) && Util.in_range?(1500, killer, npc, true)
      case npc.id
      when KASHA_BEAR
        chance1 = st.get_quest_items_count(KASHA_PARASITE)
        chance2 = Rnd.rand(100)
        chance3 = true
        SPAWN_CHANCES.each do |ch|
          if chance1 >= ch.id && chance2 <= ch.count
            st.add_spawn(KASHA_BEAR_TOTEM)
            st.take_items(KASHA_PARASITE, -1)
            chance3 = false
          end
        end
        if chance3
          st.give_item_randomly(KASHA_PARASITE, 1, 0, 1, true)
        end
      when KASHA_BEAR_TOTEM
        if st.give_item_randomly(KASHA_CRYSTAL, 1, 1, 1, true)
          st.set_cond(2)
        end
      else
        # automatically added
      end

    end

    super
  end

  def on_talk(npc, pc)
    unless st = get_quest_state!(pc)
      return get_no_quest_msg(pc)
    end

    case st.state
    when State::CREATED
      if pc.race.orc?
        if pc.level >= MIN_LVL
          html = "30571-02.htm"
        else
          html = "30571-01.htm"
        end
      else
        html = "30571-00.htm"
      end
    when State::STARTED
      case st.cond
      when 1
        html = "30571-04.html"
      when 2
        if st.has_quest_items?(KASHA_CRYSTAL)
          Q00261_CollectorsDream.give_newbie_reward(pc)
          REWARDS.each { |reward| st.reward_items(reward, 1) }
          st.exit_quest(true, true)
          html = "30571-05.html"
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