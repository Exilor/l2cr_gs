class Scripts::Q00238_SuccessFailureOfBusiness < Quest
  # NPCs
  private HELVETICA = 32641
  # Mobs
  private BRAZIER_OF_PURITY = 18806
  private EVIL_SPIRITS = 22658
  private GUARDIAN_SPIRITS = 22659
  # Items
  private VICINITY_OF_FOS = 14865
  private BROKEN_PIECE_OF_MAGIC_FORCE = 14867
  private GUARDIAN_SPIRIT_FRAGMENT = 14868
  # Misc
  private BROKEN_PIECE_OF_MAGIC_FORCE_NEEDED = 10
  private GUARDIAN_SPIRIT_FRAGMENT_NEEDED = 20
  private CHANCE_FOR_FRAGMENT = 80
  private MIN_LEVEL = 82

  def initialize
    super(238, self.class.simple_name, "Success/Failure Of Business")

    add_start_npc(HELVETICA)
    add_talk_id(HELVETICA)
    add_kill_id(BRAZIER_OF_PURITY, EVIL_SPIRITS, GUARDIAN_SPIRITS)
    register_quest_items(BROKEN_PIECE_OF_MAGIC_FORCE, GUARDIAN_SPIRIT_FRAGMENT)
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    unless st = get_quest_state(pc, false)
      return
    end

    case event
    when "32461-02.htm"
      html = event
    when "32461-03.html"
      st.start_quest
      html = event
    when "32461-06.html"
      if st.cond?(2)
        st.set_cond(3, true)
        html = event
      end
    end


    html
  end

  def on_kill(npc, killer, is_summon)
    if npc.id == BRAZIER_OF_PURITY
      m = get_random_party_member(killer, 1)
      if m = get_random_party_member(killer, 1)
        st = get_quest_state(m, false).not_nil!
        if st.get_quest_items_count(BROKEN_PIECE_OF_MAGIC_FORCE) < BROKEN_PIECE_OF_MAGIC_FORCE_NEEDED
          st.give_items(BROKEN_PIECE_OF_MAGIC_FORCE, 1)
        end
        if st.get_quest_items_count(BROKEN_PIECE_OF_MAGIC_FORCE) == BROKEN_PIECE_OF_MAGIC_FORCE_NEEDED
          st.set_cond(2, true)
        else
          st.play_sound(Sound::ITEMSOUND_QUEST_ITEMGET)
        end
      end
    else
      m = get_random_party_member(killer, 3)
      if m && Rnd.rand(100) < CHANCE_FOR_FRAGMENT
        st = get_quest_state(m, false).not_nil!
        if st.get_quest_items_count(GUARDIAN_SPIRIT_FRAGMENT) < GUARDIAN_SPIRIT_FRAGMENT_NEEDED
          st.give_items(GUARDIAN_SPIRIT_FRAGMENT, 1)
        end
        if st.get_quest_items_count(GUARDIAN_SPIRIT_FRAGMENT) == GUARDIAN_SPIRIT_FRAGMENT_NEEDED
          st.set_cond(4, true)
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
    when State::COMPLETED
      html = "32461-09.html"
    when State::CREATED
      if st.player.quest_completed?(Q00239_WontYouJoinUs.simple_name)
        html = "32461-10.html"
      elsif st.player.quest_completed?(Q00239_WontYouJoinUs.simple_name) && pc.level >= MIN_LEVEL && st.has_quest_items?(VICINITY_OF_FOS)
        html = "32461-01.htm"
      else
        html = "32461-00.html"
      end
    when State::STARTED
      case st.cond
      when 1
        html = "32461-04.html"
      when 2
        if st.get_quest_items_count(BROKEN_PIECE_OF_MAGIC_FORCE) == BROKEN_PIECE_OF_MAGIC_FORCE_NEEDED
          html = "32461-05.html"
          st.take_items(BROKEN_PIECE_OF_MAGIC_FORCE, -1)
        end
      when 3
        html = "32461-07.html"
      when 4
        if st.get_quest_items_count(GUARDIAN_SPIRIT_FRAGMENT) == GUARDIAN_SPIRIT_FRAGMENT_NEEDED
          html = "32461-08.html"
          st.give_adena(283346, true)
          st.take_items(VICINITY_OF_FOS, 1)
          st.add_exp_and_sp(1319736, 103553)
          st.exit_quest(false, true)
        end
      end

    end


    html || get_no_quest_msg(pc)
  end
end
