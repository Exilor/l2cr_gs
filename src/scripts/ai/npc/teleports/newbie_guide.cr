class Scripts::NewbieGuide < AbstractNpcAI
  # Suffix
  private SUFFIX_FIGHTER_5_LEVEL = "-f05.htm"
  private SUFFIX_FIGHTER_10_LEVEL = "-f10.htm"
  private SUFFIX_FIGHTER_15_LEVEL = "-f15.htm"
  private SUFFIX_FIGHTER_20_LEVEL = "-f20.htm"
  private SUFFIX_MAGE_7_LEVEL = "-m07.htm"
  private SUFFIX_MAGE_14_LEVEL = "-m14.htm"
  private SUFFIX_MAGE_20_LEVEL = "-m20.htm"

  # Vars
  private FIRST_COUPON_SIZE = 5i64
  private SECOND_COUPON_SIZE = 1i64

  # Newbie helpers
  private NEWBIE_GUIDE_HUMAN = 30598
  private NEWBIE_GUIDE_ELF = 30599
  private NEWBIE_GUIDE_DARK_ELF = 30600
  private NEWBIE_GUIDE_DWARF = 30601
  private NEWBIE_GUIDE_ORC = 30602
  private NEWBIE_GUIDE_KAMAEL = 32135
  private NEWBIE_GUIDE_GLUDIN = 31076
  private NEWBIE_GUIDE_GLUDIO = 31077
  private ADVENTURERS_GUIDE = 32327

  private GUIDE_MISSION = 41 # where is that quest?

  # Item
  private SOULSHOT_NO_GRADE_FOR_BEGINNERS = 5789
  private SPIRITSHOT_NO_GRADE_FOR_BEGINNERS = 5790
  private SCROLL_RECOVERY_NO_GRADE = 8594

  private APPRENTICE_ADVENTURERS_WEAPON_EXCHANGE_COUPON = 7832
  private ADVENTURERS_MAGIC_ACCESSORY_EXCHANGE_COUPON = 7833

  # Buffs
  private WIND_WALK_FOR_BEGINNERS = SkillHolder.new(4322)
  private SHIELD_FOR_BEGINNERS = SkillHolder.new(4323)
  private BLESS_THE_BODY_FOR_BEGINNERS = SkillHolder.new(4324)
  private VAMPIRIC_RAGE_FOR_BEGINNERS = SkillHolder.new(4325)
  private REGENERATION_FOR_BEGINNERS = SkillHolder.new(4326)
  private HASTE_FOR_BEGINNERS = SkillHolder.new(4327)
  private BLESS_THE_SOUL_FOR_BEGINNERS = SkillHolder.new(4328)
  private ACUMEN_FOR_BEGINNERS = SkillHolder.new(4329)
  private CONCENTRATION_FOR_BEGINNERS = SkillHolder.new(4330)
  private EMPOWER_FOR_BEGINNERS = SkillHolder.new(4331)
  private LIFE_CUBIC_FOR_BEGINNERS = SkillHolder.new(4338)
  private BLESSING_OF_PROTECTION = SkillHolder.new(5182)
  private ADVENTURERS_HASTE = SkillHolder.new(5632)
  private ADVENTURERS_MAGIC_BARRIER = SkillHolder.new(5637)

  # Buylist
  private WEAPON_MULTISELL = 305986001
  private ACCESORIES_MULTISELL = 305986002

  private TALKING_ISLAND_VILLAGE = Location.new(-84081, 243227, -3723)
  private DARK_ELF_VILLAGE = Location.new(12111, 16686, -4582)
  private DWARVEN_VILLAGE = Location.new(115632, -177996, -905)
  private ELVEN_VILLAGE = Location.new(45475, 48359, -3060)
  private ORC_VILLAGE = Location.new(-45032, -113598, -192)
  private KAMAEL_VILLAGE = Location.new(-119697, 44532, 380)

  private TELEPORT_MAP = {
    NEWBIE_GUIDE_HUMAN => {
      DARK_ELF_VILLAGE,
      DWARVEN_VILLAGE,
      ELVEN_VILLAGE,
      ORC_VILLAGE,
      KAMAEL_VILLAGE
    },
    NEWBIE_GUIDE_ELF => {
      DARK_ELF_VILLAGE,
      DWARVEN_VILLAGE,
      TALKING_ISLAND_VILLAGE,
      ORC_VILLAGE,
      KAMAEL_VILLAGE
    },
    NEWBIE_GUIDE_DARK_ELF => {
      DWARVEN_VILLAGE,
      TALKING_ISLAND_VILLAGE,
      ELVEN_VILLAGE,
      ORC_VILLAGE,
      KAMAEL_VILLAGE
    },
    NEWBIE_GUIDE_DWARF => {
      DARK_ELF_VILLAGE,
      TALKING_ISLAND_VILLAGE,
      ELVEN_VILLAGE,
      ORC_VILLAGE,
      KAMAEL_VILLAGE
    },
    NEWBIE_GUIDE_ORC => {
      DARK_ELF_VILLAGE,
      DWARVEN_VILLAGE,
      TALKING_ISLAND_VILLAGE,
      ELVEN_VILLAGE,
      KAMAEL_VILLAGE
    },
    NEWBIE_GUIDE_KAMAEL => {
      TALKING_ISLAND_VILLAGE,
      DARK_ELF_VILLAGE,
      ELVEN_VILLAGE,
      DWARVEN_VILLAGE,
      ORC_VILLAGE
    }
  }

  def initialize
    super(self.class.simple_name, "ai/npc/Teleports")

    newbie_list = {
      NEWBIE_GUIDE_HUMAN,
      NEWBIE_GUIDE_ELF,
      NEWBIE_GUIDE_DARK_ELF,
      NEWBIE_GUIDE_DWARF,
      NEWBIE_GUIDE_ORC,
      NEWBIE_GUIDE_KAMAEL,
      NEWBIE_GUIDE_GLUDIN,
      NEWBIE_GUIDE_GLUDIO,
      ADVENTURERS_GUIDE
    }
    add_start_npc(newbie_list)
    add_first_talk_id(newbie_list)
    add_talk_id(newbie_list)
  end

  def on_first_talk(npc, player)
    if qs = player.get_quest_state(Scripts::Q00255_Tutorial.simple_name)
      if npc.id == ADVENTURERS_GUIDE
        return "32327.htm"
      end

      return talk_guide(player, qs)
    end

    super
  end

  def on_adv_event(event, npc, talker)
    if event.ends_with?(".htm")
      return event
    end

    if event.starts_with?("teleport")
      talker = talker.not_nil!
      npc = npc.not_nil!

      tel = event.split('_')
      if tel.size != 2
        teleport_request(talker, npc, -1)
      else
        teleport_request(talker, npc, tel[1].to_i)
      end

      return event
    end

    talker = talker.not_nil!
    npc = npc.not_nil!

    qs = get_quest_state!(talker)

    temp = event.split(';')
    ask = temp[0].to_i
    reply = temp[1].to_i

    case ask
    when -7
      case reply
      when 1
        if talker.race.kamael?
          if talker.race != npc.race
            show_page(talker, "32135-003.htm")
          elsif talker.level > 20 || !talker.race.kamael? || talker.class_id.level != 0
            show_page(talker, "32135-002.htm")
          elsif talker.class_id.male_soldier?
            if talker.level <= 5
              show_page(talker, "32135-kmf05.htm")
            elsif talker.level <= 10
              show_page(talker, "32135-kmf10.htm")
            elsif talker.level <= 15
              show_page(talker, "32135-kmf15.htm")
            else
              show_page(talker, "32135-kmf20.htm")
            end
          elsif talker.class_id.female_soldier?
            if talker.level <= 5
              show_page(talker, "32135-kff05.htm")
            elsif talker.level <= 10
              show_page(talker, "32135-kff10.htm")
            elsif talker.level <= 15
              show_page(talker, "32135-kff15.htm")
            else
              show_page(talker, "32135-kff20.htm")
            end
          end
        elsif talker.race != npc.race
          show_page(talker, "")
        elsif talker.level > 20 || talker.class_id.level != 0
          show_page(talker, "")
        elsif !talker.mage_class?
          if talker.level <= 5
            show_page(talker, "#{npc.id}#{SUFFIX_FIGHTER_5_LEVEL}")
          elsif talker.level <= 10
            show_page(talker, "#{npc.id}#{SUFFIX_FIGHTER_10_LEVEL}")
          elsif talker.level <= 15
            show_page(talker, "#{npc.id}#{SUFFIX_FIGHTER_15_LEVEL}")
          else
            show_page(talker, "#{npc.id}#{SUFFIX_FIGHTER_20_LEVEL}")
          end
        elsif talker.level <= 7
          show_page(talker, "#{npc.id}#{SUFFIX_MAGE_7_LEVEL}")
        elsif talker.level <= 14
          show_page(talker, "#{npc.id}#{SUFFIX_MAGE_14_LEVEL}")
        else
          show_page(talker, "#{npc.id}#{SUFFIX_MAGE_20_LEVEL}")
        end
      when 2
        if talker.level <= 75
          if talker.level < 6
            show_page(talker, "buffs-low-level.htm")
          elsif !talker.mage_class? && talker.class_id.level < 3
            npc.target = talker
            npc.do_cast(WIND_WALK_FOR_BEGINNERS)
            npc.do_cast(WIND_WALK_FOR_BEGINNERS)
            npc.do_cast(SHIELD_FOR_BEGINNERS)
            npc.do_cast(ADVENTURERS_MAGIC_BARRIER)
            npc.do_cast(BLESS_THE_BODY_FOR_BEGINNERS)
            npc.do_cast(VAMPIRIC_RAGE_FOR_BEGINNERS)
            npc.do_cast(REGENERATION_FOR_BEGINNERS)
            if talker.level.between?(6, 36)
              npc.do_cast(HASTE_FOR_BEGINNERS)
            end
            if talker.level.between?(40, 75)
              npc.do_cast(ADVENTURERS_HASTE)
            end
            if talker.level.between?(16, 34)
              npc.do_cast(LIFE_CUBIC_FOR_BEGINNERS)
            end
          elsif talker.mage_class? && talker.class_id.level < 3
            npc.target = talker
            npc.do_cast(WIND_WALK_FOR_BEGINNERS)
            npc.do_cast(SHIELD_FOR_BEGINNERS)
            npc.do_cast(ADVENTURERS_MAGIC_BARRIER)
            npc.do_cast(BLESS_THE_SOUL_FOR_BEGINNERS)
            npc.do_cast(ACUMEN_FOR_BEGINNERS)
            npc.do_cast(CONCENTRATION_FOR_BEGINNERS)
            npc.do_cast(EMPOWER_FOR_BEGINNERS)
            if talker.level.between?(16, 34)
              npc.do_cast(LIFE_CUBIC_FOR_BEGINNERS)
            end
          end
        else
          show_page(talker, "buffs-big-level.htm")
        end
      when 3
        if talker.level <= 39 && talker.class_id.level < 3
          npc.target = talker
          npc.do_cast(BLESSING_OF_PROTECTION)
        else
          show_page(talker, "pk-protection-002.htm")
        end
      when 4
        summon = talker.summon
        if summon && !summon.pet?
          if !talker.level.between?(6, 75)
            show_page(talker, "buffs-big-level.htm")
          else
            npc.target = talker
            npc.do_cast(WIND_WALK_FOR_BEGINNERS)
            npc.do_cast(SHIELD_FOR_BEGINNERS)
            npc.do_cast(ADVENTURERS_MAGIC_BARRIER)
            npc.do_cast(BLESS_THE_BODY_FOR_BEGINNERS)
            npc.do_cast(VAMPIRIC_RAGE_FOR_BEGINNERS)
            npc.do_cast(REGENERATION_FOR_BEGINNERS)
            npc.do_cast(BLESS_THE_SOUL_FOR_BEGINNERS)
            npc.do_cast(ACUMEN_FOR_BEGINNERS)
            npc.do_cast(CONCENTRATION_FOR_BEGINNERS)
            npc.do_cast(EMPOWER_FOR_BEGINNERS)
            case talker.level
            when 6..39
              npc.do_cast(HASTE_FOR_BEGINNERS)
            when 40..75
              npc.do_cast(ADVENTURERS_HASTE)
            end
          end
        else
          show_page(talker, "buffs-no-pet.htm")
        end
      end
    when -1000
      case reply
      when 1
        if talker.level > 5
          if talker.level < 20 && talker.class_id.level == 0
            if get_one_time_quest_flag(talker, 207) == 0
              qs.give_items(APPRENTICE_ADVENTURERS_WEAPON_EXCHANGE_COUPON, FIRST_COUPON_SIZE)
              set_one_time_quest_flag(talker, 207, 1)
              show_page(talker, "newbie-guide-002.htm")
              qs.set_nr_memo_state(talker, GUIDE_MISSION, qs.get_nr_memo_state(talker, GUIDE_MISSION) + 100)
              show_on_screen_msg(talker, NpcString::ACQUISITION_OF_WEAPON_EXCHANGE_COUPON_FOR_BEGINNERS_COMPLETE_N_GO_SPEAK_WITH_THE_NEWBIE_GUIDE, 2, 5000, "")
            else
              show_page(talker, "newbie-guide-004.htm")
            end
          else
            show_page(talker, "newbie-guide-003.htm")
          end
        else
          show_page(talker, "newbie-guide-003.htm")
        end
      when 2
        if talker.class_id.level == 1 # L2J says 2 but I"m pretty sure it"s mistaken
          if talker.level < 40
            if get_one_time_quest_flag(talker, 208) == 0
              qs.give_items(ADVENTURERS_MAGIC_ACCESSORY_EXCHANGE_COUPON, SECOND_COUPON_SIZE)
              set_one_time_quest_flag(talker, 208, 1)
              show_page(talker, "newbie-guide-011.htm")
            else
              show_page(talker, "newbie-guide-013.htm")
            end
          else
            show_page(talker, "newbie-guide-012.htm")
          end
        else
          show_page(talker, "newbie-guide-012.htm")
        end
      end
    when -303
      case reply
      when 528
        if talker.level > 5
          if talker.level < 20 && talker.class_id.level == 0
            MultisellData.separate_and_send(WEAPON_MULTISELL, talker, npc, false)
          else
            show_page(talker, "newbie-guide-005.htm")
          end
        else
          show_page(talker, "newbie-guide-005.htm")
        end
      when 529
        if talker.level > 5
          if talker.level < 40 && talker.class_id.level == 1
            MultisellData.separate_and_send(ACCESORIES_MULTISELL, talker, npc, false)
          else
            show_page(talker, "newbie-guide-014.htm")
          end
        else
          show_page(talker, "newbie-guide-014.htm")
        end
      end
    end

    case npc.id
    when NEWBIE_GUIDE_HUMAN
      tmp = event_guide_human_cnacelot(reply, qs)
      unless tmp.empty?
        return tmp
      end
    when NEWBIE_GUIDE_ELF
      tmp = event_guide_elf_roios(reply, qs)
      unless tmp.empty?
        return tmp
      end
    when NEWBIE_GUIDE_DARK_ELF
      tmp = event_guide_d_elf_frankia(reply, qs)
      unless tmp.empty?
        return tmp
      end
    when NEWBIE_GUIDE_DWARF
      tmp = event_guide_dwarf_gullin(reply, qs)
      unless tmp.empty?
        return tmp
      end
    when NEWBIE_GUIDE_ORC
      tmp = event_guide_orc_tanai(reply, qs)
      unless tmp.empty?
        return tmp
      end
    when NEWBIE_GUIDE_KAMAEL
      tmp = event_guide_krenisk(reply, qs)
      unless tmp.empty?
        return tmp
      end
    end

    ""
  end

  private def teleport_request(pc, npc, teleport_id)
    if pc.level >= 20
      show_page(pc, "teleport-big-level.htm")
    elsif pc.transformation_id.in?(111, 112, 124)
      show_page(pc, "frog-teleport.htm")
    else
      if teleport_id < 0 || teleport_id > 5
        show_page(pc, "#{npc.id}-teleport.htm")
      else
        if tmp = TELEPORT_MAP[npc.id]?
          if tmp.size > teleport_id
            pc.tele_to_location(tmp[teleport_id], false)
          end
        end
      end
    end
  end

  private def talk_guide(talker, tutorial_qs)
    # debug "memo_state_ex: #{tutorial_qs.get_memo_state_ex(1)}"
    # debug "one_time_quest_flag: #{get_one_time_quest_flag(talker, GUIDE_MISSION)}"

    qs = get_quest_state!(talker)
    if tutorial_qs.get_memo_state_ex(1) < 5 && get_one_time_quest_flag(talker, GUIDE_MISSION) == 0
      unless talker.mage_class?
        qs.play_sound(Voice::TUTORIAL_VOICE_026_1000)
        qs.give_items(SOULSHOT_NO_GRADE_FOR_BEGINNERS, 200)
        qs.give_items(SCROLL_RECOVERY_NO_GRADE, 2)
        tutorial_qs.set_memo_state_ex(1, 5)
        if talker.level <= 1
          qs.add_exp_and_sp(68, 50)
        else
          qs.add_exp_and_sp(0, 50)
        end
      end
      if talker.mage_class?
        if talker.class_id.orc_mage?
          qs.play_sound(Voice::TUTORIAL_VOICE_026_1000)
          qs.give_items(SOULSHOT_NO_GRADE_FOR_BEGINNERS, 200)
        else
          qs.play_sound(Voice::TUTORIAL_VOICE_027_1000)
          qs.give_items(SPIRITSHOT_NO_GRADE_FOR_BEGINNERS, 100)
        end
        qs.give_items(SCROLL_RECOVERY_NO_GRADE, 2)
        tutorial_qs.set_memo_state_ex(1, 5)
        if talker.level <= 1
          qs.add_exp_and_sp(68, 50)
        else
          qs.add_exp_and_sp(0, 50)
        end
      end
      if talker.level < 6
        if qs.get_nr_memo_state(talker, GUIDE_MISSION) % 10 == 1
          if talker.level >= 5
            qs.give_adena(695, true)
            qs.add_exp_and_sp(3154, 127)
          elsif talker.level >= 4
            qs.give_adena(1041, true)
            qs.add_exp_and_sp(4870, 195)
          elsif talker.level >= 3
            qs.give_adena(1240, true)
            qs.add_exp_and_sp(5970, 239)
          end
          if !qs.has_nr_memo?(talker, GUIDE_MISSION)
            qs.set_nr_memo(talker, GUIDE_MISSION)
            qs.set_nr_memo_state(talker, GUIDE_MISSION, 10)
          else
            qs.set_nr_memo_state(talker, GUIDE_MISSION, qs.get_nr_memo_state(talker, GUIDE_MISSION) + 10)
          end
          return "newbie-guide-02.htm"
        end
        case talker.race
        when .human?
          qs.add_radar(-84436, 242793, -3729)
          return "newbie-guide-01a.htm"
        when .elf?
          qs.add_radar(42978, 49115, 2994)
          return "newbie-guide-01b.htm"
        when .dark_elf?
          qs.add_radar(25790, 10844, -3727)
          return "newbie-guide-01c.htm"
        when .orc?
          qs.add_radar(-47360, -113791, -237)
          return "newbie-guide-01d.htm"
        when .dwarf?
          qs.add_radar(112656, -174864, -611)
          return "newbie-guide-01e.htm"
        when .kamael?
          qs.add_radar(-119378, 49242, 22)
          return "newbie-guide-01f.htm"
        end

        unless qs.has_nr_memo?(talker, GUIDE_MISSION)
          qs.set_nr_memo(talker, GUIDE_MISSION)
          qs.set_nr_memo_state(talker, GUIDE_MISSION, 0)
        end
      elsif talker.level < 10
        if (qs.get_nr_memo_state(talker, GUIDE_MISSION) % 1000) // 100 == 1 && (qs.get_nr_memo_state(talker, GUIDE_MISSION) % 10000) // 100 == 1
          case talker.race
          when .human?
            unless talker.mage_class?
              qs.add_radar(-71384, 258304, -3109)
              return "newbie-guide-05a.htm"
            end
            qs.add_radar(-91008, 248016, -3568)
            return "newbie-guide-05b.htm"
          when .elf?
            qs.add_radar(47595, 51569, -2996)
            return "newbie-guide-05c.htm"
          when .dark_elf?
            unless talker.mage_class?
              qs.add_radar(10580, 17574, -4554)
              return "newbie-guide-05d.htm"
            end
            qs.add_radar(10775, 14190, -4242)
            return "newbie-guide-05e.htm"
          when .orc?
            qs.add_radar(46808, -113184, -112)
            return "newbie-guide-05f.htm"
          when .dwarf?
            qs.add_radar(115717, -183488, -1483)
            return "newbie-guide-05g.htm"
          when .kamael?
            qs.add_radar(115717, -183488, -1483)
            return "newbie-guide-05h.htm"
          end

          if talker.level >= 9
            qs.give_adena(5563, true)
            qs.add_exp_and_sp(16851, 711)
          elsif talker.level >= 8
            qs.give_adena(9290, true)
            qs.add_exp_and_sp(28806, 1207)
          elsif talker.level >= 7
            qs.give_adena(11567, true)
            qs.add_exp_and_sp(36942, 1541)
          else
            qs.give_adena(12928, true)
            qs.add_exp_and_sp(42191, 1753)
          end
          if !qs.has_nr_memo?(talker, GUIDE_MISSION)
            qs.set_nr_memo(talker, GUIDE_MISSION)
            qs.set_nr_memo_state(talker, GUIDE_MISSION, 10000)
          else
            qs.set_nr_memo_state(talker, GUIDE_MISSION, qs.get_nr_memo_state(talker, GUIDE_MISSION) + 10000)
          end
        elsif (qs.get_nr_memo_state(talker, GUIDE_MISSION) % 1000) // 100 == 1 && (qs.get_nr_memo_state(talker, GUIDE_MISSION) % 10000) // 100 != 1
          case talker.race
          when .human?
            qs.add_radar(-82236, 241573, -3728)
            return "newbie-guide-04a.htm"
          when .elf?
            qs.add_radar(42812, 51138, -2996)
            return "newbie-guide-04b.htm"
          when .dark_elf?
            qs.add_radar(7644, 18048, -4377)
            return "newbie-guide-04c.htm"
          when .orc?
            qs.add_radar(-46802, -114011, -112)
            return "newbie-guide-04d.htm"
          when .dwarf?
            qs.add_radar(116103, -178407, -948)
            return "newbie-guide-04e.htm"
          when .kamael?
            qs.add_radar(-119378, 49242, 22)
            return "newbie-guide-04f.htm"
          end

          unless qs.has_nr_memo?(talker, GUIDE_MISSION)
            qs.set_nr_memo(talker, GUIDE_MISSION)
            qs.set_nr_memo_state(talker, GUIDE_MISSION, 0)
          end
        else
          unless qs.has_nr_memo?(talker, GUIDE_MISSION)
            qs.set_nr_memo(talker, GUIDE_MISSION)
            qs.set_nr_memo_state(talker, GUIDE_MISSION, 0)
          end
          return "newbie-guide-03.htm"
        end
      else
        set_one_time_quest_flag(talker, GUIDE_MISSION, 1)
        unless qs.has_nr_memo?(talker, GUIDE_MISSION)
          qs.set_nr_memo(talker, GUIDE_MISSION)
          qs.set_nr_memo_state(talker, GUIDE_MISSION, 0)
        end
        return "newbie-guide-06.htm"
      end
    elsif tutorial_qs.get_memo_state_ex(1) >= 5 && get_one_time_quest_flag(talker, GUIDE_MISSION) == 0
      if talker.level < 6
        if qs.get_nr_memo_state(talker, GUIDE_MISSION) % 10 == 1
          if talker.level >= 5
            qs.give_adena(695, true)
            qs.add_exp_and_sp(3154, 127)
          elsif talker.level >= 4
            qs.give_adena(1041, true)
            qs.add_exp_and_sp(4870, 195)
          elsif talker.level >= 3
            qs.give_adena(1186, true)
            qs.add_exp_and_sp(5675, 227)
          else
            qs.give_adena(1240, true)
            qs.add_exp_and_sp(5970, 239)
          end
          if !qs.has_nr_memo?(talker, GUIDE_MISSION)
            qs.set_nr_memo(talker, GUIDE_MISSION)
            qs.set_nr_memo_state(talker, GUIDE_MISSION, 10)
          else
            qs.set_nr_memo_state(talker, GUIDE_MISSION, qs.get_nr_memo_state(talker, GUIDE_MISSION) + 10)
          end
          return "newbie-guide-08.htm"
        end
        case talker.race
        when .human?
          qs.add_radar(-84436, 242793, -3729)
          return "newbie-guide-07a.htm"
        when .elf?
          qs.add_radar(42978, 49115, 2994)
          return "newbie-guide-07b.htm"
        when .dark_elf?
          qs.add_radar(25790, 10844, -3727)
          return "newbie-guide-07c.htm"
        when .orc?
          qs.add_radar(-47360, -113791, -237)
          return "newbie-guide-07d.htm"
        when .dwarf?
          qs.add_radar(112656, -174864, -611)
          return "newbie-guide-07e.htm"
        when .kamael?
          qs.add_radar(-119378, 49242, 22)
          return "newbie-guide-07f.htm"
        end

        unless qs.has_nr_memo?(talker, GUIDE_MISSION)
          qs.set_nr_memo(talker, GUIDE_MISSION)
          qs.set_nr_memo_state(talker, GUIDE_MISSION, 0)
        end
      elsif talker.level < 10
        if (qs.get_nr_memo_state(talker, GUIDE_MISSION) % 100000) // 10000 == 1
          return "newbie-guide-09g.htm"
        elsif (qs.get_nr_memo_state(talker, GUIDE_MISSION) % 1000) // 100 == 1 && ((qs.get_nr_memo_state(talker, GUIDE_MISSION) % 10000) // 1000) == 1 && (qs.get_nr_memo_state(talker, GUIDE_MISSION) % 100000) // 10000 != 1
          case talker.race
          when .human?
            unless talker.mage_class?
              qs.add_radar(-71384, 258304, -3109)
              return "newbie-guide-10a.htm"
            end
            qs.add_radar(-91008, 248016, -3568)
            return "newbie-guide-10b.htm"
          when .elf?
            qs.add_radar(47595, 51569, -2996)
            return "newbie-guide-10c.htm"
          when .dark_elf?
            unless talker.mage_class?
              qs.add_radar(10580, 17574, -4554)
              return "newbie-guide-10d.htm"
            end
            qs.add_radar(10775, 14190, -4242)
            return "newbie-guide-10e.htm"
          when .orc?
            qs.add_radar(-46808, -113184, -112)
            return "newbie-guide-10f.htm"
          when .dwarf?
            qs.add_radar(115717, -183488, -1483)
            return "newbie-guide-10g.htm"
          when .kamael?
            qs.add_radar(-118080, 42835, 720)
            return "newbie-guide-10h.htm"
          end

          if talker.level >= 9
            qs.give_adena(5563, true)
            qs.add_exp_and_sp(16851, 711)
          elsif talker.level >= 8
            qs.give_adena(9290, true)
            qs.add_exp_and_sp(28806, 1207)
          elsif talker.level >= 7
            qs.give_adena(11567, true)
            qs.add_exp_and_sp(36942, 1541)
          else
            qs.give_adena(12928, true)
            qs.add_exp_and_sp(42191, 1753)
          end
          if !qs.has_nr_memo?(talker, GUIDE_MISSION)
            qs.set_nr_memo(talker, GUIDE_MISSION)
            qs.set_nr_memo_state(talker, GUIDE_MISSION, 10000)
          else
            qs.set_nr_memo_state(talker, GUIDE_MISSION, qs.get_nr_memo_state(talker, GUIDE_MISSION) + 10000)
          end
        elsif (qs.get_nr_memo_state(talker, GUIDE_MISSION) % 1000) // 100 == 1 && (qs.get_nr_memo_state(talker, GUIDE_MISSION) % 10000) // 1000 != 1
          case talker.race
          when .human?
            qs.add_radar(-82236, 241573, -3728)
            return "newbie-guide-09a.htm"
          when .elf?
            qs.add_radar(42812, 51138, -2996)
            return "newbie-guide-09b.htm"
          when .dark_elf?
            qs.add_radar(7644, 18048, -4377)
            return "newbie-guide-09c.htm"
          when .orc?
            qs.add_radar(-46802, -114011, -112)
            return "newbie-guide-09d.htm"
          when .dwarf?
            qs.add_radar(116103, -178407, -948)
            return "newbie-guide-09e.htm"
          when .kamael?
            qs.add_radar(-119378, 49242, 22)
            return "newbie-guide-09f.htm"
          end

          unless qs.has_nr_memo?(talker, GUIDE_MISSION)
            qs.set_nr_memo(talker, GUIDE_MISSION)
            qs.set_nr_memo_state(talker, GUIDE_MISSION, 0)
          end
        else
          unless qs.has_nr_memo?(talker, GUIDE_MISSION)
            qs.set_nr_memo(talker, GUIDE_MISSION)
            qs.set_nr_memo_state(talker, GUIDE_MISSION, 0)
          end
          return "newbie-guide-08.htm"
        end
      elsif talker.level < 15
        if (qs.get_nr_memo_state(talker, GUIDE_MISSION) % 1000000) // 100000 == 1 && (qs.get_nr_memo_state(talker, GUIDE_MISSION) % 10000000) // 1000000 == 1
          return "newbie-guide-15.htm"
        elsif (qs.get_nr_memo_state(talker, GUIDE_MISSION) % 1000000) // 100000 == 1 && (qs.get_nr_memo_state(talker, GUIDE_MISSION) % 10000000) // 1000000 != 1
          case talker.race
          when .human?
            qs.add_radar(-84057, 242832, -3729)
            return "newbie-guide-11a.htm"
          when .elf?
            qs.add_radar(45859, 50827, -3058)
            return "newbie-guide-11b.htm"
          when .dark_elf?
            qs.add_radar(11258, 14431, -4242)
            return "newbie-guide-11c.htm"
          when .orc?
            qs.add_radar(-45863, -112621, -200)
            return "newbie-guide-11d.htm"
          when .dwarf?
            qs.add_radar(116268, -177524, -914)
            return "newbie-guide-11e.htm"
          when .kamael?
            qs.add_radar(-125872, 38208, 1251)
            return "newbie-guide-11f.htm"
          end

          if talker.level >= 14
            qs.give_adena(13002, true)
            qs.add_exp_and_sp(62876, 2891)
          elsif talker.level >= 13
            qs.give_adena(23468, true)
            qs.add_exp_and_sp(113137, 5161)
          elsif talker.level >= 12
            qs.give_adena(31752, true)
            qs.add_exp_and_sp(152653, 6914)
          elsif talker.level >= 11
            qs.give_adena(38180, true)
            qs.add_exp_and_sp(183128, 8242)
          else
            qs.give_adena(43054, true)
            qs.add_exp_and_sp(206101, 9227)
          end
          if !qs.has_nr_memo?(talker, GUIDE_MISSION)
            qs.set_nr_memo(talker, GUIDE_MISSION)
            qs.set_nr_memo_state(talker, GUIDE_MISSION, 1000000)
          else
            qs.set_nr_memo_state(talker, GUIDE_MISSION, qs.get_nr_memo_state(talker, GUIDE_MISSION) + 1000000)
          end
        elsif (qs.get_nr_memo_state(talker, GUIDE_MISSION) % 1000000) // 100000 != 1
          case talker.race
          when .human?
            unless talker.mage_class?
              qs.add_radar(-71384, 258304, -3109)
              return "newbie-guide-10a.htm"
            end
            qs.add_radar(-91008, 248016, -3568)
            return "newbie-guide-10b.htm"
          when .elf?
            qs.add_radar(47595, 51569, -2996)
            return "newbie-guide-10c.htm"
          when .dark_elf?
            unless talker.mage_class?
              qs.add_radar(10580, 17574, -4554)
              return "newbie-guide-10d.htm"
            end
            qs.add_radar(10775, 14190, -4242)
            return "newbie-guide-10e.htm"
          when .orc?
            qs.add_radar(-46808, -113184, -112)
            return "newbie-guide-10f.htm"
          when .dwarf?
            qs.add_radar(115717, -183488, -1483)
            return "newbie-guide-10g.htm"
          when .kamael?
            qs.add_radar(-118080, 42835, 720)
            return "newbie-guide-10h.htm"
          end

          unless qs.has_nr_memo?(talker, GUIDE_MISSION)
            qs.set_nr_memo(talker, GUIDE_MISSION)
            qs.set_nr_memo_state(talker, GUIDE_MISSION, 0)
          end
        end
      elsif talker.level < 18
        if (qs.get_nr_memo_state(talker, GUIDE_MISSION) % 100000000) // 10000000 == 1 && (qs.get_nr_memo_state(talker, GUIDE_MISSION) % 1000000000) // 100000000 == 1
          set_one_time_quest_flag(talker, GUIDE_MISSION, 1)
          return "newbie-guide-13.htm"
        elsif (qs.get_nr_memo_state(talker, GUIDE_MISSION) % 100000000) // 10000000 == 1 && (qs.get_nr_memo_state(talker, GUIDE_MISSION) % 1000000000) // 100000000 != 1
          if talker.level >= 17
            qs.give_adena(22996, true)
            qs.add_exp_and_sp(113712, 5518)
          elsif talker.level >= 16
            qs.give_adena(10018, true)
            qs.add_exp_and_sp(208133, 42237)
          else
            qs.give_adena(13648, true)
            qs.add_exp_and_sp(285670, 58155)
          end
          if !qs.has_nr_memo?(talker, GUIDE_MISSION)
            qs.set_nr_memo(talker, GUIDE_MISSION)
            qs.set_nr_memo_state(talker, GUIDE_MISSION, 100000000)
          else
            qs.set_nr_memo_state(talker, GUIDE_MISSION, qs.get_nr_memo_state(talker, GUIDE_MISSION) + 100000000)
          end
          set_one_time_quest_flag(talker, GUIDE_MISSION, 1)
          return "newbie-guide-12.htm"
        elsif (qs.get_nr_memo_state(talker, GUIDE_MISSION) % 100000000) // 10000000 != 1
          case talker.race
          when .human?
            qs.add_radar(-84057, 242832, -3729)
            return "newbie-guide-11a.htm"
          when .elf?
            qs.add_radar(45859, 50827, -3058)
            return "newbie-guide-11b.htm"
          when .dark_elf?
            qs.add_radar(11258, 14431, -4242)
            return "newbie-guide-11c.htm"
          when .orc?
            qs.add_radar(-45863, -112621, -200)
            return "newbie-guide-11d.htm"
          when .dwarf?
            qs.add_radar(116268, -177524, -914)
            return "newbie-guide-11e.htm"
          when .kamael?
            qs.add_radar(-125872, 38208, 1251)
            return "newbie-guide-11f.htm"
          end
        end
        unless qs.has_nr_memo?(talker, GUIDE_MISSION)
          qs.set_nr_memo(talker, GUIDE_MISSION)
          qs.set_nr_memo_state(talker, GUIDE_MISSION, 0)
        end
      elsif talker.class_id.level == 1
        set_one_time_quest_flag(talker, GUIDE_MISSION, 1)
        unless qs.has_nr_memo?(talker, GUIDE_MISSION)
          qs.set_nr_memo(talker, GUIDE_MISSION)
          qs.set_nr_memo_state(talker, GUIDE_MISSION, 0)
        end
        return "newbie-guide-13.htm"
      else
        set_one_time_quest_flag(talker, GUIDE_MISSION, 1)
        unless qs.has_nr_memo?(talker, GUIDE_MISSION)
          qs.set_nr_memo(talker, GUIDE_MISSION)
          qs.set_nr_memo_state(talker, GUIDE_MISSION, 0)
        end
        return "newbie-guide-14.htm"
      end
    end

    ""
  end

  private def event_guide_human_cnacelot(event, qs)
    case event
    when 10
      return "30598-04.htm"
    when 11
      return "30598-04a.htm"
    when 12
      return "30598-04b.htm"
    when 13
      return "30598-04c.htm"
    when 14
      return "30598-04d.htm"
    when 15
      return "30598-04e.htm"
    when 16
      return "30598-04f.htm"
    when 17
      return "30598-04g.htm"
    when 18
      return "30598-04h.htm"
    when 19
      return "30598-04i.htm"
    when 31
      qs.clear_radar
      qs.add_radar(-84108, 244604, -3729)
      return "30598-05.htm"
    when 32
      qs.clear_radar
      qs.add_radar(-82236, 241573, -3728)
      return "30598-05.htm"
    when 33
      qs.clear_radar
      qs.add_radar(-82515, 241221, -3728)
      return "30598-05.htm"
    when 34
      qs.clear_radar
      qs.add_radar(-82319, 244709, -3727)
      return "30598-05.htm"
    when 35
      qs.clear_radar
      qs.add_radar(-82659, 244992, -3717)
      return "30598-05.htm"
    when 36
      qs.clear_radar
      qs.add_radar(-86114, 244682, -3727)
      return "30598-05.htm"
    when 37
      qs.clear_radar
      qs.add_radar(-86328, 244448, -3724)
      return "30598-05.htm"
    when 38
      qs.clear_radar
      qs.add_radar(-86322, 241215, -3727)
      return "30598-05.htm"
    when 39
      qs.clear_radar
      qs.add_radar(-85964, 240947, -3727)
      return "30598-05.htm"
    when 40
      qs.clear_radar
      qs.add_radar(-85026, 242689, -3729)
      return "30598-05.htm"
    when 41
      qs.clear_radar
      qs.add_radar(-83789, 240799, -3717)
      return "30598-05.htm"
    when 42
      qs.clear_radar
      qs.add_radar(-84204, 240403, -3717)
      return "30598-05.htm"
    when 43
      qs.clear_radar
      qs.add_radar(-86385, 243267, -3717)
      return "30598-05.htm"
    when 44
      qs.clear_radar
      qs.add_radar(-86733, 242918, -3717)
      return "30598-05.htm"
    when 45
      qs.clear_radar
      qs.add_radar(-84516, 245449, -3714)
      return "30598-05.htm"
    when 46
      qs.clear_radar
      qs.add_radar(-84729, 245001, -3726)
      return "30598-05.htm"
    when 47
      qs.clear_radar
      qs.add_radar(-84965, 245222, -3726)
      return "30598-05.htm"
    when 48
      qs.clear_radar
      qs.add_radar(-84981, 244764, -3726)
      return "30598-05.htm"
    when 49
      qs.clear_radar
      qs.add_radar(-85186, 245001, -3726)
      return "30598-05.htm"
    when 50
      qs.clear_radar
      qs.add_radar(-83326, 242964, -3718)
      return "30598-05.htm"
    when 51
      qs.clear_radar
      qs.add_radar(-83020, 242553, -3718)
      return "30598-05.htm"
    when 52
      qs.clear_radar
      qs.add_radar(-83175, 243065, -3718)
      return "30598-05.htm"
    when 53
      qs.clear_radar
      qs.add_radar(-82809, 242751, -3718)
      return "30598-05.htm"
    when 54
      qs.clear_radar
      qs.add_radar(-81895, 243917, -3721)
      return "30598-05.htm"
    when 55
      qs.clear_radar
      qs.add_radar(-81840, 243534, -3721)
      return "30598-05.htm"
    when 56
      qs.clear_radar
      qs.add_radar(-81512, 243424, -3720)
      return "30598-05.htm"
    when 57
      qs.clear_radar
      qs.add_radar(-84436, 242793, -3729)
      return "30598-05.htm"
    when 58
      qs.clear_radar
      qs.add_radar(-78939, 240305, -3443)
      return "30598-05.htm"
    when 59
      qs.clear_radar
      qs.add_radar(-85301, 244587, -3725)
      return "30598-05.htm"
    when 60
      qs.clear_radar
      qs.add_radar(-83163, 243560, -3728)
      return "30598-05.htm"
    when 61
      qs.clear_radar
      qs.add_radar(-97131, 258946, -3622)
      return "30598-05.htm"
    when 62
      qs.clear_radar
      qs.add_radar(-114685, 222291, -2925)
      return "30598-05.htm"
    when 63
      qs.clear_radar
      qs.add_radar(-84057, 242832, -3729)
      return "30598-05.htm"
    when 64
      qs.clear_radar
      qs.add_radar(-100332, 238019, -3573)
      return "30598-05.htm"
    when 65
      qs.clear_radar
      qs.add_radar(-82041, 242718, -3725)
      return "30598-05.htm"
    end

    ""
  end

  private def event_guide_elf_roios(event, qs)
    case event
    when 10
      return "30599-04.htm"
    when 11
      return "30599-04a.htm"
    when 12
      return "30599-04b.htm"
    when 13
      return "30599-04c.htm"
    when 14
      return "30599-04d.htm"
    when 15
      return "30599-04e.htm"
    when 16
      return "30599-04f.htm"
    when 17
      return "30599-04g.htm"
    when 18
      return "30599-04h.htm"
    when 31
      qs.clear_radar
      qs.add_radar(46926, 51511, -2977)
      return "30599-05.htm"
    when 32
      qs.clear_radar
      qs.add_radar(44995, 51706, -2803)
      return "30599-05.htm"
    when 33
      qs.clear_radar
      qs.add_radar(45727, 51721, -2803)
      return "30599-05.htm"
    when 34
      qs.clear_radar
      qs.add_radar(42812, 51138, -2996)
      return "30599-05.htm"
    when 35
      qs.clear_radar
      qs.add_radar(45487, 46511, -2996)
      return "30599-05.htm"
    when 36
      qs.clear_radar
      qs.add_radar(47401, 51764, -2996)
      return "30599-05.htm"
    when 37
      qs.clear_radar
      qs.add_radar(42971, 51372, -2996)
      return "30599-05.htm"
    when 38
      qs.clear_radar
      qs.add_radar(47595, 51569, -2996)
      return "30599-05.htm"
    when 39
      qs.clear_radar
      qs.add_radar(45778, 46534, -2996)
      return "30599-05.htm"
    when 40
      qs.clear_radar
      qs.add_radar(44476, 47153, -2984)
      return "30599-05.htm"
    when 41
      qs.clear_radar
      qs.add_radar(42700, 50057, -2984)
      return "30599-05.htm"
    when 42
      qs.clear_radar
      qs.add_radar(42766, 50037, -2984)
      return "30599-05.htm"
    when 43
      qs.clear_radar
      qs.add_radar(44683, 46952, -2981)
      return "30599-05.htm"
    when 44
      qs.clear_radar
      qs.add_radar(44667, 46896, -2982)
      return "30599-05.htm"
    when 45
      qs.clear_radar
      qs.add_radar(45725, 52105, -2795)
      return "30599-05.htm"
    when 46
      qs.clear_radar
      qs.add_radar(44823, 52414, -2795)
      return "30599-05.htm"
    when 47
      qs.clear_radar
      qs.add_radar(45000, 52101, -2795)
      return "30599-05.htm"
    when 48
      qs.clear_radar
      qs.add_radar(45919, 52414, -2795)
      return "30599-05.htm"
    when 49
      qs.clear_radar
      qs.add_radar(44692, 52261, -2795)
      return "30599-05.htm"
    when 50
      qs.clear_radar
      qs.add_radar(47780, 49568, -2983)
      return "30599-05.htm"
    when 51
      qs.clear_radar
      qs.add_radar(47912, 50170, -2983)
      return "30599-05.htm"
    when 52
      qs.clear_radar
      qs.add_radar(47868, 50167, -2983)
      return "30599-05.htm"
    when 53
      qs.clear_radar
      qs.add_radar(28928, 74248, -3773)
      return "30599-05.htm"
    when 54
      qs.clear_radar
      qs.add_radar(43673, 49683, -3046)
      return "30599-05.htm"
    when 55
      qs.clear_radar
      qs.add_radar(45610, 49008, -3059)
      return "30599-05.htm"
    when 56
      qs.clear_radar
      qs.add_radar(50592, 54986, -3376)
      return "30599-05.htm"
    when 57
      qs.clear_radar
      qs.add_radar(42978, 49115, -2994)
      return "30599-05.htm"
    when 58
      qs.clear_radar
      qs.add_radar(46475, 50495, -3058)
      return "30599-05.htm"
    when 59
      qs.clear_radar
      qs.add_radar(45859, 50827, -3058)
      return "30599-05.htm"
    when 60
      qs.clear_radar
      qs.add_radar(51210, 82474, -3283)
      return "30599-05.htm"
    when 61
      qs.clear_radar
      qs.add_radar(49262, 53607, -3216)
      return "30599-05.htm"
    end

    ""
  end

  private def event_guide_d_elf_frankia(event, qs)
    case event
    when 10
      return "30600-04.htm"
    when 11
      return "30600-04a.htm"
    when 12
      return "30600-04b.htm"
    when 13
      return "30600-04c.htm"
    when 14
      return "30600-04d.htm"
    when 15
      return "30600-04e.htm"
    when 16
      return "30600-04f.htm"
    when 17
      return "30600-04g.htm"
    when 18
      return "30600-04h.htm"
    when 31
      qs.clear_radar
      qs.add_radar(9670, 15537, -4574)
      return "30600-05.htm"
    when 32
      qs.clear_radar
      qs.add_radar(15120, 15656, -4376)
      return "30600-05.htm"
    when 33
      qs.clear_radar
      qs.add_radar(17306, 13592, -3724)
      return "30600-05.htm"
    when 34
      qs.clear_radar
      qs.add_radar(15272, 16310, -4377)
      return "30600-05.htm"
    when 35
      qs.clear_radar
      qs.add_radar(6449, 19619, -3694)
      return "30600-05.htm"
    when 36
      qs.clear_radar
      qs.add_radar(-15404, 71131, -3445)
      return "30600-05.htm"
    when 37
      qs.clear_radar
      qs.add_radar(7496, 17388, -4377)
      return "30600-05.htm"
    when 38
      qs.clear_radar
      qs.add_radar(17102, 13002, -3743)
      return "30600-05.htm"
    when 39
      qs.clear_radar
      qs.add_radar(6532, 19903, -3693)
      return "30600-05.htm"
    when 40
      qs.clear_radar
      qs.add_radar(-15648, 71405, -3451)
      return "30600-05.htm"
    when 41
      qs.clear_radar
      qs.add_radar(7644, 18048, -4377)
      return "30600-05.htm"
    when 42
      qs.clear_radar
      qs.add_radar(-1301, 75883, -3566)
      return "30600-05.htm"
    when 43
      qs.clear_radar
      qs.add_radar(-1152, 76125, -3566)
      return "30600-05.htm"
    when 44
      qs.clear_radar
      qs.add_radar(10580, 17574, -4554)
      return "30600-05.htm"
    when 45
      qs.clear_radar
      qs.add_radar(12009, 15704, -4554)
      return "30600-05.htm"
    when 46
      qs.clear_radar
      qs.add_radar(11951, 15661, -4554)
      return "30600-05.htm"
    when 47
      qs.clear_radar
      qs.add_radar(10761, 17970, -4554)
      return "30600-05.htm"
    when 48
      qs.clear_radar
      qs.add_radar(10823, 18013, -4554)
      return "30600-05.htm"
    when 49
      qs.clear_radar
      qs.add_radar(11283, 14226, -4242)
      return "30600-05.htm"
    when 50
      qs.clear_radar
      qs.add_radar(10447, 14620, -4242)
      return "30600-05.htm"
    when 51
      qs.clear_radar
      qs.add_radar(11258, 14431, -4242)
      return "30600-05.htm"
    when 52
      qs.clear_radar
      qs.add_radar(10344, 14445, -4242)
      return "30600-05.htm"
    when 53
      qs.clear_radar
      qs.add_radar(10315, 14293, -4242)
      return "30600-05.htm"
    when 54
      qs.clear_radar
      qs.add_radar(10775, 14190, -4242)
      return "30600-05.htm"
    when 55
      qs.clear_radar
      qs.add_radar(11235, 14078, -4242)
      return "30600-05.htm"
    when 56
      qs.clear_radar
      qs.add_radar(11012, 14128, -4242)
      return "30600-05.htm"
    when 57
      qs.clear_radar
      qs.add_radar(13380, 17430, -4542)
      return "30600-05.htm"
    when 58
      qs.clear_radar
      qs.add_radar(13464, 17751, -4541)
      return "30600-05.htm"
    when 59
      qs.clear_radar
      qs.add_radar(13763, 17501, -4542)
      return "30600-05.htm"
    when 60
      qs.clear_radar
      qs.add_radar(-44225, 79721, -3652)
      return "30600-05.htm"
    when 61
      qs.clear_radar
      qs.add_radar(-44015, 79683, -3652)
      return "30600-05.htm"
    when 62
      qs.clear_radar
      qs.add_radar(25856, 10832, -3724)
      return "30600-05.htm"
    when 63
      qs.clear_radar
      qs.add_radar(12328, 14947, -4574)
      return "30600-05.htm"
    when 64
      qs.clear_radar
      qs.add_radar(13081, 18444, -4573)
      return "30600-05.htm"
    when 65
      qs.clear_radar
      qs.add_radar(12311, 17470, -4574)
      return "30600-05.htm"
    end

    ""
  end

  private def event_guide_dwarf_gullin(event, qs)
    case event
    when 10
      return "30601-04.htm"
    when 11
      return "30601-04a.htm"
    when 12
      return "30601-04b.htm"
    when 13
      return "30601-04c.htm"
    when 14
      return "30601-04d.htm"
    when 15
      return "30601-04e.htm"
    when 16
      return "30601-04f.htm"
    when 17
      return "30601-04g.htm"
    when 18
      return "30601-04h.htm"
    when 31
      qs.clear_radar
      qs.add_radar(115072, -178176, -906)
      return "30601-05.htm"
    when 32
      qs.clear_radar
      qs.add_radar(117847, -182339, -1537)
      return "30601-05.htm"
    when 33
      qs.clear_radar
      qs.add_radar(116617, -184308, -1569)
      return "30601-05.htm"
    when 34
      qs.clear_radar
      qs.add_radar(117826, -182576, -1537)
      return "30601-05.htm"
    when 35
      qs.clear_radar
      qs.add_radar(116378, -184308, -1571)
      return "30601-05.htm"
    when 36
      qs.clear_radar
      qs.add_radar(115183, -176728, -791)
      return "30601-05.htm"
    when 37
      qs.clear_radar
      qs.add_radar(114969, -176752, -790)
      return "30601-05.htm"
    when 38
      qs.clear_radar
      qs.add_radar(117366, -178725, -1118)
      return "30601-05.htm"
    when 39
      qs.clear_radar
      qs.add_radar(117378, -178914, -1120)
      return "30601-05.htm"
    when 40
      qs.clear_radar
      qs.add_radar(116226, -178529, -948)
      return "30601-05.htm"
    when 41
      qs.clear_radar
      qs.add_radar(116190, -178441, -948)
      return "30601-05.htm"
    when 42
      qs.clear_radar
      qs.add_radar(116016, -178615, -948)
      return "30601-05.htm"
    when 43
      qs.clear_radar
      qs.add_radar(116190, -178615, -948)
      return "30601-05.htm"
    when 44
      qs.clear_radar
      qs.add_radar(116103, -178407, -948)
      return "30601-05.htm"
    when 45
      qs.clear_radar
      qs.add_radar(116103, -178653, -948)
      return "30601-05.htm"
    when 46
      qs.clear_radar
      qs.add_radar(115468, -182446, -1434)
      return "30601-05.htm"
    when 47
      qs.clear_radar
      qs.add_radar(115315, -182155, -1444)
      return "30601-05.htm"
    when 48
      qs.clear_radar
      qs.add_radar(115271, -182692, -1445)
      return "30601-05.htm"
    when 49
      qs.clear_radar
      qs.add_radar(115900, -177316, -915)
      return "30601-05.htm"
    when 50
      qs.clear_radar
      qs.add_radar(116268, -177524, -914)
      return "30601-05.htm"
    when 51
      qs.clear_radar
      qs.add_radar(115741, -181645, -1344)
      return "30601-05.htm"
    when 52
      qs.clear_radar
      qs.add_radar(116192, -181072, -1344)
      return "30601-05.htm"
    when 53
      qs.clear_radar
      qs.add_radar(115205, -180024, -870)
      return "30601-05.htm"
    when 54
      qs.clear_radar
      qs.add_radar(114716, -180018, -871)
      return "30601-05.htm"
    when 55
      qs.clear_radar
      qs.add_radar(114832, -179520, -871)
      return "30601-05.htm"
    when 56
      qs.clear_radar
      qs.add_radar(115717, -183488, -1483)
      return "30601-05.htm"
    when 57
      qs.clear_radar
      qs.add_radar(115618, -183265, -1483)
      return "30601-05.htm"
    when 58
      qs.clear_radar
      qs.add_radar(114348, -178537, -813)
      return "30601-05.htm"
    when 59
      qs.clear_radar
      qs.add_radar(114990, -177294, -854)
      return "30601-05.htm"
    when 60
      qs.clear_radar
      qs.add_radar(114426, -178672, -812)
      return "30601-05.htm"
    when 61
      qs.clear_radar
      qs.add_radar(114409, -178415, -812)
      return "30601-05.htm"
    when 62
      qs.clear_radar
      qs.add_radar(117061, -181867, -1413)
      return "30601-05.htm"
    when 63
      qs.clear_radar
      qs.add_radar(116164, -184029, -1507)
      return "30601-05.htm"
    when 64
      qs.clear_radar
      qs.add_radar(115563, -182923, -1448)
      return "30601-05.htm"
    when 65
      qs.clear_radar
      qs.add_radar(112656, -174864, -611)
      return "30601-05.htm"
    when 66
      qs.clear_radar
      qs.add_radar(116852, -183595, -1566)
      return "30601-05.htm"
    end

    ""
  end

  private def event_guide_orc_tanai(event, qs)
    case event
    when 10
      return "30602-04.htm"
    when 11
      return "30602-04a.htm"
    when 12
      return "30602-04b.htm"
    when 13
      return "30602-04c.htm"
    when 14
      return "30602-04d.htm"
    when 15
      return "30602-04e.htm"
    when 16
      return "30602-04f.htm"
    when 17
      return "30602-04g.htm"
    when 18
      return "30602-04h.htm"
    when 19
      return "30602-04i.htm"
    when 31
      qs.clear_radar
      qs.add_radar(-45264, -112512, -235)
      return "30602-05.htm"
    when 32
      qs.clear_radar
      qs.add_radar(-46576, -117311, -242)
      return "30602-05.htm"
    when 33
      qs.clear_radar
      qs.add_radar(-47360, -113791, -237)
      return "30602-05.htm"
    when 34
      qs.clear_radar
      qs.add_radar(-47360, -113424, -235)
      return "30602-05.htm"
    when 35
      qs.clear_radar
      qs.add_radar(-45744, -117165, -236)
      return "30602-05.htm"
    when 36
      qs.clear_radar
      qs.add_radar(-46528, -109968, -250)
      return "30602-05.htm"
    when 37
      qs.clear_radar
      qs.add_radar(-45808, -110055, -255)
      return "30602-05.htm"
    when 38
      qs.clear_radar
      qs.add_radar(-45731, -113844, -237)
      return "30602-05.htm"
    when 39
      qs.clear_radar
      qs.add_radar(-45728, -113360, -237)
      return "30602-05.htm"
    when 40
      qs.clear_radar
      qs.add_radar(-45952, -114784, -199)
      return "30602-05.htm"
    when 41
      qs.clear_radar
      qs.add_radar(-45952, -114496, -199)
      return "30602-05.htm"
    when 42
      qs.clear_radar
      qs.add_radar(-45863, -112621, -200)
      return "30602-05.htm"
    when 43
      qs.clear_radar
      qs.add_radar(-45864, -112540, -199)
      return "30602-05.htm"
    when 44
      qs.clear_radar
      qs.add_radar(-43264, -112532, -220)
      return "30602-05.htm"
    when 45
      qs.clear_radar
      qs.add_radar(-43910, -115518, -194)
      return "30602-05.htm"
    when 46
      qs.clear_radar
      qs.add_radar(-43950, -115457, -194)
      return "30602-05.htm"
    when 47
      qs.clear_radar
      qs.add_radar(-44416, -111486, -222)
      return "30602-05.htm"
    when 48
      qs.clear_radar
      qs.add_radar(-43926, -111794, -222)
      return "30602-05.htm"
    when 49
      qs.clear_radar
      qs.add_radar(-43109, -113770, -221)
      return "30602-05.htm"
    when 50
      qs.clear_radar
      qs.add_radar(-43114, -113404, -221)
      return "30602-05.htm"
    when 51
      qs.clear_radar
      qs.add_radar(-46768, -113610, -3)
      return "30602-05.htm"
    when 52
      qs.clear_radar
      qs.add_radar(-46802, -114011, -112)
      return "30602-05.htm"
    when 53
      qs.clear_radar
      qs.add_radar(-46247, -113866, -21)
      return "30602-05.htm"
    when 54
      qs.clear_radar
      qs.add_radar(-46808, -113184, -112)
      return "30602-05.htm"
    when 55
      qs.clear_radar
      qs.add_radar(-45328, -114736, -237)
      return "30602-05.htm"
    when 56
      qs.clear_radar
      qs.add_radar(-44624, -111873, -238)
      return "30602-05.htm"
    end

    ""
  end

  private def event_guide_krenisk(event, qs)
    case event
    when 10
      return "32135-04.htm"
    when 11
      return "32135-04a.htm"
    when 12
      return "32135-04b.htm"
    when 13
      return "32135-04c.htm"
    when 14
      return "32135-04d.htm"
    when 15
      return "32135-04e.htm"
    when 16
      return "32135-04f.htm"
    when 17
      return "32135-04g.htm"
    when 18
      return "32135-04h.htm"
    when 19
      return "32135-04i.htm"
    when 20
      return "32135-04j.htm"
    when 21
      return "32135-04k.htm"
    when 22
      return "32135-04l.htm"
    when 31
      qs.clear_radar
      qs.add_radar(-116879, 46591, 380)
      return "32135-05.htm"
    when 32
      qs.clear_radar
      qs.add_radar(-119378, 49242, 22)
      return "32135-05.htm"
    when 33
      qs.clear_radar
      qs.add_radar(-119774, 49245, 22)
      return "32135-05.htm"
    when 34
      qs.clear_radar
      qs.add_radar(-119830, 51860, -787)
      return "32135-05.htm"
    when 35
      qs.clear_radar
      qs.add_radar(-119362, 51862, -780)
      return "32135-05.htm"
    when 36
      qs.clear_radar
      qs.add_radar(-112872, 46850, 68)
      return "32135-05.htm"
    when 37
      qs.clear_radar
      qs.add_radar(-112352, 47392, 68)
      return "32135-05.htm"
    when 38
      qs.clear_radar
      qs.add_radar(-110544, 49040, -1124)
      return "32135-05.htm"
    when 39
      qs.clear_radar
      qs.add_radar(-110536, 45162, -1132)
      return "32135-05.htm"
    when 40
      qs.clear_radar
      qs.add_radar(-115888, 43568, 524)
      return "32135-05.htm"
    when 41
      qs.clear_radar
      qs.add_radar(-115486, 43567, 525)
      return "32135-05.htm"
    when 42
      qs.clear_radar
      qs.add_radar(-116920, 47792, 464)
      return "32135-05.htm"
    when 43
      qs.clear_radar
      qs.add_radar(-116749, 48077, 462)
      return "32135-05.htm"
    when 44
      qs.clear_radar
      qs.add_radar(-117153, 48075, 463)
      return "32135-05.htm"
    when 45
      qs.clear_radar
      qs.add_radar(-119104, 43280, 559)
      return "32135-05.htm"
    when 46
      qs.clear_radar
      qs.add_radar(-119104, 43152, 559)
      return "32135-05.htm"
    when 47
      qs.clear_radar
      qs.add_radar(-117056, 43168, 559)
      return "32135-05.htm"
    when 48
      qs.clear_radar
      qs.add_radar(-117060, 43296, 559)
      return "32135-05.htm"
    when 49
      qs.clear_radar
      qs.add_radar(-118192, 42384, 838)
      return "32135-05.htm"
    when 50
      qs.clear_radar
      qs.add_radar(-117968, 42384, 838)
      return "32135-05.htm"
    when 51
      qs.clear_radar
      qs.add_radar(-118132, 42788, 723)
      return "32135-05.htm"
    when 52
      qs.clear_radar
      qs.add_radar(-118028, 42788, 720)
      return "32135-05.htm"
    when 53
      qs.clear_radar
      qs.add_radar(-114802, 44821, 524)
      return "32135-05.htm"
    when 54
      qs.clear_radar
      qs.add_radar(-114975, 44658, 524)
      return "32135-05.htm"
    when 55
      qs.clear_radar
      qs.add_radar(-114801, 45031, 525)
      return "32135-05.htm"
    when 56
      qs.clear_radar
      qs.add_radar(-120432, 45296, 416)
      return "32135-05.htm"
    when 57
      qs.clear_radar
      qs.add_radar(-120706, 45079, 419)
      return "32135-05.htm"
    when 58
      qs.clear_radar
      qs.add_radar(-120356, 45293, 416)
      return "32135-05.htm"
    when 59
      qs.clear_radar
      qs.add_radar(-120604, 44960, 423)
      return "32135-05.htm"
    when 60
      qs.clear_radar
      qs.add_radar(-120294, 46013, 384)
      return "32135-05.htm"
    when 61
      qs.clear_radar
      qs.add_radar(-120157, 45813, 355)
      return "32135-05.htm"
    when 62
      qs.clear_radar
      qs.add_radar(-120158, 46221, 354)
      return "32135-05.htm"
    when 63
      qs.clear_radar
      qs.add_radar(-120400, 46921, 415)
      return "32135-05.htm"
    when 64
      qs.clear_radar
      qs.add_radar(-120407, 46755, 423)
      return "32135-05.htm"
    when 65
      qs.clear_radar
      qs.add_radar(-120442, 47125, 422)
      return "32135-05.htm"
    when 66
      qs.clear_radar
      qs.add_radar(-118720, 48062, 473)
      return "32135-05.htm"
    when 67
      qs.clear_radar
      qs.add_radar(-118918, 47956, 474)
      return "32135-05.htm"
    when 68
      qs.clear_radar
      qs.add_radar(-118527, 47955, 473)
      return "32135-05.htm"
    when 69
      qs.clear_radar
      qs.add_radar(-117605, 48079, 472)
      return "32135-05.htm"
    when 70
      qs.clear_radar
      qs.add_radar(-117824, 48080, 476)
      return "32135-05.htm"
    when 71
      qs.clear_radar
      qs.add_radar(-118030, 47930, 465)
      return "32135-05.htm"
    when 72
      qs.clear_radar
      qs.add_radar(-119221, 46981, 380)
      return "32135-05.htm"
    when 73
      qs.clear_radar
      qs.add_radar(-118080, 42835, 720)
      return "32135-05.htm"
    end

    ""
  end
end
