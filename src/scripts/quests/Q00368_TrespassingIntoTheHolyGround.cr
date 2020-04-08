class Scripts::Q00368_TrespassingIntoTheHolyGround < Quest
  # NPC
  private RESTINA = 30926
  # Item
  private BLADE_STAKATO_FANG = 5881
  # Misc
  private MIN_LEVEL = 36
  # Mobs
  private MOBS = {
    20794 => 0.60, # blade_stakato
    20795 => 0.57, # blade_stakato_worker
    20796 => 0.61, # blade_stakato_soldier
    20797 => 0.93  # blade_stakato_drone
  }

  def initialize
    super(368, self.class.simple_name, "Trespassing into the Holy Ground")

    add_start_npc(RESTINA)
    add_talk_id(RESTINA)
    add_kill_id(MOBS.keys)
    register_quest_items(BLADE_STAKATO_FANG)
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    unless st = get_quest_state(pc, false)
      return
    end

    case event
    when "30926-02.htm"
      st.start_quest
      event
    when "30926-05.html"
      st.exit_quest(true, true)
      event
    when "30926-06.html"
      event
    else
      # automatically added
    end

  end

  def on_kill(npc, pc, is_summon)
    case npc.id
    when 20795, 20797
      i = 1
    else
      i = 3
    end

    if st = get_random_party_member_state(pc, -1, i, npc)
      st.give_item_randomly(npc, BLADE_STAKATO_FANG, 1, 0, MOBS[npc.id], true)
    end

    super
  end

  def on_talk(npc, pc)
    st = get_quest_state!(pc)

    if st.created?
      html = pc.level >= MIN_LEVEL ? "30926-01.htm" : "30926-03.html"
    elsif st.started?
      if has_quest_items?(pc, BLADE_STAKATO_FANG)
        count = get_quest_items_count(pc, BLADE_STAKATO_FANG)
        bonus = count >= 10 ? 9450 : 2000
        give_adena(pc, (count * 250) + bonus, true)
        take_items(pc, BLADE_STAKATO_FANG, -1)
        html = "30926-04.html"
      else
        html = "30926-07.html"
      end
    end

    html || get_no_quest_msg(pc)
  end
end