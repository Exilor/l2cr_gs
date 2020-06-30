require "../../enums/music/voice"

class Scripts::Q00255_Tutorial < Quest
  # Npc
  private ROIEN = 30008
  private NEWBIE_HELPER_HUMAN_FIGHTER = 30009
  private GALLINT = 30017
  private NEWBIE_HELPER_HUMAN_MAGE = 30019
  private MITRAELL = 30129
  private NEWBIE_HELPER_DARK_ELF = 30131
  private NERUPA = 30370
  private NEWBIE_HELPER_ELF = 30400
  private LAFERON = 30528
  private NEWBIE_HELPER_DWARF = 30530
  private VULKUS = 30573
  private NEWBIE_HELPER_ORC = 30575
  private PERWAN = 32133
  private NEWBIE_HELPER_KAMAEL = 32134

  # Monster
  private TUTORIAL_GREMLIN = 18342

  # Items
  private SOULSHOT_NO_GRADE_FOR_BEGINNERS = 5789
  private SPIRITSHOT_NO_GRADE_FOR_BEGINNERS = 5790
  private BLUE_GEMSTONE = 6353
  private TUTORIAL_GUIDE = 5588

  # Quest items
  private RECOMMENDATION_1 = 1067
  private RECOMMENDATION_2 = 1068
  private LEAF_OF_THE_MOTHER_TREE = 1069
  private BLOOD_OF_MITRAELL = 1070
  private LICENSE_OF_MINER = 1498
  private VOUCHER_OF_FLAME = 1496
  private DIPLOMA = 9881

  # Territory wars
  private TW_GLUDIO = 81
  private TW_DION = 82
  private TW_GIRAN = 83
  private TW_OREN = 84
  private TW_ADEN = 85
  private TW_HEINE = 86
  private TW_GODDARD = 87
  private TW_RUNE = 88
  private TW_SCHUTTGART = 89

  # Connected quests
  private Q10276_MUTATED_KANEUS_GLUDIO = 10276
  private Q10277_MUTATED_KANEUS_DION = 10277
  private Q10278_MUTATED_KANEUS_HEINE = 10278
  private Q10279_MUTATED_KANEUS_OREN = 10279
  private Q10280_MUTATED_KANEUS_SCHUTTGART = 10280
  private Q10281_MUTATED_KANEUS_RUNE = 10281
  private Q192_SEVEN_SIGNS_SERIES_OF_DOUBT = 192
  private Q10292_SEVEN_SIGNS_GIRL_OF_DOUBT = 10292
  private Q234_FATES_WHISPER = 234
  private Q128_PAILAKA_SONG_OF_ICE_AND_FIRE = 128
  private Q129_PAILAKA_DEVILS_LEGACY = 129
  private Q144_PAIRAKA_WOUNDED_DRAGON = 144

  private Q729_PROTECT_THE_TERRITORY_CATAPULT = 729
  private Q730_PROTECT_THE_SUPPLIES_SAFE = 730
  private Q731_PROTECT_THE_MILITARY_ASSOCIATION_LEADER = 731
  private Q732_PROTECT_THE_RELIGIOUS_ASSOCIATION_LEADER = 732
  private Q733_PROTECT_THE_ECONOMIC_ASSOCIATION_LEADER = 733

  private Q201_TUTORIAL_HUMAN_FIGHTER = 201
  private Q202_TUTORIAL_HUMAN_MAGE = 202
  private Q203_TUTORIAL_ELF = 203
  private Q204_TUTORIAL_DARK_ELF = 204
  private Q205_TUTORIAL_ORC = 205
  private Q206_TUTORIAL_DWARF = 206

  private Q717_FOR_THE_SAKE_OF_THE_TERRITORY_GLUDIO = 717
  private Q718_FOR_THE_SAKE_OF_THE_TERRITORY_DION = 718
  private Q719_FOR_THE_SAKE_OF_THE_TERRITORY_GIRAN = 719
  private Q720_FOR_THE_SAKE_OF_THE_TERRITORY_OREN = 720
  private Q721_FOR_THE_SAKE_OF_THE_TERRITORY_ADEN = 721
  private Q722_FOR_THE_SAKE_OF_THE_TERRITORY_INNADRIL = 722
  private Q723_FOR_THE_SAKE_OF_THE_TERRITORY_GODDARD = 723
  private Q724_FOR_THE_SAKE_OF_THE_TERRITORY_RUNE = 724
  private Q725_FOR_THE_SAKE_OF_THE_TERRITORY_SCHUTTGART = 725
  private Q728_TERRITORY_WAR = 728

  # Quests
  def initialize
    super(255, self.class.simple_name, "Tutorial")

    unless Config.disable_tutorial
      self.on_enter_world = true

      register_tutorial_event
      register_tutorial_client_event
      register_tutorial_question_mark
      register_tutorial_cmd

      list = {
        ROIEN,
        NEWBIE_HELPER_HUMAN_FIGHTER,
        GALLINT,
        NEWBIE_HELPER_HUMAN_MAGE,
        MITRAELL,
        NEWBIE_HELPER_DARK_ELF,
        NERUPA,
        NEWBIE_HELPER_ELF,
        LAFERON,
        NEWBIE_HELPER_DWARF,
        VULKUS,
        NEWBIE_HELPER_ORC,
        PERWAN,
        NEWBIE_HELPER_KAMAEL
      }
      add_start_npc(list)
      add_first_talk_id(list)
      add_talk_id(list)
      add_kill_id(TUTORIAL_GREMLIN)
    end
  end

  # Handle only tutorial_close_
  def on_tutorial_event(pc, event)
    # Prevent codes from custom class master
    if event.starts_with?("CO")
      return
    end

    pass = event.from(15).to_i
    if pass < 302
      pass = -pass
    end

    tutorial_event(pc, pass)
  end

  # Handle client events 1, 2, 8
  def on_tutorial_client_event(pc : L2PcInstance, event : Int32)
    tutorial_event(pc, event)
  end

  def on_tutorial_question_mark(pc : L2PcInstance, number : Int32)
    question_mark_clicked(pc, number)
    super
  end

  def on_tutorial_cmd(pc : L2PcInstance, command : String)
    select_from_menu(pc, command.to_i)
    super
  end

  def on_enter_world(pc)
    debug "on_enter_world(#{pc})"
    user_connected(pc)
    listener = ConsumerEventListener.new(pc, EventType::ON_PLAYER_LEVEL_CHANGED, pc) do |event|
      event = event.as(OnPlayerLevelChanged)
      level_up(event.active_char, event.new_level)
    end
    pc.add_listener(listener)

    super
  end

  private def enable_tutorial_event(qs, event_status)
    pc = qs.player

    if event_status & (1048576 | 2097152) != 0
      unless pc.has_listener?(EventType::ON_PLAYER_ITEM_PICKUP)
        listener = ConsumerEventListener.new(pc, EventType::ON_PLAYER_ITEM_PICKUP, pc) do |event|
          event = event.as(OnPlayerItemPickup)
          if event.item.id == BLUE_GEMSTONE && (qs.memo_state & 1048576) != 0
            tutorial_event(event.active_char, 1048576)
          end

          if event.item.id == 57 && qs.memo_state & 2097152 != 0
            tutorial_event(event.active_char, 2097152)
          end
        end
        pc.add_listener(listener)
      end
    elsif pc.has_listener?(EventType::ON_PLAYER_ITEM_PICKUP)
      pc.remove_listener_if(EventType::ON_PLAYER_ITEM_PICKUP) do |listener|
        listener.owner == pc
      end
    end

    if event_status & 8388608 != 0
      unless pc.has_listener?(EventType::ON_PLAYER_SIT)
        listener = ConsumerEventListener.new(pc, EventType::ON_PLAYER_SIT, pc) do |event|
          event = event.as(OnPlayerSit)
          tutorial_event(pc, 8388608)
        end
        pc.add_listener(listener)
      end
    elsif pc.has_listener?(EventType::ON_PLAYER_SIT)
      pc.remove_listener_if(EventType::ON_PLAYER_SIT) do |listener|
        listener.owner == pc
      end
    end

    if event_status & 256 != 0
      unless pc.has_listener?(EventType::ON_CREATURE_ATTACKED)
        listener = ConsumerEventListener.new(pc, EventType::ON_CREATURE_ATTACKED, pc) do |event|
          event = event.as(OnCreatureAttacked)
          pp = event.target.acting_player
          if pp && pp.current_hp <= pp.max_hp * 0.3
            tutorial_event(pp, 256)
          end
        end
        pc.add_listener(listener)
      end
    else
      pc.remove_listener_if(EventType::ON_CREATURE_ATTACKED) do |listener|
        listener.owner == pc
      end
    end

    qs.enable_tutorial_event(pc, event_status)
  end

  def on_first_talk(npc, pc)
    qs = get_quest_state!(pc)

    case npc.id
    when ROIEN
      talk_roien(pc, qs)
    when NEWBIE_HELPER_HUMAN_FIGHTER
      talk_carl(npc, pc, qs)
    when GALLINT
      talk_gallint(pc, qs)
    when NEWBIE_HELPER_HUMAN_MAGE
      talk_doff(npc, pc, qs)
    when MITRAELL
      talk_jundin(pc, qs)
    when NEWBIE_HELPER_DARK_ELF
      talk_poeny(npc, pc, qs)
    when NERUPA
      talk_nerupa(pc, qs)
    when NEWBIE_HELPER_ELF
      talk_mother_temp(npc, pc, qs)
    when LAFERON
      talk_foreman_laferon(pc, qs)
    when NEWBIE_HELPER_DWARF
      talk_miner_mai(npc, pc, qs)
    when VULKUS
      talk_guardian_vulkus(pc, qs)
    when NEWBIE_HELPER_ORC
      talk_shela_priestess(npc, pc, qs)
    when PERWAN
      talk_subelder_perwan(pc, qs)
    when NEWBIE_HELPER_KAMAEL
      talk_helper_krenisk(npc, pc, qs)
    end


    ""
  end

  def on_adv_event(event, npc, pc)
    event_id = event.to_i

    if event_id > 1_000_000
      fire_event(event_id, pc)
      return super
    end

    return "" unless pc

    if pc.dead?
      return super
    end

    qs = get_quest_state!(pc)

    return "" unless npc

    case npc.id
    when NEWBIE_HELPER_HUMAN_FIGHTER
      case qs.get_memo_state_ex(1)
      when 0
        qs.play_sound(Voice::TUTORIAL_VOICE_009A)
        qs.set_memo_state_ex(1, 1)
      when 3
        qs.play_sound(Voice::TUTORIAL_VOICE_010A)
      end

    when NEWBIE_HELPER_HUMAN_MAGE
      case qs.get_memo_state_ex(1)
      when 0
        qs.play_sound(Voice::TUTORIAL_VOICE_009B)
        qs.set_memo_state_ex(1, 1)
      when 3
        qs.play_sound(Voice::TUTORIAL_VOICE_010B)
      end

    when NEWBIE_HELPER_DARK_ELF
      case qs.get_memo_state_ex(1)
      when 0
        if !pc.mage_class?
          qs.play_sound(Voice::TUTORIAL_VOICE_009A)
        else
          qs.play_sound(Voice::TUTORIAL_VOICE_009B)
        end
        qs.set_memo_state_ex(1, 1)
      when 3
        qs.play_sound(Voice::TUTORIAL_VOICE_010D)
      end

    when NEWBIE_HELPER_ELF
      case qs.get_memo_state_ex(1)
      when 0
        if !pc.mage_class?
          qs.play_sound(Voice::TUTORIAL_VOICE_009A)
        else
          qs.play_sound(Voice::TUTORIAL_VOICE_009B)
        end
        qs.set_memo_state_ex(1, 1)
      when 3
        qs.play_sound(Voice::TUTORIAL_VOICE_010C)
      end

    when NEWBIE_HELPER_DWARF
      case qs.get_memo_state_ex(1)
      when 0
        qs.play_sound(Voice::TUTORIAL_VOICE_009A)
        qs.set_memo_state_ex(1, 1)
      when 3
        qs.play_sound(Voice::TUTORIAL_VOICE_010F)
      end

    when NEWBIE_HELPER_ORC
      case qs.get_memo_state_ex(1)
      when 0
        if !pc.mage_class?
          qs.play_sound(Voice::TUTORIAL_VOICE_009A)
        else
          qs.play_sound(Voice::TUTORIAL_VOICE_009C)
        end
        qs.set_memo_state_ex(1, 1)
      when 3
        qs.play_sound(Voice::TUTORIAL_VOICE_010E)
      end

    when NEWBIE_HELPER_KAMAEL
      case qs.get_memo_state_ex(1)
      when 0
        qs.play_sound(Voice::TUTORIAL_VOICE_009A)
        qs.set_memo_state_ex(1, 1)
      when 3
        qs.play_sound(Voice::TUTORIAL_VOICE_010G)
      end

    when ROIEN
      if event_id == ROIEN
        if qs.get_memo_state_ex(1) >= 4
          qs.show_question_mark(pc, 7)
          qs.play_sound(Sound::ITEMSOUND_QUEST_TUTORIAL)
          qs.play_sound(Voice::TUTORIAL_VOICE_025_1000)
        end
      end
      event_roien(event_id, pc, npc, qs)
    when GALLINT
      event_gallint(event_id, pc, npc, qs)
    when MITRAELL
      if event_id == MITRAELL
        if qs.get_memo_state_ex(1) >= 4
          qs.show_question_mark(pc, 7)
          qs.play_sound(Sound::ITEMSOUND_QUEST_TUTORIAL)
          qs.play_sound(Voice::TUTORIAL_VOICE_025_1000)
        end
      end
      event_jundin(event_id, pc, npc, qs)
    when NERUPA
      if event_id == NERUPA
        if qs.get_memo_state_ex(1) >= 4
          qs.show_question_mark(pc, 7)
          qs.play_sound(Sound::ITEMSOUND_QUEST_TUTORIAL)
          qs.play_sound(Voice::TUTORIAL_VOICE_025_1000)
        end
      end
      event_nerupa(event_id, pc, npc, qs)
    when LAFERON
      if event_id == LAFERON
        if qs.get_memo_state_ex(1) >= 4
          qs.show_question_mark(pc, 7)
          qs.play_sound(Sound::ITEMSOUND_QUEST_TUTORIAL)
          qs.play_sound(Voice::TUTORIAL_VOICE_025_1000)
        end
      end
      event_foreman_laferon(event_id, pc, npc, qs)
    when VULKUS
      if event_id == VULKUS
        if qs.get_memo_state_ex(1) >= 4
          qs.show_question_mark(pc, 7)
          qs.play_sound(Sound::ITEMSOUND_QUEST_TUTORIAL)
          qs.play_sound(Voice::TUTORIAL_VOICE_025_1000)
        end
      end
      event_guardian_vulkus(event_id, pc, npc, qs)
    when PERWAN
      if event_id == PERWAN
        if qs.get_memo_state_ex(1) >= 4
          qs.show_question_mark(pc, 7)
          qs.play_sound(Sound::ITEMSOUND_QUEST_TUTORIAL)
          qs.play_sound(Voice::TUTORIAL_VOICE_025_1000)
        end
      end
      event_subelder_perwan(event_id, pc, npc, qs)
    end


    ""
  end

  private def fire_event(timer_id, pc)
    return unless pc.is_a?(L2PcInstance)
    if pc.dead? || timer_id <= 1000000
      return
    end

    qs = pc.get_quest_state(self.class.simple_name).not_nil!

    case qs.get_memo_state_ex(1)
    when -2
      case pc.class_id
      when ClassId::FIGHTER
        qs.play_sound(Voice::TUTORIAL_VOICE_001A_2000)
        show_tutorial_html(pc, "tutorial-human-fighter-001.htm")
      when ClassId::MAGE
        qs.play_sound(Voice::TUTORIAL_VOICE_001B_2000)
        show_tutorial_html(pc, "tutorial-human-mage-001.htm")
      when ClassId::ELVEN_FIGHTER
        qs.play_sound(Voice::TUTORIAL_VOICE_001C_2000)
        show_tutorial_html(pc, "tutorial-elven-fighter-001.htm")
      when ClassId::ELVEN_MAGE
        qs.play_sound(Voice::TUTORIAL_VOICE_001D_2000)
        show_tutorial_html(pc, "tutorial-elven-mage-001.htm")
      when ClassId::DARK_FIGHTER
        qs.play_sound(Voice::TUTORIAL_VOICE_001E_2000)
        show_tutorial_html(pc, "tutorial-delf-fighter-001.htm")
      when ClassId::DARK_MAGE
        qs.play_sound(Voice::TUTORIAL_VOICE_001F_2000)
        show_tutorial_html(pc, "tutorial-delf-mage-001.htm")
      when ClassId::ORC_FIGHTER
        qs.play_sound(Voice::TUTORIAL_VOICE_001G_2000)
        show_tutorial_html(pc, "tutorial-orc-fighter-001.htm")
      when ClassId::ORC_MAGE
        qs.play_sound(Voice::TUTORIAL_VOICE_001H_2000)
        show_tutorial_html(pc, "tutorial-orc-mage-001.htm")
      when ClassId::DWARVEN_FIGHTER
        qs.play_sound(Voice::TUTORIAL_VOICE_001I_2000)
        show_tutorial_html(pc, "tutorial-dwarven-fighter-001.htm")
      when ClassId::MALE_SOLDIER, ClassId::FEMALE_SOLDIER
        qs.play_sound(Voice::TUTORIAL_VOICE_001K_2000)
        show_tutorial_html(pc, "tutorial-kamael-001.htm")
      end

      unless qs.has_quest_items?(TUTORIAL_GUIDE)
        qs.give_items(TUTORIAL_GUIDE, 1)
      end
      qs.start_quest_timer((pc.l2id + 1000000).to_s, 30000)
      qs.set_memo_state_ex(1, -3)
    when -3
      qs.play_sound(Voice::TUTORIAL_VOICE_002_1000)
    when -4
      qs.play_sound(Voice::TUTORIAL_VOICE_008_1000)
      qs.set_memo_state_ex(1, -5)
    end

  end

  private def tutorial_event(pc : L2PcInstance, event_id : Int32)
    return unless qs = pc.get_quest_state(self.class.simple_name)

    # TODO is custom! (L2J)
    if event_id == 0
      qs.close_tutorial_html(pc)
      return
    end

    memo_state = qs.memo_state
    memo_flag = memo_state & 2147483632

    if event_id < 0
      case event_id.abs
      when 1
        qs.close_tutorial_html(pc)
        qs.play_sound(Voice::TUTORIAL_VOICE_006_3500)
        qs.show_question_mark(pc, 1)
        qs.play_sound(Sound::ITEMSOUND_QUEST_TUTORIAL)
        qs.start_quest_timer((pc.l2id + 1000000).to_s, 30000)
        if qs.get_memo_state_ex(1) < 0
          qs.set_memo_state_ex(1, -4)
        end
      when 2
        qs.play_sound(Voice::TUTORIAL_VOICE_003_2000)
        show_tutorial_html(pc, "tutorial-02.htm")
        enable_tutorial_event(qs, memo_flag | 1)

        if qs.get_memo_state_ex(1) < 0
          qs.set_memo_state_ex(1, -5)
        end
      when 3
        show_tutorial_html(pc, "tutorial-03.htm")
        enable_tutorial_event(qs, memo_flag | 2)
      when 4
        show_tutorial_html(pc, "tutorial-04.htm")
        enable_tutorial_event(qs, memo_flag | 4)
      when 5
        show_tutorial_html(pc, "tutorial-05.htm")
        enable_tutorial_event(qs, memo_flag | 8)
      when 6
        show_tutorial_html(pc, "tutorial-06.htm")
        enable_tutorial_event(qs, memo_flag | 16)
      when 7
        show_tutorial_html(pc, "tutorial-100.htm")
        enable_tutorial_event(qs, memo_flag)
      when 8
        show_tutorial_html(pc, "tutorial-101.htm")
        enable_tutorial_event(qs, memo_flag)
      when 9
        show_tutorial_html(pc, "tutorial-102.htm")
        enable_tutorial_event(qs, memo_flag)
      when 10
        show_tutorial_html(pc, "tutorial-103.htm")
        enable_tutorial_event(qs, memo_flag)
      when 11
        show_tutorial_html(pc, "tutorial-104.htm")
        enable_tutorial_event(qs, memo_flag)
      when 12
        qs.close_tutorial_html(pc)
      end


      return
    end

    case event_id
    when 1
      if pc.level < 6
        qs.play_sound(Voice::TUTORIAL_VOICE_004_5000)
        show_tutorial_html(pc, "tutorial-03.htm")
        qs.play_sound(Sound::ITEMSOUND_QUEST_TUTORIAL)
        enable_tutorial_event(qs, memo_flag | 2)
      end
    when 2
      if pc.level < 6
        qs.play_sound(Voice::TUTORIAL_VOICE_005_5000)
        show_tutorial_html(pc, "tutorial-05.htm")
        qs.play_sound(Sound::ITEMSOUND_QUEST_TUTORIAL)
        enable_tutorial_event(qs, memo_flag | 8)
      end
    when 8
      if pc.level < 6
        show_tutorial_html(pc, "tutorial-human-fighter-007.htm")
        qs.play_sound(Sound::ITEMSOUND_QUEST_TUTORIAL)
        case pc.class_id
        when ClassId::FIGHTER
          qs.add_radar(-71424, 258336, -3109)
        when ClassId::MAGE
          qs.add_radar(-91036, 248044, -3568)
        when ClassId::ELVEN_FIGHTER, ClassId::ELVEN_MAGE
          qs.add_radar(46112, 41200, -3504)
        when ClassId::DARK_FIGHTER, ClassId::DARK_MAGE
          qs.add_radar(28384, 11056, -4233)
        when ClassId::ORC_FIGHTER, ClassId::ORC_MAGE
          qs.add_radar(-56736, -113680, -672)
        when ClassId::DWARVEN_FIGHTER
          qs.add_radar(108567, -173994, -406)
        when ClassId::MALE_SOLDIER, ClassId::FEMALE_SOLDIER
          qs.add_radar(-125872, 38016, 1251)
        end


        qs.play_sound(Voice::TUTORIAL_VOICE_007_3500)
        qs.memo_state = memo_flag | 2
        if qs.get_memo_state_ex(1) < 0
          qs.set_memo_state_ex(1, -5)
        end
      end
    when 256
      if pc.level < 6
        qs.play_sound(Voice::TUTORIAL_VOICE_017_1000)
        qs.show_question_mark(pc, 10)
        qs.play_sound(Sound::ITEMSOUND_QUEST_TUTORIAL)
        qs.memo_state = memo_state & ~256
        enable_tutorial_event(qs, (memo_flag & ~256) | 8388608)
      end
    when 512
      qs.show_question_mark(pc, 8)
      qs.play_sound(Voice::TUTORIAL_VOICE_016_1000)
      qs.play_sound(Sound::ITEMSOUND_QUEST_TUTORIAL)
      qs.memo_state = memo_state & ~512
    when 1024
      qs.memo_state = memo_state & ~1024
      case pc.class_id
      when ClassId::FIGHTER
        qs.add_radar(-83020, 242553, -3718)
      when ClassId::ELVEN_FIGHTER
        qs.add_radar(45061, 52468, -2796)
      when ClassId::DARK_FIGHTER
        qs.add_radar(10447, 14620, -4242)
      when ClassId::ORC_FIGHTER
        qs.add_radar(-46389, -113905, -21)
      when ClassId::DWARVEN_FIGHTER
        qs.add_radar(115271, -182692, -1445)
      when ClassId::MALE_SOLDIER, ClassId::FEMALE_SOLDIER
        qs.add_radar(-118132, 42788, 723)
      end


      unless pc.mage_class?
        qs.play_sound(Voice::TUTORIAL_VOICE_014_1000)
        qs.show_question_mark(pc, 9)
        qs.play_sound(Sound::ITEMSOUND_QUEST_TUTORIAL)
      end

      enable_tutorial_event(qs, memo_flag | 134217728)
      qs.memo_state = memo_state & ~1024
    when 134217728
      qs.show_question_mark(pc, 24)
      qs.play_sound(Voice::TUTORIAL_VOICE_020_1000)
      qs.play_sound(Sound::ITEMSOUND_QUEST_TUTORIAL)
      enable_tutorial_event(qs, memo_flag & ~134217728)
      qs.memo_state = memo_state & ~134217728
      enable_tutorial_event(qs, memo_flag | 2048)
    when 2048
      if pc.mage_class?
        qs.play_sound(Voice::TUTORIAL_VOICE_019_1000)
        qs.show_question_mark(pc, 11)
        qs.play_sound(Sound::ITEMSOUND_QUEST_TUTORIAL)
        case pc.class_id
        when ClassId::MAGE
          qs.add_radar(-84981, 244764, -3726)
        when ClassId::ELVEN_MAGE
          qs.add_radar(45701, 52459, -2796)
        when ClassId::DARK_MAGE
          qs.add_radar(10344, 14445, -4242)
        when ClassId::ORC_MAGE
          qs.add_radar(-46225, -113312, -21)
        end


        qs.memo_state = memo_state & ~2048
      end
      enable_tutorial_event(qs, memo_flag | 268435456)
    when 268435456
      if pc.class_id.fighter?
        qs.play_sound(Voice::TUTORIAL_VOICE_021_1000)
        qs.show_question_mark(pc, 25)
        qs.play_sound(Sound::ITEMSOUND_QUEST_TUTORIAL)
        qs.memo_state = memo_state & ~268435456
      end

      enable_tutorial_event(qs, memo_flag | 536870912)
    when 536870912
      case pc.class_id
      when ClassId::DWARVEN_FIGHTER, ClassId::MAGE, ClassId::ELVEN_FIGHTER,
           ClassId::ELVEN_MAGE, ClassId::DARK_MAGE, ClassId::DARK_FIGHTER,
           ClassId::MALE_SOLDIER, ClassId::FEMALE_SOLDIER
        qs.play_sound(Voice::TUTORIAL_VOICE_021_1000)
        qs.show_question_mark(pc, 25)
        qs.play_sound(Sound::ITEMSOUND_QUEST_TUTORIAL)
        qs.memo_state = memo_state & ~536870912
      else
        qs.play_sound(Voice::TUTORIAL_VOICE_030_1000)
        qs.show_question_mark(pc, 27)
        qs.play_sound(Sound::ITEMSOUND_QUEST_TUTORIAL)
        qs.memo_state = memo_state & ~536870912
      end

      enable_tutorial_event(qs, memo_flag | 1073741824)
    when 1073741824
      case pc.class_id
      when ClassId::ORC_FIGHTER, ClassId::ORC_MAGE
        qs.play_sound(Voice::TUTORIAL_VOICE_021_1000)
        qs.show_question_mark(pc, 25)
        qs.play_sound(Sound::ITEMSOUND_QUEST_TUTORIAL)
        qs.memo_state = memo_state & ~1073741824
      end


      enable_tutorial_event(qs, memo_flag | 67108864)
    when 67108864
      qs.show_question_mark(pc, 17)
      qs.play_sound(Sound::ITEMSOUND_QUEST_TUTORIAL)
      qs.memo_state = memo_state & ~67108864
      enable_tutorial_event(qs, memo_flag | 4096)
    when 4096
      qs.show_question_mark(pc, 13)
      qs.play_sound(Sound::ITEMSOUND_QUEST_TUTORIAL)
      qs.memo_state = memo_state & ~4096
      enable_tutorial_event(qs, memo_flag | 16777216)
    when 16777216
      unless pc.class_id.race.kamael?
        qs.play_sound(Voice::TUTORIAL_VOICE_023_1000)
        qs.show_question_mark(pc, 15)
        qs.play_sound(Sound::ITEMSOUND_QUEST_TUTORIAL)
        qs.memo_state = memo_state & ~16777216
      end

      enable_tutorial_event(qs, memo_flag | 32)
    when 16384
      if pc.class_id.race.kamael? && pc.class_id.level == 1
        qs.play_sound(Voice::TUTORIAL_VOICE_028_1000)
        qs.show_question_mark(pc, 15)
        qs.play_sound(Sound::ITEMSOUND_QUEST_TUTORIAL)
        qs.memo_state = memo_state & ~16384
      end

      enable_tutorial_event(qs, memo_flag | 64)
    when 33554432
      if get_one_time_quest_flag(pc, Q234_FATES_WHISPER) == 0
        qs.play_sound(Voice::TUTORIAL_VOICE_024_1000)
        qs.show_question_mark(pc, 16)
        qs.play_sound(Sound::ITEMSOUND_QUEST_TUTORIAL)
        qs.memo_state = memo_state & ~33554432
      end

      enable_tutorial_event(qs, memo_flag | 32768)
    when 32768
      if get_one_time_quest_flag(pc, Q234_FATES_WHISPER) == 1
        qs.show_question_mark(pc, 29)
        qs.play_sound(Sound::ITEMSOUND_QUEST_TUTORIAL)
        qs.memo_state = memo_state & ~32768
      end
    when 32
      if get_one_time_quest_flag(pc, Q128_PAILAKA_SONG_OF_ICE_AND_FIRE) == 0
        qs.show_question_mark(pc, 30)
        qs.play_sound(Sound::ITEMSOUND_QUEST_TUTORIAL)
        qs.memo_state = memo_state & ~32
      end

      enable_tutorial_event(qs, memo_flag | 16384)
    when 64
      if get_one_time_quest_flag(pc, Q129_PAILAKA_DEVILS_LEGACY) == 0
        qs.show_question_mark(pc, 31)
        qs.play_sound(Sound::ITEMSOUND_QUEST_TUTORIAL)
        qs.memo_state = memo_state & ~64
      end

      enable_tutorial_event(qs, memo_flag | 128)
    when 128
      if get_one_time_quest_flag(pc, Q144_PAIRAKA_WOUNDED_DRAGON) == 0
        qs.show_question_mark(pc, 32)
        qs.play_sound(Sound::ITEMSOUND_QUEST_TUTORIAL)
        qs.memo_state = memo_state & ~128
      end

      enable_tutorial_event(qs, memo_flag | 33554432)
    when 2097152
      if pc.level < 6
        qs.show_question_mark(pc, 23)
        qs.play_sound(Voice::TUTORIAL_VOICE_012_1000)
        qs.play_sound(Sound::ITEMSOUND_QUEST_TUTORIAL)
        qs.memo_state = memo_state & ~2097152
      end
    when 1048576
      if pc.level < 6
        qs.show_question_mark(pc, 5)
        qs.play_sound(Voice::TUTORIAL_VOICE_013_1000)
        qs.play_sound(Sound::ITEMSOUND_QUEST_TUTORIAL)
        qs.memo_state = memo_state & ~1048576
      end
    when 8388608
      if pc.level < 6
        qs.play_sound(Voice::TUTORIAL_VOICE_018_1000)
        show_tutorial_html(pc, "tutorial-21z.htm")
        qs.memo_state = memo_state & ~8388608
        enable_tutorial_event(qs, memo_flag & ~8388608)
      end
    end

  end

  private def level_up(pc, level)
    case level
    when 5
      tutorial_event(pc, 1024)
    when 6
      tutorial_event(pc, 134217728)
    when 7
      tutorial_event(pc, 2048)
    when 9
      tutorial_event(pc, 268435456)
    when 10
      tutorial_event(pc, 536870912)
    when 12
      tutorial_event(pc, 1073741824)
    when 15
      tutorial_event(pc, 67108864)
    when 18
      tutorial_event(pc, 4096)
      if !has_memo?(pc, Q10276_MUTATED_KANEUS_GLUDIO) || get_one_time_quest_flag(pc, Q10276_MUTATED_KANEUS_GLUDIO) == 0
        show_tutorial_html(pc, "tw-gludio.htm")
        play_sound(pc, Sound::ITEMSOUND_QUEST_TUTORIAL)
        show_radar(pc, -13900, 123822, -3112, 2)
      end
    when 28
      if !has_memo?(pc, Q10277_MUTATED_KANEUS_DION) || get_one_time_quest_flag(pc, Q10277_MUTATED_KANEUS_DION) == 0
        show_tutorial_html(pc, "tw-dion.htm")
        play_sound(pc, Sound::ITEMSOUND_QUEST_TUTORIAL)
        show_radar(pc, 18199, 146081, -3080, 2)
      end
    when 35
      tutorial_event(pc, 16777216)
    when 36
      tutorial_event(pc, 32)
    when 38
      if !has_memo?(pc, Q10278_MUTATED_KANEUS_HEINE) || get_one_time_quest_flag(pc, Q10278_MUTATED_KANEUS_HEINE) == 0
        show_tutorial_html(pc, "tw-heine.htm")
        play_sound(pc, Sound::ITEMSOUND_QUEST_TUTORIAL)
        show_radar(pc, 108384, 221563, -3592, 2)
      end
    when 39
      if pc.race.kamael?
        tutorial_event(pc, 16384)
      end
    when 48
      if !has_memo?(pc, Q10279_MUTATED_KANEUS_OREN) || get_one_time_quest_flag(pc, Q10279_MUTATED_KANEUS_OREN) == 0
        show_tutorial_html(pc, "tw-oren.htm")
        play_sound(pc, Sound::ITEMSOUND_QUEST_TUTORIAL)
        show_radar(pc, 81023, 56456, -1552, 2)
      end
    when 58
      if !has_memo?(pc, Q10280_MUTATED_KANEUS_SCHUTTGART) || get_one_time_quest_flag(pc, Q10280_MUTATED_KANEUS_SCHUTTGART) == 0
        show_tutorial_html(pc, "tw-schuttgart.htm")
        play_sound(pc, Sound::ITEMSOUND_QUEST_TUTORIAL)
        show_radar(pc, 85868, -142164, -1342, 2)
      end
    when 61
      tutorial_event(pc, 64)
    when 68
      if !has_memo?(pc, Q10281_MUTATED_KANEUS_RUNE) || get_one_time_quest_flag(pc, Q10281_MUTATED_KANEUS_RUNE) == 0
        show_tutorial_html(pc, "tw-rune.htm")
        play_sound(pc, Sound::ITEMSOUND_QUEST_TUTORIAL)
        show_radar(pc, 42596, -47988, -800, 2)
      end
    when 73
      tutorial_event(pc, 128)
    when 79
      if !has_memo?(pc, Q192_SEVEN_SIGNS_SERIES_OF_DOUBT) || get_one_time_quest_flag(pc, Q192_SEVEN_SIGNS_SERIES_OF_DOUBT) == 0
        show_tutorial_html(pc, "tutorial-ss-79.htm")
        play_sound(pc, Sound::ITEMSOUND_QUEST_TUTORIAL)
        show_radar(pc, 81655, 54736, -1509, 2)
      end
    when 81
      if !has_memo?(pc, Q10292_SEVEN_SIGNS_GIRL_OF_DOUBT) || get_one_time_quest_flag(pc, Q10292_SEVEN_SIGNS_GIRL_OF_DOUBT) == 0
        show_tutorial_html(pc, "tutorial-ss-81.htm")
        play_sound(pc, Sound::ITEMSOUND_QUEST_TUTORIAL)
        show_radar(pc, 146995, 23755, -1984, 2)
      end
    end

  end

  private def select_from_menu(pc, reply)
    case reply
    when 1
      show_tutorial_html(pc, "tutorial-22g.htm")
    when 2
      show_tutorial_html(pc, "tutorial-22w.htm")
    when 3
      show_tutorial_html(pc, "tutorial-22ap.htm")
    when 4
      show_tutorial_html(pc, "tutorial-22ad.htm")
    when 5
      show_tutorial_html(pc, "tutorial-22bt.htm")
    when 6
      show_tutorial_html(pc, "tutorial-22bh.htm")
    when 7
      show_tutorial_html(pc, "tutorial-22cs.htm")
    when 8
      show_tutorial_html(pc, "tutorial-22cn.htm")
    when 9
      show_tutorial_html(pc, "tutorial-22cw.htm")
    when 10
      show_tutorial_html(pc, "tutorial-22db.htm")
    when 11
      show_tutorial_html(pc, "tutorial-22dp.htm")
    when 12
      show_tutorial_html(pc, "tutorial-22et.htm")
    when 13
      show_tutorial_html(pc, "tutorial-22es.htm")
    when 14
      show_tutorial_html(pc, "tutorial-22fp.htm")
    when 15
      show_tutorial_html(pc, "tutorial-22fs.htm")
    when 16
      show_tutorial_html(pc, "tutorial-22gs.htm")
    when 17
      show_tutorial_html(pc, "tutorial-22ge.htm")
    when 18
      show_tutorial_html(pc, "tutorial-22ko.htm")
    when 19
      show_tutorial_html(pc, "tutorial-22kw.htm")
    when 20
      show_tutorial_html(pc, "tutorial-22ns.htm")
    when 21
      show_tutorial_html(pc, "tutorial-22nb.htm")
    when 22
      show_tutorial_html(pc, "tutorial-22oa.htm")
    when 23
      show_tutorial_html(pc, "tutorial-22op.htm")
    when 24
      show_tutorial_html(pc, "tutorial-22ps.htm")
    when 25
      show_tutorial_html(pc, "tutorial-22pp.htm")
    when 26
      case pc.class_id
      when ClassId::WARRIOR
        show_tutorial_html(pc, "tutorial-22.htm")
      when ClassId::KNIGHT
        show_tutorial_html(pc, "tutorial-22a.htm")
      when ClassId::ROGUE
        show_tutorial_html(pc, "tutorial-22b.htm")
      when ClassId::WIZARD
        show_tutorial_html(pc, "tutorial-22c.htm")
      when ClassId::CLERIC
        show_tutorial_html(pc, "tutorial-22d.htm")
      when ClassId::ELVEN_KNIGHT
        show_tutorial_html(pc, "tutorial-22e.htm")
      when ClassId::ELVEN_SCOUT
        show_tutorial_html(pc, "tutorial-22f.htm")
      when ClassId::ELVEN_WIZARD
        show_tutorial_html(pc, "tutorial-22g.htm")
      when ClassId::ORACLE
        show_tutorial_html(pc, "tutorial-22h.htm")
      when ClassId::ORC_RAIDER
        show_tutorial_html(pc, "tutorial-22i.htm")
      when ClassId::ORC_MONK
        show_tutorial_html(pc, "tutorial-22j.htm")
      when ClassId::ORC_SHAMAN
        show_tutorial_html(pc, "tutorial-22k.htm")
      when ClassId::SCAVENGER
        show_tutorial_html(pc, "tutorial-22l.htm")
      when ClassId::ARTISAN
        show_tutorial_html(pc, "tutorial-22m.htm")
      when ClassId::PALUS_KNIGHT
        show_tutorial_html(pc, "tutorial-22n.htm")
      when ClassId::ASSASSIN
        show_tutorial_html(pc, "tutorial-22o.htm")
      when ClassId::DARK_WIZARD
        show_tutorial_html(pc, "tutorial-22p.htm")
      when ClassId::SHILLIEN_ORACLE
        show_tutorial_html(pc, "tutorial-22q.htm")
      else
        show_tutorial_html(pc, "tutorial-22qe.htm")
      end
    when 27
      show_tutorial_html(pc, "tutorial-29.htm")
    when 28
      show_tutorial_html(pc, "tutorial-28.htm")
    when 29
      show_tutorial_html(pc, "tutorial-07a.htm")
    when 30
      show_tutorial_html(pc, "tutorial-07b.htm")
    when 31
      case pc.class_id
      when ClassId::TROOPER
        show_tutorial_html(pc, "tutorial-28a.htm")
      when ClassId::WARDER
        show_tutorial_html(pc, "tutorial-28b.htm")
      end

    when 32
      show_tutorial_html(pc, "tutorial-22qa.htm")
    when 33
      case pc.class_id
      when ClassId::TROOPER
        show_tutorial_html(pc, "tutorial-22qb.htm")
      when ClassId::WARDER
        show_tutorial_html(pc, "tutorial-22qc.htm")
      end

    when 34
      show_tutorial_html(pc, "tutorial-22qd.htm")
    end

  end

  private def question_mark_clicked(pc, question_id)
    qs = pc.get_quest_state(self.class.simple_name).not_nil!

    memo_flag = qs.memo_state & 2147483392

    case question_id
    when 1
      qs.play_sound(Voice::TUTORIAL_VOICE_007_3500)

      if qs.get_memo_state_ex(1) < 0
        qs.set_memo_state_ex(1, -5)
      end

      case pc.class_id
      when ClassId::FIGHTER
        show_tutorial_html(pc, "tutorial-human-fighter-007.htm")
        qs.add_radar(-71424, 258336, -3109)
      when ClassId::MAGE
        show_tutorial_html(pc, "tutorial-human-fighter-007.htm")
        qs.add_radar(-91036, 248044, -3568)
      when ClassId::ELVEN_FIGHTER, ClassId::ELVEN_MAGE
        show_tutorial_html(pc, "tutorial-human-fighter-007.htm")
        qs.add_radar(-91036, 248044, -3568)
      when ClassId::DARK_FIGHTER, ClassId::DARK_MAGE
        show_tutorial_html(pc, "tutorial-human-fighter-007.htm")
        qs.add_radar(28384, 11056, -4233)
      when ClassId::ORC_FIGHTER, ClassId::ORC_MAGE
        show_tutorial_html(pc, "tutorial-human-fighter-007.htm")
        qs.add_radar(-56736, -113680, -672)
      when ClassId::DWARVEN_FIGHTER
        show_tutorial_html(pc, "tutorial-human-fighter-007.htm")
        qs.add_radar(108567, -173994, -406)
      when ClassId::MALE_SOLDIER, ClassId::FEMALE_SOLDIER
        show_tutorial_html(pc, "tutorial-human-fighter-007.htm")
        qs.add_radar(-125872, 38016, 1251)
      end


      qs.memo_state = memo_flag | 2
    when 2
      case pc.class_id
      when ClassId::FIGHTER
        show_tutorial_html(pc, "tutorial-human-fighter-008.htm")
      when ClassId::MAGE
        show_tutorial_html(pc, "tutorial-human-mage-008.htm")
      when ClassId::ELVEN_FIGHTER, ClassId::ELVEN_MAGE
        show_tutorial_html(pc, "tutorial-elf-008.htm")
      when ClassId::DARK_FIGHTER, ClassId::DARK_MAGE
        show_tutorial_html(pc, "tutorial-delf-008.htm")
      when ClassId::ORC_FIGHTER, ClassId::ORC_MAGE
        show_tutorial_html(pc, "tutorial-orc-008.htm")
      when ClassId::DWARVEN_FIGHTER
        show_tutorial_html(pc, "tutorial-dwarven-fighter-008.htm")
      when ClassId::MALE_SOLDIER, ClassId::FEMALE_SOLDIER
        show_tutorial_html(pc, "tutorial-kamael-008.htm")
      end


      qs.memo_state = memo_flag | 2
    when 3
      show_tutorial_html(pc, "tutorial-09.htm")
      enable_tutorial_event(qs, memo_flag | 1048576)
      qs.memo_state |= 1048576 # TODO find better way
    when 4
      show_tutorial_html(pc, "tutorial-10.htm")
    when 5
      case pc.class_id
      when ClassId::FIGHTER
        qs.add_radar(-71424, 258336, -3109)
      when ClassId::MAGE
        qs.add_radar(-91036, 248044, -3568)
      when ClassId::ELVEN_FIGHTER, ClassId::ELVEN_MAGE
        qs.add_radar(46112, 41200, -3504)
      when ClassId::DARK_FIGHTER, ClassId::DARK_MAGE
        qs.add_radar(28384, 11056, -4233)
      when ClassId::ORC_FIGHTER, ClassId::ORC_MAGE
        qs.add_radar(-56736, -113680, -672)
      when ClassId::DWARVEN_FIGHTER
        qs.add_radar(108567, -173994, -406)
      when ClassId::MALE_SOLDIER, ClassId::FEMALE_SOLDIER
        qs.add_radar(-125872, 38016, 1251)
      end


      show_tutorial_html(pc, "tutorial-11.htm")
    when 7
      show_tutorial_html(pc, "tutorial-15.htm")
      qs.memo_state = memo_flag | 5
    when 8
      show_tutorial_html(pc, "tutorial-18.htm")
    when 9
      unless pc.mage_class?
        case pc.race
        when Race::HUMAN, Race::ELF, Race::DARK_ELF
          show_tutorial_html(pc, "tutorial-fighter-017.htm")
        when Race::DWARF
          show_tutorial_html(pc, "tutorial-fighter-dwarf-017.htm")
        when Race::ORC
          show_tutorial_html(pc, "tutorial-fighter-orc-017.htm")
        when Race::KAMAEL
          show_tutorial_html(pc, "tutorial-kamael-017.htm")
        end

      end
    when 10
      show_tutorial_html(pc, "tutorial-19.htm")
    when 11
      case pc.race
      when Race::HUMAN
        show_tutorial_html(pc, "tutorial-mage-020.htm")
      when Race::ELF, Race::DARK_ELF
        show_tutorial_html(pc, "tutorial-mage-elf-020.htm")
      when Race::ORC
        show_tutorial_html(pc, "tutorial-mage-orc-020.htm")
      end

    when 12
      show_tutorial_html(pc, "tutorial-15.htm")
    when 13
      case pc.class_id
      when ClassId::FIGHTER
        show_tutorial_html(pc, "tutorial-21.htm")
      when ClassId::MAGE
        show_tutorial_html(pc, "tutorial-21a.htm")
      when ClassId::ELVEN_FIGHTER
        show_tutorial_html(pc, "tutorial-21b.htm")
      when ClassId::ELVEN_MAGE
        show_tutorial_html(pc, "tutorial-21c.htm")
      when ClassId::ORC_FIGHTER
        show_tutorial_html(pc, "tutorial-21d.htm")
      when ClassId::ORC_MAGE
        show_tutorial_html(pc, "tutorial-21e.htm")
      when ClassId::DWARVEN_FIGHTER
        show_tutorial_html(pc, "tutorial-21f.htm")
      when ClassId::DARK_FIGHTER
        show_tutorial_html(pc, "tutorial-21g.htm")
      when ClassId::DARK_MAGE
        show_tutorial_html(pc, "tutorial-21h.htm")
      when ClassId::MALE_SOLDIER
        show_tutorial_html(pc, "tutorial-21i.htm")
      when ClassId::FEMALE_SOLDIER
        show_tutorial_html(pc, "tutorial-21j.htm")
      end

    when 15
      if !pc.race.kamael?
        show_tutorial_html(pc, "tutorial-28.htm")
      elsif pc.class_id.trooper?
        show_tutorial_html(pc, "tutorial-28a.htm")
      elsif pc.class_id.warder?
        show_tutorial_html(pc, "tutorial-28b.htm")
      end
    when 16
      show_tutorial_html(pc, "tutorial-30.htm")
    when 17
      show_tutorial_html(pc, "tutorial-27.htm")
    when 19
      show_tutorial_html(pc, "tutorial-07.htm")
    when 20
      show_tutorial_html(pc, "tutorial-14.htm")
    when 21
      show_tutorial_html(pc, "tutorial-newbie-001.htm")
    when 22
      show_tutorial_html(pc, "tutorial-14.htm")
    when 23
      show_tutorial_html(pc, "tutorial-24.htm")
    when 24
      case pc.race
      when Race::HUMAN
        show_tutorial_html(pc, "tutorial-newbie-003a.htm")
      when Race::ELF
        show_tutorial_html(pc, "tutorial-newbie-003b.htm")
      when Race::DARK_ELF
        show_tutorial_html(pc, "tutorial-newbie-003c.htm")
      when Race::ORC
        show_tutorial_html(pc, "tutorial-newbie-003d.htm")
      when Race::DWARF
        show_tutorial_html(pc, "tutorial-newbie-003e.htm")
      when Race::KAMAEL
        show_tutorial_html(pc, "tutorial-newbie-003f.htm")
      end

    when 25
      case pc.class_id
      when ClassId::FIGHTER
        show_tutorial_html(pc, "tutorial-newbie-002a.htm")
      when ClassId::MAGE
        show_tutorial_html(pc, "tutorial-newbie-002b.htm")
      when ClassId::ELVEN_FIGHTER, ClassId::ELVEN_MAGE
        show_tutorial_html(pc, "tutorial-newbie-002c.htm")
      when ClassId::DARK_MAGE
        show_tutorial_html(pc, "tutorial-newbie-002d.htm")
      when ClassId::DARK_FIGHTER
        show_tutorial_html(pc, "tutorial-newbie-002e.htm")
      when ClassId::DWARVEN_FIGHTER
        show_tutorial_html(pc, "tutorial-newbie-002g.htm")
      when ClassId::ORC_FIGHTER, ClassId::ORC_MAGE
        show_tutorial_html(pc, "tutorial-newbie-002f.htm")
      when ClassId::MALE_SOLDIER, ClassId::FEMALE_SOLDIER
        show_tutorial_html(pc, "tutorial-newbie-002i.htm")
      end

    when 26
      if !pc.mage_class? || pc.class_id.orc_mage?
        show_tutorial_html(pc, "tutorial-newbie-004a.htm")
      else
        show_tutorial_html(pc, "tutorial-newbie-004b.htm")
      end
    when 27
      case pc.class_id
      when ClassId::FIGHTER, ClassId::ORC_MAGE, ClassId::ORC_FIGHTER
        show_tutorial_html(pc, "tutorial-newbie-002h.htm")
      end

    when 28
      show_tutorial_html(pc, "tutorial-31.htm")
    when 29
      show_tutorial_html(pc, "tutorial-32.htm")
    when 30
      show_tutorial_html(pc, "tutorial-33.htm")
    when 31
      show_tutorial_html(pc, "tutorial-34.htm")
    when 32
      show_tutorial_html(pc, "tutorial-35.htm")
    when 33
      case pc.level
      when 18
        show_tutorial_html(pc, "tw-gludio.htm")
      when 28
        show_tutorial_html(pc, "tw-dion.htm")
      when 38
        show_tutorial_html(pc, "tw-heine.htm")
      when 48
        show_tutorial_html(pc, "tw-oren.htm")
      when 58
        show_tutorial_html(pc, "tw-shuttgart.htm")
      when 68
        show_tutorial_html(pc, "tw-rune.htm")
      end

    when 34
      if pc.level == 79
        show_tutorial_html(pc, "tutorial-ss-79.htm")
      end
    end

  end

  private def user_connected(pc)
    unless qs = get_quest_state(pc, true)
      return
    end

    unless qs.started?
      qs.state = State::STARTED
    end

    if pc.level < 6
      if get_one_time_quest_flag(pc, 255) != 0
        return
      end
      memo_state = qs.memo_state
      debug "Memo state: #{memo_state}."
      if memo_state == -1
        memo_state = 0
        memo_flag = 0
      else
        memo_flag = memo_state & 255
        memo_state = memo_state & 2147483392
      end


      case memo_flag
      when 0
        qs.start_quest_timer((pc.l2id + 1000000).to_s, 10000)
        memo_state = 2147483392 & ~(8388608 | 1048576)
        qs.memo_state = 1 | memo_state
        if qs.get_memo_state_ex(1) < 0
          qs.set_memo_state_ex(1, -2)
        end
      when 1
        qs.show_question_mark(pc, 1)
        qs.play_sound(Voice::TUTORIAL_VOICE_006_1000)
        qs.play_sound(Sound::ITEMSOUND_QUEST_TUTORIAL)
      when 2
        if has_memo?(pc, Q201_TUTORIAL_HUMAN_FIGHTER) || has_memo?(pc, Q202_TUTORIAL_HUMAN_MAGE) || has_memo?(pc, Q203_TUTORIAL_ELF) || has_memo?(pc, Q204_TUTORIAL_DARK_ELF) || has_memo?(pc, Q205_TUTORIAL_ORC) || has_memo?(pc, Q206_TUTORIAL_DWARF)
          qs.show_question_mark(pc, 6)
          qs.play_sound(Sound::ITEMSOUND_QUEST_TUTORIAL)
        else
          qs.show_question_mark(pc, 2)
          qs.play_sound(Sound::ITEMSOUND_QUEST_TUTORIAL)
        end
      when 3
        state_mark = 1
        if qs.get_quest_items_count(BLUE_GEMSTONE) == 1
          state_mark = 3
        elsif qs.get_memo_state_ex(1) == 2
          state_mark = 2
        end

        case state_mark
        when 1
          qs.show_question_mark(pc, 3)
        when 2
          qs.show_question_mark(pc, 4)
        when 3
          qs.show_question_mark(pc, 5)
        end

        qs.play_sound(Sound::ITEMSOUND_QUEST_TUTORIAL)
      when 4
        qs.show_question_mark(pc, 12)
        qs.play_sound(Sound::ITEMSOUND_QUEST_TUTORIAL)
      end

      enable_tutorial_event(qs, memo_state)
    else
      case pc.level
      when 18
        if has_memo?(pc, 10276) && get_one_time_quest_flag(pc, 10276) == 0
          qs.show_question_mark(pc, 33)
          qs.play_sound(Sound::ITEMSOUND_QUEST_TUTORIAL)
        end
      when 28
        if has_memo?(pc, 10277) && get_one_time_quest_flag(pc, 10277) == 0
          qs.show_question_mark(pc, 33)
          qs.play_sound(Sound::ITEMSOUND_QUEST_TUTORIAL)
        end
      when 38
        if has_memo?(pc, 10278) && get_one_time_quest_flag(pc, 10278) == 0
          qs.show_question_mark(pc, 33)
          qs.play_sound(Sound::ITEMSOUND_QUEST_TUTORIAL)
        end
      when 48
        if has_memo?(pc, 10279) && get_one_time_quest_flag(pc, 10279) == 0
          qs.show_question_mark(pc, 33)
          qs.play_sound(Sound::ITEMSOUND_QUEST_TUTORIAL)
        end
      when 58
        if has_memo?(pc, 10280) && get_one_time_quest_flag(pc, 10280) == 0
          qs.show_question_mark(pc, 33)
          qs.play_sound(Sound::ITEMSOUND_QUEST_TUTORIAL)
        end
      when 68
        if has_memo?(pc, 10281) && get_one_time_quest_flag(pc, 10281) == 0
          qs.show_question_mark(pc, 33)
          qs.play_sound(Sound::ITEMSOUND_QUEST_TUTORIAL)
        end
      when 79
        if has_memo?(pc, 192) && get_one_time_quest_flag(pc, 192) == 0
          qs.show_question_mark(pc, 34)
          qs.play_sound(Sound::ITEMSOUND_QUEST_TUTORIAL)
        end
      end

      territory_war_id = qs.get_dominion_siege_id(pc)
      territory_war_state = qs.get_nr_memo_state_ex(pc, 728, 1)

      if territory_war_id > 0 && qs.get_dominion_war_state(territory_war_id) == 5
        if !qs.has_nr_memo?(pc, 728)
          qs.set_nr_memo(pc, 728)
          qs.set_nr_memo_state(pc, 728, 0)
          qs.set_nr_memo_state_ex(pc, 728, 1, territory_war_id)
        elsif territory_war_id != territory_war_state
          qs.set_nr_memo_state(pc, 728, 0)
          qs.set_nr_memo_state_ex(pc, 728, 1, territory_war_id)
        end

        case territory_war_id
        when 81
          if qs.get_dominion_war_state(TW_GLUDIO) == 5
            if !qs.has_nr_memo?(pc, Q717_FOR_THE_SAKE_OF_THE_TERRITORY_GLUDIO)
              qs.set_nr_memo(pc, Q717_FOR_THE_SAKE_OF_THE_TERRITORY_GLUDIO)
              qs.set_nr_memo_state(pc, Q717_FOR_THE_SAKE_OF_THE_TERRITORY_GLUDIO, 0)
              qs.set_nr_flag_journal(pc, Q717_FOR_THE_SAKE_OF_THE_TERRITORY_GLUDIO, 1)
              qs.show_question_mark(pc, Q717_FOR_THE_SAKE_OF_THE_TERRITORY_GLUDIO)
              qs.play_sound(Sound::ITEMSOUND_QUEST_MIDDLE)
            else
              qs.show_question_mark(pc, Q717_FOR_THE_SAKE_OF_THE_TERRITORY_GLUDIO)
              qs.play_sound(Sound::ITEMSOUND_QUEST_MIDDLE)
            end
          end
        when 82
          if qs.get_dominion_war_state(TW_DION) == 5
            if !qs.has_nr_memo?(pc, Q718_FOR_THE_SAKE_OF_THE_TERRITORY_DION)
              qs.set_nr_memo(pc, Q718_FOR_THE_SAKE_OF_THE_TERRITORY_DION)
              qs.set_nr_memo_state(pc, Q718_FOR_THE_SAKE_OF_THE_TERRITORY_DION, 0)
              qs.set_nr_flag_journal(pc, Q718_FOR_THE_SAKE_OF_THE_TERRITORY_DION, 1)
              qs.show_question_mark(pc, Q718_FOR_THE_SAKE_OF_THE_TERRITORY_DION)
              qs.play_sound(Sound::ITEMSOUND_QUEST_MIDDLE)
            else
              qs.show_question_mark(pc, Q718_FOR_THE_SAKE_OF_THE_TERRITORY_DION)
              qs.play_sound(Sound::ITEMSOUND_QUEST_MIDDLE)
            end
          end
        when 83
          if qs.get_dominion_war_state(TW_GIRAN) == 5
            if !qs.has_nr_memo?(pc, Q719_FOR_THE_SAKE_OF_THE_TERRITORY_GIRAN)
              qs.set_nr_memo(pc, Q719_FOR_THE_SAKE_OF_THE_TERRITORY_GIRAN)
              qs.set_nr_memo_state(pc, Q719_FOR_THE_SAKE_OF_THE_TERRITORY_GIRAN, 0)
              qs.set_nr_flag_journal(pc, Q719_FOR_THE_SAKE_OF_THE_TERRITORY_GIRAN, 1)
              qs.show_question_mark(pc, Q719_FOR_THE_SAKE_OF_THE_TERRITORY_GIRAN)
              qs.play_sound(Sound::ITEMSOUND_QUEST_MIDDLE)
            else
              qs.show_question_mark(pc, Q719_FOR_THE_SAKE_OF_THE_TERRITORY_GIRAN)
              qs.play_sound(Sound::ITEMSOUND_QUEST_MIDDLE)
            end
          end
        when 84
          if qs.get_dominion_war_state(TW_OREN) == 5
            if !qs.has_nr_memo?(pc, Q720_FOR_THE_SAKE_OF_THE_TERRITORY_OREN)
              qs.set_nr_memo(pc, Q720_FOR_THE_SAKE_OF_THE_TERRITORY_OREN)
              qs.set_nr_memo_state(pc, Q720_FOR_THE_SAKE_OF_THE_TERRITORY_OREN, 0)
              qs.set_nr_flag_journal(pc, Q720_FOR_THE_SAKE_OF_THE_TERRITORY_OREN, 1)
              qs.show_question_mark(pc, Q720_FOR_THE_SAKE_OF_THE_TERRITORY_OREN)
              qs.play_sound(Sound::ITEMSOUND_QUEST_MIDDLE)
            else
              qs.show_question_mark(pc, Q720_FOR_THE_SAKE_OF_THE_TERRITORY_OREN)
              qs.play_sound(Sound::ITEMSOUND_QUEST_MIDDLE)
            end
          end
        when 85
          if qs.get_dominion_war_state(TW_ADEN) == 5
            if !qs.has_nr_memo?(pc, Q721_FOR_THE_SAKE_OF_THE_TERRITORY_ADEN)
              qs.set_nr_memo(pc, Q721_FOR_THE_SAKE_OF_THE_TERRITORY_ADEN)
              qs.set_nr_memo_state(pc, Q721_FOR_THE_SAKE_OF_THE_TERRITORY_ADEN, 0)
              qs.set_nr_flag_journal(pc, Q721_FOR_THE_SAKE_OF_THE_TERRITORY_ADEN, 1)
              qs.show_question_mark(pc, Q721_FOR_THE_SAKE_OF_THE_TERRITORY_ADEN)
              qs.play_sound(Sound::ITEMSOUND_QUEST_MIDDLE)
            else
              qs.show_question_mark(pc, Q721_FOR_THE_SAKE_OF_THE_TERRITORY_ADEN)
              qs.play_sound(Sound::ITEMSOUND_QUEST_MIDDLE)
            end
          end
        when 86
          if qs.get_dominion_war_state(TW_HEINE) == 5
            if !qs.has_nr_memo?(pc, Q722_FOR_THE_SAKE_OF_THE_TERRITORY_INNADRIL)
              qs.set_nr_memo(pc, Q722_FOR_THE_SAKE_OF_THE_TERRITORY_INNADRIL)
              qs.set_nr_memo_state(pc, Q722_FOR_THE_SAKE_OF_THE_TERRITORY_INNADRIL, 0)
              qs.set_nr_flag_journal(pc, Q722_FOR_THE_SAKE_OF_THE_TERRITORY_INNADRIL, 1)
              qs.show_question_mark(pc, Q722_FOR_THE_SAKE_OF_THE_TERRITORY_INNADRIL)
              qs.play_sound(Sound::ITEMSOUND_QUEST_MIDDLE)
            else
              qs.show_question_mark(pc, Q722_FOR_THE_SAKE_OF_THE_TERRITORY_INNADRIL)
              qs.play_sound(Sound::ITEMSOUND_QUEST_MIDDLE)
            end
          end
        when 87
          if qs.get_dominion_war_state(TW_GODDARD) == 5
            if !qs.has_nr_memo?(pc, Q723_FOR_THE_SAKE_OF_THE_TERRITORY_GODDARD)
              qs.set_nr_memo(pc, Q723_FOR_THE_SAKE_OF_THE_TERRITORY_GODDARD)
              qs.set_nr_memo_state(pc, Q723_FOR_THE_SAKE_OF_THE_TERRITORY_GODDARD, 0)
              qs.set_nr_flag_journal(pc, Q723_FOR_THE_SAKE_OF_THE_TERRITORY_GODDARD, 1)
              qs.show_question_mark(pc, Q723_FOR_THE_SAKE_OF_THE_TERRITORY_GODDARD)
              qs.play_sound(Sound::ITEMSOUND_QUEST_MIDDLE)
            else
              qs.show_question_mark(pc, Q723_FOR_THE_SAKE_OF_THE_TERRITORY_GODDARD)
              qs.play_sound(Sound::ITEMSOUND_QUEST_MIDDLE)
            end
          end
        when 88
          if qs.get_dominion_war_state(TW_RUNE) == 5
            if !qs.has_nr_memo?(pc, Q724_FOR_THE_SAKE_OF_THE_TERRITORY_RUNE)
              qs.set_nr_memo(pc, Q724_FOR_THE_SAKE_OF_THE_TERRITORY_RUNE)
              qs.set_nr_memo_state(pc, Q724_FOR_THE_SAKE_OF_THE_TERRITORY_RUNE, 0)
              qs.set_nr_flag_journal(pc, Q724_FOR_THE_SAKE_OF_THE_TERRITORY_RUNE, 1)
              qs.show_question_mark(pc, Q724_FOR_THE_SAKE_OF_THE_TERRITORY_RUNE)
              qs.play_sound(Sound::ITEMSOUND_QUEST_MIDDLE)
            else
              qs.show_question_mark(pc, Q724_FOR_THE_SAKE_OF_THE_TERRITORY_RUNE)
              qs.play_sound(Sound::ITEMSOUND_QUEST_MIDDLE)
            end
          end
        when 89
          if qs.get_dominion_war_state(TW_SCHUTTGART) == 5
            if !qs.has_nr_memo?(pc, Q725_FOR_THE_SAKE_OF_THE_TERRITORY_SCHUTTGART)
              qs.set_nr_memo(pc, Q725_FOR_THE_SAKE_OF_THE_TERRITORY_SCHUTTGART)
              qs.set_nr_memo_state(pc, Q725_FOR_THE_SAKE_OF_THE_TERRITORY_SCHUTTGART, 0)
              qs.set_nr_flag_journal(pc, Q725_FOR_THE_SAKE_OF_THE_TERRITORY_SCHUTTGART, 1)
              qs.show_question_mark(pc, Q725_FOR_THE_SAKE_OF_THE_TERRITORY_SCHUTTGART)
              qs.play_sound(Sound::ITEMSOUND_QUEST_MIDDLE)
            else
              qs.show_question_mark(pc, Q725_FOR_THE_SAKE_OF_THE_TERRITORY_SCHUTTGART)
              qs.play_sound(Sound::ITEMSOUND_QUEST_MIDDLE)
            end
          end
        end
      else
        if qs.has_nr_memo?(pc, Q728_TERRITORY_WAR)
          if territory_war_state >= 81 && territory_war_state <= 89
            tw_nr_state = qs.get_nr_memo_state(pc, Q728_TERRITORY_WAR)
            tw_nr_state_for_current_war = qs.get_nr_memo_state(pc, 636 + territory_war_state)
            if tw_nr_state_for_current_war >= 0
              qs.set_nr_memo_state(pc, Q728_TERRITORY_WAR, tw_nr_state_for_current_war + tw_nr_state)
              qs.remove_nr_memo(pc, 636 + territory_war_state)
            end
          end
        end
        if qs.has_nr_memo?(pc, 739) && qs.get_nr_memo_state(pc, 739) > 0
          qs.set_nr_memo_state(pc, 739, 0)
        end
        if qs.has_nr_memo?(pc, Q729_PROTECT_THE_TERRITORY_CATAPULT)
          qs.remove_nr_memo(pc, 729)
        end
        if qs.has_nr_memo?(pc, Q730_PROTECT_THE_SUPPLIES_SAFE)
          qs.remove_nr_memo(pc, 730)
        end
        if qs.has_nr_memo?(pc, Q731_PROTECT_THE_MILITARY_ASSOCIATION_LEADER)
          qs.remove_nr_memo(pc, 731)
        end
        if qs.has_nr_memo?(pc, Q732_PROTECT_THE_RELIGIOUS_ASSOCIATION_LEADER)
          qs.remove_nr_memo(pc, 732)
        end
        if qs.has_nr_memo?(pc, Q733_PROTECT_THE_ECONOMIC_ASSOCIATION_LEADER)
          qs.remove_nr_memo(pc, 733)
        end
      end
    end
  end

  private def event_roien(event, pc, npc, qs)
    case event
    when 31
      if qs.has_quest_items?(RECOMMENDATION_1)
        if !pc.mage_class? && qs.get_memo_state_ex(1) <= 3
          qs.give_items(SOULSHOT_NO_GRADE_FOR_BEGINNERS, 200)
          qs.play_sound(Voice::TUTORIAL_VOICE_026_1000)
          qs.add_exp_and_sp(0, 50)
          qs.set_memo_state_ex(1, 4)
        end
        if pc.mage_class? && qs.get_memo_state_ex(1) <= 3
          if pc.class_id.orc_mage?
            qs.give_items(SOULSHOT_NO_GRADE_FOR_BEGINNERS, 200)
            qs.play_sound(Voice::TUTORIAL_VOICE_026_1000)
          else
            qs.give_items(SPIRITSHOT_NO_GRADE_FOR_BEGINNERS, 100)
            qs.play_sound(Voice::TUTORIAL_VOICE_027_1000)
          end
          qs.add_exp_and_sp(0, 50)
          qs.set_memo_state_ex(1, 4)
        end
        start_quest_timer(npc.id.to_s, 60_000, npc, pc)
        qs.take_items(RECOMMENDATION_1, 1)
        show_page(pc, "30008-002.htm")
      end
    when 41
      teleport_player(pc, Location.new(-120050, 44500, 360), 0)
      show_page(pc, "30008-005.htm")
    when 42
      qs.add_radar(-84081, 243277, -3723)
      show_page(pc, "30008-006.htm")
    end
  end

  private def event_gallint(event, pc, npc, qs)
    case event
    when 31
      if qs.has_quest_items?(RECOMMENDATION_2)
        if !pc.mage_class? && qs.get_quest_items_count(SOULSHOT_NO_GRADE_FOR_BEGINNERS) <= 200
          qs.play_sound(Voice::TUTORIAL_VOICE_026_1000)
          qs.give_items(SOULSHOT_NO_GRADE_FOR_BEGINNERS, 200)
          qs.add_exp_and_sp(0, 50)
        end
        if pc.mage_class? && qs.get_quest_items_count(SOULSHOT_NO_GRADE_FOR_BEGINNERS) <= 200
          if qs.get_quest_items_count(SPIRITSHOT_NO_GRADE_FOR_BEGINNERS) <= 100
            if pc.class_id.orc_mage?
              qs.play_sound(Voice::TUTORIAL_VOICE_026_1000)
              qs.give_items(SOULSHOT_NO_GRADE_FOR_BEGINNERS, 200)
            else
              qs.play_sound(Voice::TUTORIAL_VOICE_027_1000)
              qs.give_items(SPIRITSHOT_NO_GRADE_FOR_BEGINNERS, 200)
            end
            qs.add_exp_and_sp(0, 50)
          end
        end
        qs.take_items(RECOMMENDATION_2, 1)
        start_quest_timer(npc.id.to_s, 60_000, npc, pc)
        if qs.get_memo_state_ex(1) <= 3
          qs.set_memo_state_ex(1, 4)
        end
        show_page(pc, "30017-002.htm")
      end
    when 41
      teleport_player(pc, Location.new(-120050, 44500, 360), 0)
      qs.add_radar(-119692, 44504, 380)
      show_page(pc, "30017-005.htm")
    when 42
      qs.add_radar(-84081, 243277, -3723)
      show_page(pc, "30017-006.htm")
    end
  end

  private def event_jundin(event, pc, npc, qs)
    case event
    when 31
      if qs.has_quest_items?(BLOOD_OF_MITRAELL)
        if !pc.mage_class? && qs.get_quest_items_count(SOULSHOT_NO_GRADE_FOR_BEGINNERS) <= 200
          qs.play_sound(Voice::TUTORIAL_VOICE_026_1000)
          qs.give_items(SOULSHOT_NO_GRADE_FOR_BEGINNERS, 200)
          qs.add_exp_and_sp(0, 50)
        end
        if pc.mage_class? && qs.get_quest_items_count(SOULSHOT_NO_GRADE_FOR_BEGINNERS) <= 200
          if qs.get_quest_items_count(SPIRITSHOT_NO_GRADE_FOR_BEGINNERS) <= 100
            if pc.class_id.orc_mage?
              qs.play_sound(Voice::TUTORIAL_VOICE_026_1000)
              qs.give_items(SOULSHOT_NO_GRADE_FOR_BEGINNERS, 200)
            else
              qs.play_sound(Voice::TUTORIAL_VOICE_027_1000)
              qs.give_items(SPIRITSHOT_NO_GRADE_FOR_BEGINNERS, 200)
            end
            qs.add_exp_and_sp(0, 50)
          end
        end
        qs.take_items(BLOOD_OF_MITRAELL, 1)
        start_quest_timer(npc.id.to_s, 60000, npc, pc)
        if qs.get_memo_state_ex(1) <= 3
          qs.set_memo_state_ex(1, 4)
        end
        show_page(pc, "30129-002.htm")
      end
    when 41
      teleport_player(pc, Location.new(-120050, 44500, 360), 0)
      qs.add_radar(-119692, 44504, 380)
      show_page(pc, "30129-005.htm")
    when 42
      qs.add_radar(17024, 13296, -3744)
      show_page(pc, "30129-006.htm")
    end
  end

  private def event_nerupa(event, pc, npc, qs)
    case event
    when 31
      if qs.has_quest_items?(LEAF_OF_THE_MOTHER_TREE)
        if !pc.mage_class? && qs.get_quest_items_count(SOULSHOT_NO_GRADE_FOR_BEGINNERS) <= 200

          qs.play_sound(Voice::TUTORIAL_VOICE_026_1000)
          qs.give_items(SOULSHOT_NO_GRADE_FOR_BEGINNERS, 200)
          qs.add_exp_and_sp(0, 50)
        end
        if pc.mage_class? && qs.get_quest_items_count(SOULSHOT_NO_GRADE_FOR_BEGINNERS) <= 200 && qs.get_quest_items_count(SPIRITSHOT_NO_GRADE_FOR_BEGINNERS) <= 100
          qs.play_sound(Voice::TUTORIAL_VOICE_027_1000)
          qs.give_items(SPIRITSHOT_NO_GRADE_FOR_BEGINNERS, 200)
          qs.add_exp_and_sp(0, 50)
        end
        qs.take_items(LEAF_OF_THE_MOTHER_TREE, 1)
        start_quest_timer(npc.id.to_s, 60000, npc, pc)
        if qs.get_memo_state_ex(1) <= 3
          qs.set_memo_state_ex(1, 4)
        end
        show_page(pc, "30370-002.htm")
      end
    when 41
      teleport_player(pc, Location.new(-120050, 44500, 360), 0)
      qs.add_radar(-119692, 44504, 380)
      show_page(pc, "30370-005.htm")
    when 42
      qs.add_radar(45475, 48359, -3060)
      show_page(pc, "30370-006.htm")
    end
  end

  private def event_foreman_laferon(event, pc, npc, qs)
    case event
    when 31
      if qs.has_quest_items?(LICENSE_OF_MINER)
        if !pc.mage_class? && qs.get_quest_items_count(SOULSHOT_NO_GRADE_FOR_BEGINNERS) <= 200
          qs.play_sound(Voice::TUTORIAL_VOICE_026_1000)
          qs.give_items(SOULSHOT_NO_GRADE_FOR_BEGINNERS, 200)
          qs.add_exp_and_sp(0, 50)
        end
        if pc.mage_class? && qs.get_quest_items_count(SOULSHOT_NO_GRADE_FOR_BEGINNERS) <= 200 && qs.get_quest_items_count(SPIRITSHOT_NO_GRADE_FOR_BEGINNERS) <= 100
          qs.play_sound(Voice::TUTORIAL_VOICE_027_1000)
          qs.give_items(SPIRITSHOT_NO_GRADE_FOR_BEGINNERS, 100)
          qs.add_exp_and_sp(0, 50)
        end
        qs.take_items(LICENSE_OF_MINER, 1)
        start_quest_timer(npc.id.to_s, 60000, npc, pc)
        if qs.get_memo_state_ex(1) <= 3
          qs.set_memo_state_ex(1, 4)
        end
        show_page(pc, "30528-002.htm")
      end
    when 41
      teleport_player(pc, Location.new(-120050, 44500, 360), 0)
      qs.add_radar(-119692, 44504, 380)
      show_page(pc, "30528-005.htm")
    when 42
      qs.add_radar(115632, -177996, -905)
      show_page(pc, "30528-006.htm")
    end
  end

  private def event_guardian_vulkus(event, pc, npc, qs)
    case event
    when 31
      if qs.has_quest_items?(VOUCHER_OF_FLAME)
        qs.take_items(VOUCHER_OF_FLAME, 1)
        start_quest_timer(npc.id.to_s, 60000, npc, pc)
        if qs.get_memo_state_ex(1) <= 3
          qs.set_memo_state_ex(1, 4)
        end
        if qs.get_quest_items_count(SOULSHOT_NO_GRADE_FOR_BEGINNERS) <= 200
          qs.give_items(SOULSHOT_NO_GRADE_FOR_BEGINNERS, 200)
          qs.add_exp_and_sp(0, 50)
        end
        qs.play_sound(Voice::TUTORIAL_VOICE_026_1000)
        show_page(pc, "30573-002.htm")
      end
    when 41
      teleport_player(pc, Location.new(-120050, 44500, 360), 0)
      qs.add_radar(-119692, 44504, 380)
      show_page(pc, "30573-005.htm")
    when 42
      qs.add_radar(-45032, -113598, -192)
      show_page(pc, "30573-006.htm")
    end
  end

  private def event_subelder_perwan(event, pc, npc, qs)
    if event == 31 && qs.has_quest_items?(DIPLOMA)
      if pc.race.kamael? && pc.class_id.level == 0 && qs.get_memo_state_ex(1) <= 3
        qs.give_items(SOULSHOT_NO_GRADE_FOR_BEGINNERS, 200)
        qs.play_sound(Voice::TUTORIAL_VOICE_026_1000)
        qs.add_exp_and_sp(0, 50)
        qs.set_memo_state_ex(1, 4)
      end
      qs.take_items(DIPLOMA, -1)
      start_quest_timer(npc.id.to_s, 60000, npc, pc)
      qs.add_radar(-119692, 44504, 380)
      show_page(pc, "32133-002.htm")
    end
  end

  private def talk_roien(pc, qs)
    if qs.has_quest_items?(RECOMMENDATION_1)
      show_page(pc, "30008-001.htm", true)
    else
      if qs.get_memo_state_ex(1) > 3
        show_page(pc, "30008-004.htm", true)
      elsif qs.get_memo_state_ex(1) <= 3
        show_page(pc, "30008-003.htm", true)
      end
    end
  end

  private def talk_carl(npc, pc, qs)
    if qs.get_memo_state_ex(1) < 0
      if pc.class_id.fighter? && pc.race.human?
        qs.remove_radar(-71424, 258336, -3109)
        start_quest_timer(npc.id.to_s, 30_000, npc, pc)
        qs.set_memo_state_ex(1, 0)
        enable_tutorial_event(qs, (qs.memo_state & 2147483392) | 1048576)
        show_page(pc, "30009-001.htm")
      else
        show_page(pc, "30009-006.htm")
      end
    elsif ((qs.get_memo_state_ex(1) == 0) || (qs.get_memo_state_ex(1) == 1) || (qs.get_memo_state_ex(1) == 2)) && !qs.has_quest_items?(BLUE_GEMSTONE)
      show_page(pc, "30009-002.htm")
    elsif ((qs.get_memo_state_ex(1) == 0) || (qs.get_memo_state_ex(1) == 1) || (qs.get_memo_state_ex(1) == 2)) && qs.has_quest_items?(BLUE_GEMSTONE)
      qs.take_items(BLUE_GEMSTONE, -1)
      qs.set_memo_state_ex(1, 3)
      qs.give_items(RECOMMENDATION_1, 1)

      start_quest_timer(npc.id.to_s, 30_000, npc, pc)
      qs.memo_state = (qs.memo_state & 2147483392) | 4
      if !pc.mage_class? && !qs.has_quest_items?(SOULSHOT_NO_GRADE_FOR_BEGINNERS)
        qs.give_items(SOULSHOT_NO_GRADE_FOR_BEGINNERS, 200)
        qs.play_sound(Voice::TUTORIAL_VOICE_026_1000)
      end
      if pc.mage_class? && !qs.has_quest_items?(SOULSHOT_NO_GRADE_FOR_BEGINNERS) && !qs.has_quest_items?(SPIRITSHOT_NO_GRADE_FOR_BEGINNERS)
        if pc.class_id.orc_mage?
          qs.play_sound(Voice::TUTORIAL_VOICE_026_1000)
          qs.give_items(SOULSHOT_NO_GRADE_FOR_BEGINNERS, 200)
        else
          qs.play_sound(Voice::TUTORIAL_VOICE_027_1000)
          qs.give_items(SPIRITSHOT_NO_GRADE_FOR_BEGINNERS, 100)
        end
      end
      show_page(pc, "30009-003.htm")
    elsif qs.get_memo_state_ex(1) == 3
      show_page(pc, "30009-004.htm")
    elsif qs.get_memo_state_ex(1) > 3
      show_page(pc, "30009-005.htm")
    end
  end

  private def talk_gallint(pc, qs)
    if qs.has_quest_items?(RECOMMENDATION_2)
      show_page(pc, "30017-001.htm", true)
    elsif !qs.has_quest_items?(RECOMMENDATION_2) && qs.get_memo_state_ex(1) > 3
      show_page(pc, "30017-004.htm", true)
    elsif !qs.has_quest_items?(RECOMMENDATION_2) && qs.get_memo_state_ex(1) <= 3
      show_page(pc, "30017-003.htm", true)
    end
  end

  private def talk_doff(npc, pc, qs)
    if qs.get_memo_state_ex(1) < 0
      if pc.class_id.mage? && pc.race.human?
        qs.remove_radar(-91036, 248044, -3568)
        start_quest_timer(npc.id.to_s, 30_000, npc, pc)
        qs.set_memo_state_ex(1, 0)
        enable_tutorial_event(qs, (qs.memo_state & 2147483392) | 1048576)
        show_page(pc, "30019-001.htm")
      else
        show_page(pc, "30009-006.htm")
      end
    elsif (qs.get_memo_state_ex(1) == 0 || qs.get_memo_state_ex(1) == 1 || qs.get_memo_state_ex(1) == 2) && !qs.has_quest_items?(BLUE_GEMSTONE)
      show_page(pc, "30019-002.htm")
    end
    if (qs.get_memo_state_ex(1) == 0 || qs.get_memo_state_ex(1) == 1 || qs.get_memo_state_ex(1) == 2) && qs.has_quest_items?(BLUE_GEMSTONE)
      qs.take_items(BLUE_GEMSTONE, -1)
      qs.set_memo_state_ex(1, 3)
      qs.give_items(RECOMMENDATION_2, 1)

      start_quest_timer(npc.id.to_s, 30_000, npc, pc)
      qs.memo_state = (qs.memo_state & 2147483392) | 4
      if !pc.mage_class? && !qs.has_quest_items?(SOULSHOT_NO_GRADE_FOR_BEGINNERS)
        qs.give_items(SOULSHOT_NO_GRADE_FOR_BEGINNERS, 200)
        qs.play_sound(Voice::TUTORIAL_VOICE_026_1000)
      end
      if pc.mage_class? && !qs.has_quest_items?(SOULSHOT_NO_GRADE_FOR_BEGINNERS) && !qs.has_quest_items?(SPIRITSHOT_NO_GRADE_FOR_BEGINNERS)
        if pc.class_id.orc_mage?
          qs.play_sound(Voice::TUTORIAL_VOICE_026_1000)
          qs.give_items(SOULSHOT_NO_GRADE_FOR_BEGINNERS, 200)
        else
          qs.play_sound(Voice::TUTORIAL_VOICE_027_1000)
          qs.give_items(SPIRITSHOT_NO_GRADE_FOR_BEGINNERS, 100)
        end
      end
      show_page(pc, "30019-003.htm")
    elsif qs.get_memo_state_ex(1) == 3
      show_page(pc, "30019-004.htm")
    elsif qs.get_memo_state_ex(1) > 3
      show_page(pc, "30009-005.htm")
    end
  end

  private def talk_jundin(pc, qs)
    if qs.has_quest_items?(BLOOD_OF_MITRAELL)
      show_page(pc, "30129-001.htm", true)
    elsif !qs.has_quest_items?(BLOOD_OF_MITRAELL) && qs.get_memo_state_ex(1) > 3
      show_page(pc, "30129-004.htm", true)
    elsif !qs.has_quest_items?(BLOOD_OF_MITRAELL) && qs.get_memo_state_ex(1) <= 3
      show_page(pc, "30129-003.htm", true)
    end
  end

  private def talk_poeny(npc, pc, qs)
    if qs.get_memo_state_ex(1) < 0
      if pc.race.dark_elf?
        qs.remove_radar(28384, 11056, -4233)
        start_quest_timer(npc.id.to_s, 30_000, npc, pc)

        if !pc.mage_class?
          show_page(pc, "30009-001.htm")
        else
          show_page(pc, "30019-001.htm")
        end

        qs.set_memo_state_ex(1, 0)
        enable_tutorial_event(qs, (qs.memo_state & 2147483392) | 1048576)
      else
        show_page(pc, "30009-006.htm")
      end
    elsif (qs.get_memo_state_ex(1) == 0 || qs.get_memo_state_ex(1) == 1 || qs.get_memo_state_ex(1) == 2) && !qs.has_quest_items?(BLUE_GEMSTONE)
      if !pc.mage_class?
        show_page(pc, "30009-002.htm")
      else
        show_page(pc, "30019-002.htm")
      end
    elsif (qs.get_memo_state_ex(1) == 0 || qs.get_memo_state_ex(1) == 1 || qs.get_memo_state_ex(1) == 2) && qs.has_quest_items?(BLUE_GEMSTONE)
      if !pc.mage_class?
        show_page(pc, "30131-003f.htm")
      else
        show_page(pc, "30131-003m.htm")
      end

      qs.take_items(BLUE_GEMSTONE, -1)
      qs.set_memo_state_ex(1, 3)
      qs.give_items(BLOOD_OF_MITRAELL, 1)
      start_quest_timer(npc.id.to_s, 30_000, npc, pc)

      qs.memo_state = (qs.memo_state & 2147483392) | 4

      if !pc.mage_class? && !qs.has_quest_items?(SOULSHOT_NO_GRADE_FOR_BEGINNERS)
        qs.play_sound(Voice::TUTORIAL_VOICE_026_1000)
        qs.give_items(SOULSHOT_NO_GRADE_FOR_BEGINNERS, 200)
      end
      if pc.mage_class? && !qs.has_quest_items?(SOULSHOT_NO_GRADE_FOR_BEGINNERS) && !qs.has_quest_items?(SPIRITSHOT_NO_GRADE_FOR_BEGINNERS)
        if pc.class_id.orc_mage?
          qs.play_sound(Voice::TUTORIAL_VOICE_026_1000)
          qs.give_items(SOULSHOT_NO_GRADE_FOR_BEGINNERS, 100)
        else
          qs.play_sound(Voice::TUTORIAL_VOICE_027_1000)
          qs.give_items(SPIRITSHOT_NO_GRADE_FOR_BEGINNERS, 100)
        end
      end
    elsif qs.get_memo_state_ex(1) == 3
      show_page(pc, "30131-004.htm")
    elsif qs.get_memo_state_ex(1) > 3
      show_page(pc, "30009-005.htm")
    end
  end

  private def talk_nerupa(pc, qs)
    if qs.has_quest_items?(LEAF_OF_THE_MOTHER_TREE)
      show_page(pc, "30370-001.htm", true)
    elsif !qs.has_quest_items?(LEAF_OF_THE_MOTHER_TREE) && qs.get_memo_state_ex(1) > 3
      show_page(pc, "30370-004.htm", true)
    elsif !qs.has_quest_items?(LEAF_OF_THE_MOTHER_TREE) && qs.get_memo_state_ex(1) <= 3
      show_page(pc, "30370-003.htm", true)
    end
  end

  private def talk_mother_temp(npc, pc, qs)
    if qs.get_memo_state_ex(1) < 0
      if pc.race.elf?
        qs.remove_radar(46112, 41200, -3504)
        start_quest_timer(npc.id.to_s, 30_000, npc, pc)
        qs.set_memo_state_ex(1, 0)
        enable_tutorial_event(qs, (qs.memo_state & 2147483392) | 1048576)
        if !pc.mage_class?
          show_page(pc, "30009-001.htm")
        else
          show_page(pc, "30019-001.htm")
        end
      else
        show_page(pc, "30009-006.htm")
      end
    elsif (qs.get_memo_state_ex(1) == 0 || qs.get_memo_state_ex(1) == 1 || qs.get_memo_state_ex(1) == 2) && !qs.has_quest_items?(BLUE_GEMSTONE)
      if !pc.mage_class?
        show_page(pc, "30009-002.htm")
      else
        show_page(pc, "30019-002.htm")
      end
    elsif (qs.get_memo_state_ex(1) == 0 || qs.get_memo_state_ex(1) == 1 || qs.get_memo_state_ex(1) == 2) && qs.has_quest_items?(BLUE_GEMSTONE)
      qs.take_items(BLUE_GEMSTONE, -1)
      qs.set_memo_state_ex(1, 3)
      qs.give_items(LEAF_OF_THE_MOTHER_TREE, 1)
      start_quest_timer(npc.id.to_s, 30_000, npc, pc)
      qs.memo_state = (qs.memo_state & 2147483392) | 4
      if !pc.mage_class? && !qs.has_quest_items?(SOULSHOT_NO_GRADE_FOR_BEGINNERS)
        qs.play_sound(Voice::TUTORIAL_VOICE_026_1000)
        qs.give_items(SOULSHOT_NO_GRADE_FOR_BEGINNERS, 200)
      end
      if pc.mage_class? && !qs.has_quest_items?(SOULSHOT_NO_GRADE_FOR_BEGINNERS) && !qs.has_quest_items?(SPIRITSHOT_NO_GRADE_FOR_BEGINNERS)
        if pc.class_id.orc_mage?
          qs.play_sound(Voice::TUTORIAL_VOICE_026_1000)
          qs.give_items(SOULSHOT_NO_GRADE_FOR_BEGINNERS, 200)
        else
          qs.play_sound(Voice::TUTORIAL_VOICE_027_1000)
          qs.give_items(SPIRITSHOT_NO_GRADE_FOR_BEGINNERS, 100)
        end
      end

      if !pc.mage_class?
        show_page(pc, "30400-003f.htm")
      else
        show_page(pc, "30400-003m.htm")
      end
    elsif qs.get_memo_state_ex(1) == 3
      show_page(pc, "30400-004.htm")
    elsif qs.get_memo_state_ex(1) > 3
      show_page(pc, "30009-005.htm")
    end
  end

  private def talk_foreman_laferon(pc, qs)
    if qs.has_quest_items?(LICENSE_OF_MINER)
      show_page(pc, "30528-001.htm", true)
    elsif !qs.has_quest_items?(LICENSE_OF_MINER) && qs.get_memo_state_ex(1) > 3
      show_page(pc, "30528-004.htm", true)
    elsif !qs.has_quest_items?(LICENSE_OF_MINER) && qs.get_memo_state_ex(1) <= 3
      show_page(pc, "30528-003.htm", true)
    end
  end

  private def talk_miner_mai(npc, pc, qs)
    if qs.get_memo_state_ex(1) < 0
      if pc.race.dwarf?
        qs.remove_radar(108567, -173994, -406)
        start_quest_timer(npc.id.to_s, 30_000, npc, pc)

        qs.set_memo_state_ex(1, 0)
        enable_tutorial_event(qs, (qs.memo_state & 2147483392) | 1048576)
        if !pc.mage_class?
          show_page(pc, "30009-001.htm")
        else
          show_page(pc, "30019-001.htm")
        end
      else
        show_page(pc, "30009-006.htm")
      end
    elsif (qs.get_memo_state_ex(1) == 0 || qs.get_memo_state_ex(1) == 1 || qs.get_memo_state_ex(1) == 2) && !qs.has_quest_items?(BLUE_GEMSTONE)
      show_page(pc, "30009-002.htm")
    elsif (qs.get_memo_state_ex(1) == 0 || qs.get_memo_state_ex(1) == 1 || qs.get_memo_state_ex(1) == 2) && qs.has_quest_items?(BLUE_GEMSTONE)
      qs.take_items(BLUE_GEMSTONE, -1)
      qs.set_memo_state_ex(1, 3)
      qs.give_items(LICENSE_OF_MINER, 1)
      start_quest_timer(npc.id.to_s, 30_000, npc, pc)
      qs.memo_state = (qs.memo_state & 2147483392) | 4
      if !pc.mage_class? && !qs.has_quest_items?(SOULSHOT_NO_GRADE_FOR_BEGINNERS)
        qs.play_sound(Voice::TUTORIAL_VOICE_026_1000)
        qs.give_items(SOULSHOT_NO_GRADE_FOR_BEGINNERS, 200)
      end
      if pc.mage_class? && !qs.has_quest_items?(SOULSHOT_NO_GRADE_FOR_BEGINNERS) && !qs.has_quest_items?(SPIRITSHOT_NO_GRADE_FOR_BEGINNERS)
        if pc.class_id.orc_mage?
          qs.play_sound(Voice::TUTORIAL_VOICE_026_1000)
          qs.give_items(SOULSHOT_NO_GRADE_FOR_BEGINNERS, 200)
        else
          qs.play_sound(Voice::TUTORIAL_VOICE_027_1000)
          qs.give_items(SPIRITSHOT_NO_GRADE_FOR_BEGINNERS, 100)
        end
      else
        show_page(pc, "30530-003.htm")
      end
    elsif qs.get_memo_state_ex(1) == 3
      show_page(pc, "30530-004.htm")
    elsif qs.get_memo_state_ex(1) > 3
      show_page(pc, "30009-005.htm")
    end
  end

  private def talk_guardian_vulkus(pc, qs)
    if qs.has_quest_items?(VOUCHER_OF_FLAME)
      show_page(pc, "30573-001.htm", true)
    else
      if qs.get_memo_state_ex(1) > 3
        show_page(pc, "30573-004.htm", true)
      else
        show_page(pc, "30573-003.htm", true)
      end
    end
  end

  private def talk_shela_priestess(npc, pc, qs)
    if qs.get_memo_state_ex(1) < 0
      if pc.race.orc?
        qs.remove_radar(-56736, -113680, -672)
        start_quest_timer(npc.id.to_s, 30_000, npc, pc)
        qs.set_memo_state_ex(1, 0)
        enable_tutorial_event(qs, (qs.memo_state & 2147483392) | 1048576)
        if !pc.mage_class?
          show_page(pc, "30009-001.htm")
        else
          show_page(pc, "30575-001.htm")
        end
      else
        show_page(pc, "30009-006.htm")
      end
    elsif (qs.get_memo_state_ex(1) == 0 || qs.get_memo_state_ex(1) == 1 || qs.get_memo_state_ex(1) == 2) && !qs.has_quest_items?(BLUE_GEMSTONE)
      if !pc.mage_class?
        show_page(pc, "30009-002.htm")
      else
        show_page(pc, "30575-002.htm")
      end
    elsif (qs.get_memo_state_ex(1) == 0 || qs.get_memo_state_ex(1) == 1 || qs.get_memo_state_ex(1) == 2) && qs.has_quest_items?(BLUE_GEMSTONE)
      if !pc.mage_class?
        show_page(pc, "30575-003f.htm")
      else
        show_page(pc, "30575-003m.htm")
      end

      qs.take_items(BLUE_GEMSTONE, -1)
      qs.set_memo_state_ex(1, 3)
      qs.give_items(VOUCHER_OF_FLAME, 1)
      start_quest_timer(npc.id.to_s, 30_000, npc, pc)
      qs.memo_state = (qs.memo_state & 2147483392) | 4
      unless qs.has_quest_items?(SOULSHOT_NO_GRADE_FOR_BEGINNERS)
        qs.give_items(SOULSHOT_NO_GRADE_FOR_BEGINNERS, 200)
      end
      qs.play_sound(Voice::TUTORIAL_VOICE_026_1000)
    elsif qs.get_memo_state_ex(1) == 3
      show_page(pc, "30575-004.htm")
    elsif qs.get_memo_state_ex(1) > 3
      show_page(pc, "30009-005.htm")
    end
  end

  private def talk_subelder_perwan(pc, qs)
    if qs.has_quest_items?(DIPLOMA)
      show_page(pc, "32133-001.htm", true)
    else
      if qs.get_memo_state_ex(1) > 3
        show_page(pc, "32133-004.htm", true)
      elsif qs.get_memo_state_ex(1) <= 3
        show_page(pc, "32133-003.htm", true)
      end
    end
  end

  private def talk_helper_krenisk(npc, pc, qs)
    if qs.get_memo_state_ex(1) < 0
      if pc.race.kamael?
        qs.remove_radar(-125872, 38016, 1251)
        qs.set_memo_state_ex(1, 0)
        start_quest_timer(npc.id.to_s, 30_000, npc, pc)
        enable_tutorial_event(qs, (qs.memo_state & 2147483392) | 1048576)
        show_page(pc, "32134-001.htm")
      else
        show_page(pc, "30009-006.htm")
      end
    elsif (qs.get_memo_state_ex(1) == 0 || qs.get_memo_state_ex(1) == 1 || qs.get_memo_state_ex(1) == 2) && !qs.has_quest_items?(BLUE_GEMSTONE)
      show_page(pc, "32134-002.htm")
    elsif (qs.get_memo_state_ex(1) == 0 || qs.get_memo_state_ex(1) == 1 || qs.get_memo_state_ex(1) == 2) && qs.has_quest_items?(BLUE_GEMSTONE)
      show_page(pc, "32134-003.htm")
      qs.take_items(BLUE_GEMSTONE, -1)
      qs.set_memo_state_ex(1, 3)
      qs.give_items(DIPLOMA, 1)
      start_quest_timer(npc.id.to_s, 30_000, npc, pc)
      qs.memo_state = (qs.memo_state & 2147483392) | 4
      if pc.race.kamael? && pc.class_id.level == 0 && !qs.has_quest_items?(SOULSHOT_NO_GRADE_FOR_BEGINNERS)
        qs.give_items(SOULSHOT_NO_GRADE_FOR_BEGINNERS, 200)
        qs.play_sound(Voice::TUTORIAL_VOICE_026_1000)
      end
    elsif qs.get_memo_state_ex(1) == 3
      show_page(pc, "32134-004.htm")
    elsif qs.get_memo_state_ex(1) > 3
      show_page(pc, "32134-005.htm")
    end
  end

  def on_kill(npc, killer, is_summon)
    qs = get_quest_state(killer, false).not_nil!
    if npc.id == TUTORIAL_GREMLIN
      if qs.get_memo_state_ex(1) == 1 || qs.get_memo_state_ex(1) == 0
        qs.play_sound(Voice::TUTORIAL_VOICE_011_1000)
        qs.show_question_mark(killer.acting_player, 3)
        qs.set_memo_state_ex(1, 2)
      end

      if (qs.get_memo_state_ex(1) == 1 || qs.get_memo_state_ex(1) == 2 || qs.get_memo_state_ex(1) == 0) && !qs.has_quest_items?(BLUE_GEMSTONE) && Rnd.rand(2) <= 1
        npc.drop_item(killer, BLUE_GEMSTONE, 1)
        qs.play_sound(Sound::ITEMSOUND_QUEST_TUTORIAL)
      end
    end

    super
  end

  def visible_in_quest_window?
    false
  end
end
