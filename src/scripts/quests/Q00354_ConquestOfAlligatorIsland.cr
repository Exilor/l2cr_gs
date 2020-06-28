class Scripts::Q00354_ConquestOfAlligatorIsland < Quest
  # NPC
  private KLUCK = 30895
  # Items
  private ALLIGATOR_TOOTH = 5863
  private MYSTERIOUS_MAP_PIECE = 5864
  private PIRATES_TREASURE_MAP = 5915
  # Misc
  private MIN_LEVEL = 38
  # Mobs
  private MOB1 = {
    20804 => 0.84, # crokian_lad
    20805 => 0.91, # dailaon_lad
    20806 => 0.88, # crokian_lad_warrior
    20807 => 0.92  # farhite_lad
  }
  private MOB2 = {
    22208 => 14, # nos_lad
    20991 => 69  # tribe_of_swamp
  }

  def initialize
    super(354, self.class.simple_name, "Conquest of Alligator Island")

    add_start_npc(KLUCK)
    add_talk_id(KLUCK)
    add_kill_id(MOB1.keys)
    add_kill_id(MOB2.keys)
    register_quest_items(ALLIGATOR_TOOTH, MYSTERIOUS_MAP_PIECE)
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    unless st = get_quest_state(pc, false)
      return
    end

    case event
    when "30895-04.html", "30895-05.html", "30895-09.html"
      html = event
    when "30895-02.html"
      st.start_quest
      html = event
    when "ADENA"
      count = st.get_quest_items_count(ALLIGATOR_TOOTH)
      if count >= 100
        st.give_adena((count * 220) + 10700, true)
        st.take_items(ALLIGATOR_TOOTH, -1)
        html = "30895-06.html"
      elsif count > 0
        st.give_adena((count * 220) + 3100, true)
        st.take_items(ALLIGATOR_TOOTH, -1)
        html = "30895-07.html"
      else
        html = "30895-08.html"
      end
    when "30895-10.html"
      st.exit_quest(true, true)
      html = event
    when "REWARD"
      count = st.get_quest_items_count(MYSTERIOUS_MAP_PIECE)
      if count >= 10
        st.give_items(PIRATES_TREASURE_MAP, 1)
        st.take_items(MYSTERIOUS_MAP_PIECE, 10)
        html = "30895-13.html"
      elsif count > 0
        html = "30895-12.html"
      end
    end


    html
  end

  def on_kill(npc, pc, is_summon)
    if st = get_random_party_member_state(pc, -1, 3, npc)
      npc_id = npc.id
      if MOB1.has_key?(npc_id)
        st.give_item_randomly(npc, ALLIGATOR_TOOTH, 1, 0, MOB1[npc_id], true)
      else
        item_count = Rnd.rand(100) < MOB2[npc_id] ? 2 : 1
        st.give_item_randomly(npc, ALLIGATOR_TOOTH, item_count, 0, 1.0, true)
      end

      st.give_item_randomly(npc, MYSTERIOUS_MAP_PIECE, 1, 0, 0.1, false)
    end

    super
  end

  def on_talk(npc, pc)
    st = get_quest_state!(pc)

    if st.created?
      html = pc.level >= MIN_LEVEL ? "30895-01.htm" : "30895-03.html"
    elsif st.started?
      if st.has_quest_items?(MYSTERIOUS_MAP_PIECE)
        html = "30895-11.html"
      else
        html = "30895-04.html"
      end
    end

    html || get_no_quest_msg(pc)
  end
end
