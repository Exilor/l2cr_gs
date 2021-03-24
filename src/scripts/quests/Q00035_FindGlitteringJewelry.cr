class Scripts::Q00035_FindGlitteringJewelry < Quest
  # NPCs
  private ELLIE = 30091
  private FELTON = 30879
  # Monster
  private ALLIGATOR = 20135
  # Items
  private SILVER_NUGGET = 1873
  private ORIHARUKON = 1893
  private THONS = 4044
  private JEWEL_BOX = 7077
  private ROUGH_JEWEL = 7162
  # Misc
  private MIN_LEVEL = 60
  private JEWEL_COUNT = 10
  private ORIHARUKON_COUNT = 5
  private NUGGET_COUNT = 500
  private THONS_COUNT = 150

  def initialize
    super(35, self.class.simple_name, "Find Glittering Jewelry")

    add_start_npc(ELLIE)
    add_talk_id(ELLIE, FELTON)
    add_kill_id(ALLIGATOR)
    register_quest_items(ROUGH_JEWEL)
  end

  def on_adv_event(event, npc, pc)
    return unless pc && (st = get_quest_state(pc, false))

    html = event
    case event
    when "30091-03.htm"
      st.start_quest
    when "30879-02.html"
      st.set_cond(2, true)
    when "30091-07.html"
      if st.get_quest_items_count(ROUGH_JEWEL) < JEWEL_COUNT
        return "30091-08.html"
      end
      st.take_items(ROUGH_JEWEL, -1)
      st.set_cond(4, true)
    when "30091-11.html"
      if st.get_quest_items_count(ORIHARUKON) >= ORIHARUKON_COUNT && st.get_quest_items_count(SILVER_NUGGET) >= NUGGET_COUNT && st.get_quest_items_count(THONS) >= THONS_COUNT
        st.take_items(ORIHARUKON, ORIHARUKON_COUNT)
        st.take_items(SILVER_NUGGET, NUGGET_COUNT)
        st.take_items(THONS, THONS_COUNT)
        st.give_items(JEWEL_BOX, 1)
        st.exit_quest(false, true)
      else
        html = "30091-12.html"
      end
    else
      html = nil
    end

    html
  end

  def on_kill(npc, pc, is_summon)
    if member = get_random_party_member(pc, 2)
      st = get_quest_state(member, false).not_nil!
      if Rnd.bool
        st.give_items(ROUGH_JEWEL, 1)
        if st.get_quest_items_count(ROUGH_JEWEL) >= JEWEL_COUNT
          st.set_cond(3, true)
        else
          st.play_sound(Sound::ITEMSOUND_QUEST_ITEMGET)
        end
      end
    end

    super
  end

  def on_talk(npc, pc)
    st = get_quest_state!(pc)

    case npc.id
    when ELLIE
      case st.state
      when State::CREATED
        html = pc.level >= MIN_LEVEL ? "30091-01.htm" : "30091-02.html"
      when State::STARTED
        case st.cond
        when 1
          html = "30091-04.html"
        when 3
          if st.get_quest_items_count(ROUGH_JEWEL) >= JEWEL_COUNT
            html = "30091-06.html"
          else
            html = "30091-05.html"
          end
        when 4
          if st.get_quest_items_count(ORIHARUKON) >= ORIHARUKON_COUNT && st.get_quest_items_count(SILVER_NUGGET) >= NUGGET_COUNT && st.get_quest_items_count(THONS) >= THONS_COUNT
            html = "30091-09.html"
          else
            html = "30091-10.html"
          end
        end
      when State::COMPLETED
        html = get_already_completed_msg(pc)
      end
    when FELTON
      if st.started?
        if st.cond?(1)
          html = "30879-01.html"
        elsif st.cond?(2)
          html = "30879-03.html"
        end
      end
    end

    html || get_no_quest_msg(pc)
  end
end
