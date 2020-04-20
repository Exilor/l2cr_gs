class Scripts::Q00036_MakeASewingKit < Quest
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

  def on_adv_event(event, npc, pc)
    return unless pc
    unless st = get_quest_state(pc, false)
      return
    end

    html = event
    case event
    when "30847-03.htm"
      st.start_quest
    when "30847-06.html"
      if st.get_quest_items_count(ENCHANTED_IRON) < IRON_COUNT
        return get_no_quest_msg(pc)
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
        html = "30847-10.html"
      end
    else
      html = nil
    end

    html
  end

  def on_kill(npc, pc, is_summon)
    if member = get_random_party_member(pc, 1)
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

  def on_talk(npc, pc)
    st = get_quest_state!(pc)

    case st.state
    when State::CREATED
      html = pc.level >= MIN_LEVEL ? "30847-01.htm" : "30847-02.html"
    when State::STARTED
      case st.cond
      when 1
        html = "30847-04.html"
      when 2
        html = "30847-05.html"
      when 3
        if st.get_quest_items_count(ARTISANS_FRAME) >= COUNT && st.get_quest_items_count(ORIHARUKON) >= COUNT
          html = "30847-07.html"
        else
          html = "30847-08.html"
        end
      else
        # [automatically added else]
      end

    when State::COMPLETED
      html = get_already_completed_msg(pc)
    else
      # [automatically added else]
    end

    html || get_no_quest_msg(pc)
  end
end
