class Scripts::Q00610_MagicalPowerOfWaterPart2 < Quest
  # NPCs
  private ASEFA = 31372
  private VARKA_TOTEM = 31560
  # Monster
  private ASHUTAR = 25316
  # Items
  private GREEN_TOTEM = 7238
  private ASHUTAR_HEART = 7239
  # Misc
  private MIN_LEVEL = 75

  def initialize
    super(610, self.class.simple_name, "Magical Power of Water - Part 2")

    add_start_npc(ASEFA)
    add_talk_id(ASEFA, VARKA_TOTEM)
    add_kill_id(ASHUTAR)
    register_quest_items(GREEN_TOTEM, ASHUTAR_HEART)

    var = load_global_quest_var("Q00610_respawn")
    remain = var.empty? ? 0i64 : var.to_i64 - Time.ms
    if remain > 0
      start_quest_timer("spawn_npc", remain, nil, nil)
    else
      add_spawn(VARKA_TOTEM, 105452, -36775, -1050, 34000, false, 0, true)
    end
  end

  def action_for_each_player(pc, npc, is_summon)
    st = get_quest_state(pc, false)
    if st && Util.in_range?(1500, npc, pc, false)
      if npc.id == ASHUTAR
        case st.cond
        when 1
          st.take_items(GREEN_TOTEM, 1)
        when 2
          unless st.has_quest_items?(ASHUTAR_HEART)
            st.give_items(ASHUTAR_HEART, 1)
          end
          st.set_cond(3, true)
        end
      end
    end
  end

  def on_adv_event(event, npc, pc)
    if pc
      unless st = get_quest_state(pc, false)
        return
      end

      case event
      when "31372-02.html"
        st.start_quest
        html = event
      when "give_heart"
        if st.has_quest_items?(ASHUTAR_HEART)
          st.add_exp_and_sp(10000, 0)
          st.exit_quest(true, true)
          html = "31372-06.html"
        else
          html = "31372-07.html"
        end
      when "spawn_totem"
        if st.has_quest_items?(GREEN_TOTEM)
          html = spawn_ashutar(npc.not_nil!, st)
        else
          html = "31560-04.html"
        end
      end
    else
      if event == "despawn_ashutar"
        npc = npc.not_nil!
        npc.broadcast_packet(NpcSay.new(npc, Say2::NPC_ALL, NpcString::THE_POWER_OF_CONSTRAINT_IS_GETTING_WEAKER_YOUR_RITUAL_HAS_FAILED))
        npc.delete_me
        add_spawn(VARKA_TOTEM, 105452, -36775, -1050, 34000, false, 0, true)
      elsif event == "spawn_npc"
        add_spawn(VARKA_TOTEM, 105452, -36775, -1050, 34000, false, 0, true)
      end
    end

    html
  end

  def on_kill(npc, killer, is_summon)
    respawn_min_delay = (43200000 * Config.raid_min_respawn_multiplier).to_i
    respawn_max_delay = (129600000 * Config.raid_max_respawn_multiplier).to_i
    respawn_delay = rand(respawn_min_delay..respawn_max_delay)
    cancel_quest_timer("despawn_ashutar", npc, nil)
    save_global_quest_var("Q00610_respawn", (Time.ms + respawn_delay).to_s)
    start_quest_timer("spawn_npc", respawn_delay, nil, nil)
    execute_for_each_player(killer, npc, is_summon, true, false)

    super
  end

  def on_talk(npc, pc)
    st = get_quest_state!(pc)
    case npc.id
    when ASEFA
      case st.state
      when State::CREATED
        if pc.level >= MIN_LEVEL
          if st.has_quest_items?(GREEN_TOTEM)
            html = "31372-01.htm"
          else
            html = "31372-00a.html"
          end
        else
          html = "31372-00b.html"
        end
      when State::STARTED
        if st.cond?(1)
          html = "31372-03.html"
        else
          if st.has_quest_items?(ASHUTAR_HEART)
            html = "31372-04.html"
          else
            html = "31372-05.html"
          end
        end
      end
    when VARKA_TOTEM
      if st.started?
        case st.cond
        when 1
          html = "31560-01.html"
        when 2
          html = spawn_ashutar(npc, st)
        when 3
          html = "31560-05.html"
        end
      end
    end

    html || get_no_quest_msg(pc)
  end

  private def spawn_ashutar(npc : L2Npc, st : QuestState) : String
    if get_quest_timer("spawn_npc", nil, nil)
      return "31560-03.html"
    end

    if st.cond?(1)
      st.take_items(GREEN_TOTEM, 1)
      st.set_cond(2, true)
    end

    npc.delete_me
    ashutar = add_spawn(ASHUTAR, 104825, -36926, -1136, 0, false, 0)
    ashutar.broadcast_packet(NpcSay.new(ashutar, Say2::NPC_ALL, NpcString::THE_MAGICAL_POWER_OF_WATER_COMES_FROM_THE_POWER_OF_STORM_AND_HAIL_IF_YOU_DARE_TO_CONFRONT_IT_ONLY_DEATH_WILL_AWAIT_YOU))
    start_quest_timer("despawn_ashutar", 1200000, ashutar, nil)
    "31560-02.html"
  end
end
