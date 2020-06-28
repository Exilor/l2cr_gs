class Scripts::Q00616_MagicalPowerOfFirePart2 < Quest
  # NPCs
  private UDAN = 31379
  private KETRA_TOTEM = 31558
  # Monster
  private NASTRON = 25306
  # Items
  private RED_TOTEM = 7243
  private NASTRON_HEART = 7244
  # Misc
  private MIN_LEVEL = 75

  def initialize
    super(616, self.class.simple_name, "Magical Power of Fire - Part 2")

    add_start_npc(UDAN)
    add_talk_id(UDAN, KETRA_TOTEM)
    add_kill_id(NASTRON)
    register_quest_items(RED_TOTEM, NASTRON_HEART)

    var = load_global_quest_var("Q00616_respawn")
    remain = var.empty? ? 0i64 : var.to_i64 - Time.ms
    if remain > 0
      start_quest_timer("spawn_npc", remain, nil, nil)
    else
      add_spawn(KETRA_TOTEM, 142368, -82512, -6487, 58000, false, 0, true)
    end
  end

  def action_for_each_player(pc, npc, is_summon)
    st = get_quest_state(pc, false)
    if st && Util.in_range?(1500, npc, pc, false)
      if npc.id == NASTRON
        case st.cond
        when 1
          st.take_items(RED_TOTEM, 1)
        when 2
          unless st.has_quest_items?(NASTRON_HEART)
            st.give_items(NASTRON_HEART, 1)
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
      when "31379-02.html"
        st.start_quest
        html = event
      when "give_heart"
        if st.has_quest_items?(NASTRON_HEART)
          st.add_exp_and_sp(10000, 0)
          st.exit_quest(true, true)
          html = "31379-06.html"
        else
          html = "31379-07.html"
        end
      when "spawn_totem"
        if st.has_quest_items?(RED_TOTEM)
          html = spawn_nastron(npc.not_nil!, st)
        else
          html = "31558-04.html"
        end
      end

    else
      if event == "despawn_nastron"
        npc = npc.not_nil!
        npc.broadcast_packet(NpcSay.new(npc, Say2::NPC_ALL, NpcString::THE_POWER_OF_CONSTRAINT_IS_GETTING_WEAKER_YOUR_RITUAL_HAS_FAILED))
        npc.delete_me
        add_spawn(KETRA_TOTEM, 142368, -82512, -6487, 58000, false, 0, true)
      elsif event == "spawn_npc"
        add_spawn(KETRA_TOTEM, 142368, -82512, -6487, 58000, false, 0, true)
      end
    end

    html
  end

  def on_kill(npc, killer, is_summon)
    respawn_min_delay = (43200000i64 * Config.raid_min_respawn_multiplier).to_i64
    respawn_max_delay = (129600000i64 * Config.raid_max_respawn_multiplier).to_i64
    respawn_delay = Rnd.rand(respawn_min_delay..respawn_max_delay)
    cancel_quest_timer("despawn_nastron", npc, nil)
    save_global_quest_var("Q00616_respawn", (Time.ms + respawn_delay).to_s)
    start_quest_timer("spawn_npc", respawn_delay, nil, nil)
    execute_for_each_player(killer, npc, is_summon, true, false)

    super
  end

  def on_talk(npc, pc)
    st = get_quest_state!(pc)
    case npc.id
    when UDAN
      case st.state
      when State::CREATED
        if pc.level >= MIN_LEVEL
          if st.has_quest_items?(RED_TOTEM)
            html = "31379-01.htm"
          else
            html = "31379-00a.html"
          end
        else
          html = "31379-00b.html"
        end
      when State::STARTED
        if st.cond?(1)
          html = "31379-03.html"
        else
          if st.has_quest_items?(NASTRON_HEART)
            html = "31379-04.html"
          else
            html = "31379-05.html"
          end
        end
      end

    when KETRA_TOTEM
      if st.started?
        case st.cond
        when 1
          html = "31558-01.html"
        when 2
          html = spawn_nastron(npc, st)
        when 3
          html = "31558-05.html"
        end

      end
    end


    html || get_no_quest_msg(pc)
  end

  private def spawn_nastron(npc : L2Npc, st : QuestState)
    if get_quest_timer("spawn_npc", nil, nil)
      return "31558-03.html"
    end
    if st.cond?(1)
      st.take_items(RED_TOTEM, 1)
      st.set_cond(2, true)
    end
    npc.delete_me
    nastron = add_spawn(NASTRON, 142528, -82528, -6496, 0, false, 0)
    nastron.broadcast_packet(NpcSay.new(nastron, Say2::NPC_ALL, NpcString::THE_MAGICAL_POWER_OF_FIRE_IS_ALSO_THE_POWER_OF_FLAMES_AND_LAVA_IF_YOU_DARE_TO_CONFRONT_IT_ONLY_DEATH_WILL_AWAIT_YOU))
    start_quest_timer("despawn_nastron", 1200000, nastron, nil)
    "31558-02.html"
  end
end
