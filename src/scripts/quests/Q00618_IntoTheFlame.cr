class Scripts::Q00618_IntoTheFlame < Quest
  # NPCs
  private KLEIN = 31540
  private HILDA = 31271
  # Monsters
  private MONSTERS = {
    21274 => 630,
    21276 => 630,
    21282 => 670,
    21283 => 670,
    21284 => 670,
    21290 => 710,
    21291 => 710,
    21292 => 710
  }
  # Items
  private VACUALITE_ORE = 7265
  private VACUALITE = 7266
  private VACUALITE_FLOATING_STONE = 7267
  # Misc
  private MIN_LEVEL = 60
  private REQUIRED_COUNT = 50


  def initialize
    super(618, self.class.simple_name, "Into the Flame")

    add_start_npc(KLEIN)
    add_talk_id(HILDA, KLEIN)
    add_kill_id(MONSTERS.keys)
    register_quest_items(VACUALITE_ORE, VACUALITE)
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    unless st = get_quest_state(pc, false)
      return
    end

    case event
    when "31540-03.htm"
      st.start_quest
      html = event
    when "31540-05.html"
      if !st.has_quest_items?(VACUALITE)
        html = "31540-03.htm"
      else
        st.give_items(VACUALITE_FLOATING_STONE, 1)
        st.exit_quest(true, true)
        html = event
      end
    when "31271-02.html"
      if st.cond?(1)
        st.set_cond(2, true)
        html = event
      end
    when "31271-05.html"
      if st.get_quest_items_count(VACUALITE_ORE) == REQUIRED_COUNT && st.cond?(3)
        st.take_items(VACUALITE_ORE, -1)
        st.give_items(VACUALITE, 1)
        st.set_cond(4, true)
        html = event
      else
        html = "31271-03.html"
      end
    else
      # automatically added
    end


    html
  end

  def on_kill(npc, pc, is_pet)
    if member = get_random_party_member(pc, 2)
      qs = get_quest_state!(member, false)
      if qs.get_quest_items_count(VACUALITE_ORE) < REQUIRED_COUNT
        if Rnd.rand(1000) < MONSTERS[npc.id]
          qs.give_items(VACUALITE_ORE, 1)
          if qs.get_quest_items_count(VACUALITE_ORE) >= REQUIRED_COUNT
            qs.set_cond(3, true)
          else
            qs.play_sound(Sound::ITEMSOUND_QUEST_ITEMGET)
          end
        end
      end
    end

    super
  end

  def on_talk(npc, pc)
    st = get_quest_state!(pc)
    case npc.id
    when KLEIN
      if st.created?
        html = pc.level < MIN_LEVEL ? "31540-01.html" : "31540-02.htm"
      elsif st.started?
        html = st.cond?(4) ? "31540-04.html" : "31540-03.htm"
      end
    when HILDA
      case st.cond
      when 1
        html = "31271-01.html"
      when 2
        html = "31271-03.html"
      when 3
        html = "31271-04.html"
      when 4
        html = "31271-06.html"
      else
        # automatically added
      end

    else
      # automatically added
    end


    html || get_no_quest_msg(pc)
  end
end