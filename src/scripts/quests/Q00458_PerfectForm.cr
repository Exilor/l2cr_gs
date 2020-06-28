class Scripts::Q00458_PerfectForm < Quest
  # NPCs
  private KELLEYIA = 32768
  # Monsters
  # Level 4 (full grown) feedable beasts
  private KOOKABURRAS = {
    18878,
    18879
  }
  private COUGARS = {
    18885,
    18886
  }
  private BUFFALOS = {
    18892,
    18893
  }
  private GRENDELS = {
    18899,
    18900
  }

  # Rewards
  # 60% Icarus weapon recipes (except kamael weapons)
  private ICARUS_WEAPON_RECIPES = {
    10373, 10374, 10375, 10376, 10377, 10378, 10379, 10380, 10381
  }

  private ICARUS_WEAPON_PIECES = {
    10397, 10398, 10399, 10400, 10401, 10402, 10403, 10404, 10405
  }

  def initialize
    super(458, self.class.simple_name, "Perfect Form")

    add_start_npc(KELLEYIA)
    add_talk_id(KELLEYIA)
    add_kill_id(KOOKABURRAS)
    add_kill_id(COUGARS)
    add_kill_id(BUFFALOS)
    add_kill_id(GRENDELS)
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    no_quest = get_no_quest_msg(pc)
    unless st = get_quest_state(pc, false)
      return no_quest
    end

    html = event
    overhits = 0
    overhit_html = false

    case event
    when "32768-10.htm"
      st.start_quest
    when "results1"
      if st.cond?(2)
        overhits_total = st.get_int("overhitsTotal")
        if overhits_total >= 35
          html = "32768-14a.html"
        elsif overhits_total >= 10
          html = "32768-14b.html"
        else
          html = "32768-14c.html"
        end
        overhits = overhits_total
        overhit_html = true
      else
        html = no_quest
      end
    when "results2"
      if st.cond?(2)
        overhits_critical = st.get_int("overhitsCritical")
        if overhits_critical >= 30
          html = "32768-15a.html"
        elsif overhits_critical >= 5
          html = "32768-15b.html"
        else
          html = "32768-15c.html"
        end
        overhits = overhits_critical
        overhit_html = true
      else
        html = no_quest
      end
    when "results3"
      if st.cond?(2)
        overhits_consecutive = st.get_int("overhitsConsecutive")
        if overhits_consecutive >= 20
          html = "32768-16a.html"
        elsif overhits_consecutive >= 7
          html = "32768-16b.html"
        else
          html = "32768-16c.html"
        end
        overhits = overhits_consecutive
        overhit_html = true
      else
        html = no_quest
      end
    when "32768-17.html"
      if st.cond?(2)
        overhits_consecutive = st.get_int("overhitsConsecutive")
        if overhits_consecutive >= 20
          st.reward_items(ICARUS_WEAPON_RECIPES.sample(random: Rnd), 1)
        elsif overhits_consecutive >= 7
          st.reward_items(ICARUS_WEAPON_PIECES.sample(random: Rnd), 5)
        else
          st.reward_items(ICARUS_WEAPON_PIECES.sample(random: Rnd), 2)
          # not sure if this should use rewardItems
          st.give_items(15482, 10) # Golden Spice Crate
          st.give_items(15483, 10) # Crystal Spice Crate
        end
        st.exit_quest(QuestType::DAILY, true)
      else
        html = no_quest
      end
    end


    if overhit_html
      html = get_htm(pc, html)
      html = html.sub("<?number?>", overhits.to_s)
    end

    html
  end

  def on_kill(npc, pc, is_summon)
    st = get_quest_state(pc, false)
    if st && st.cond?(1)
      npc_id = npc.id
      if npc_id == KOOKABURRAS[0] || npc_id == COUGARS[0] || npc_id == BUFFALOS[0] || npc_id == GRENDELS[0]
        npc_id += 1
      end

      variable = npc_id.to_s # i3
      current_val = st.get_int(variable)
      if current_val < 10
        st.set(variable, (current_val + 1).to_s) # IncreaseNPCLogByID

        mob = npc.as(L2Attackable)
        if mob.overhit?
          st.set("overhitsTotal", (st.get_int("overhitsTotal") + 1).to_s) # memo_stateEx 1
          max_hp = mob.max_hp
          # L2Attackable#calculateOverhitExp way of calculating overhit % seems illogical
          overhit_percentage = (max_hp + mob.overhit_damage) // max_hp
          if overhit_percentage >= 1.2
            st.set("overhitsCritical", (st.get_int("overhitsCritical") + 1).to_s) # memo_stateEx 2
          end
          overhits_consecutive = st.get_int("overhitsConsecutive") + 1
          st.set("overhitsConsecutive", overhits_consecutive.to_s) # memo_stateEx 3
          # /*
          #  * Retail logic (makes for a long/messy string in database): i0 = overhits_consecutive % 100; i1 = overhitsConsecutive - (i0 * 100); if i0 < i1) { st.set("overhitsConsecutive", String.valueOf((i1 * 100) + i1)); }
          #  */
        else
          # st.set("overhitsConsecutive", String.valueOf((st.get_int("overhitsConsecutive") % 100) * 100))
          if st.get_int("overhitsConsecutive") > 0
            # avoid writing to database if variable is already zero
            st.set("overhitsConsecutive", "0")
          end
        end

        if st.get_int("18879") == 10 && st.get_int("18886") == 10 && st.get_int("18893") == 10 && st.get_int("18900") == 10
          st.set_cond(2, true)
          # st.set("overhitsConsecutive", String.valueOf(st.get_int("overhitsConsecutive") % 100))
        else
          st.play_sound(Sound::ITEMSOUND_QUEST_ITEMGET)
        end

        log = ExQuestNpcLogList.new(id)
        log.add_npc(18879, st.get_int("18879"))
        log.add_npc(18886, st.get_int("18886"))
        log.add_npc(18893, st.get_int("18893"))
        log.add_npc(18900, st.get_int("18900"))

        pc.send_packet(log)
      end
    end

    super
  end

  def on_talk(npc, pc)
    st = get_quest_state!(pc)
    case st.state
    when State::COMPLETED
      unless st.now_available?
        html = "32768-18.htm"
      end
      st.state = State::CREATED
      html = pc.level > 81 ? "32768-01.htm" : "32768-00.htm"
    when State::CREATED
      html = pc.level > 81 ? "32768-01.htm" : "32768-00.htm"
    when State::STARTED
      case st.cond
      when 1
        if st.get_int("18879") == 0 && st.get_int("18886") == 0 && st.get_int("18893") == 0 && st.get_int("18900") == 0
          html = "32768-11.html"
        else
          html = "32768-12.html"
        end
      when 2
        html = "32768-13.html"
      end

    end


    html || get_no_quest_msg(pc)
  end
end
