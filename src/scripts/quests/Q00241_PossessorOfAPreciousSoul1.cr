class Scripts::Q00241_PossessorOfAPreciousSoul1 < Quest
  # NPCs
  private STEDMIEL = 30692
  private GABRIELLE = 30753
  private GILMORE = 30754
  private KANTABILON = 31042
  private RAHORAKTI = 31336
  private TALIEN = 31739
  private CARADINE = 31740
  private VIRGIL = 31742
  private KASSANDRA = 31743
  private OGMAR = 31744
  # Mobs
  private BARAHAM = 27113
  private MALRUK_SUCCUBUS_1 = 20244
  private MALRUK_SUCCUBUS_TUREN_1 = 20245
  private MALRUK_SUCCUBUS_2 = 20283
  private MALRUK_SUCCUBUS_TUREN_2 = 20284
  private TAIK_ORC_SUPPLY_LEADER = 20669
  # Items
  private LEGEND_OF_SEVENTEEN = 7587
  private MALRUK_SUCCUBUS_CLAW = 7597
  private ECHO_CRYSTAL = 7589
  private POETRY_BOOK = 7588
  private CRIMSON_MOSS = 7598
  private RAHORAKTIS_MEDICINE = 7599
  private VIRGILS_LETTER = 7677
  # Rewards
  private CRIMSON_MOSS_CHANCE = 30
  private MALRUK_SUCCUBUS_CLAW_CHANCE = 60

  def initialize
    super(241, self.class.simple_name, "Possessor Of A Precious Soul 1")

    add_start_npc(TALIEN)
    add_talk_id(
      TALIEN, STEDMIEL, GABRIELLE, GILMORE, KANTABILON, RAHORAKTI, CARADINE,
      KASSANDRA, VIRGIL, OGMAR
    )
    add_kill_id(
      BARAHAM, MALRUK_SUCCUBUS_1, MALRUK_SUCCUBUS_TUREN_1, MALRUK_SUCCUBUS_2,
      MALRUK_SUCCUBUS_TUREN_2, TAIK_ORC_SUPPLY_LEADER
    )
    register_quest_items(
      LEGEND_OF_SEVENTEEN, MALRUK_SUCCUBUS_CLAW, ECHO_CRYSTAL, POETRY_BOOK,
      CRIMSON_MOSS, RAHORAKTIS_MEDICINE
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
    when "31739-02.html"
      st.start_quest
    when "30753-02.html"
      if st.cond?(1)
        st.set_cond(2, true)
      end
    when "30754-02.html"
      if st.cond?(2)
        st.set_cond(3, true)
      end
    when "31739-05.html"
      if st.cond?(4) && st.has_quest_items?(LEGEND_OF_SEVENTEEN)
        st.take_items(LEGEND_OF_SEVENTEEN, -1)
        st.set_cond(5, true)
      end
    when "31042-02.html"
      if st.cond?(5)
        st.set_cond(6, true)
      end
    when "31042-05.html"
      if st.cond?(7) && st.get_quest_items_count(MALRUK_SUCCUBUS_CLAW) >= 10
        st.take_items(MALRUK_SUCCUBUS_CLAW, -1)
        st.give_items(ECHO_CRYSTAL, 1)
        st.set_cond(8, true)
      end
    when "31739-08.html"
      if st.cond?(8) && st.has_quest_items?(ECHO_CRYSTAL)
        st.take_items(ECHO_CRYSTAL, -1)
        st.set_cond(9, true)
      end
    when "30692-02.html"
      if st.cond?(9) && !st.has_quest_items?(POETRY_BOOK)
        st.give_items(POETRY_BOOK, 1)
        st.set_cond(10, true)
      end
    when "31739-11.html"
      if st.cond?(10) && st.has_quest_items?(POETRY_BOOK)
        st.take_items(POETRY_BOOK, -1)
        st.set_cond(11, true)
      end
    when "31742-02.html"
      if st.cond?(11)
        st.set_cond(12, true)
      end
    when "31744-02.html"
      if st.cond?(12)
        st.set_cond(13, true)
      end
    when "31336-02.html"
      if st.cond?(13)
        st.set_cond(14, true)
      end
    when "31336-05.html"
      if st.cond?(15) && st.get_quest_items_count(CRIMSON_MOSS) >= 5
        st.take_items(CRIMSON_MOSS, -1)
        st.give_items(RAHORAKTIS_MEDICINE, 1)
        st.set_cond(16, true)
      end
    when "31743-02.html"
      if st.cond?(16) && st.has_quest_items?(RAHORAKTIS_MEDICINE)
        st.take_items(RAHORAKTIS_MEDICINE, -1)
        st.set_cond(17, true)
      end
    when "31742-05.html"
      if st.cond?(17)
        st.set_cond(18, true)
      end
    when "31740-05.html"
      if st.cond >= 18
        st.give_items(VIRGILS_LETTER, 1)
        st.add_exp_and_sp(263043, 0)
        st.exit_quest(false, true)
      end
    end

    event
  end

  def on_kill(npc, pc, is_summon)
    case npc.id
    when BARAHAM
      unless member = get_random_party_member(pc, 3)
        return
      end

      st = get_quest_state(member, false).not_nil!
      st.give_items(LEGEND_OF_SEVENTEEN, 1)
      st.set_cond(4, true)
    when MALRUK_SUCCUBUS_1, MALRUK_SUCCUBUS_TUREN_1, MALRUK_SUCCUBUS_2,
         MALRUK_SUCCUBUS_TUREN_2
      member = get_random_party_member(pc, 6)
      if member.nil?
        return
      end
      st = get_quest_state(member, false).not_nil!
      if MALRUK_SUCCUBUS_CLAW_CHANCE >= Rnd.rand(100) && st.get_quest_items_count(MALRUK_SUCCUBUS_CLAW) < 10
        st.give_items(MALRUK_SUCCUBUS_CLAW, 1)
        if st.get_quest_items_count(MALRUK_SUCCUBUS_CLAW) == 10
          st.set_cond(7, true)
        else
          st.play_sound(Sound::ITEMSOUND_QUEST_ITEMGET)
        end
      end
    when TAIK_ORC_SUPPLY_LEADER
      unless member = get_random_party_member(pc, 14)
        return
      end
      st = get_quest_state(member, false).not_nil!
      if CRIMSON_MOSS_CHANCE >= Rnd.rand(100) && st.get_quest_items_count(CRIMSON_MOSS) < 5
        st.give_items(CRIMSON_MOSS, 1)
        if st.get_quest_items_count(CRIMSON_MOSS) == 5
          st.set_cond(15, true)
        else
          st.play_sound(Sound::ITEMSOUND_QUEST_ITEMGET)
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
    when TALIEN
      case st.state
      when State::CREATED
        if pc.level >= 50 && pc.subclass_active?
          html = "31739-01.htm"
        else
          html = "31739-00.htm"
        end
      when State::STARTED
        case st.cond
        when 1
          html = "31739-03.html"
        when 4
          if st.has_quest_items?(LEGEND_OF_SEVENTEEN)
            html = "31739-04.html"
          end
        when 5
          html = "31739-06.html"
        when 8
          if st.has_quest_items?(ECHO_CRYSTAL)
            html = "31739-07.html"
          end
        when 9
          html = "31739-09.html"
        when 10
          if st.has_quest_items?(POETRY_BOOK)
            html = "31739-10.html"
          end
        when 11
          html = "31739-12.html"
        end
      when State::COMPLETED
        html = get_already_completed_msg(pc)
      end
    when GABRIELLE
      case st.cond
      when 1
        html = "30753-01.html"
      when 2
        html = "30753-03.html"
      end
    when GILMORE
      case st.cond
      when 2
        html = "30754-01.html"
      when 3
        html = "30754-03.html"
      end
    when KANTABILON
      case st.cond
      when 5
        html = "31042-01.html"
      when 6
        html = "31042-04.html"
      when 7
        if st.get_quest_items_count(MALRUK_SUCCUBUS_CLAW) >= 10
          html = "31042-03.html"
        end
      when 8
        html = "31042-06.html"
      end
    when STEDMIEL
      case st.cond
      when 9
        html = "30692-01.html"
      when 10
        html = "30692-03.html"
      end
    when VIRGIL
      case st.cond
      when 11
        html = "31742-01.html"
      when 12
        html = "31742-03.html"
      when 17
        html = "31742-04.html"
      when 18
        html = "31742-06.html"
      end
    when OGMAR
      case st.cond
      when 12
        html = "31744-01.html"
      when 13
        html = "31744-03.html"
      end
    when RAHORAKTI
      case st.cond
      when 13
        html = "31336-01.html"
      when 14
        html = "31336-04.html"
      when 15
        if st.get_quest_items_count(CRIMSON_MOSS) >= 5
          html = "31336-03.html"
        end
      when 16
        html = "31336-06.html"
      end
    when KASSANDRA
      case st.cond
      when 16
        if st.has_quest_items?(RAHORAKTIS_MEDICINE)
          html = "31743-01.html"
        end
      when 17
        html = "31743-03.html"
      end
    when CARADINE
      if st.cond >= 18
        html = "31740-01.html"
      end
    end

    html || get_no_quest_msg(pc)
  end
end
