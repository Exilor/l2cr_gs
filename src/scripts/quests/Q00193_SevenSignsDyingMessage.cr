class Quests::Q00193_SevenSignsDyingMessage < Quest
  # NPCs
  private SHILENS_EVIL_THOUGHTS = 27343
  private HOLLINT = 30191
  private SIR_GUSTAV_ATHEBALDT = 30760
  private CAIN = 32569
  private ERIC = 32570
  # Items
  private JACOBS_NECKLACE = 13814
  private DEADMANS_HERB = 13816
  private SCULPTURE_OF_DOUBT = 14353
  # Misc
  private MIN_LEVEL = 79
  # Skill
  private NPC_HEAL = SkillHolder.new(4065, 8)

  @busy = false

  def initialize
    super(193, self.class.simple_name, "Seven Signs, Dying Message")

    add_start_npc(HOLLINT)
    add_talk_id(HOLLINT, CAIN, ERIC, SIR_GUSTAV_ATHEBALDT)
    add_kill_id(SHILENS_EVIL_THOUGHTS)
    register_quest_items(JACOBS_NECKLACE, DEADMANS_HERB, SCULPTURE_OF_DOUBT)
  end

  def on_adv_event(event, npc, player)
    npc = npc.not_nil!
    if npc.id == SHILENS_EVIL_THOUGHTS && event == "despawn"
      unless npc.alive?
        @busy = false
        npc.broadcast_packet(NpcSay.new(npc.l2id, Say2::NPC_ALL, npc.id, NpcString::NEXT_TIME_YOU_WILL_NOT_ESCAPE))
        npc.delete_me
      end

      return super
    end

    player = player.not_nil!

    unless st = get_quest_state(player, false)
      return
    end

    case event
    when "30191-02.html"
      st.give_items(JACOBS_NECKLACE, 1)
      st.start_quest
      htmltext = event
    when "32569-02.html", "32569-03.html", "32569-04.html"
      if st.cond?(1) && st.has_quest_items?(JACOBS_NECKLACE)
        htmltext = event
      end
    when "32569-05.html"
      if st.cond?(1) && st.has_quest_items?(JACOBS_NECKLACE)
        st.take_items(JACOBS_NECKLACE, -1)
        st.set_cond(2, true)
        htmltext = event
      end
    when "showmovie"
      if st.cond?(3) && st.has_quest_items?(DEADMANS_HERB)
        st.take_items(DEADMANS_HERB, -1)
        st.set_cond(4, true)
        player.show_quest_movie(9)
        return ""
      end
    when "32569-10.html", "32569-11.html"
      if st.cond?(5) && st.has_quest_items?(SCULPTURE_OF_DOUBT)
        htmltext = event
      end
    when "32569-12.html"
      if st.cond?(5) && st.has_quest_items?(SCULPTURE_OF_DOUBT)
        st.take_items(SCULPTURE_OF_DOUBT, -1)
        st.set_cond(6, true)
        htmltext = event
      end
    when "32570-02.html"
      if st.cond?(2)
        st.give_items(DEADMANS_HERB, 1)
        st.set_cond(3, true)
        htmltext = event
      end
    when "fight"
      htmltext = "32569-14.html"
      if st.cond?(4)
        @busy = true
        ns = NpcSay.new(npc.l2id, Say2::NPC_ALL, npc.id, NpcString::S1_THAT_STRANGER_MUST_BE_DEFEATED_HERE_IS_THE_ULTIMATE_HELP)
        ns.add_string_parameter(player.name)
        npc.broadcast_packet(ns)
        start_quest_timer("heal", 30000 - rand(20000), npc, player)
        monster = add_spawn(SHILENS_EVIL_THOUGHTS, 82425, 47232, -3216, 0, false, 0, false).as(L2MonsterInstance)
        monster.broadcast_packet(NpcSay.new(monster.l2id, Say2::NPC_ALL, monster.id, NpcString::YOU_ARE_NOT_THE_OWNER_OF_THAT_ITEM))
        monster.set_running
        monster.add_damage_hate(player, 0, 999i64)
        monster.set_intention(AI::ATTACK, player)
        start_quest_timer("despawn", 300000, monster, nil)
      end
    when "heal"
      if !npc.inside_radius?(player, 600, true, false)
        ns = NpcSay.new(npc.l2id, Say2::NPC_ALL, npc.id, NpcString::LOOK_HERE_S1_DONT_FALL_TOO_FAR_BEHIND)
        ns.add_string_parameter(player.name)
        npc.broadcast_packet(ns)
      elsif player.alive?
        npc.target = player
        npc.do_cast(NPC_HEAL)
      end
      start_quest_timer("heal", 30000 - rand(20000), npc, player)
    when "reward"
      if st.cond?(6)
        if player.level >= MIN_LEVEL
          st.add_exp_and_sp(52518015, 5817677)
          st.exit_quest(false, true)
          htmltext = "30760-02.html"
        else
          htmltext = "level_check.html"
        end
      end
    end

    htmltext
  end

  def on_kill(npc, player, is_summon)
    unless member = get_random_party_member(player, 4)
      return
    end

    st = get_quest_state(member, false).not_nil!
    if npc.inside_radius?(member, 1500, true, false)
      st.give_items(SCULPTURE_OF_DOUBT, 1)
      st.play_sound(Sound::ITEMSOUND_QUEST_FINISH)
      st.set_cond(5)
    end

    @busy = false
    cancel_quest_timers("despawn")
    cancel_quest_timers("heal")
    npc.broadcast_packet(NpcSay.new(npc.l2id, Say2::NPC_ALL, npc.id, NpcString::S1_YOU_MAY_HAVE_WON_THIS_TIME_BUT_NEXT_TIME_I_WILL_SURELY_CAPTURE_YOU).add_string_parameter(member.name))

    super
  end

  def on_talk(npc, player)
    st = get_quest_state!(player)

    case st.state
    when State::COMPLETED
      htmltext = get_already_completed_msg(player)
    when State::CREATED
      if npc.id == HOLLINT
        if player.level >= MIN_LEVEL && player.quest_completed?(Q00192_SevenSignsSeriesOfDoubt.simple_name)
          htmltext = "30191-01.htm"
        else
          htmltext = "30191-03.html"
        end
      end
    when State::STARTED
      case npc.id
      when HOLLINT
        if st.cond?(1) && st.has_quest_items?(JACOBS_NECKLACE)
          htmltext = "30191-04.html"
        end
      when CAIN
        case st.cond
        when 1
          if st.has_quest_items?(JACOBS_NECKLACE)
            htmltext = "32569-01.html"
          end
        when 2
          htmltext = "32569-06.html"
        when 3
          if st.has_quest_items?(DEADMANS_HERB)
            htmltext = "32569-07.html"
          end
        when 4
          if @busy
            htmltext = "32569-13.html"
          else
            htmltext = "32569-08.html"
          end
        when 5
          if st.has_quest_items?(SCULPTURE_OF_DOUBT)
            htmltext = "32569-09.html"
          end
        end
      when ERIC
        case st.cond
        when 2
          htmltext = "32570-01.html"
        when 3
          htmltext = "32570-03.html"
        end
      when SIR_GUSTAV_ATHEBALDT
        if st.cond?(6)
          htmltext = "30760-01.html"
        end
      end
    end

    htmltext || get_no_quest_msg(player)
  end
end
