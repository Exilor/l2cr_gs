class Scripts::Q00264_KeenClaws < Quest
  # Npc
  private PAYNE = 30136
  # Item
  private WOLF_CLAW = 1367
  # Monsters
  private MONSTER_CHANCES = {
    20003 => {ItemHolder.new(2, 25), ItemHolder.new(8, 50)},
    20456 => {ItemHolder.new(1, 80), ItemHolder.new(2, 100)}
  }
  # Rewards
  private REWARDS = {
    1 => {ItemHolder.new(4633, 1)},
    2 => {ItemHolder.new(57, 2000)},
    5 => {ItemHolder.new(5140, 1)},
    8 => {ItemHolder.new(735, 1), ItemHolder.new(57, 50)},
    11 => {ItemHolder.new(737, 1)},
    14 => {ItemHolder.new(734, 1)},
    17 => {ItemHolder.new(35, 1), ItemHolder.new(57, 50)}
  }
  # Misc
  private MIN_LVL = 3
  private WOLF_CLAW_COUNT = 50

  def initialize
    super(264, self.class.simple_name, "Keen Claws")

    add_start_npc(PAYNE)
    add_talk_id(PAYNE)
    add_kill_id(MONSTER_CHANCES.keys)
    register_quest_items(WOLF_CLAW)
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    st = get_quest_state(pc, false)
    if st && event == "30136-03.htm"
      st.start_quest
      return event
    end

    nil
  end

  def on_kill(npc, killer, is_summon)
    st = get_quest_state(killer, false)
    if st && st.cond?(1)
      random = Rnd.rand(100)
      MONSTER_CHANCES[npc.id].each do |drop|
        if random < drop.count
          if st.give_item_randomly(WOLF_CLAW, drop.id, WOLF_CLAW_COUNT, 1, true)
            st.set_cond(2)
          end
          break
        end
      end
    end

    super
  end

  def on_talk(npc, pc)
    st = get_quest_state!(pc)

    case st.state
    when State::CREATED
      html = pc.level >= MIN_LVL ? "30136-02.htm" : "30136-01.htm"
    when State::STARTED
      case st.cond
      when 1
        html = "30136-04.html"
      when 2
        if st.get_quest_items_count(WOLF_CLAW) >= WOLF_CLAW_COUNT
          chance = Rnd.rand(17)
          REWARDS.each do |key, value|
            if chance < key
              value.each do |item|
                st.reward_items(item)
              end
              if chance == 0
                st.play_sound(Sound::ITEMSOUND_QUEST_JACKPOT)
              end
              break
            end
          end
          st.exit_quest(true, true)
          html = "30136-05.html"
        end
      end

    end


    html || get_no_quest_msg(pc)
  end
end
