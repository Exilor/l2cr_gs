class Scripts::Q00627_HeartInSearchOfPower < Quest
  # NPCs
  private MYSTERIOUS_NECROMANCER = 31518
  private ENFEUX = 31519
  # Items
  private SEAL_OF_LIGHT = 7170
  private BEAD_OF_OBEDIENCE = 7171
  private GEM_OF_SAINTS = 7172
  # Monsters
  private MONSTERS = {
    21520 => 661, # Eye of Splendor
    21523 => 668, # Flash of Splendor
    21524 => 714, # Blade of Splendor
    21525 => 714, # Blade of Splendor
    21526 => 796, # Wisdom of Splendor
    21529 => 659, # Soul of Splendor
    21530 => 704, # Victory of Splendor
    21531 => 791, # Punishment of Splendor
    21532 => 820, # Shout of Splendor
    21535 => 827, # Signet of Splendor
    21536 => 798, # Crown of Splendor
    21539 => 875, # Wailing of Splendor
    21540 => 875, # Wailing of Splendor
    21658 => 791  # Punishment of Splendor
  }
  # Misc
  private MIN_LEVEL_REQUIRED = 60
  private BEAD_OF_OBEDIENCE_COUNT_REQUIRED = 300
  # Rewards ID's
  private ASOFE = 4043
  private THONS = 4044
  private ENRIA = 4042
  private MOLD_HARDENER = 4041

  def initialize
    super(627, self.class.simple_name, "Heart in Search of Power")

    add_start_npc(MYSTERIOUS_NECROMANCER)
    add_talk_id(MYSTERIOUS_NECROMANCER, ENFEUX)
    add_kill_id(MONSTERS.keys)
    register_quest_items(SEAL_OF_LIGHT, BEAD_OF_OBEDIENCE, GEM_OF_SAINTS)
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    unless st = get_quest_state(pc, false)
      return
    end

    html = event
    case event
    when "31518-02.htm"
      st.start_quest
    when "31518-06.html"
      if st.get_quest_items_count(BEAD_OF_OBEDIENCE) < BEAD_OF_OBEDIENCE_COUNT_REQUIRED
        return "31518-05.html"
      end
      st.give_items(SEAL_OF_LIGHT, 1)
      st.take_items(BEAD_OF_OBEDIENCE, -1)
      st.set_cond(3)
    when "Adena", "Asofes", "Thons", "Enrias", "Mold_Hardener"
      unless st.has_quest_items?(GEM_OF_SAINTS)
        return "31518-11.html"
      end
      case event
      when "Adena"
        st.give_adena(100000, true)
      when "Asofes"
        st.reward_items(ASOFE, 13)
        st.give_adena(6400, true)
      when "Thons"
        st.reward_items(THONS, 13)
        st.give_adena(6400, true)
      when "Enrias"
        st.reward_items(ENRIA, 6)
        st.give_adena(13600, true)
      when "Mold_Hardener"
        st.reward_items(MOLD_HARDENER, 3)
        st.give_adena(17200, true)
      else
        # [automatically added else]
      end

      html = "31518-10.html"
      st.exit_quest(true)
    when "31519-02.html"
      if st.has_quest_items?(SEAL_OF_LIGHT) && st.cond?(3)
        st.give_items(GEM_OF_SAINTS, 1)
        st.take_items(SEAL_OF_LIGHT, -1)
        st.set_cond(4)
      else
        html = get_no_quest_msg(pc)
      end
    when "31518-09.html"
      # do nothing
    else
      html = nil
    end

    html
  end

  def on_kill(npc, killer, is_summon)
    if m = get_random_party_member(killer, 1)
      st = get_quest_state!(m, false)
      chance = MONSTERS[npc.id] * Config.rate_quest_drop
      if Rnd.rand(1000) < chance
        st.give_items(BEAD_OF_OBEDIENCE, 1)
        if st.get_quest_items_count(BEAD_OF_OBEDIENCE) < BEAD_OF_OBEDIENCE_COUNT_REQUIRED
          st.play_sound(Sound::ITEMSOUND_QUEST_ITEMGET)
        else
          st.set_cond(2, true)
        end
      end
    end

    super
  end

  def on_talk(npc, pc)
    st = get_quest_state!(pc)

    case st.state
    when State::CREATED
      if npc.id == MYSTERIOUS_NECROMANCER
        html = pc.level >= MIN_LEVEL_REQUIRED ? "31518-01.htm" : "31518-00.htm"
      end
    when State::STARTED
      case npc.id
      when MYSTERIOUS_NECROMANCER
        case st.cond
        when 1
          html = "31518-03.html"
        when 2
          html = "31518-04.html"
        when 3
          html = "31518-07.html"
        when 4
          html = "31518-08.html"
        else
          # [automatically added else]
        end

      when ENFEUX
        case st.cond
        when 3
          html = "31519-01.html"
        when 4
          html = "31519-03.html"
        else
          # [automatically added else]
        end

      else
        # [automatically added else]
      end

    else
      # [automatically added else]
    end


    html || get_no_quest_msg(pc)
  end
end
