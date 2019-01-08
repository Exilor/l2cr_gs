class Quests::Q00293_TheHiddenVeins < Quest
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

  def on_adv_event(event, npc, player)
    return unless player
    return unless st = get_quest_state(player, false)

    case event
    when "30535-04.htm"
      st.start_quest
      htmltext = event
    when "30535-07.html"
      st.exit_quest(true, true)
      htmltext = event
    when "30535-08.html"
      htmltext = event
    when "30539-03.html"
      if st.get_quest_items_count(TORN_MAP_FRAGMENT) >= REQUIRED_TORN_MAP_FRAGMENT
        st.give_items(HIDDEN_ORE_MAP, 1)
        st.take_items(TORN_MAP_FRAGMENT, REQUIRED_TORN_MAP_FRAGMENT)
        htmltext = event
      else
        htmltext = "30539-02.html"
      end
    end

    htmltext
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

  def on_talk(npc, player)
    st = get_quest_state!(player)
    htmltext = get_no_quest_msg(player)

    case npc.id
    when FILAUR
      case st.state
      when State::CREATED
        htmltext = player.race.dwarf? ? player.level >= MIN_LVL ? "30535-03.htm" : "30535-02.htm" : "30535-01.htm"
      when State::STARTED
        if has_at_least_one_quest_item?(player, CHRYSOLITE_ORE, HIDDEN_ORE_MAP)
          ores = st.get_quest_items_count(CHRYSOLITE_ORE)
          maps = st.get_quest_items_count(HIDDEN_ORE_MAP)
          st.give_adena((ores * 5) + (maps * 500) + (ores + maps >= 10 ? 2000 : 0), true)
          take_items(player, -1, {CHRYSOLITE_ORE, HIDDEN_ORE_MAP})
          Q00281_HeadForTheHills.give_newbie_reward(player)
          htmltext = ores > 0 ? maps > 0 ? "30535-10.html" : "30535-06.html" : "30535-09.html"
        else
          htmltext = "30535-05.html"
        end
      end
    when CHICHIRIN
      htmltext = "30539-01.html"
    end

    htmltext
  end
end
