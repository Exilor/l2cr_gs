class Scripts::Q00246_PossessorOfAPreciousSoul3 < Quest
  # NPCs
  private LADD = 30721
  private CARADINE = 31740
  private OSSIAN = 31741
  private PILGRIM_OF_SPLENDOR = 21541
  private JUDGE_OF_SPLENDOR = 21544
  private BARAKIEL = 25325
  private MOBS = {
    21535, # Signet of Splendor
    21536, # Crown of Splendor
    21537, # Fang of Splendor
    21538, # Fang of Splendor
    21539, # Wailing of Splendor
    21540, # Wailing of Splendor
  }
  # Items
  private CARADINE_LETTER = 7678
  private CARADINE_LETTER_LAST = 7679
  private WATERBINDER = 7591
  private EVERGREEN = 7592
  private RAIN_SONG = 7593
  private RELIC_BOX = 7594
  private FRAGMENTS = 21725
  # Rewards
  private CHANCE_FOR_DROP = 30
  private CHANCE_FOR_DROP_FRAGMENTS = 60

  def initialize
    super(246, self.class.simple_name, "Possessor Of A Precious Soul 3")

    add_start_npc(CARADINE)
    add_talk_id(LADD, CARADINE, OSSIAN)
    add_kill_id(PILGRIM_OF_SPLENDOR, JUDGE_OF_SPLENDOR, BARAKIEL)
    add_kill_id(MOBS)
    register_quest_items(
      WATERBINDER, EVERGREEN, FRAGMENTS, RAIN_SONG, RELIC_BOX
    )
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    unless st = get_quest_state(pc, false)
      return get_no_quest_msg(pc)
    end

    unless pc.subclass_active?
      return "no_sub.html"
    end

    case event
    when "31740-4.html"
      if st.created?
        st.take_items(CARADINE_LETTER, -1)
        st.start_quest
      end
    when "31741-2.html"
      if st.started? && st.cond?(1)
        st.set("awaitsWaterbinder", "1")
        st.set("awaitsEvergreen", "1")
        st.set_cond(2, true)
      end
    when "31741-5.html"
      if st.cond?(3) && st.has_quest_items?(WATERBINDER) && st.has_quest_items?(EVERGREEN)
        st.take_items(WATERBINDER, 1)
        st.take_items(EVERGREEN, 1)
        st.set_cond(4, true)
      end
    when "31741-9.html"
      if st.cond?(5) && (st.has_quest_items?(RAIN_SONG) || st.get_quest_items_count(FRAGMENTS) >= 100)
        st.take_items(RAIN_SONG, -1)
        st.take_items(FRAGMENTS, -1)
        st.give_items(RELIC_BOX, 1)
        st.set_cond(6, true)
      else
        return "31741-8.html"
      end
    when "30721-2.html"
      if st.cond?(6) && st.has_quest_items?(RELIC_BOX)
        st.take_items(RELIC_BOX, -1)
        st.give_items(CARADINE_LETTER_LAST, 1)
        st.add_exp_and_sp(719843, 0)
        st.exit_quest(false, true)
      end
    end


    event
  end

  def on_kill(npc, pc, is_summon)
    case npc.id
    when PILGRIM_OF_SPLENDOR
      if m = get_random_party_member(pc, "awaitsWaterbinder", "1")
        st = get_quest_state(m, false).not_nil!
        chance = Rnd.rand(100)
        if st.cond?(2) && !st.has_quest_items?(WATERBINDER)
          if chance < CHANCE_FOR_DROP
            st.give_items(WATERBINDER, 1)
            st.unset("awaitsWaterbinder")
            if st.has_quest_items?(EVERGREEN)
              st.set_cond(3, true)
            else
              st.play_sound(Sound::ITEMSOUND_QUEST_ITEMGET)
            end
          end
        end
      end
    when JUDGE_OF_SPLENDOR
      if m = get_random_party_member(pc, "awaitsEvergreen", "1")
        st = get_quest_state(m, false).not_nil!
        chance = Rnd.rand(100)
        if st.cond?(2) && !st.has_quest_items?(EVERGREEN)
          if chance < CHANCE_FOR_DROP
            st.give_items(EVERGREEN, 1)
            st.unset("awaitsEvergreen")
            if st.has_quest_items?(WATERBINDER)
              st.set_cond(3, true)
            else
              st.play_sound(Sound::ITEMSOUND_QUEST_ITEMGET)
            end
          end
        end
      end
    when BARAKIEL
      if (party = pc.party) && !party.members.empty?
        party.members.each do |member|
          if pst = get_quest_state(member, false)
            if pst.cond?(4) && !pst.has_quest_items?(RAIN_SONG)
              pst.give_items(RAIN_SONG, 1)
              pst.set_cond(5, true)
            end
          end
        end
      else
        if pst = get_quest_state(pc, false)
          if pst.cond?(4) && !pst.has_quest_items?(RAIN_SONG)
            pst.give_items(RAIN_SONG, 1)
            pst.set_cond(5, true)
          end
        end
      end
    else
      unless st = get_quest_state(pc, false)
        return super
      end

      if MOBS.includes?(npc.id) && st.get_quest_items_count(FRAGMENTS) < 100
        if st.cond?(4)
          if Rnd.rand(100) < CHANCE_FOR_DROP_FRAGMENTS
            st.give_items(FRAGMENTS, 1)
            if st.get_quest_items_count(FRAGMENTS) < 100
              st.play_sound(Sound::ITEMSOUND_QUEST_ITEMGET)
            else
              st.set_cond(5, true)
            end
          end
        end
      end
    end

    super
  end

  def on_talk(npc, pc)
    st = get_quest_state!(pc)
    if st.started? && !pc.subclass_active?
      return "no_sub.html"
    end

    case npc.id
    when CARADINE
      case st.state
      when State::CREATED
        if pc.level >= 65 && pc.quest_completed?(Q00242_PossessorOfAPreciousSoul2.simple_name)
          html = "31740-1.htm"
        else
          html = "31740-2.html"
        end
      when State::STARTED
        html = "31740-5.html"
      end
    when OSSIAN
      case st.state
      when State::STARTED
        case st.cond
        when 1
          html = "31741-1.html"
        when 2
          html = "31741-4.html"
        when 3
          if st.has_quest_items?(WATERBINDER) && st.has_quest_items?(EVERGREEN)
            html = "31741-3.html"
          end
        when 4
          html = "31741-8.html"
        when 5
          if st.has_quest_items?(RAIN_SONG) || st.get_quest_items_count(FRAGMENTS) >= 100
            html = "31741-7.html"
          else
            html = "31741-8.html"
          end
        when 6
          if st.get_quest_items_count(RELIC_BOX) == 1
            html = "31741-11.html"
          end
        end
      end
    when LADD
      case st.state
      when State::STARTED
        if st.cond?(6)
          html = "30721-1.html"
        end
      when State::COMPLETED
        html = get_already_completed_msg(pc)
      end
    end

    html || get_no_quest_msg(pc)
  end
end
