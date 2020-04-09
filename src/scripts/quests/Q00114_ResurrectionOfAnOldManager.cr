class Scripts::Q00114_ResurrectionOfAnOldManager < Quest
  # NPCs
  private NEWYEAR = 31961
  private YUMI = 32041
  private STONES = 32046
  private WENDY = 32047
  private BOX = 32050
  # Items
  private STARSTONE = 8287
  private LETTER = 8288
  private STARSTONE2 = 8289
  private DETECTOR = 8090
  private DETECTOR2 = 8091
  # Monster
  private GUARDIAN = 27318

  @golem : L2Attackable?

  def initialize
    super(114, self.class.simple_name, "Resurrection of an Old Manager")

    add_start_npc(YUMI)
    add_talk_id(YUMI, WENDY, BOX, STONES, NEWYEAR)
    add_kill_id(GUARDIAN)
    add_see_creature_id(STONES)
    register_quest_items(STARSTONE, STARSTONE2, DETECTOR, DETECTOR2, LETTER)
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    unless st = get_quest_state(pc, false)
      return
    end

    html = event
    case event
    # Yumi
    when "32041-04.htm"
      st.start_quest
    when "32041-08.html"
      st.set("talk", "1")
    when "32041-09.html"
      st.set_cond(2, true)
      st.unset("talk")
    when "32041-12.html"
      case st.cond
      when 3
        html = "32041-12.html"
      when 4
        html = "32041-13.html"
      when 5
        html = "32041-14.html"
      else
        # [automatically added else]
      end

    when "32041-15.html"
      st.set("talk", "1")
    when "32041-23.html"
      st.set("talk", "2")
    when "32041-26.html"
      st.set_cond(6, true)
      st.unset("talk")
    when "32041-31.html"
      st.give_items(DETECTOR, 1)
      st.set_cond(17, true)
    when "32041-34.html"
      st.set("talk", "1")
      st.take_items(DETECTOR2, 1)
    when "32041-38.html"
      if st.get_int("choice") == 2
        html = "32041-37.html"
      end
    when "32041-39.html"
      st.unset("talk")
      st.set_cond(20, true)
    when "32041-40.html"
      st.set_cond(21, true)
      st.unset("talk")
      st.give_items(LETTER, 1)
    # Suspicious-Looking Pile of Stones
    when "32046-03.html"
      st.set_cond(19, true)
    when "32046-07.html"
      st.add_exp_and_sp(1846611, 144270)
      st.exit_quest(false, true)
    # Wendy
    when "32047-02.html"
      if st.get_int("talk") == 0
        st.set("talk", "1")
      end
    when "32047-03.html"
      if st.get_int("talk1") == 0
        st.set("talk1", "1")
      end
    when "32047-05.html"
      if st.get_int("talk") == 0 || st.get_int("talk1") == 0
        html = "32047-04.html"
      end
    when "32047-06.html"
      st.set("choice", "1")
      st.set_cond(3, true)
      st.unset("talk1")
      st.unset("talk")
    when "32047-07.html"
      st.set("choice", "2")
      st.set_cond(4, true)
      st.unset("talk1")
      st.unset("talk")
    when "32047-09.html"
      st.set("choice", "3")
      st.set_cond(5, true)
      st.unset("talk1")
      st.unset("talk")
    when "32047-14ab.html"
      st.set("choice", "3")
      st.set_cond(7, true)
    when "32047-14b.html"
      st.set_cond(10, true)
    when "32047-15b.html"
      golem = @golem
      if golem.nil? || (golem && golem.dead?)
        golem = add_spawn(GUARDIAN, 96977, -110625, -3280, 0, false, 0).as(L2Attackable)
        @golem = golem
        golem.broadcast_packet(NpcSay.new(golem.l2id, Say2::NPC_ALL, golem.id, NpcString::YOU_S1_YOU_ATTACKED_WENDY_PREPARE_TO_DIE).add_string_parameter(pc.name))
        golem.set_running
        golem.add_damage_hate(pc, 0, 999)
        golem.set_intention(AI::ATTACK, pc)
        st.set("spawned", "1")
        start_quest_timer("golem_despawn", 300000, nil, pc)
      elsif st.get_int("spawned") == 1
        html = "32047-17b.html"
      else
        html = "32047-16b.html"
      end
    when "32047-20a.html"
      st.set_cond(8, true)
    when "32047-20b.html"
      st.set_cond(12, true)
    when "32047-20c.html"
      st.set_cond(13, true)
    when "32047-21a.html"
      st.set_cond(9, true)
    when "32047-23a.html"
      st.set_cond(23, true)
    when "32047-23c.html"
      st.take_items(STARSTONE, 1)
      st.set_cond(15, true)
    when "32047-29c.html"
      if pc.adena >= 3000
        st.give_items(STARSTONE2, 1)
        st.take_items(Inventory::ADENA_ID, 3000)
        st.unset("talk")
        st.set_cond(26, true)
      else
        html = "32047-29ca.html"
      end
    when "32047-30c.html"
      st.set("talk", "1")
    # Box
    when "32050-01r.html"
      st.set("talk", "1")
    when "32050-03.html"
      st.give_items(STARSTONE, 1)
      st.set_cond(14, true)
      st.unset("talk")
    when "32050-05.html"
      st.set_cond(24, true)
      st.give_items(STARSTONE2, 1)
    # Newyear
    when "31961-02.html"
      st.take_items(LETTER, 1)
      st.give_items(STARSTONE2, 1)
      st.set_cond(22, true)
    # Quest timer
    when "golem_despawn"
      st.unset("spawned")
      golem = @golem.not_nil!
      golem.broadcast_packet(NpcSay.new(golem.l2id, Say2::NPC_ALL, golem.id, NpcString::S1_YOUR_ENEMY_WAS_DRIVEN_OUT_I_WILL_NOW_WITHDRAW_AND_AWAIT_YOUR_NEXT_COMMAND).add_string_parameter(pc.name))
      golem.delete_me
      @golem = nil
      html = nil
    # HTMLs
    when "32041-05.html", "32041-06.html", "32041-07.html", "32041-17.html",
         "32041-18.html", "32041-19.html", "32041-20.html", "32041-21.html",
         "32041-22.html", "32041-25.html", "32041-29.html", "32041-30.html",
         "32041-35.html", "32041-36.html", "32046-05.html", "32046-06.html",
         "32047-06a.html", "32047-12a.html", "32047-12b.html",
         "32047-12c.html", "32047-13a.html", "32047-14a.html",
         "32047-13b.html", "32047-13c.html", "32047-14c.html",
         "32047-15c.html", "32047-17c.html", "32047-13ab.html",
         "32047-15a.html", "32047-16a.html", "32047-16c.html",
         "32047-18a.html", "32047-19a.html", "32047-18ab.html",
         "32047-19ab.html", "32047-18c.html", "32047-17a.html",
         "32047-19c.html", "32047-21b.html", "32047-27c.html",
         "32047-28c.html"
      # do nothing
    else
      html = nil
    end

    html
  end

  def on_kill(npc, pc, is_summon)
    st = get_quest_state(pc, false)

    if st && st.cond?(10) && st.get_int("spawned") == 1
      npc.broadcast_packet(NpcSay.new(npc.l2id, Say2::NPC_ALL, npc.id, NpcString::THIS_ENEMY_IS_FAR_TOO_POWERFUL_FOR_ME_TO_FIGHT_I_MUST_WITHDRAW))
      st.set_cond(11, true)
      st.unset("spawned")
      cancel_quest_timers("golem_despawn")
    end

    super
  end

  def on_see_creature(npc, creature, is_summon)
    if creature.is_a?(L2PcInstance)
      st = get_quest_state(creature, false)
      if st && st.cond?(17)
        st.take_items(DETECTOR, 1)
        st.give_items(DETECTOR2, 1)
        st.set_cond(18, true)
        show_on_screen_msg(creature, NpcString::THE_RADIO_SIGNAL_DETECTOR_IS_RESPONDING_A_SUSPICIOUS_PILE_OF_STONES_CATCHES_YOUR_EYE, 2, 4500)
      end
    end

    super
  end

  def on_talk(npc, pc)
    st = get_quest_state!(pc)
    talk = st.get_int("talk")

    case npc.id
    when YUMI
      case st.state
      when State::CREATED
        if pc.quest_completed?(Q00121_PavelTheGiant.simple_name)
          html = pc.level >= 70 ? "32041-02.htm" : "32041-03.htm"
        else
          html = "32041-01.htm"
        end
      when State::STARTED
        case st.cond
        when 1
          html = talk == 1 ? "32041-08.html" : "32041-04.htm"
        when 2
          html = "32041-10.html"
        when 3..5
          case talk
          when 0
            html = "32041-11.html"
          when 1
            html = "32041-16.html"
          when 2
            html = "32041-24.html"
          else
            # [automatically added else]
          end

        when 6..8, 10, 11, 13..15
          html = "32041-27.html"
        when 9, 12, 16
          html = "32041-28.html"
        when 17, 18
          html = "32041-32.html"
        when 19
          html = talk == 1 ? "32041-34z.html" : "32041-33.html"
        when 20
          html = "32041-39z.html"
        when 21
          html = "32041-40z.html"
        when 22, 25, 26
          st.set_cond(27, true)
          html = "32041-41.html"
        when 27
          html = "32041-42.html"
        else
          # [automatically added else]
        end

      when State::COMPLETED
        html = get_already_completed_msg(pc)
      else
        # [automatically added else]
      end

    when WENDY
      if st.started?
        case st.cond
        when 2
          if talk == 1 && st.get_int("talk1") == 1
            html = "32047-05.html"
          else
            html = "32047-01.html"
          end
        when 3
          html = "32047-06b.html"
        when 4
          html = "32047-08.html"
        when 5
          html = "32047-10.html"
        when 6
          case st.get_int("choice")
          when 1
            html = "32047-11a.html"
          when 2
            html = "32047-11b.html"
          when 3
            html = "32047-11c.html"
          else
            # [automatically added else]
          end

        when 7
          html = "32047-11c.html"
        when 8
          html = "32047-17a.html"
        when 9, 12, 16
          html = "32047-25c.html"
        when 10
          html = "32047-18b.html"
        when 11
          html = "32047-19b.html"
        when 13
          html = "32047-21c.html"
        when 14
          html = "32047-22c.html"
        when 15
          st.set_cond(16, true)
          html = "32047-24c.html"
        when 20
          if st.get_int("choice") == 1
            html = "32047-22a.html"
          else
            html = talk == 1 ? "32047-31c.html" : "32047-26c.html"
          end
        when 23
          html = "32047-23z.html"
        when 24
          st.set_cond(25, true)
          html = "32047-24a.html"
        when 25
          html = "32047-24a.html"
        when 26
          html = "32047-32c.html"
        else
          # [automatically added else]
        end

      end
    when NEWYEAR
      if st.started?
        case st.cond
        when 21
          html = "31961-01.html"
        when 22
          html = "31961-03.html"
        else
          # [automatically added else]
        end

      end
    when BOX
      if st.started?
        case st.cond
        when 13
          html = talk == 1 ? "32050-02.html" : "32050-01.html"
        when 14
          html = "32050-04.html"
        when 23
          html = "32050-04b.html"
        when 24
          html = "32050-05z.html"
        else
          # [automatically added else]
        end

      end
    when STONES
      if st.started?
        case st.cond
        when 18
          html = "32046-02.html"
        when 19
          html = "32046-03.html"
        when 27
          html = "32046-04.html"
        else
          # [automatically added else]
        end

      end
    else
      # [automatically added else]
    end


    html || get_no_quest_msg(pc)
  end
end
