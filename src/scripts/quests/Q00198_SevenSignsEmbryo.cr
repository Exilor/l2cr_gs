class Scripts::Q00198_SevenSignsEmbryo < Quest
  # NPCs
  private SHILENS_EVIL_THOUGHTS = 27346
  private WOOD = 32593
  private FRANZ = 32597
  # Items
  private SCULPTURE_OF_DOUBT = 14355
  private DAWNS_BRACELET = 15312
  # Misc
  private MIN_LEVEL = 79
  # Skill
  private NPC_HEAL = SkillHolder.new(4065, 8)

  @busy = false

  def initialize
    super(198, self.class.simple_name, "Seven Signs, Embryo")

    add_start_npc(WOOD)
    add_talk_id(WOOD, FRANZ)
    add_kill_id(SHILENS_EVIL_THOUGHTS)
    register_quest_items(SCULPTURE_OF_DOUBT)
  end

  def on_adv_event(event, npc, pc)
    npc = npc.not_nil!

    if npc.id == SHILENS_EVIL_THOUGHTS && event == "despawn"
      if npc.alive?
        @busy = false
        npc.broadcast_packet(NpcSay.new(npc.l2id, Say2::NPC_ALL, npc.id, NpcString::NEXT_TIME_YOU_WILL_NOT_ESCAPE))
        npc.delete_me
      end

      return super
    end

    return unless pc
    unless st = get_quest_state(pc, false)
      return
    end

    html = nil
    case event
    when "32593-02.html"
      st.start_quest
      html = event
    when "32597-02.html", "32597-03.html", "32597-04.html"
      if st.cond?(1)
        html = event
      end
    when "fight"
      html = "32597-05.html"
      if st.cond?(1)
        @busy = true
        ns = NpcSay.new(npc.l2id, Say2::NPC_ALL, npc.id, NpcString::S1_THAT_STRANGER_MUST_BE_DEFEATED_HERE_IS_THE_ULTIMATE_HELP)
        ns.add_string_parameter(pc.name)
        npc.broadcast_packet(ns)
        start_quest_timer("heal", 30000 - rand(20000), npc, pc)
        mob = add_spawn(SHILENS_EVIL_THOUGHTS, -23734, -9184, -5384, 0, false, 0, false, npc.instance_id).as(L2MonsterInstance)
        mob.broadcast_packet(NpcSay.new(mob.l2id, Say2::NPC_ALL, mob.id, NpcString::YOU_ARE_NOT_THE_OWNER_OF_THAT_ITEM))
        mob.set_running
        mob.add_damage_hate(pc, 0, 999)
        mob.set_intention(AI::ATTACK, pc)
        start_quest_timer("despawn", 300000, mob, nil)
      end
    when "heal"
      if !npc.inside_radius?(pc, 600, true, false)
        ns = NpcSay.new(npc.l2id, Say2::NPC_ALL, npc.id, NpcString::LOOK_HERE_S1_DONT_FALL_TOO_FAR_BEHIND)
        ns.add_string_parameter(pc.name)
        npc.broadcast_packet(ns)
      elsif pc.alive?
        npc.target = pc
        npc.do_cast(NPC_HEAL)
      end
      start_quest_timer("heal", 30000 - rand(20000), npc, pc)
    when "32597-08.html", "32597-09.html", "32597-10.html"
      if st.cond?(2) && st.has_quest_items?(SCULPTURE_OF_DOUBT)
        html = event
      end
    when "32597-11.html"
      if st.cond?(2) && st.has_quest_items?(SCULPTURE_OF_DOUBT)
        st.take_items(SCULPTURE_OF_DOUBT, -1)
        st.set_cond(3, true)
        html = event
        npc.broadcast_packet(NpcSay.new(npc.l2id, Say2::NPC_ALL, npc.id, NpcString::WE_WILL_BE_WITH_YOU_ALWAYS))
      end
    when "32617-02.html"
      html = event
    end

    html
  end

  def on_kill(npc, pc, is_summon)
    unless member = get_random_party_member(pc, 1)
      return
    end

    st = get_quest_state(member, false).not_nil!
    if npc.inside_radius?(member, 1500, true, false)
      st.give_items(SCULPTURE_OF_DOUBT, 1)
      st.set_cond(2, true)
    end

    @busy = false
    cancel_quest_timers("despawn")
    cancel_quest_timers("heal")
    ns = NpcSay.new(npc.l2id, Say2::NPC_ALL, npc.id, NpcString::S1_YOU_MAY_HAVE_WON_THIS_TIME_BUT_NEXT_TIME_I_WILL_SURELY_CAPTURE_YOU)
    ns.add_string_parameter(member.name)
    npc.broadcast_packet(ns)
    npc.delete_me
    member.show_quest_movie(14)

    super
  end

  def on_talk(npc, pc)
    st = get_quest_state!(pc)

    case st.state
    when State::COMPLETED
      html = get_already_completed_msg(pc)
    when State::CREATED
      if npc.id == WOOD
        if pc.level >= MIN_LEVEL && pc.quest_completed?(Q00197_SevenSignsTheSacredBookOfSeal.simple_name)
          html = "32593-01.htm"
        else
          html = "32593-03.html"
        end
      end
    when State::STARTED
      if npc.id == WOOD
        if st.cond > 0 && st.cond < 3
          html = "32593-04.html"
        elsif st.cond?(3)
          if pc.level >= MIN_LEVEL
            st.add_exp_and_sp(315108090, 34906059)
            st.give_items(DAWNS_BRACELET, 1)
            st.give_items(Inventory::ANCIENT_ADENA_ID, 1500000)
            st.exit_quest(false, true)
            html = "32593-05.html"
          else
            html = "level_check.html"
          end
        end
      elsif npc.id == FRANZ
        case st.cond
        when 1
          html = @busy ? "32597-06.html" : "32597-01.html"
        when 2
          if st.has_quest_items?(SCULPTURE_OF_DOUBT)
            html = "32597-07.html"
          end
        when 3
          html = "32597-12.html"
        end
      end
    end

    html || get_no_quest_msg(pc)
  end
end
