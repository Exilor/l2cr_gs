class Scripts::Q00902_ReclaimOurEra < Quest
  # Npc
  private MATHIAS = 31340
  # Misc
  private MIN_LVL = 80
  # Items
  private SHATTERED_BONES                = 21997
  private CANNIBALISTIC_STAKATO_LDR_CLAW = 21998
  private ANAIS_SCROLL                   = 21999
  private PROOF_OF_CHALLENGE             = 21750
  # Monsters
  private MONSTER_DROPS = {
    25309 => SHATTERED_BONES,                # Varka's Hero Shadith
    25312 => SHATTERED_BONES,                # Varka's Commander Mos
    25315 => SHATTERED_BONES,                # Varka's Chief Horus
    25299 => SHATTERED_BONES,                # Ketra's Hero Hekaton
    25302 => SHATTERED_BONES,                # Ketra's Commander Tayr
    25305 => SHATTERED_BONES,                # Ketra's Chief Brakki
    25667 => CANNIBALISTIC_STAKATO_LDR_CLAW, # Cannibalistic Stakato Chief
    25668 => CANNIBALISTIC_STAKATO_LDR_CLAW, # Cannibalistic Stakato Chief
    25669 => CANNIBALISTIC_STAKATO_LDR_CLAW, # Cannibalistic Stakato Chief
    25670 => CANNIBALISTIC_STAKATO_LDR_CLAW, # Cannibalistic Stakato Chief
    25701 => ANAIS_SCROLL,                   # Anais - Master of Splendor
  }

  def initialize
    super(902, self.class.simple_name, "Reclaim Our Era")

    add_start_npc(MATHIAS)
    add_talk_id(MATHIAS)
    add_kill_id(MONSTER_DROPS.keys)
    register_quest_items(
      SHATTERED_BONES, CANNIBALISTIC_STAKATO_LDR_CLAW, ANAIS_SCROLL
    )
  end

  private def give_item(npc, pc)
    st = get_quest_state(pc, false)
    if st && (st.started? && !st.cond?(5))
      if Util.in_range?(1500, npc, pc, false)
        st.give_items(MONSTER_DROPS[npc.id], 1)
        st.set_cond(5, true)
      end
    end
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    unless st = get_quest_state(pc, false)
      return
    end

    case event
    when "31340-04.htm"
      if st.created?
        html = event
      end
    when "31340-05.html"
      if st.created?
        st.start_quest
        html = event
      end
    when "31340-06.html"
      if st.cond?(1)
        st.set_cond(2, true)
        html = event
      end
    when "31340-07.html"
      if st.cond?(1)
        st.set_cond(3, true)
        html = event
      end
    when "31340-08.html"
      if st.cond?(1)
        st.set_cond(4, true)
        html = event
      end
    when "31340-10.html"
      if st.cond?(1)
        html = event
      end
    else
      # [automatically added else]
    end


    html
  end

  def on_kill(npc, killer, is_summon)
    if party = killer.party
      party.members.each do |m|
        give_item(npc, m)
      end
    else
      give_item(npc, killer)
    end

    super
  end

  def on_talk(npc, pc)
    st = get_quest_state!(pc)

    case st.state
    when State::COMPLETED
      unless st.now_available?
        html = "31340-02.htm"
      end
      st.state = State::CREATED
    when State::CREATED
      html = pc.level >= MIN_LVL ? "31340-01.htm" : "31340-03.htm"
    when State::STARTED
      case st.cond
      when 1
        html = "31340-09.html"
      when 2
        html = "31340-11.html"
      when 3
        html = "31340-12.html"
      when 4
        html = "31340-13.html"
      when 5
        if st.has_quest_items?(SHATTERED_BONES)
          st.give_items(PROOF_OF_CHALLENGE, 1)
          st.give_adena(134038, true)
        elsif st.has_quest_items?(CANNIBALISTIC_STAKATO_LDR_CLAW)
          st.give_items(PROOF_OF_CHALLENGE, 3)
          st.give_adena(210119, true)
        elsif st.has_quest_items?(ANAIS_SCROLL)
          st.give_items(PROOF_OF_CHALLENGE, 3)
          st.give_adena(348155, true)
        end
        st.exit_quest(QuestType::DAILY, true)
        html = "31340-14.html"
      else
        # [automatically added else]
      end

    else
      # [automatically added else]
    end


    html || get_no_quest_msg(pc)
  end
end
