class Scripts::Q00102_SeaOfSporesFever < Quest
  # NPCs
  private COBENDELL = 30156
  private BERROS = 30217
  private VELTRESS = 30219
  private RAYEN = 30221
  private ALBERIUS = 30284
  private GARTRANDELL = 30285
  # Monsters
  private DRYAD = 20013
  private DRYAD_ELDER = 20019
  # Items
  private SWORD_OF_SENTINEL = 743
  private STAFF_OF_SENTINEL = 744
  private ALBERIUS_LIST = 746
  private ALBERIUS_LETTER = 964
  private EVERGREEN_AMULET = 965
  private DRYADS_TEAR = 966
  private LESSER_HEALING_POTION = 1060
  private COBENDELLS_MEDICINE1 = 1130
  private COBENDELLS_MEDICINE2 = 1131
  private COBENDELLS_MEDICINE3 = 1132
  private COBENDELLS_MEDICINE4 = 1133
  private COBENDELLS_MEDICINE5 = 1134
  private SOULSHOT_NO_GRADE = 1835
  private SPIRITSHOT_NO_GRADE = 2509
  private ECHO_CRYSTAL_THEME_OF_BATTLE = 4412
  private ECHO_CRYSTAL_THEME_OF_LOVE = 4413
  private ECHO_CRYSTAL_THEME_OF_SOLITUDE = 4414
  private ECHO_CRYSTAL_THEME_OF_FEAST = 4415
  private ECHO_CRYSTAL_THEME_OF_CELEBRATION = 4416
  # Misc
  private MIN_LVL = 12
  private SENTINELS = {
    GARTRANDELL => COBENDELLS_MEDICINE5,
    RAYEN => COBENDELLS_MEDICINE4,
    VELTRESS => COBENDELLS_MEDICINE3,
    BERROS => COBENDELLS_MEDICINE2,
    ALBERIUS => COBENDELLS_MEDICINE1
  }

  def initialize
    super(102, self.class.simple_name, "Sea of Spores Fever")

    add_start_npc(ALBERIUS)
    add_talk_id(ALBERIUS, COBENDELL, GARTRANDELL, BERROS, VELTRESS, RAYEN)
    add_kill_id(DRYAD, DRYAD_ELDER)
    register_quest_items(
      ALBERIUS_LIST, ALBERIUS_LETTER, EVERGREEN_AMULET, DRYADS_TEAR,
      COBENDELLS_MEDICINE1, COBENDELLS_MEDICINE2, COBENDELLS_MEDICINE3,
      COBENDELLS_MEDICINE4, COBENDELLS_MEDICINE5
    )
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    st = get_quest_state(pc, false)
    if st && event == "30284-02.htm"
      st.start_quest
      st.give_items(ALBERIUS_LETTER, 1)
      return event
    end

    super
  end

  def on_kill(npc, killer, is_summon)
    st = get_quest_state(killer, false)
    if st && st.cond?(2) && Rnd.rand(10) < 3
      st.give_items(DRYADS_TEAR, 1)
      if st.get_quest_items_count(DRYADS_TEAR) < 10
        st.play_sound(Sound::ITEMSOUND_QUEST_ITEMGET)
      else
        st.set_cond(3, true)
      end
    end

    super
  end

  def on_talk(npc, pc)
    st = get_quest_state(pc, true)
    if st
      case npc.id
      when ALBERIUS
        case st.state
        when State::CREATED
          if pc.race.elf?
            if pc.level >= MIN_LVL
              html = "30284-07.htm"
            else
              html = "30284-08.htm"
            end
          else
            html = "30284-00.htm"
          end
        when State::STARTED
          case st.cond
          when 1
            if st.has_quest_items?(ALBERIUS_LETTER)
              html = "30284-03.html"
            end
          when 2
            if st.has_quest_items?(EVERGREEN_AMULET)
              html = "30284-09.html"
            end
          when 4
            if st.has_quest_items?(COBENDELLS_MEDICINE1)
              st.take_items(COBENDELLS_MEDICINE1, 1)
              st.give_items(ALBERIUS_LIST, 1)
              st.set_cond(5)
              html = "30284-04.html"
            end
          when 5
            if has_at_least_one_quest_item?(pc, COBENDELLS_MEDICINE1, COBENDELLS_MEDICINE2, COBENDELLS_MEDICINE3, COBENDELLS_MEDICINE4, COBENDELLS_MEDICINE5)
              html = "30284-05.html"
            end
          when 6
            unless has_at_least_one_quest_item?(pc, COBENDELLS_MEDICINE1, COBENDELLS_MEDICINE2, COBENDELLS_MEDICINE3, COBENDELLS_MEDICINE4, COBENDELLS_MEDICINE5)
              st.give_items(LESSER_HEALING_POTION, 100)
              st.give_items(ECHO_CRYSTAL_THEME_OF_BATTLE, 10)
              st.give_items(ECHO_CRYSTAL_THEME_OF_LOVE, 10)
              st.give_items(ECHO_CRYSTAL_THEME_OF_SOLITUDE, 10)
              st.give_items(ECHO_CRYSTAL_THEME_OF_FEAST, 10)
              st.give_items(ECHO_CRYSTAL_THEME_OF_CELEBRATION, 10)
              if pc.mage_class?
                st.give_items(STAFF_OF_SENTINEL, 1)
                st.give_items(SPIRITSHOT_NO_GRADE, 500)
              else
                st.give_items(SWORD_OF_SENTINEL, 1)
                st.give_items(SOULSHOT_NO_GRADE, 500)
              end
              st.add_exp_and_sp(30202, 1339)
              st.give_adena(6331, true)
              st.exit_quest(false, true)
              html = "30284-06.html"
            end
          end
        when State::COMPLETED
          html = get_already_completed_msg(pc)
        end
      when COBENDELL
        case st.cond
        when 1
          if st.has_quest_items?(ALBERIUS_LETTER)
            st.take_items(ALBERIUS_LETTER, 1)
            st.give_items(EVERGREEN_AMULET, 1)
            st.set_cond(2, true)
            html = "30156-03.html"
          end
        when 2
          if st.has_quest_items?(EVERGREEN_AMULET) && st.get_quest_items_count(DRYADS_TEAR) < 10
            html = "30156-04.html"
          end
        when 3
          if st.get_quest_items_count(DRYADS_TEAR) >= 10
            st.take_items(EVERGREEN_AMULET, -1)
            st.take_items(DRYADS_TEAR, -1)
            st.give_items(COBENDELLS_MEDICINE1, 1)
            st.give_items(COBENDELLS_MEDICINE2, 1)
            st.give_items(COBENDELLS_MEDICINE3, 1)
            st.give_items(COBENDELLS_MEDICINE4, 1)
            st.give_items(COBENDELLS_MEDICINE5, 1)
            st.set_cond(4, true)
            html = "30156-05.html"
          end
        when 4
          if has_at_least_one_quest_item?(pc, COBENDELLS_MEDICINE1, COBENDELLS_MEDICINE2, COBENDELLS_MEDICINE3, COBENDELLS_MEDICINE4, COBENDELLS_MEDICINE5)
            html = "30156-06.html"
          end
        when 5
          if has_at_least_one_quest_item?(pc, COBENDELLS_MEDICINE1, COBENDELLS_MEDICINE2, COBENDELLS_MEDICINE3, COBENDELLS_MEDICINE4, COBENDELLS_MEDICINE5)
            html = "30156-07.html"
          end
        end
      when GARTRANDELL, RAYEN, VELTRESS, BERROS
        if st.has_quest_items?(ALBERIUS_LIST, SENTINELS[npc.id])
          st.take_items(SENTINELS[npc.id], -1)
          unless has_at_least_one_quest_item?(pc, COBENDELLS_MEDICINE1, COBENDELLS_MEDICINE2, COBENDELLS_MEDICINE3, COBENDELLS_MEDICINE4, COBENDELLS_MEDICINE5)
            st.set_cond(6)
          end

          html = "#{npc.id}-01.html"
        end
      end
    end

    html || get_no_quest_msg(pc)
  end
end
