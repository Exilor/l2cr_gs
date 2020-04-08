class Scripts::Q00293_TheHiddenVeins < Quest
  # NPCs
  private FILAUR = 30535
  private CHICHIRIN = 30539
  # Items
  private CHRYSOLITE_ORE = 1488
  private TORN_MAP_FRAGMENT = 1489
  private HIDDEN_ORE_MAP = 1490
  # Monsters
  private MONSTERS = {20446, 20447, 20448}
  # Misc
  private MIN_LVL = 6
  private REQUIRED_TORN_MAP_FRAGMENT = 4

  def initialize
    super(293, self.class.simple_name, "The Hidden Veins")

    add_start_npc(FILAUR)
    add_talk_id(FILAUR, CHICHIRIN)
    add_kill_id(MONSTERS)
    register_quest_items(CHRYSOLITE_ORE, TORN_MAP_FRAGMENT, HIDDEN_ORE_MAP)
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    return unless st = get_quest_state(pc, false)

    case event
    when "30535-04.htm"
      st.start_quest
      html = event
    when "30535-07.html"
      st.exit_quest(true, true)
      html = event
    when "30535-08.html"
      html = event
    when "30539-03.html"
      if st.get_quest_items_count(TORN_MAP_FRAGMENT) >= REQUIRED_TORN_MAP_FRAGMENT
        st.give_items(HIDDEN_ORE_MAP, 1)
        st.take_items(TORN_MAP_FRAGMENT, REQUIRED_TORN_MAP_FRAGMENT)
        html = event
      else
        html = "30539-02.html"
      end
    else
      # automatically added
    end


    html
  end

  def on_kill(npc, killer, is_summon)
    if st = get_quest_state(killer, false)
      chance = Rnd.rand(100)
      if chance > 50
        st.give_items(CHRYSOLITE_ORE, 1)
        st.play_sound(Sound::ITEMSOUND_QUEST_ITEMGET)
      elsif chance < 5
        st.give_items(TORN_MAP_FRAGMENT, 1)
        st.play_sound(Sound::ITEMSOUND_QUEST_ITEMGET)
      end
    end

    super
  end

  def on_talk(npc, pc)
    st = get_quest_state!(pc)

    case npc.id
    when FILAUR
      case st.state
      when State::CREATED
        if pc.race.dwarf?
          if pc.level >= MIN_LVL
            html = "30535-03.htm"
          else
            html = "30535-02.htm"
          end
        else
          html = "30535-01.htm"
        end
      when State::STARTED
        if has_at_least_one_quest_item?(pc, CHRYSOLITE_ORE, HIDDEN_ORE_MAP)
          ores = st.get_quest_items_count(CHRYSOLITE_ORE)
          maps = st.get_quest_items_count(HIDDEN_ORE_MAP)
          adena = (ores * 5) + (maps * 500)
          if ores + maps >= 10
            adena += 2000
          end
          st.give_adena(adena, true)
          take_items(pc, -1, {CHRYSOLITE_ORE, HIDDEN_ORE_MAP})
          Q00281_HeadForTheHills.give_newbie_reward(pc)
          html = ores > 0 ? maps > 0 ? "30535-10.html" : "30535-06.html" : "30535-09.html"
        else
          html = "30535-05.html"
        end
      else
        # automatically added
      end

    when CHICHIRIN
      html = "30539-01.html"
    else
      # automatically added
    end


    html || get_no_quest_msg(pc)
  end
end