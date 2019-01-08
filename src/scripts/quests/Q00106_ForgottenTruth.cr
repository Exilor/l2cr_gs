class Quests::Q00106_ForgottenTruth < Quest
  # NPCs
  private THIFIELL = 30358
  private KARTA = 30133
  # Monster
  private TUMRAN_ORC_BRIGAND = 27070
  # Items
  private ONYX_TALISMAN1 = 984
  private ONYX_TALISMAN2 = 985
  private ANCIENT_SCROLL = 986
  private ANCIENT_CLAY_TABLET = 987
  private KARTAS_TRANSLATION = 988
  # Misc
  private MIN_LVL = 10

  def initialize
    super(106, self.class.simple_name, "Forgotten Truth")

    add_start_npc(THIFIELL)
    add_talk_id(THIFIELL, KARTA)
    add_kill_id(TUMRAN_ORC_BRIGAND)
    register_quest_items(KARTAS_TRANSLATION, ONYX_TALISMAN1, ONYX_TALISMAN2, ANCIENT_SCROLL, ANCIENT_CLAY_TABLET)
  end

  def on_adv_event(event, npc, player)
    return unless player
    return unless st = get_quest_state(player, false)

    case event
    when "30358-04.htm"
      htmltext = event
    when "30358-05.htm"
      if st.created?
        st.start_quest
        st.give_items(ONYX_TALISMAN1, 1)
        htmltext = event
      end
    end

    htmltext
  end

  def on_kill(npc, killer, is_summon)
    st = get_quest_state(killer, false)
    if st && st.cond?(2) && Util.in_range?(1500, npc, killer, true)
      if Rnd.rand(100) < 20 && st.has_quest_items?(ONYX_TALISMAN2)
        if !st.has_quest_items?(ANCIENT_SCROLL)
          st.give_items(ANCIENT_SCROLL, 1)
          st.play_sound(Sound::ITEMSOUND_QUEST_MIDDLE)
        elsif !st.has_quest_items?(ANCIENT_CLAY_TABLET)
          st.set_cond(3, true)
          st.give_items(ANCIENT_CLAY_TABLET, 1)
        end
      end
    end

    super
  end

  def on_talk(npc, talker)
    st = get_quest_state(talker, true)
    htmltext = get_no_quest_msg(talker)
    return htmltext unless st

    case npc.id
    when THIFIELL
      case st.state
      when State::CREATED
        if talker.race.dark_elf?
          htmltext = talker.level >= MIN_LVL ? "30358-03.htm" : "30358-02.htm"
        else
          htmltext = "30358-01.htm"
        end
      when State::STARTED
        if has_at_least_one_quest_item?(talker, ONYX_TALISMAN1, ONYX_TALISMAN2) && !st.has_quest_items?(KARTAS_TRANSLATION)
          htmltext = "30358-06.html"
        elsif st.cond?(4) && st.has_quest_items?(KARTAS_TRANSLATION)
          Q00281_HeadForTheHills.give_newbie_reward(talker)
          talker.send_packet(SocialAction.new(talker.l2id, 3))
          st.give_adena(10266, true)
          st.add_exp_and_sp(24195, 2074)
          st.exit_quest(false, true)
          htmltext = "30358-07.html"
        end
      when State::COMPLETED
        htmltext = get_already_completed_msg(talker)
      end
    when KARTA
      if st.started?
        case st.cond
        when 1
          if st.has_quest_items?(ONYX_TALISMAN1)
            st.set_cond(2, true)
            st.take_items(ONYX_TALISMAN1, -1)
            st.give_items(ONYX_TALISMAN2, 1)
            htmltext = "30133-01.html"
          end
        when 2
          if st.has_quest_items?(ONYX_TALISMAN2)
            htmltext = "30133-02.html"
          end
        when 3
          if st.has_quest_items?(ANCIENT_SCROLL, ANCIENT_CLAY_TABLET)
            st.set_cond(4, true)
            take_items(talker, -1, {ANCIENT_SCROLL, ANCIENT_CLAY_TABLET, ONYX_TALISMAN2})
            st.give_items(KARTAS_TRANSLATION, 1)
            htmltext = "30133-03.html"
          end
        when 4
          if st.has_quest_items?(KARTAS_TRANSLATION)
            htmltext = "30133-04.html"
          end
        end
      end
    end

    htmltext
  end
end
