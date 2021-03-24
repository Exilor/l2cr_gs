class Scripts::Q00901_HowLavasaurusesAreMade < Quest
  # NPC
  private ROONEY = 32049
  # Monsters
  private LAVASAURUS_NEWBORN   = 18799
  private LAVASAURUS_FLEDGLING = 18800
  private LAVASAURUS_ADULT     = 18801
  private LAVASAURUS_ELDERLY   = 18802
  # Items
  private FRAGMENT_STONE = 21909
  private FRAGMENT_HEAD  = 21910
  private FRAGMENT_BODY  = 21911
  private FRAGMENT_HORN  = 21912
  # Rewards
  private TOTEM_OF_BODY      = 21899
  private TOTEM_OF_SPIRIT    = 21900
  private TOTEM_OF_COURAGE   = 21901
  private TOTEM_OF_FORTITUDE = 21902

  def initialize
    super(901, self.class.simple_name, "How Lavasauruses Are Made")

    add_start_npc(ROONEY)
    add_talk_id(ROONEY)
    add_kill_id(
      LAVASAURUS_NEWBORN, LAVASAURUS_FLEDGLING, LAVASAURUS_ADULT,
      LAVASAURUS_ELDERLY
    )
    register_quest_items(
      FRAGMENT_STONE, FRAGMENT_HORN, FRAGMENT_HEAD, FRAGMENT_BODY
    )
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    unless st = get_quest_state(pc, false)
      return get_no_quest_msg(pc)
    end

    html = event
    case event
    when "32049-03.htm", "32049-08.html", "32049-09.html", "32049-10.html",
         "32049-11.html"
      # do nothing
    when "32049-04.htm"
      st.start_quest
    when "32049-12.html"
      st.give_items(TOTEM_OF_BODY, 1)
      st.exit_quest(QuestType::DAILY, true)
    when "32049-13.html"
      st.give_items(TOTEM_OF_SPIRIT, 1)
      st.exit_quest(QuestType::DAILY, true)
    when "32049-14.html"
      st.give_items(TOTEM_OF_FORTITUDE, 1)
      st.exit_quest(QuestType::DAILY, true)
    when "32049-15.html"
      st.give_items(TOTEM_OF_COURAGE, 1)
      st.exit_quest(QuestType::DAILY, true)
    else
      html = nil
    end

    html
  end

  def on_kill(npc, pc, is_summon)
    st = get_quest_state(pc, false)
    if st && st.cond?(1)
      case npc.id
      when LAVASAURUS_NEWBORN
        give_quest_items(st, FRAGMENT_STONE)
      when LAVASAURUS_FLEDGLING
        give_quest_items(st, FRAGMENT_HEAD)
      when LAVASAURUS_ADULT
        give_quest_items(st, FRAGMENT_BODY)
      when LAVASAURUS_ELDERLY
        give_quest_items(st, FRAGMENT_HORN)
      end
    end

    super
  end

  def on_talk(npc, pc)
    st = get_quest_state!(pc)

    case st.state
    when State::CREATED
      html = st.player.level >= 76 ? "32049-01.htm" : "32049-02.htm"
    when State::STARTED
      if st.cond?(1)
        html = "32049-05.html"
      elsif st.cond?(2)
        if got_all_quest_items?(st)
          st.take_items(FRAGMENT_STONE, -1)
          st.take_items(FRAGMENT_HEAD, -1)
          st.take_items(FRAGMENT_BODY, -1)
          st.take_items(FRAGMENT_HORN, -1)
          html = "32049-06.html"
        else
          html = "32049-07.html"
        end
      end
    when State::COMPLETED
      if st.now_available?
        st.state = State::CREATED
        html = st.player.level >= 76 ? "32049-01.htm" : "32049-02.html"
      else
        html = "32049-16.html"
      end
    end

    html || get_no_quest_msg(pc)
  end

  private def give_quest_items(st, item_id)
    if st.get_quest_items_count(item_id) < 10
      st.give_items(item_id, 1)
      st.play_sound(Sound::ITEMSOUND_QUEST_ITEMGET)
    elsif got_all_quest_items?(st)
      st.set_cond(2, true)
    end
  end

  private def got_all_quest_items?(st)
    st.get_quest_items_count(FRAGMENT_STONE) >= 10 &&
      st.get_quest_items_count(FRAGMENT_HEAD) >= 10 &&
      st.get_quest_items_count(FRAGMENT_BODY) >= 10 &&
      st.get_quest_items_count(FRAGMENT_HORN) >= 10
  end
end
