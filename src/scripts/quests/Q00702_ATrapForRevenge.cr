class Scripts::Q00702_ATrapForRevenge < Quest
  # NPC
  private PLENOS = 32563
  private LEKON = 32557
  private TENIUS = 32555
  private MONSTERS = {
    22612,
    22613,
    25632,
    22610,
    22611,
    25631,
    25626
  }
  # Items
  private DRAKES_FLESH = 13877
  private ROTTEN_BLOOD = 13878
  private BAIT_FOR_DRAKES = 13879
  private VARIANT_DRAKE_WING_HORNS = 13880
  private EXTRACTED_RED_STAR_STONE = 14009

  def initialize
    super(702, self.class.simple_name, "A Trap for Revenge")

    add_start_npc(PLENOS)
    add_talk_id(PLENOS, LEKON, TENIUS)
    add_kill_id(MONSTERS)
    register_quest_items(
      DRAKES_FLESH, ROTTEN_BLOOD, BAIT_FOR_DRAKES, VARIANT_DRAKE_WING_HORNS
    )
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    unless st = get_quest_state(pc, false)
      return get_no_quest_msg(pc)
    end
    html = event

    if event.casecmp?("32563-04.htm")
      st.start_quest
    elsif event.casecmp?("32563-07.html")
      if st.has_quest_items?(DRAKES_FLESH)
        html = "32563-08.html"
      else
        html = "32563-07.html"
      end
    elsif event.casecmp?("32563-09.html")
      st.give_adena(st.get_quest_items_count(DRAKES_FLESH) * 100, false)
      st.take_items(DRAKES_FLESH, -1)
    elsif event.casecmp?("32563-11.html")
      if st.has_quest_items?(VARIANT_DRAKE_WING_HORNS)
        adena = st.get_quest_items_count(VARIANT_DRAKE_WING_HORNS) * 200000
        st.give_adena(adena, false)
        st.take_items(VARIANT_DRAKE_WING_HORNS, -1)
        html = "32563-12.html"
      else
        html = "32563-11.html"
      end
    elsif event.casecmp?("32563-14.html")
      st.exit_quest(true, true)
    elsif event.casecmp?("32557-03.html")
      if !st.has_quest_items?(ROTTEN_BLOOD) && st.get_quest_items_count(EXTRACTED_RED_STAR_STONE) < 100
        html = "32557-03.html"
      elsif st.has_quest_items?(ROTTEN_BLOOD) && st.get_quest_items_count(EXTRACTED_RED_STAR_STONE) < 100
        html = "32557-04.html"
      elsif !st.has_quest_items?(ROTTEN_BLOOD) && st.get_quest_items_count(EXTRACTED_RED_STAR_STONE) >= 100
        html = "32557-05.html"
      elsif st.has_quest_items?(ROTTEN_BLOOD) && st.get_quest_items_count(EXTRACTED_RED_STAR_STONE) >= 100
        st.give_items(BAIT_FOR_DRAKES, 1)
        st.take_items(ROTTEN_BLOOD, 1)
        st.take_items(EXTRACTED_RED_STAR_STONE, 100)
        html = "32557-06.html"
      end
    elsif event.casecmp?("32555-03.html")
      st.set_cond(2, true)
    elsif event.casecmp?("32555-05.html")
      st.exit_quest(true, true)
    elsif event.casecmp?("32555-06.html")
      if st.get_quest_items_count(DRAKES_FLESH) < 100
        html = "32555-06.html"
      else
        html = "32555-07.html"
      end
    elsif event.casecmp?("32555-08.html")
      st.give_items(ROTTEN_BLOOD, 1)
      st.take_items(DRAKES_FLESH, 100)
    elsif event.casecmp?("32555-10.html")
      if st.has_quest_items?(VARIANT_DRAKE_WING_HORNS)
        html = "32555-11.html"
      else
        html = "32555-10.html"
      end
    elsif event.casecmp?("32555-15.html")
      i0 = Rnd.rand(1000)
      i1 = Rnd.rand(1000)

      if i0 >= 500 && i1 >= 600
        st.give_adena(Rnd.rand(49917) + 125000, false)
        if i1 < 720
          st.give_items(9628, Rnd.rand(3) + 1)
          st.give_items(9629, Rnd.rand(3) + 1)
        elsif i1 < 840
          st.give_items(9629, Rnd.rand(3) + 1)
          st.give_items(9630, Rnd.rand(3) + 1)
        elsif i1 < 960
          st.give_items(9628, Rnd.rand(3) + 1)
          st.give_items(9630, Rnd.rand(3) + 1)
        elsif i1 < 1000
          st.give_items(9628, Rnd.rand(3) + 1)
          st.give_items(9629, Rnd.rand(3) + 1)
          st.give_items(9630, Rnd.rand(3) + 1)
        end

        html = "32555-15.html"
      elsif i0 >= 500 && i1 < 600
        st.give_adena(Rnd.rand(49917) + 125000, false)
        if i1 < 210
        elsif i1 < 340
          st.give_items(9628, Rnd.rand(3) + 1)
        elsif i1 < 470
          st.give_items(9629, Rnd.rand(3) + 1)
        elsif i1 < 600
          st.give_items(9630, Rnd.rand(3) + 1)
        end

        html = "32555-16.html"
      elsif i0 < 500 && i1 >= 600
        st.give_adena(Rnd.rand(49917) + 25000, false)
        if i1 < 720
          st.give_items(9628, Rnd.rand(3) + 1)
          st.give_items(9629, Rnd.rand(3) + 1)
        elsif i1 < 840
          st.give_items(9629, Rnd.rand(3) + 1)
          st.give_items(9630, Rnd.rand(3) + 1)
        elsif i1 < 960
          st.give_items(9628, Rnd.rand(3) + 1)
          st.give_items(9630, Rnd.rand(3) + 1)
        elsif i1 < 1000
          st.give_items(9628, Rnd.rand(3) + 1)
          st.give_items(9629, Rnd.rand(3) + 1)
          st.give_items(9630, Rnd.rand(3) + 1)
        end
        html = "32555-17.html"
      elsif i0 < 500 && i1 < 600
        st.give_adena(Rnd.rand(49917) + 25000, false)
        if i1 < 210
          # do nothing
        elsif i1 < 340
          st.give_items(9628, Rnd.rand(3) + 1)
        elsif i1 < 470
          st.give_items(9629, Rnd.rand(3) + 1)
        elsif i1 < 600
          st.give_items(9630, Rnd.rand(3) + 1)
        end

        html = "32555-18.html"
      end
      st.take_items(VARIANT_DRAKE_WING_HORNS, 1)
    end

    html
  end

  def on_kill(npc, pc, is_summon)
    unless member = get_random_party_member(pc, 2)
      return
    end
    st = get_quest_state!(member, false)
    chance = Rnd.rand(1000)
    case npc.id
    when 22612
      if chance < 413
        st.give_items(DRAKES_FLESH, 2)
      else
        st.give_items(DRAKES_FLESH, 1)
      end
    when 22613
      if chance < 440
        st.give_items(DRAKES_FLESH, 2)
      else
        st.give_items(DRAKES_FLESH, 1)
      end
    when 25632
      if chance < 996
        st.give_items(DRAKES_FLESH, 1)
      end
    when 22610
      if chance < 485
        st.give_items(DRAKES_FLESH, 2)
      else
        st.give_items(DRAKES_FLESH, 1)
      end
    when 22611
      if chance < 451
        st.give_items(DRAKES_FLESH, 2)
      else
        st.give_items(DRAKES_FLESH, 1)
      end
    when 25631
      if chance < 485
        st.give_items(DRAKES_FLESH, 2)
      else
        st.give_items(DRAKES_FLESH, 1)
      end
    when 25626
      count = 0
      if chance < 708
        count = Rnd.rand(2) + 1
      elsif chance < 978
        count = Rnd.rand(3) + 3
      elsif chance < 994
        count = Rnd.rand(4) + 6
      elsif chance < 998
        count = Rnd.rand(4) + 10
      elsif chance < 1000
        count = Rnd.rand(5) + 14
      end
      st.give_items(VARIANT_DRAKE_WING_HORNS, count)
    end

    st.play_sound(Sound::ITEMSOUND_QUEST_ITEMGET)

    nil
  end

  def on_talk(npc, pc)
    st = get_quest_state!(pc)

    if npc.id == PLENOS
      case st.state
      when State::CREATED
        if pc.quest_completed?(Q10273_GoodDayToFly.simple_name) && pc.level >= 78
          html = "32563-01.htm"
        else
          html = "32563-02.htm"
        end
      when State::STARTED
        html = st.cond?(1) ? "32563-05.html" : "32563-06.html"
      end

    end

    if st.state == State::STARTED
      if npc.id == LEKON
        case st.cond
        when 1
          html = "32557-01.html"
        when 2
          html = "32557-02.html"
        end

      elsif npc.id == TENIUS
        case st.cond
        when 1
          html = "32555-01.html"
        when 2
          html = "32555-04.html"
        end

      end
    end

    html || get_no_quest_msg(pc)
  end
end
