class Scripts::Q00329_CuriosityOfADwarf < Quest
  # NPC
  private TRADER_ROLENTO = 30437
  # Items
  private GOLEM_HEARTSTONE = 1346
  private BROKEN_HEARTSTONE = 1365
  # Misc
  private MIN_LEVEL = 33
  # Monsters
  private MONSTER_DROPS = {
    20083 => { # Granitic Golem
      ItemHolder.new(GOLEM_HEARTSTONE, 3),
      ItemHolder.new(BROKEN_HEARTSTONE, 54)
    },
    20085 => { # Puncher
      ItemHolder.new(GOLEM_HEARTSTONE, 3),
      ItemHolder.new(BROKEN_HEARTSTONE, 58)
    }
  }

  def initialize
    super(329, self.class.simple_name, "Curiosity Of A Dwarf")

    add_start_npc(TRADER_ROLENTO)
    add_talk_id(TRADER_ROLENTO)
    add_kill_id(MONSTER_DROPS.keys)
    register_quest_items(GOLEM_HEARTSTONE, BROKEN_HEARTSTONE)
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    unless st = get_quest_state(pc, false)
      return
    end

    case event
    when "30437-03.htm"
      if st.created?
        st.start_quest
        html = event
      end
    when "30437-06.html"
      st.exit_quest(true, true)
      html = event
    when "30437-07.html"
      html = event
    else
      # [automatically added else]
    end


    html
  end

  def on_kill(npc, killer, is_summon)
    st = get_quest_state(killer, false)
    if st && Util.in_range?(1500, npc, killer, true)
      rnd = Rnd.rand(100)
      MONSTER_DROPS[npc.id].each do |drop|
        if rnd < drop.count
          st.give_item_randomly(npc, drop.id, 1, 0, 1.0, true)
          break
        end
      end
    end

    super
  end

  def on_talk(npc, pc)
    st = get_quest_state!(pc)

    case st.state
    when State::CREATED
      html = pc.level >= MIN_LEVEL ? "30437-02.htm" : "30437-01.htm"
    when State::STARTED
      if has_at_least_one_quest_item?(pc, registered_item_ids)
        broken = st.get_quest_items_count(BROKEN_HEARTSTONE)
        golem = st.get_quest_items_count(GOLEM_HEARTSTONE)
        adena = (broken * 50) + (golem * 1000)
        if broken + golem >= 10
          adena += 1183
        end
        st.give_adena(adena, true)
        take_items(pc, -1, registered_item_ids)
        html = "30437-05.html"
      else
        html = "30437-04.html"
      end
    else
      # [automatically added else]
    end


    html || get_no_quest_msg(pc)
  end
end
