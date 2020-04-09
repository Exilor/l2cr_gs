class Scripts::Q00266_PleasOfPixies < Quest
  # NPC
  private PIXY_MURIKA = 31852
  # Items
  private PREDATORS_FANG = 1334
  # Monsters
  private MONSTERS = {
    20537 => {ItemHolder.new(10, 2)}, # Elder Red Keltir
    20525 => {ItemHolder.new(5, 2), ItemHolder.new(10, 3)}, # Gray Wolf
    20534 => {ItemHolder.new(6, 1)},  # Red Keltir
    20530 => {ItemHolder.new(8, 1)}   # Young Red Keltir
  }
  # Rewards
  private REWARDS = {
    0 => {ItemHolder.new(1337, 1), ItemHolder.new(3032, 1)}, # Emerald, Recipe: Spiritshot D
    1 => {ItemHolder.new(2176, 1), ItemHolder.new(1338, 1)}, # Recipe: Leather Boots, Blue Onyx
    2 => {ItemHolder.new(1339, 1), ItemHolder.new(1061, 1)}, # Onyx, Greater Healing Potion
    3 => {ItemHolder.new(1336, 1), ItemHolder.new(1060, 1)}  # Glass Shard, Lesser Healing Potion
  }
  # Misc
  private MIN_LVL = 3

  def initialize
    super(266, self.class.simple_name, "Pleas of Pixies")

    add_start_npc(PIXY_MURIKA)
    add_talk_id(PIXY_MURIKA)
    add_kill_id(MONSTERS.keys)
    register_quest_items(PREDATORS_FANG)
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    st = get_quest_state(pc, false)
    if st && "31852-04.htm" == event
      st.start_quest
      event
    end
  end

  def on_kill(npc, killer, is_summon)
    st = get_quest_state(killer, false)
    if st && st.cond?(1)
      chance = Rnd.rand(10)
      MONSTERS[npc.id].each do |mob|
        if chance < mob.id
          if st.give_item_randomly(npc, PREDATORS_FANG, mob.count, 100, 1.0, true)
            st.set_cond(2)
          end
        end
      end
    end

    super
  end

  def on_talk(npc, pc)
    st = get_quest_state!(pc)

    case st.state
    when State::CREATED
      if !pc.race.elf?
        html = "31852-01.htm"
      elsif pc.level < MIN_LVL
        html = "31852-02.htm"
      else
        html = "31852-03.htm"
      end
    when State::STARTED
      case st.cond
      when 1
        html = "31852-05.html"
      when 2
        if st.get_quest_items_count(PREDATORS_FANG) >= 100
          chance = Rnd.rand(100)
          if chance < 2
            reward = 0
            st.play_sound(Sound::ITEMSOUND_QUEST_JACKPOT)
          elsif chance < 20
            reward = 1
          elsif chance < 45
            reward = 2
          else
            reward = 3
          end
          REWARDS[reward].each do |item|
            st.reward_items(item)
          end
          st.exit_quest(true, true)
          html = "31852-06.html"
        end
      else
        # [automatically added else]
      end

    else
      # [automatically added else]
    end


    html || get_no_quest_msg(pc)
  end
end
