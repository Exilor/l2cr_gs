class Scripts::Q00159_ProtectTheWaterSource < Quest
  # NPC
  private ASTERIOS = 30154
  # Monster
  private PLAGUE_ZOMBIE = 27017
  # Items
  private PLAGUE_DUST = 1035
  private HYACINTH_CHARM = 1071
  private HYACINTH_CHARM2 = 1072
  # Misc
  private MIN_LVL = 12

  def initialize
    super(159, self.class.simple_name, "Protect the Water Source")

    add_start_npc(ASTERIOS)
    add_talk_id(ASTERIOS)
    add_kill_id(PLAGUE_ZOMBIE)
    register_quest_items(PLAGUE_DUST, HYACINTH_CHARM, HYACINTH_CHARM2)
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    st = get_quest_state(pc, false)
    if st && event == "30154-04.htm"
      st.start_quest
      st.give_items(HYACINTH_CHARM, 1)
      return event
    end
  end

  def on_kill(npc, killer, is_summon)
    st = get_quest_state(killer, false)
    if st
      case st.cond
      when 1
        if Rnd.rand(100) < 40 && st.has_quest_items?(HYACINTH_CHARM)
          unless st.has_quest_items?(PLAGUE_DUST)
            st.give_items(PLAGUE_DUST, 1)
            st.set_cond(2, true)
          end
        end
      when 3
        dust = st.get_quest_items_count(PLAGUE_DUST)
        if Rnd.rand(100) < 40 && dust < 5 && st.has_quest_items?(HYACINTH_CHARM2)
          st.give_items(PLAGUE_DUST, 1)
          dust += 1
          if dust >= 5
            st.set_cond(4, true)
          else
            st.play_sound(Sound::ITEMSOUND_QUEST_ITEMGET)
          end
        end
      end
    end

    super
  end

  def on_talk(npc, pc)
    if st = get_quest_state(pc, true)
      case st.state
      when State::CREATED
        if pc.race.elf?
          if pc.level >= MIN_LVL
            html = "30154-03.htm"
          else
            html = "30154-02.htm"
          end
        else
          html = "30154-01.htm"
        end
      when State::STARTED
        case st.cond
        when 1
          if st.has_quest_items?(HYACINTH_CHARM)
            unless st.has_quest_items?(PLAGUE_DUST)
              html = "30154-05.html"
            end
          end
        when 2
          if st.has_quest_items?(HYACINTH_CHARM, PLAGUE_DUST)
            st.take_items(HYACINTH_CHARM, -1)
            st.take_items(PLAGUE_DUST, -1)
            st.give_items(HYACINTH_CHARM2, 1)
            st.set_cond(3, true)
            html = "30154-06.html"
          end
        when 3
          if st.has_quest_items?(HYACINTH_CHARM2)
            html = "30154-07.html"
          end
        when 4
          if st.has_quest_items?(HYACINTH_CHARM2)
            if st.get_quest_items_count(PLAGUE_DUST) >= 5
              st.give_adena(18250, true)
              st.exit_quest(false, true)
              html = "30154-08.html"
            end
          end
        end
      when State::COMPLETED
        html = get_already_completed_msg(pc)
      end
    end

    html || get_no_quest_msg(pc)
  end
end
