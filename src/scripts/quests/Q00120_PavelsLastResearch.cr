class Scripts::Q00120_PavelsLastResearch < Quest
  # NPCs
  private SUSPICIOUS_LOOKING_PILE_OF_STONES = 32046
  private WENDY = 32047
  private YUMI = 32041
  private WEATHERMASTER_1 = 32042
  private WEATHERMASTER_2 = 32043
  private WEATHERMASTER_3 = 32044
  private DOCTOR_CHAOS_SECRET_BOOKSHELF = 32045
  # Items
  private FLOWER_OF_PAVEL = 8290
  private HEART_OF_ATLANTA = 8291
  private WENDYS_NECKLACE = 8292
  private LOCKUP_RESEARCH_REPORT = 8058
  private RESEARCH_REPORT = 8059
  private KEY_OF_ENIGMA = 8060
  # Skills
  private QUEST_TRAP_POWER_SHOT = SkillHolder.new(5073, 5)
  private NPC_DEFAULT = SkillHolder.new(7000)
  # Rewards
  private SEALED_PHOENIX_EARRING = 6324

  def initialize
    super(120, self.class.simple_name, "Pavel's Last Research")

    add_start_npc(SUSPICIOUS_LOOKING_PILE_OF_STONES)
    add_talk_id(
      SUSPICIOUS_LOOKING_PILE_OF_STONES, WENDY, YUMI, WEATHERMASTER_1,
      WEATHERMASTER_2, WEATHERMASTER_3, DOCTOR_CHAOS_SECRET_BOOKSHELF
    )
    add_skill_see_id(WEATHERMASTER_1, WEATHERMASTER_2, WEATHERMASTER_3)
    register_quest_items(
      FLOWER_OF_PAVEL, HEART_OF_ATLANTA, WENDYS_NECKLACE,
      LOCKUP_RESEARCH_REPORT, RESEARCH_REPORT, KEY_OF_ENIGMA
    )
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    unless qs = get_quest_state(pc, false)
      return super
    end

    html = nil
    case event
    when "32046-03.html", "32046-04.htm", "32046-05.html", "32046-06.html"
      if qs.created?
        html = event
      end
    when "quest_accept"
      if qs.created? && pc.quest_completed?(Q00114_ResurrectionOfAnOldManager.simple_name)
        if pc.level >= 70
          qs.start_quest
          qs.memo_state = 1
          html = "32046-08.htm"
        else
          html = "32046-07.htm"
        end
      end
    when "32046-10.html"
      if qs.memo_state?(1)
        html = event
      end
    when "32046-11.html"
      if qs.memo_state?(1)
        qs.memo_state = 2
        qs.set_cond(2, true)
        html = event
      end
    when "32046-14.html"
      if qs.memo_state?(3)
        html = event
      end
    when "32046-15.html"
      if qs.memo_state?(3)
        give_items(pc, FLOWER_OF_PAVEL, 1)
        qs.memo_state = 4
        qs.set_cond(6, true)
        html = event
      end
    when "32046-18.html", "32046-19.html", "32046-20.html", "32046-21.html",
         "32046-22.html", "32046-23.html", "32046-24.html"
      if qs.memo_state?(7)
        html = event
      end
    when "32046-25.html"
      if qs.memo_state?(7)
        qs.memo_state = 8
        qs.set_cond(10, true)
        html = event
      end
    when "32046-26.html", "32046-27.html", "32046-28.html"
      if qs.memo_state?(8)
        html = event
      end
    when "32046-30.html", "32046-31.html", "32046-32.html", "32046-33.html",
         "32046-34.html"
      if qs.memo_state?(11)
        html = event
      end
    when "32046-35.html"
      if qs.memo_state?(11)
        qs.memo_state = 12
        qs.set_cond(13, true)
        html = event
      end
    when "32046-38.html", "32046-39.html", "32046-40.html"
      if qs.memo_state?(19)
        html = event
      end
    when "32046-41.html"
      if qs.memo_state?(19)
        qs.memo_state = 20
        qs.set_cond(20, true)
        html = event
      end
    when "32046-44.html"
      if qs.memo_state?(22)
        give_items(pc, HEART_OF_ATLANTA, 1)
        qs.memo_state = 23
        qs.set_cond(23, true)
        html = event
      end
    when "32047-02.html", "32047-03.html", "32047-04.html", "32047-05.html"
      if qs.memo_state?(2)
        html = event
      end
    when "32047-06.html"
      if qs.memo_state?(2)
        qs.memo_state = 3
        qs.set_cond(5, true)
        html = event
      end
    when "32047-09.html"
      if qs.memo_state?(4) && has_quest_items?(pc, FLOWER_OF_PAVEL)
        html = event
      end
    when "32047-10.html"
      if qs.memo_state?(4) && has_quest_items?(pc, FLOWER_OF_PAVEL)
        take_items(pc, FLOWER_OF_PAVEL, -1)
        qs.memo_state = 5
        qs.set_cond(7, true)
        html = event
      end
    when "32047-13.html", "32047-14.html"
      if qs.memo_state?(6)
        html = event
      end
    when "32047-15.html"
      if qs.memo_state?(6)
        qs.memo_state = 7
        qs.set_cond(9, true)
        html = event
      end
    when "32047-18.html"
      if qs.memo_state?(12)
        html = event
      end
    when "32047-19.html"
      if qs.memo_state?(12)
        qs.memo_state = 13
        qs.set_cond(14, true)
        html = event
      end
    when "32047-23.html", "32047-24.html", "32047-25.html", "32047-26.html"
      if qs.memo_state?(23) && has_quest_items?(pc, HEART_OF_ATLANTA)
        html = event
      end
    when "32047-27.html"
      if qs.memo_state?(23) && has_quest_items?(pc, HEART_OF_ATLANTA)
        take_items(pc, HEART_OF_ATLANTA, -1)
        qs.memo_state = 24
        qs.set_cond(24, true)
        html = event
      end
    when "32047-28.html", "32047-29.html"
      if qs.memo_state?(24)
        html = event
      end
    when "32047-30.html"
      if qs.memo_state?(24)
        qs.memo_state = 25
        html = event
      end
    when "32047-31.html", "32047-32.html"
      if qs.memo_state?(25)
        html = event
      end
    when "32047-33.html"
      if qs.memo_state?(25)
        give_items(pc, WENDYS_NECKLACE, 1)
        qs.memo_state = 26
        qs.set_cond(25, true)
        html = event
      end
    when "32041-02.html"
      if qs.memo_state?(2)
        html = event
      end
    when "32041-03.html"
      if qs.memo_state?(2) && qs.memo_state_ex?(0, 0)
        qs.set_memo_state_ex(0, 1)
        qs.set_cond(3, true)
        html = event
      end
    when "32041-05.html"
      if qs.memo_state?(2) && qs.memo_state_ex?(0, 0)
        qs.set_memo_state_ex(0, 2)
        qs.set_cond(4, true)
        html = event
      end
    when "32041-09.html", "32041-10.html", "32041-11.html", "32041-12.html"
      if qs.memo_state?(5)
        html = event
      end
    when "32041-13.html"
      if qs.memo_state?(5)
        qs.memo_state = 6
        qs.set_cond(8, true)
        html = event
      end
    when "32041-16.html"
      if qs.memo_state?(14) && has_quest_items?(pc, LOCKUP_RESEARCH_REPORT)
        html = event
      end
    when "32041-17.html"
      if qs.memo_state?(14) && has_quest_items?(pc, LOCKUP_RESEARCH_REPORT)
        give_items(pc, KEY_OF_ENIGMA, 1)
        qs.memo_state = 15
        qs.set_cond(16, true)
        html = event
      end
    when "32041-20.html"
      if qs.memo_state?(15) && has_quest_items?(pc, RESEARCH_REPORT, KEY_OF_ENIGMA)
        html = event
      end
    when "pavel", "e=mc2"
      if qs.memo_state?(15) && has_quest_items?(pc, RESEARCH_REPORT, KEY_OF_ENIGMA)
        html = "32041-21.html"
      end
    when "wdl"
      if qs.memo_state?(15) && has_quest_items?(pc, RESEARCH_REPORT, KEY_OF_ENIGMA)
        html = "32041-22.html"
      end
    when "32041-23.html"
      if qs.memo_state?(15) && has_quest_items?(pc, RESEARCH_REPORT, KEY_OF_ENIGMA)
        take_items(pc, KEY_OF_ENIGMA, -1)
        qs.memo_state = 16
        qs.set_cond(17, true)
        html = event
      end
    when "32041-24.html", "32041-26.html"
      if qs.memo_state?(16) && has_quest_items?(pc, RESEARCH_REPORT)
        html = event
      end
    when "32041-29.html", "32041-30.html", "32041-31.html", "32041-32.html",
         "32041-33.html"
      if qs.memo_state?(26) && has_quest_items?(pc, WENDYS_NECKLACE)
        html = event
      end
    when "32041-34.html"
      if qs.memo_state?(26) && has_quest_items?(pc, WENDYS_NECKLACE)
        take_items(pc, WENDYS_NECKLACE, -1)
        reward_items(pc, SEALED_PHOENIX_EARRING, 1)
        give_adena(pc, 783720, true)
        add_exp_and_sp(pc, 3447315, 272615)
        qs.exit_quest(false, true)
        html = event
      end
    when "32042-02.html"
      if qs.memo_state?(8)
        qs.set_memo_state_ex(0, 0)
        html = event
      end
    when "wm1_1_b", "wm1_1_c", "wm1_1_d", "wm1_1_l", "wm1_1_m", "wm1_1_n",
         "wm1_1_s", "wm1_1_t", "wm1_1_u"
      if qs.memo_state?(8)
        html = "32042-03.html"
      end
    when "wm1_1_a"
      if qs.memo_state?(8)
        qs.set_memo_state_ex(0, 1)
        html = "32042-03.html"
      end
    when "wm1_2_a", "wm1_2_b", "wm1_2_c", "wm1_2_d", "wm1_2_l", "wm1_2_m",
         "wm1_2_n", "wm1_2_s", "wm1_2_u"
      if qs.memo_state?(8)
        html = "32042-04.html"
      end
    when "wm1_2_t"
      if qs.memo_state?(8)
        qs.set_memo_state_ex(0, 10 + (qs.get_memo_state_ex(0) % 10))
        html = "32042-04.html"
      end
    when "wm1_3_a", "wm1_3_b", "wm1_3_c", "wm1_3_d", "wm1_3_m", "wm1_3_n",
         "wm1_3_s", "wm1_3_t", "wm1_3_u"
      if qs.memo_state?(8)
        html = "32042-05.html"
      end
    when "wm1_3_l"
      if qs.memo_state?(8)
        if qs.memo_state_ex?(0, 11)
          qs.memo_state = 9
          qs.set_cond(11, true)
          qs.set_memo_state_ex(0, 0)
          html = "32042-06.html"
        else
          html = "32042-05.html"
        end
      end
    when "32042-15.html", "32042-06.html", "32042-07.html"
      if qs.memo_state?(9)
        html = event
      end
    when "32042-08.html"
      if qs.memo_state?(9)
        qs.memo_state = 10
        play_sound(pc, Sound::AMBSOUND_PERCUSSION_01)
        html = event
      end
    when "wm1_return"
      if qs.memo_state?(10)
        if qs.memo_state_ex?(0, 10101)
          html = "32042-13.html"
        else
          html = "32042-09.html"
        end
      end
    when "32042-10.html"
      if qs.memo_state?(10)
        qs.set_memo_state_ex(0, ((qs.get_memo_state_ex(0) // 10) * 10) + 1)
        html = event
      end
    when "32042-11.html"
      if qs.memo_state?(10)
        memo_state_ex = qs.get_memo_state_ex(0)
        i1 = (memo_state_ex // 1000) * 1000
        i2 = (memo_state_ex % 100) + 100
        qs.set_memo_state_ex(0, i1 + i2)
        html = event
      end
    when "32042-12.html"
      if qs.memo_state?(10)
        qs.set_memo_state_ex(0, 10000 + (qs.get_memo_state_ex(0) % 10000))
        html = event
      end
    when "32042-14.html"
      if qs.memo_state?(10) && qs.memo_state_ex?(0, 10101)
        qs.memo_state = 11
        qs.set_cond(12, true)
        qs.set_memo_state_ex(0, 0)
        html = event
      end
    when "32043-02.html"
      if qs.memo_state?(16)
        qs.set_memo_state_ex(0, 0)
        html = event
      end
    when "wm2_1_a", "wm2_1_b", "wm2_1_c", "wm2_1_d", "wm2_1_l", "wm2_1_m",
         "wm2_1_n", "wm2_1_v", "wm2_1_x"
      if qs.memo_state?(16)
        html = "32043-03.html"
      end
    when "wm2_1_w"
      if qs.memo_state?(16)
        qs.set_memo_state_ex(0, 1)
        html = "32043-03.html"
      end
    when "wm2_2_a", "wm2_2_b", "wm2_2_c", "wm2_2_l", "wm2_2_m", "wm2_2_n",
         "wm2_2_v", "wm2_2_w", "wm2_2_x"
      if qs.memo_state?(16)
        html = "32043-04.html"
      end
    when "wm2_2_d"
      if qs.memo_state?(16)
        qs.set_memo_state_ex(0, 10 + (qs.get_memo_state_ex(0) % 10))
        html = "32043-04.html"
      end
    when "wm2_3_a", "wm2_3_b", "wm2_3_c", "wm2_3_d", "wm2_3_m", "wm2_3_n",
         "wm2_3_v", "wm2_3_w", "wm2_3_x"
      if qs.memo_state?(8)
        html = "32043-05.html"
      end
    when "wm2_3_l"
      if qs.memo_state?(16)
        if qs.memo_state_ex?(0, 11)
          qs.memo_state = 17
          qs.set_cond(18, true)
          qs.set_memo_state_ex(0, 0)
          html = "32043-06.html"
        else
          html = "32043-05.html"
        end
      end
    when "32043-31.html", "32043-30.html", "32043-29.html", "32043-28.html",
         "32043-06.html", "32043-07.html", "32043-08.html"
      if qs.memo_state?(17)
        html = event
      end
    when "32043-09.html"
      if qs.memo_state?(17)
        qs.memo_state = 18
        html = event
      end
    when "32043-10.html", "wm2_return"
      if qs.memo_state?(18)
        if qs.memo_state_ex?(0, 1111)
          html = "32043-12.html"
        else
          html = "32043-11.html"
        end
      end
    when "32043-13.html"
      if qs.memo_state?(18)
        qs.set_memo_state_ex(0, ((qs.get_memo_state_ex(0) // 10) * 10) + 1)
        html = event
      end
    when "32043-14.html"
      if qs.memo_state?(18)
        html = event
      end
    when "wm2_output"
      if qs.memo_state?(18)
        if qs.get_memo_state_ex(0) < 1000
          html = "32043-15.html"
        else
          html = "32043-18.html"
        end
      end
    when "32043-16.html"
      if qs.memo_state?(18)
        html = event
      end
    when "32043-17.html"
      if qs.memo_state?(18)
        memo_state_ex = qs.get_memo_state_ex(0)
        i1 = (memo_state_ex // 10000) * 10000
        i2 = (memo_state_ex % 1000) + 1000
        qs.set_memo_state_ex(0, i1 + i2)
        play_sound(pc, Sound::AMBSOUND_DRONE)
        html = event
      end
    when "32043-19.html", "32043-20.html"
      if qs.memo_state?(18)
        html = event
      end
    when "32043-21.html"
      if qs.memo_state?(18)
        memo_state_ex = qs.get_memo_state_ex(0)
        i1 = (memo_state_ex // 100) * 100
        i2 = (memo_state_ex % 10) + 10
        qs.set_memo_state_ex(0, i1 + i2)
        html = event
      end
    when "32043-22.html"
      if qs.memo_state?(18) && qs.memo_state_ex?(0, 1111)
        qs.memo_state = 19
        qs.set_cond(19, true)
        qs.set_memo_state_ex(0, 0)
        html = event
      end
    when "32043-24.html", "32043-25.html"
      if qs.memo_state?(18)
        html = event
      end
    when "32043-26.html"
      if qs.memo_state?(18)
        memo_state_ex = qs.get_memo_state_ex(0)
        i1 = (memo_state_ex // 1000) * 1000
        i2 = (memo_state_ex % 100) + 100
        qs.set_memo_state_ex(0, i1 + i2)
        html = event
      end
    when "32043-27.html"
      if qs.memo_state?(18)
        html = event
      end
    when "32044-02.html"
      if qs.memo_state?(20)
        qs.set_memo_state_ex(0, 0)
        html = event
      end
    when "wm3_1_a", "wm3_1_b", "wm3_1_c", "wm3_1_d", "wm3_1_l", "wm3_1_m",
         "wm3_1_v", "wm3_1_w", "wm3_1_x"
      if qs.memo_state?(20)
        html = "32044-03.html"
      end
    when "wm3_1_n"
      if qs.memo_state?(20)
        qs.set_memo_state_ex(0, 1)
        html = "32044-03.html"
      end
    when "wm3_2_1", "wm3_2_2", "wm3_2_3", "wm3_2_5", "wm3_2_6", "wm3_2_7",
         "wm3_2_8", "wm3_2_9", "wm3_2_10"
      if qs.memo_state?(20)
        html = "32044-04.html"
      end
    when "wm3_2_4"
      if qs.memo_state?(20)
        qs.set_memo_state_ex(0, 10 + (qs.get_memo_state_ex(0) % 10))
        html = "32044-04.html"
      end
    when "wm3_3_1", "wm3_3_2", "wm3_3_3", "wm3_3_4", "wm3_3_6", "wm3_3_7",
         "wm3_3_8", "wm3_3_9", "wm3_3_10"
      if qs.memo_state?(20)
        html = "32044-05.html"
      end
    when "wm3_3_5"
      if qs.memo_state?(20)
        if qs.memo_state_ex?(0, 11)
          qs.memo_state = 21
          qs.set_cond(21, true)
          qs.set_memo_state_ex(0, 0)
          play_sound(pc, Sound::AMBSOUND_PERCUSSION_02)
          html = "32044-06.html"
        else
          html = "32044-05.html"
        end
      end
    when "32044-07.html"
      if qs.memo_state?(21)
        html = event
      end
    when "wm3_observe"
      if qs.memo_state?(21)
        if qs.get_memo_state_ex(0) % 100 == 11
          html = "32044-10.html"
        else
          html = "32044-09.html"
        end
      end
    when "32044-11.html"
      if qs.memo_state?(21)
        memo_state_ex = qs.get_memo_state_ex(0)
        i1 = (memo_state_ex // 100) * 100
        i2 = (memo_state_ex % 10) + 10
        qs.set_memo_state_ex(0, i1 + i2)
        html = event
      end
    when "wm3_fire_of_paagrio"
      if qs.memo_state?(21)
        if qs.get_memo_state_ex(0) // 100 == 1
          html = "32044-13.html"
        else
          qs.set_memo_state_ex(0, ((qs.get_memo_state_ex(0) // 10) * 10) + 1)
          html = "32044-12.html"
        end
      end
    when "wm3_control"
      if qs.memo_state?(21)
        if qs.get_memo_state_ex(0) // 100 == 1
          html = "32044-15.html"
        else
          html = "32044-14.html"
        end
      end
    when "32044-16.html"
      if qs.memo_state?(21) && qs.get_memo_state_ex(0) // 100 != 1
        qs.set_memo_state_ex(0, (qs.get_memo_state_ex(0) % 100) + 100)
        html = event
      end
    when "32044-17.html", "32044-18.html", "32044-19.html"
      if qs.memo_state?(21)
        html = event
      end
    when "32044-20.html"
      if qs.memo_state?(21) && qs.get_memo_state_ex(0) // 100 == 1
        npc = npc.not_nil!
        qs.memo_state = 22
        qs.set_cond(22, true)
        qs.set_memo_state_ex(0, 0)
        play_sound(pc, Sound::AMBSOUND_DRONE)
        npc.target = pc
        npc.do_cast(QUEST_TRAP_POWER_SHOT)
        html = event
      end
    when "32044-21.html"
      if qs.memo_state?(22)
        html = event
      end
    when "32045-02.html"
      if qs.memo_state?(13)
        npc = npc.not_nil!
        give_items(pc, LOCKUP_RESEARCH_REPORT, 1)
        # IMPORTANT!
        # locked report is exchanged to unlocked by using key of enigma
        # which is given by Wendy
        qs.memo_state = 14
        qs.set_cond(15, true)
        npc.target = pc
        npc.do_cast(QUEST_TRAP_POWER_SHOT)
        html = event
      end
    end



    html
  end

  def on_skill_see(npc, pc, skill, targets, is_summon)
    qs = get_quest_state(pc, false)
    if qs && qs.started?
      npc_default = NPC_DEFAULT.skill
      cast_skill(npc, pc, npc_default)
      cast_skill(npc, pc, npc_default)
    end

    nil
  end

  def on_talk(npc, pc)
    qs = get_quest_state!(pc)

    case npc.id
    when SUSPICIOUS_LOOKING_PILE_OF_STONES
      if qs.created?
        if pc.quest_completed?(Q00114_ResurrectionOfAnOldManager.simple_name)
          html = "32046-01.htm"
        else
          html = "32046-02.htm"
        end
      elsif qs.started?
        case qs.memo_state
        when 1
          html = "32046-09.html"
        when 2
          html = "32046-12.html"
        when 3
          html = "32046-13.html"
        when 4
          if has_quest_items?(pc, FLOWER_OF_PAVEL)
            html = "32046-16.html"
          end
        when 7
          html = "32046-17.html"
        when 8
          html = "32046-28.html"
        when 11
          html = "32046-29.html"
        when 12
          html = "32046-36.html"
        when 19
          html = "32046-37.html"
        when 20
          html = "32046-42.html"
        when 22
          html = "32046-43.html"
        when 23
          if has_quest_items?(pc, HEART_OF_ATLANTA)
            html = "32046-45.html"
          end
        end

      else
        if pc.quest_completed?(Q00114_ResurrectionOfAnOldManager.simple_name)
          html = get_already_completed_msg(pc)
        end
      end
    when WENDY
      case qs.memo_state
      when 2
        html = "32047-01.html"
      when 3
        html = "32047-07.html"
      when 4
        if has_quest_items?(pc, FLOWER_OF_PAVEL)
          html = "32047-08.html"
        end
      when 5
        html = "32047-11.html"
      when 6
        html = "32047-12.html"
      when 7
        html = "32047-16.html"
      when 12
        html = "32047-17.html"
      when 13
        html = "32047-20.html"
      when 14
        if has_quest_items?(pc, LOCKUP_RESEARCH_REPORT)
          html = "32047-21.html"
        end
      when 23
        if has_quest_items?(pc, HEART_OF_ATLANTA)
          html = "32047-22.html"
        end
      when 24
        html = "32047-27.html"
      when 25
        html = "32047-30.html"
      when 26
        if has_quest_items?(pc, WENDYS_NECKLACE)
          html = "32047-34.html"
        end
      end

    when YUMI
      case qs.memo_state
      when 2
        case qs.get_memo_state_ex(0)
        when 0
          html = "32041-01.html"
        when 1
          html = "32041-04.html"
        when 2
          html = "32041-06.html"
        end

      when 5
        if qs.get_memo_state_ex(0) > 0
          html = "32041-07.html"
        else
          html = "32041-08.html"
        end
      when 6
        html = "32041-14.html"
      when 14
        if has_quest_items?(pc, LOCKUP_RESEARCH_REPORT)
          html = "32041-15.html"
        end
      when 15
        if has_quest_items?(pc, KEY_OF_ENIGMA)
          if has_quest_items?(pc, RESEARCH_REPORT)
            html = "32041-19.html"
          elsif has_quest_items?(pc, LOCKUP_RESEARCH_REPORT)
            html = "32041-18.html"
          end
        end
      when 16
        if has_quest_items?(pc, RESEARCH_REPORT)
          html = "32041-27.html"
        end
      when 26
        if has_quest_items?(pc, WENDYS_NECKLACE)
          html = "32041-28.html"
        end
      end

    when WEATHERMASTER_1
      case qs.memo_state
      when 8
        html = "32042-01.html"
        play_sound(pc, Sound::AMBSOUND_CRYSTAL_LOOP)
      when 9
        html = "32042-06.html"
      when 10
        if qs.memo_state_ex?(0, 10101)
          html = "32042-13.html"
        else
          html = "32042-09.html"
        end
      when 11
        html = "32042-14.html"
      end

    when WEATHERMASTER_2
      case qs.memo_state
      when 16
        html = "32043-01.html"
      when 17
        html = "32043-06.html"
      when 18
        html = "32043-09.html"
      when 19
        html = "32043-23.html"
      end

    when WEATHERMASTER_3
      case qs.memo_state
      when 20
        html = "32044-01.html"
      when 21
        html = "32044-08.html"
      when 22
        html = "32044-22.html"
      end

    when DOCTOR_CHAOS_SECRET_BOOKSHELF
      case qs.memo_state
      when 13
        html = "32045-01.html"
      when 14
        html = "32045-03.html"
      end

    end


    html || get_no_quest_msg(pc)
  end
end
