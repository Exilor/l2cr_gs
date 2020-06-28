class Scripts::Q10290_LandDragonConqueror < Quest
  # NPC
  private THEODRIC = 30755
  # Monster
  private ANTHARAS = 29068
  # Items
  private PORTAL_STONE = 3865
  private SHABBY_NECKLACE = 15522
  private MIRACLE_NECKLACE = 15523
  # Reward
  private ANTHARAS_SLAYER_CIRCLET = 8568
  # Misc
  private MIN_LEVEL = 83

  def initialize
    super(10290, self.class.simple_name, "Land Dragon Conqueror")

    add_start_npc(THEODRIC)
    add_talk_id(THEODRIC)
    add_kill_id(ANTHARAS)
    register_quest_items(MIRACLE_NECKLACE, SHABBY_NECKLACE)
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    unless st = get_quest_state(pc, false)
      return get_no_quest_msg(pc)
    end

    if event == "30755-05.htm"
      st.start_quest
      st.give_items(SHABBY_NECKLACE, 1)
    end

    event
  end

  def on_kill(npc, pc, is_summon)
    unless party = pc.party
      return super
    end

    # rewards go only to command channel, not to a single party or player (retail Freya AI)
    if cc = party.command_channel
      cc.each do |p|
        if Util.in_range?(8000, npc, p, false)
          st = get_quest_state(p, false)

          if st && st.cond?(1) && st.has_quest_items?(SHABBY_NECKLACE)
            st.take_items(SHABBY_NECKLACE, -1)
            st.give_items(MIRACLE_NECKLACE, 1)
            st.set_cond(2, true)
          end
        end
      end
    else
      party.each do |p|
        if Util.in_range?(8000, npc, p, false)
          st = get_quest_state(p, false)

          if st && st.cond?(1) && st.has_quest_items?(SHABBY_NECKLACE)
            st.take_items(SHABBY_NECKLACE, -1)
            st.give_items(MIRACLE_NECKLACE, 1)
            st.set_cond(2, true)
          end
        end
      end
    end

    super
  end

  def on_talk(npc, pc)
    st = get_quest_state!(pc)

    case st.state
    when State::CREATED
      if pc.level < MIN_LEVEL
        html = "30755-00.htm"
      else
        if st.has_quest_items?(PORTAL_STONE)
          html = "30755-02.htm"
        else
          html = "30755-01.htm"
        end
      end
    when State::STARTED
      if st.cond?(1)
        if st.has_quest_items?(SHABBY_NECKLACE)
          html = "30755-06.html"
        else
          st.give_items(SHABBY_NECKLACE, 1)
          html = "30755-07.html"
        end
      elsif st.cond?(2) && st.has_quest_items?(MIRACLE_NECKLACE)
        html = "30755-08.html"
        st.give_adena(131236, true)
        st.add_exp_and_sp(702557, 76334)
        st.give_items(ANTHARAS_SLAYER_CIRCLET, 1)
        st.exit_quest(false, true)
      end
    when State::COMPLETED
      html = "30755-09.html"
    end


    html || get_no_quest_msg(pc)
  end
end
