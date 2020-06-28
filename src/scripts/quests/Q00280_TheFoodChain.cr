class Scripts::Q00280_TheFoodChain < Quest
  # Npc
  private BIXON = 32175
  # Items
  private GREY_KELTIR_TOOTH = 9809
  private BLACK_WOLF_TOOTH = 9810
  # Monsters
  private MONSTER_ITEM = {
    22229 => GREY_KELTIR_TOOTH,
    22230 => GREY_KELTIR_TOOTH,
    22231 => GREY_KELTIR_TOOTH,
    22232 => BLACK_WOLF_TOOTH,
    20317 => BLACK_WOLF_TOOTH, # custom (npcs are identical and they're side to side)
    22233 => BLACK_WOLF_TOOTH
  }
  private MONSTER_CHANCE = {
    22229 => {ItemHolder.new(1000, 1)},
    22230 => {ItemHolder.new(500, 1), ItemHolder.new(1000, 2)},
    22231 => {ItemHolder.new(1000, 2)},
    22232 => {ItemHolder.new(1000, 3)},
    20317 => {ItemHolder.new(1000, 3)}, # custom (npcs are identical and they're side to side)
    22233 => {ItemHolder.new(500, 3), ItemHolder.new(1000, 4)}
  }
  # Rewards
  private REWARDS = {28, 35, 41, 48, 116}
  # Misc
  private MIN_LVL = 3
  private TEETH_COUNT = 25

  def initialize
    super(280, self.class.simple_name, "The Food Chain")

    add_start_npc(BIXON)
    add_talk_id(BIXON)
    add_kill_id(MONSTER_ITEM.keys)
    register_quest_items(GREY_KELTIR_TOOTH, BLACK_WOLF_TOOTH)
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    return unless st = get_quest_state(pc, false)

    case event
    when "32175-03.htm"
      st.start_quest
      html = event
    when "32175-06.html"
      if has_at_least_one_quest_item?(pc, registered_item_ids)
        grey_teeth = st.get_quest_items_count(GREY_KELTIR_TOOTH)
        black_teeth = st.get_quest_items_count(BLACK_WOLF_TOOTH)
        st.give_adena(2i64 * (grey_teeth + black_teeth), true)
        take_items(pc, -1, {GREY_KELTIR_TOOTH, BLACK_WOLF_TOOTH})
        html = event
      else
        html = "32175-07.html"
      end
    when "32175-08.html"
      html = event
    when "32175-09.html"
      st.exit_quest(true, true)
      html = event
    when "32175-11.html"
      grey_teeth = st.get_quest_items_count(GREY_KELTIR_TOOTH)
      black_teeth = st.get_quest_items_count(BLACK_WOLF_TOOTH)
      if grey_teeth + black_teeth >= TEETH_COUNT
        if grey_teeth >= TEETH_COUNT
          st.take_items(GREY_KELTIR_TOOTH, TEETH_COUNT)
        else
          st.take_items(GREY_KELTIR_TOOTH, grey_teeth)
          st.take_items(BLACK_WOLF_TOOTH, TEETH_COUNT - grey_teeth)
        end
        st.reward_items(REWARDS[rand(5)], 1)
        html = event
      else
        html = "32175-10.html"
      end
    end


    html
  end

  def on_kill(npc, killer, is_summon)
    st = get_quest_state(killer, false)

    if st && Util.in_range?(1500, npc, killer, true)
      chance = Rnd.rand(1000)
      MONSTER_CHANCE[npc.id].each do |drop|
        if chance < drop.id
          st.give_item_randomly(MONSTER_ITEM[npc.id], drop.count, 0, 1, true)
        end
      end
    end

    super
  end

  def on_talk(npc, pc)
    st = get_quest_state!(pc)

    case st.state
    when State::CREATED
      html = pc.level >= MIN_LVL ? "32175-01.htm" : "32175-02.htm"
    when State::STARTED
      if has_at_least_one_quest_item?(pc, registered_item_ids)
        html = "32175-05.html"
      else
        html = "32175-04.html"
      end
    end


    html || get_no_quest_msg(pc)
  end
end
