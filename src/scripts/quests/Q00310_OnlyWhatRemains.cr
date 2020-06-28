class Scripts::Q00310_OnlyWhatRemains < Quest
  # NPC
  private KINTAIJIN = 32640
  # Items
  private GROW_ACCELERATOR = 14832
  private MULTI_COLORED_JEWEL = 14835
  private DIRTY_BEAD = 14880
  # Monsters
  private MOBS = {
    22617 => 646,
    22618 => 646,
    22619 => 646,
    22620 => 666,
    22621 => 630,
    22622 => 940,
    22623 => 622,
    22624 => 630,
    22625 => 678,
    22626 => 940,
    22627 => 646,
    22628 => 646,
    22629 => 646,
    22630 => 638,
    22631 => 880,
    22632 => 722,
    22633 => 638
  }

  def initialize
    super(310, self.class.simple_name, "Only What Remains")

    add_start_npc(KINTAIJIN)
    add_talk_id(KINTAIJIN)
    add_kill_id(MOBS.keys)
    register_quest_items(DIRTY_BEAD)
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    unless st = get_quest_state(pc, false)
      return
    end

    html = event
    case event
    when "32640-04.htm"
      st.start_quest
    when "32640-quit.html"
      st.exit_quest(true, true)
    when "32640-02.htm", "32640-03.htm", "32640-05.html", "32640-06.html",
         "32640-07.html"
    else
      html = nil
    end

    html
  end

  def on_kill(npc, pc, is_summon)
    unless m = get_random_party_member(pc, 1)
      return super
    end

    st = get_quest_state!(m, false)

    if Rnd.rand(1000) < MOBS[npc.id]
      st.give_items(DIRTY_BEAD, 1)
      st.play_sound(Sound::ITEMSOUND_QUEST_ITEMGET)
    end

    super
  end

  def on_talk(npc, pc)
    st = get_quest_state!(pc)

    case st.state
    when State::CREATED
      if pc.level >= 81 && pc.quest_completed?(Q00240_ImTheOnlyOneYouCanTrust.simple_name)
        html = "32640-01.htm"
      else
        html = "32640-00.htm"
      end
    when State::STARTED
      if !st.has_quest_items?(DIRTY_BEAD)
        html = "32640-08.html"
      elsif st.get_quest_items_count(DIRTY_BEAD) < 500
        html = "32640-09.html"
      else
        st.take_items(DIRTY_BEAD, 500)
        st.give_items(GROW_ACCELERATOR, 1)
        st.give_items(MULTI_COLORED_JEWEL, 1)
        html = "32640-10.html"
      end
    end


    html || get_no_quest_msg(pc)
  end
end
