class Scripts::Q00024_InhabitantsOfTheForestOfTheDead < Quest
  # NPCs
  private DORIAN = 31389
  private MYSTERIOUS_WIZARD = 31522
  private TOMBSTONE = 31531
  private LIDIA_MAID = 31532
  # Items
  private LIDIA_LETTER = 7065
  private LIDIA_HAIRPIN = 7148
  private SUSPICIOUS_TOTEM_DOLL = 7151
  private FLOWER_BOUQUET = 7152
  private SILVER_CROSS_OF_EINHASAD = 7153
  private BROKEN_SILVER_CROSS_OF_EINHASAD = 7154
  private TOTEM = 7156
  # Monsters
  private MOBS = {21557, 21558, 21560, 21563, 21564, 21565, 21566, 21567}

  def initialize
    super(24, self.class.simple_name, "Inhabitants of the Forest of the Dead")

    add_start_npc(DORIAN)
    add_talk_id(DORIAN, MYSTERIOUS_WIZARD, TOMBSTONE, LIDIA_MAID)
    add_kill_id(MOBS)
    register_quest_items(LIDIA_LETTER, LIDIA_HAIRPIN, SUSPICIOUS_TOTEM_DOLL, FLOWER_BOUQUET, SILVER_CROSS_OF_EINHASAD, BROKEN_SILVER_CROSS_OF_EINHASAD)
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    return unless st = get_quest_state(pc, false)

    html = event
    case event
      # Dorian
    when "31389-02.htm"
      if pc.level >= 65 && pc.quest_completed?(Q00023_LidiasHeart.simple_name)
        st.start_quest
        st.give_items(FLOWER_BOUQUET, 1)
        return "31389-03.htm"
      end
    when "31389-08.html"
      st.set("var", "1")
    when "31389-13.html"
      st.give_items(SILVER_CROSS_OF_EINHASAD, 1)
      st.set_cond(3, true)
      st.unset("var")
    when "31389-18.html"
      st.play_sound(Sound::INTERFACESOUND_CHARSTAT_OPEN)
    when "31389-19.html"
      unless st.has_quest_items?(BROKEN_SILVER_CROSS_OF_EINHASAD)
        return get_no_quest_msg(pc)
      end
      st.take_items(BROKEN_SILVER_CROSS_OF_EINHASAD, -1)
      st.set_cond(5, true)
    when "31389-06.html", "31389-07.html", "31389-10.html", "31389-11.html",
         "31389-12.html", "31389-16.html", "31389-17.html"
    # Lidia Maid
    when "31532-04.html"
      st.give_items(LIDIA_LETTER, 1)
      st.set_cond(6, true)
    when "31532-07.html"
      if st.cond?(8)
        unless has_quest_items?(pc, LIDIA_HAIRPIN, LIDIA_LETTER)
          return get_no_quest_msg(pc)
        end
        st.take_items(LIDIA_HAIRPIN, -1)
        st.take_items(LIDIA_LETTER, -1)
        st.set("var", "1")
        html = "31532-06.html"
      else
        if st.cond?(6)
          st.set_cond(7, true)
        end
      end
    when "31532-10.html"
      st.set("var", "2")
    when "31532-14.html"
      st.set("var", "3")
    when "31532-19.html"
      st.unset("var")
      st.set_cond(9, true)
    when "31532-02.html", "31532-03.html", "31532-09.html", "31532-12.html",
         "31532-13.html", "31532-15.html", "31532-16.html", "31532-17.html",
         "31532-18.html"
      # Mysterious Wizard
    when "31522-03.html"
      unless st.has_quest_items?(SUSPICIOUS_TOTEM_DOLL)
        return get_no_quest_msg(pc)
      end
      st.take_items(SUSPICIOUS_TOTEM_DOLL, 1)
      st.set("var", "1")
    when "31522-08.html"
      st.unset("var")
      st.set_cond(11, true)
    when "31522-17.html"
      st.set("var", "1")
    when "31522-21.html"
      st.give_items(TOTEM, 1)
      st.add_exp_and_sp(242105, 22529); # GoD: Harmony: 6191140 exp and 6118650 sp
      st.exit_quest(false, true)
    when "31522-02.html", "31522-05.html", "31522-06.html", "31522-07.html",
         "31522-10.html", "31522-11.html", "31522-12.html", "31522-13.html",
         "31522-14.html", "31522-15.html", "31522-16.html", "31522-19.html",
         "31522-20.html"
      # Tombstone
    when "31531-02.html"
      unless st.has_quest_items?(FLOWER_BOUQUET)
        return get_no_quest_msg(pc)
      end
      st.take_items(FLOWER_BOUQUET, -1)
      st.set_cond(2, true)
    else
      html = nil
    end

    html
  end

  def on_kill(npc, pc, is_summon)
    st = get_quest_state(pc, false)

    if st && st.cond?(9) && Rnd.rand(100) < 10
      st.give_items(SUSPICIOUS_TOTEM_DOLL, 1)
      st.set_cond(10, true)
    end

    super
  end

  def on_talk(npc, pc)
    unless st = get_quest_state(pc, true)
      return get_no_quest_msg(pc)
    end

    case npc.id
    when DORIAN
      case st.state
      when State::CREATED
        html = "31389-01.htm"
      when State::STARTED
        case st.cond
        when 1
          html = "31389-04.html"
        when 2
          html = st.get_int("var") == 0 ? "31389-05.html" : "31389-09.html"
        when 3
          html = "31389-14.html"
        when 4
          html = "31389-15.html"
        when 5
          html = "31389-20.html"
        when 6, 8
          html = "31389-22.html"
        when 7
          st.give_items(LIDIA_HAIRPIN, 1)
          st.set_cond(8, true)
          html = "31389-21.html"
        end
      when State::COMPLETED
        html = get_already_completed_msg(pc)
      end
    when MYSTERIOUS_WIZARD
      if st.started?
        if st.cond?(10)
          html = st.get_int("var") == 0 ? "31522-01.html" : "31522-04.html"
        elsif st.cond?(11)
          html = st.get_int("var") == 0 ? "31522-09.html" : "31522-18.html"
        end
      elsif st.completed?
        qs = pc.get_quest_state(Q00025_HidingBehindTheTruth.simple_name)
        unless qs && (qs.started? || qs.completed?) # L2J has two "completed?"
          html = "31522-22.html"
        end
      end
    when TOMBSTONE
      if st.started?
        if st.cond?(1)
          st.play_sound(Sound::AMDSOUND_WIND_LOOT)
          html = "31531-01.html"
        elsif st.cond?(2)
          html = "31531-03.html"
        end
      end
    when LIDIA_MAID
      if st.started?
        case st.cond
        when 5
          html = "31532-01.html"
        when 6
          html = "31532-05.html"
        when 7
          html = "31532-07a.html"
        when 8
          case st.get_int("var")
          when -1 # L2J: 0
            html = "31532-07a.html"
          when 1
            html = "31532-08.html"
          when 2
            html = "31532-11.html"
          when 3
            html = "31532-15.html"
          end
        when 9, 10
          html = "31532-20.html"
        end
      end
    end

    html || get_no_quest_msg(pc)
  end
end
