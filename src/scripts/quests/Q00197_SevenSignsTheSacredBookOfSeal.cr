class Scripts::Q00197_SevenSignsTheSacredBookOfSeal < Quest
  # NPCs
  private SHILENS_EVIL_THOUGHTS = 27396
  private ORVEN = 30857
  private WOOD = 32593
  private LEOPARD = 32594
  private LAWRENCE = 32595
  private SOPHIA = 32596
  # Items
  private MYSTERIOUS_HAND_WRITTEN_TEXT = 13829
  private SCULPTURE_OF_DOUBT = 14354
  # Misc
  private MIN_LEVEL = 79

  @busy = false

  def initialize
    super(197, self.class.simple_name, "Seven Signs, the Sacred Book of Seal")

    add_start_npc(WOOD)
    add_talk_id(WOOD, ORVEN, LEOPARD, LAWRENCE, SOPHIA)
    add_kill_id(SHILENS_EVIL_THOUGHTS)
    register_quest_items(MYSTERIOUS_HAND_WRITTEN_TEXT, SCULPTURE_OF_DOUBT)
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

    return unless pc && (st = get_quest_state(pc, false))

    case event
    when "32593-02.htm", "32593-03.htm"
      html = event
    when "32593-04.html"
      st.start_quest
      html = event
    when "32593-08.html"
      if st.cond?(6) && st.has_quest_items?(MYSTERIOUS_HAND_WRITTEN_TEXT, SCULPTURE_OF_DOUBT)
        html = event
      end
    when "32593-09.html"
      if st.cond?(6)
        if pc.level >= MIN_LEVEL
          st.add_exp_and_sp(52_518_015, 5_817_677)
          st.exit_quest(false, true)
          html = event
        else
          html = "level_check.html"
        end
      end
    when "30857-02.html", "30857-03.html"
      if st.cond?(1)
        html = event
      end
    when "30857-04.html"
      if st.cond?(1)
        st.set_cond(2, true)
        html = event
      end
    when "32594-02.html"
      if st.cond?(2)
        html = event
      end
    when "32594-03.html"
      if st.cond?(2)
        st.set_cond(3, true)
        html = event
      end
    when "32595-02.html", "32595-03.html"
      if st.cond?(3)
        html = event
      end
    when "32595-04.html"
      if st.cond?(3)
        @busy = true
        npc.broadcast_packet(NpcSay.new(npc.l2id, Say2::NPC_ALL, npc.id, NpcString::S1_THAT_STRANGER_MUST_BE_DEFEATED_HERE_IS_THE_ULTIMATE_HELP).add_string_parameter(pc.name))
        mob = add_spawn(SHILENS_EVIL_THOUGHTS, 152520, -57502, -3408, 0, false, 0, false).as(L2MonsterInstance)
        mob.broadcast_packet(NpcSay.new(mob.l2id, Say2::NPC_ALL, mob.id, NpcString::YOU_ARE_NOT_THE_OWNER_OF_THAT_ITEM))
        mob.set_running
        mob.add_damage_hate(pc, 0, 999)
        mob.set_intention(AI::ATTACK, pc)
        start_quest_timer("despawn", 300000, mob, nil)
      end
    when "32595-06.html", "32595-07.html", "32595-08.html"
      if st.cond?(4) && st.has_quest_items?(SCULPTURE_OF_DOUBT)
        html = event
      end
    when "32595-09.html"
      if st.cond?(4) && st.has_quest_items?(SCULPTURE_OF_DOUBT)
        st.set_cond(5, true)
        html = event
      end
    when "32596-02.html", "32596-03.html"
      if st.cond?(5) && st.has_quest_items?(SCULPTURE_OF_DOUBT)
        html = event
      end
    when "32596-04.html"
      if st.cond?(5) && st.has_quest_items?(SCULPTURE_OF_DOUBT)
        st.give_items(MYSTERIOUS_HAND_WRITTEN_TEXT, 1)
        st.set_cond(6, true)
        html = event
      end
    end

    html
  end

  def on_kill(npc, pc, is_summon)
    unless member = get_random_party_member(pc, 3)
      return
    end

    st = get_quest_state(member, false).not_nil!
    if npc.inside_radius?(member, 1500, true, false)
      st.give_items(SCULPTURE_OF_DOUBT, 1)
      st.play_sound(Sound::ITEMSOUND_QUEST_FINISH)
      st.set_cond(4)
    end

    @busy = false
    cancel_quest_timers("despawn")
    say = NpcSay.new(npc.l2id, Say2::NPC_ALL, npc.id, NpcString::S1_YOU_MAY_HAVE_WON_THIS_TIME_BUT_NEXT_TIME_I_WILL_SURELY_CAPTURE_YOU)
    say.add_string_parameter(member.name)
    npc.broadcast_packet(say)

    super
  end

  def on_talk(npc, pc)
    st = get_quest_state!(pc)

    case st.state
    when State::COMPLETED
      html = get_already_completed_msg(pc)
    when State::CREATED
      if npc.id == WOOD
        if pc.level >= MIN_LEVEL && pc.quest_completed?(Q00196_SevenSignsSealOfTheEmperor.simple_name)
          html = "32593-01.htm"
        else
          html = "32593-05.html"
        end
      end
    when State::STARTED
      case npc.id
      when WOOD
        if st.cond > 0 && st.cond < 6
          html = "32593-06.html"
        elsif st.cond?(6)
          if st.has_quest_items?(MYSTERIOUS_HAND_WRITTEN_TEXT, SCULPTURE_OF_DOUBT)
            html = "32593-07.html"
          end
        end
      when ORVEN
        if st.cond?(1)
          html = "30857-01.html"
        elsif st.cond >= 2
          html = "30857-05.html"
        end
      when LEOPARD
        if st.cond?(2)
          html = "32594-01.html"
        elsif st.cond >= 3
          html = "32594-04.html"
        end
      when LAWRENCE
        if st.cond?(3)
          if @busy
            html = "32595-05.html"
          else
            html = "32595-01.html"
          end
        elsif st.cond?(4)
          if st.has_quest_items?(SCULPTURE_OF_DOUBT)
            html = "32595-06.html"
          end
        elsif st.cond >= 5
          if st.has_quest_items?(SCULPTURE_OF_DOUBT)
            html = "32595-10.html"
          end
        end
      when SOPHIA
        if st.cond?(5)
          if st.has_quest_items?(SCULPTURE_OF_DOUBT)
            html = "32596-01.html"
          end
        elsif st.cond >= 6
          if st.has_quest_items?(SCULPTURE_OF_DOUBT, MYSTERIOUS_HAND_WRITTEN_TEXT)
            html = "32596-05.html"
          end
        end
      end
    end

    html || get_no_quest_msg(pc)
  end
end
