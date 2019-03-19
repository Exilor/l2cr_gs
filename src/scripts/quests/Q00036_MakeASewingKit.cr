class Quests::Q00036_MakeASewingKit < Quest
  # NPC
  private FERRIS = 30847
  # Monster
  private ENCHANTED_IRON_GOLEM = 20566
  # Items
  private ARTISANS_FRAME = 1891
  private ORIHARUKON = 1893
  private SEWING_KIT = 7078
  private ENCHANTED_IRON = 7163
  # Misc
  private MIN_LEVEL = 60
  private IRON_COUNT = 5
  private COUNT = 10

  def initialize
    super(36, self.class.simple_name, "Make a Sewing Kit")

    add_start_npc(FERRIS)
    add_talk_id(FERRIS)
    add_kill_id(ENCHANTED_IRON_GOLEM)
    register_quest_items(ENCHANTED_IRON)
  end

  def on_adv_event(event, npc, player)
    return unless player
    unless st = get_quest_state(player, false)
      return
    end

    htmltext = event
    case event
    when "30847-03.htm"
      st.start_quest
    when "30847-06.html"
      if st.get_quest_items_count(ENCHANTED_IRON) < IRON_COUNT
        return get_no_quest_msg(player)
      end
      st.take_items(ENCHANTED_IRON, -1)
      st.set_cond(3, true)
    when "30847-09.html"
      if st.get_quest_items_count(ARTISANS_FRAME) >= COUNT && st.get_quest_items_count(ORIHARUKON) >= COUNT
        st.take_items(ARTISANS_FRAME, 10)
        st.take_items(ORIHARUKON, 10)
        st.give_items(SEWING_KIT, 1)
        st.exit_quest(false, true)
      else
        htmltext = "30847-10.html"
      end
    else
      htmltext = nil
    end

    htmltext
  end

  def on_kill(npc, player, is_summon)
    if member = get_random_party_member(player, 1)
      st = get_quest_state(member, false).not_nil!
      if Rnd.bool
        st.give_items(ENCHANTED_IRON, 1)
        if st.get_quest_items_count(ENCHANTED_IRON) >= IRON_COUNT
          st.set_cond(2, true)
        else
          st.play_sound(Sound::ITEMSOUND_QUEST_ITEMGET)
        end
      end
    end

    super
  end

  def on_talk(npc, player)
    htmltext = get_no_quest_msg(player)
    st = get_quest_state!(player)
    case st.state
    when State::CREATED
      htmltext = player.level >= MIN_LEVEL ? "30847-01.htm" : "30847-02.html"
    when State::STARTED
      case st.cond
      when 1
        htmltext = "30847-04.html"
      when 2
        htmltext = "30847-05.html"
      when 3
        if st.get_quest_items_count(ARTISANS_FRAME) >= COUNT && st.get_quest_items_count(ORIHARUKON) >= COUNT
          htmltext = "30847-07.html"
        else
          htmltext = "30847-08.html"
        end
      end
    when State::COMPLETED
      htmltext = get_already_completed_msg(player)
    end

    htmltext
  end
end
