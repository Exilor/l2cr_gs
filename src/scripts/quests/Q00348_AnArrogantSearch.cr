class Scripts::Q00348_AnArrogantSearch < Quest
  # NPCs
  private HARNE = 30144
  private MARTIEN = 30645
  private SIR_GUSTAV_ATHEBALDT = 30760
  private HARDIN = 30832
  private HANELLIN = 30864
  private IASON_HEINE = 30969
  private HOLY_ARK_OF_SECRECY_1 = 30977
  private HOLY_ARK_OF_SECRECY_2 = 30978
  private HOLY_ARK_OF_SECRECY_3 = 30979
  private ARK_GUARDIANS_CORPSE = 30980
  private CLAUDIA_ATHEBALDT = 31001
  # Items
  private GREATER_HEALING_POTION = 1061
  private ANTIDOTE = 1831
  private TITANS_POWERSTONE = 4287
  private HANELLINS_1ST_LETTER = 4288
  private HANELLINS_2ND_LETTER = 4289
  private HANELLINS_3RD_LETTER = 4290
  private FIRST_KEY_OF_ARK = 4291
  private SECOND_KEY_OF_ARK = 4292
  private THIRD_KEY_OF_ARK = 4293
  private WHITE_FABRIC_1 = 4294
  private BLOODED_FABRIC = 4295
  private BOOK_OF_SAINT = 4397
  private BLOOD_OF_SAINT = 4398
  private BOUGH_OF_SAINT = 4399
  private WHITE_FABRIC_2 = 4400
  private SHELL_OF_MONSTERS = 14857
  # Misc
  private MIN_LEVEL = 60
  private MIN_HP_PERCENTAGE = 30
  # Variables
  private I_QUEST0 = "I_QUEST0"
  # Rewards
  private ANIMAL_BONE = 1872
  private ORIHARUKON_ORE = 1874
  private COKES = 1879
  private COARSE_BONE_POWDER = 1881
  private VARNISH_OF_PURITY = 1887
  private SYNTHETIC_COKES = 1888
  private ENRIA = 4042
  private GREAT_SWORD_BLADE = 4104
  private HEAVY_WAR_AXE_HEAD = 4105
  private SPRITES_STAFF_HEAD = 4106
  private KESHANBERK_BLADE = 4107
  private SWORD_OF_VALHALLA_BLADE = 4108
  private KRIS_EDGE = 4109
  private HELL_KNIFE_EDGE = 4110
  private ARTHRO_NAIL_BLADE = 4111
  private DARK_ELVEN_LONGBOW_SHAFT = 4112
  private GREAT_AXE_HEAD = 4113
  private SWORD_OF_DAMASCUS_BLADE = 4114
  private LANCE_BLADE = 4115
  private ART_OF_BATTLE_AXE_BLADE = 4117
  private EVIL_SPIRIT_HEAD = 4118
  private DEMONS_DAGGER_EDGE = 4119
  private BELLION_CESTUS_EDGE = 4120
  private BOW_OF_PERIL_SHAFT = 4121
  # Quest Monsters
  private ARK_GUARDIAN_ELBEROTH = 27182
  private ARK_GUARDIAN_SHADOWFANG = 27183
  private ANGEL_KILLER = 27184
  # Monsters
  private YINTZU = 20647
  private PALIOTE = 20648
  private PLATINUM_TRIBE_SHAMAN = 20828
  private PLATINUM_TRIBE_OVERLORD = 20829
  private GUARDIAN_ANGEL = 20830
  private SEAL_ANGEL_1 = 20831
  private SEAL_ANGEL_2 = 20860

  def initialize
    super(348, self.class.simple_name, "An Arrogant Search")

    add_attack_id(
      ARK_GUARDIAN_ELBEROTH, ARK_GUARDIAN_SHADOWFANG, ANGEL_KILLER,
      PLATINUM_TRIBE_SHAMAN, PLATINUM_TRIBE_OVERLORD
    )
    add_spawn_id(ARK_GUARDIAN_ELBEROTH, ARK_GUARDIAN_SHADOWFANG, ANGEL_KILLER)
    add_start_npc(HANELLIN)
    add_talk_id(
      HANELLIN, IASON_HEINE, HOLY_ARK_OF_SECRECY_1, HOLY_ARK_OF_SECRECY_2,
      HOLY_ARK_OF_SECRECY_3, ARK_GUARDIANS_CORPSE, CLAUDIA_ATHEBALDT, HARNE,
      MARTIEN, SIR_GUSTAV_ATHEBALDT, HARDIN
    )
    add_kill_id(
      ARK_GUARDIAN_ELBEROTH, ARK_GUARDIAN_SHADOWFANG, YINTZU, PALIOTE,
      PLATINUM_TRIBE_SHAMAN, PLATINUM_TRIBE_OVERLORD, GUARDIAN_ANGEL,
      SEAL_ANGEL_1, SEAL_ANGEL_2
    )
    register_quest_items(
      SHELL_OF_MONSTERS, TITANS_POWERSTONE, HANELLINS_1ST_LETTER,
      HANELLINS_2ND_LETTER, HANELLINS_3RD_LETTER, FIRST_KEY_OF_ARK,
      SECOND_KEY_OF_ARK, THIRD_KEY_OF_ARK, WHITE_FABRIC_1, BOOK_OF_SAINT,
      BLOOD_OF_SAINT, BOUGH_OF_SAINT, WHITE_FABRIC_2
    )
  end

  def on_adv_event(event, npc, player)
    npc = npc.not_nil!

    case npc.id
    when ARK_GUARDIAN_ELBEROTH, ARK_GUARDIAN_SHADOWFANG, ANGEL_KILLER
      if event == "DESPAWN"
        npc.delete_me
        return super
      end
    else
      # [automatically added else]
    end


    player = player.not_nil!
    unless st = get_quest_state(player, false)
      return
    end

    case event
    when "30864-02.htm", "30864-03.htm", "30864-10.html", "30864-11.html",
         "30864-12.html", "30864-25.html", "31001-02.html", "30144-02.html",
         "30645-02.html"
      html = event
    when "30864-04.htm"
      st.memo_state = 1
      st.start_quest
      st.set_cond(2)
      html = event
    when "30864-08.html"
      memo_state = st.memo_state
      if (memo_state == 1 && has_at_least_one_quest_item?(player, TITANS_POWERSTONE, SHELL_OF_MONSTERS)) || memo_state == 2
        st.set_memo_state_ex(0, 4)
        st.set_memo_state_ex(1, 0)
        st.memo_state = 4
        st.set_cond(4)
        html = event
      end
    when "30864-09.html"
      if st.memo_state?(4) && st.get_memo_state_ex(1) == 0
        give_items(player, HANELLINS_1ST_LETTER, 1)
        give_items(player, HANELLINS_2ND_LETTER, 1)
        give_items(player, HANELLINS_3RD_LETTER, 1)
        st.memo_state = 5
        st.set_cond(5)
        html = event
      end
    when "30864-26.html"
      if st.memo_state?(10) && get_quest_items_count(player, WHITE_FABRIC_1) == 1
        st.memo_state = 11
        html = event
      end
    when "30864-27.html"
      if st.memo_state?(11) && get_quest_items_count(player, WHITE_FABRIC_1) == 1 && st.get_memo_state_ex(1) > 0
        case st.get_memo_state_ex(1)
        when 1
          give_adena(player, 43000, true)
        when 2
          give_adena(player, 4000, true)
        when 3
          give_adena(player, 13000, true)
        else
          # [automatically added else]
        end


        st.set_memo_state_ex(0, 12)
        st.set_memo_state_ex(1, 100)
        st.set_cond(24)
        html = event
      else
        html = "30864-28.html"
      end
    when "30864-29.html"
      if st.memo_state?(11) && st.get_memo_state_ex(1) == 0 && get_quest_items_count(player, WHITE_FABRIC_1) == 1
        give_adena(player, 49000, true)
        st.memo_state = 12 # Custom line
        st.set_memo_state_ex(0, 12)
        st.set_memo_state_ex(1, 20000)
        st.set_cond(24)
        html = event
      end
    when "30864-30.html"
      if st.memo_state?(11) && st.get_memo_state_ex(1) == 0 && get_quest_items_count(player, WHITE_FABRIC_1) == 1
        st.memo_state = 13 # Custom line
        st.set_memo_state_ex(0, 13)
        st.set_memo_state_ex(1, 20000)
        st.set_cond(25)
        html = event
      end
    when "30864-43.html"
      if st.memo_state?(15)
        st.memo_state = 16
        html = event
      end
    when "30864-44.html"
      if st.memo_state?(15) || st.memo_state?(16)
        if has_quest_items?(player, BLOODED_FABRIC)
          give_items(player, WHITE_FABRIC_1, 9)
        else
          give_items(player, WHITE_FABRIC_1, 10)
        end
      end

      st.memo_state = 17 # Custom line
      st.set_memo_state_ex(0, 17)
      st.set_memo_state_ex(1, 0)
      st.set_cond(26)
      html = event
    when "30864-47.html"
      if st.memo_state?(17) && get_quest_items_count(player, BLOODED_FABRIC) >= 10 && !has_quest_items?(player, WHITE_FABRIC_1)
        st.memo_state = 18 # Custom line
        st.set_memo_state_ex(0, 18)
        st.set_memo_state_ex(1, 0)
        st.set_cond(27)
        html = event
      end
    when "30864-50.html"
      if st.memo_state?(19)
        give_items(player, WHITE_FABRIC_1, 10)
        st.memo_state = 17 # Custom line
        st.set_memo_state_ex(0, 17)
        st.set_memo_state_ex(1, 0)
        st.set_cond(29)
        html = event
      end
    when "30864-51.html"
      st.exit_quest(true, true)
      html = event
    else
      # [automatically added else]
    end


    html
  end

  def on_attack(npc, attacker, damage, is_summon)
    case npc.id
    when ARK_GUARDIAN_ELBEROTH
      unless npc.variables.get_bool(I_QUEST0, false)
        npc.variables[I_QUEST0] = true
        npc.broadcast_packet(NpcSay.new(npc.l2id, Say2::NPC_ALL, npc.id, NpcString::SORRY_ABOUT_THIS_BUT_I_MUST_KILL_YOU_NOW))
      end
    when ARK_GUARDIAN_SHADOWFANG
      unless npc.variables.get_bool(I_QUEST0, false)
        npc.variables[I_QUEST0] = true
        npc.broadcast_packet(NpcSay.new(npc.l2id, Say2::NPC_ALL, npc.id, NpcString::I_SHALL_DRENCH_THIS_MOUNTAIN_WITH_YOUR_BLOOD))
      end
    when ANGEL_KILLER
      st = get_quest_state(attacker, false)
      if st && st.get_memo_state_ex(0) < 8 && !has_quest_items?(attacker, FIRST_KEY_OF_ARK) && !has_quest_items?(attacker, BLOOD_OF_SAINT)
        if (st.get_memo_state_ex(1) % 100) // 10 == 1
          if npc.hp_percent < MIN_HP_PERCENTAGE
            st.set_memo_state_ex(1, st.get_memo_state_ex(1) + 10)
            if st.get_memo_state_ex(1) % 10 == 0
              st.clear_radar
              st.add_radar(-2908, 44128, -2712)
            else
              st.set_cond(19, true)
            end

            npc.broadcast_packet(NpcSay.new(npc.l2id, Say2::NPC_ALL, npc.id, NpcString::HA_THAT_WAS_FUN_IF_YOU_WISH_TO_FIND_THE_KEY_SEARCH_THE_CORPSE))
            npc.delete_me
          end
        elsif (st.get_memo_state_ex(1) % 100) // 10 == 2
          npc.broadcast_packet(NpcSay.new(npc.l2id, Say2::NPC_ALL, npc.id, NpcString::WE_DONT_HAVE_ANY_FURTHER_BUSINESS_TO_DISCUSS_HAVE_YOU_SEARCHED_THE_CORPSE_FOR_THE_KEY))
          npc.delete_me
        end
      elsif has_at_least_one_quest_item?(attacker, FIRST_KEY_OF_ARK, BLOOD_OF_SAINT)
        npc.broadcast_packet(NpcSay.new(npc.l2id, Say2::NPC_ALL, npc.id, NpcString::WE_DONT_HAVE_ANY_FURTHER_BUSINESS_TO_DISCUSS_HAVE_YOU_SEARCHED_THE_CORPSE_FOR_THE_KEY))
        npc.delete_me
      end
    when PLATINUM_TRIBE_SHAMAN
      st = get_random_party_member_state(attacker, -1, 3, npc)
      if st && npc.inside_radius?(attacker, 1500, true, false)
        if (st.get_memo_state_ex(0) == 12 || st.get_memo_state_ex(0) == 13) && has_quest_items?(st.player, WHITE_FABRIC_1)
          if st.get_memo_state_ex(0) == 12
            st.set_memo_state_ex(1, st.get_memo_state_ex(1) + 60)
            if st.get_memo_state_ex(1) + 60 > 80000
              give_items(st.player, BLOODED_FABRIC, 1)
              take_items(st.player, WHITE_FABRIC_1, 1)
              st.exit_quest(true, true)
            end
          end

          if st.get_memo_state_ex(0) == 13
            st.set_memo_state_ex(1, st.get_memo_state_ex(1) + 60)
            if st.get_memo_state_ex(1) + 60 > 100000
              give_items(st.player, BLOODED_FABRIC, 1)
              take_items(st.player, WHITE_FABRIC_1, 1)
              st.memo_state = 14 # Custom line
              st.set_memo_state_ex(0, 14)
              st.play_sound(Sound::ITEMSOUND_QUEST_MIDDLE)
            end
          end
        end
      end
    when PLATINUM_TRIBE_OVERLORD
      st = get_random_party_member_state(attacker, -1, 3, npc)
      if st && npc.inside_radius?(attacker, 1500, true, false)
        if (st.get_memo_state_ex(0) == 12 || st.get_memo_state_ex(0) == 13) && has_quest_items?(st.player, WHITE_FABRIC_1)
          if st.get_memo_state_ex(0) == 12
            st.set_memo_state_ex(1, st.get_memo_state_ex(1) + 70)
            if st.get_memo_state_ex(1) + 70 > 80000
              give_items(st.player, BLOODED_FABRIC, 1)
              take_items(st.player, WHITE_FABRIC_1, 1)
              st.exit_quest(true, true)
            end
          end

          if st.get_memo_state_ex(0) == 13
            st.set_memo_state_ex(1, st.get_memo_state_ex(1) + 70)
            if st.get_memo_state_ex(1) + 70 > 100000
              give_items(st.player, BLOODED_FABRIC, 1)
              take_items(st.player, WHITE_FABRIC_1, 1)
              st.memo_state = 14 # Custom line
              st.set_memo_state_ex(0, 14)
              st.play_sound(Sound::ITEMSOUND_QUEST_MIDDLE)
            end
          end
        end
      end
    else
      # [automatically added else]
    end


    super
  end

  def on_kill(npc, player, is_summon)
    st = get_random_party_member_state(player, -1, 3, npc)
    if st && npc.inside_radius?(player, 1500, true, false)
      case npc.id
      when ARK_GUARDIAN_ELBEROTH
        if npc.inside_radius?(player, 1500, true, false)
          if st.get_memo_state_ex(0) < 8 && (st.get_memo_state_ex(1) % 1000) // 100 == 1 && !has_quest_items?(st.player, SECOND_KEY_OF_ARK) && !has_quest_items?(st.player, BOOK_OF_SAINT)
            st.set_memo_state_ex(1, st.get_memo_state_ex(1) + 100)
            if st.get_memo_state_ex(1) % 10 != 0
              st.set_cond(11)
            end

            give_items(st.player, SECOND_KEY_OF_ARK, 1)
            st.play_sound(Sound::ITEMSOUND_QUEST_ITEMGET)
            npc.broadcast_packet(NpcSay.new(npc.l2id, Say2::NPC_ALL, npc.id, NpcString::YOU_FOOLS_WILL_GET_WHATS_COMING_TO_YOU))
          end
        end
      when ARK_GUARDIAN_SHADOWFANG
        if npc.inside_radius?(player, 1500, true, false)
          if st.get_memo_state_ex(0) < 8 && (st.get_memo_state_ex(1) % 10000) // 1000 == 1 && !has_quest_items?(st.player, THIRD_KEY_OF_ARK) && !has_quest_items?(st.player, BOUGH_OF_SAINT)
            st.set_memo_state_ex(1, st.get_memo_state_ex(1) + 1000)
            if (st.get_memo_state_ex(1) % 10) != 0
              st.set_cond(15)
            end

            give_items(st.player, THIRD_KEY_OF_ARK, 1)
            st.play_sound(Sound::ITEMSOUND_QUEST_ITEMGET)
            npc.broadcast_packet(NpcSay.new(npc.l2id, Say2::NPC_ALL, npc.id, NpcString::YOU_GUYS_WOULDNT_KNOW_THE_SEVEN_SEALS_ARE_ARRRGH))
          end
        end
      when YINTZU, PALIOTE
        if npc.inside_radius?(player, 1500, true, false) && st.memo_state?(1) && !has_quest_items?(st.player, SHELL_OF_MONSTERS)
          give_items(st.player, SHELL_OF_MONSTERS, 1)
          st.play_sound(Sound::ITEMSOUND_QUEST_ITEMGET)
        end
      when PLATINUM_TRIBE_SHAMAN
        if (st.get_memo_state_ex(0) == 12 || st.get_memo_state_ex(0) == 13) && has_quest_items?(st.player, WHITE_FABRIC_1)
          if st.get_memo_state_ex(0) == 12
            st.set_memo_state_ex(1, st.get_memo_state_ex(1) + 600)
            if st.get_memo_state_ex(1) + 600 > 80000
              give_items(st.player, BLOODED_FABRIC, 1)
              take_items(st.player, WHITE_FABRIC_1, 1)
              st.exit_quest(true, true)
            end
          end

          if st.get_memo_state_ex(0) == 13
            st.set_memo_state_ex(1, st.get_memo_state_ex(1) + 600)
            if st.get_memo_state_ex(1) + 600 > 100000
              give_items(st.player, BLOODED_FABRIC, 1)
              take_items(st.player, WHITE_FABRIC_1, 1)
              st.memo_state = 14 # Custom line
              st.set_memo_state_ex(0, 14)
              st.play_sound(Sound::ITEMSOUND_QUEST_MIDDLE)
            end
          end
        end
      when PLATINUM_TRIBE_OVERLORD
        if (st.get_memo_state_ex(0) == 12 || st.get_memo_state_ex(0) == 13) && has_quest_items?(st.player, WHITE_FABRIC_1)
          if st.get_memo_state_ex(0) == 12
            st.set_memo_state_ex(1, st.get_memo_state_ex(1) + 700)
            if st.get_memo_state_ex(1) + 700 > 80000
              give_items(st.player, BLOODED_FABRIC, 1)
              take_items(st.player, WHITE_FABRIC_1, 1)
              st.exit_quest(true, true)
            end
          end

          if st.get_memo_state_ex(0) == 13
            st.set_memo_state_ex(1, st.get_memo_state_ex(1) + 700)
            if st.get_memo_state_ex(1) + 700 > 100000
              give_items(st.player, BLOODED_FABRIC, 1)
              take_items(st.player, WHITE_FABRIC_1, 1)
              st.memo_state = 14 # Custom line
              st.set_memo_state_ex(0, 14)
              st.play_sound(Sound::ITEMSOUND_QUEST_MIDDLE)
            end
          end
        end
      when GUARDIAN_ANGEL, SEAL_ANGEL_1, SEAL_ANGEL_2
        if st.get_memo_state_ex(0) == 17 && has_quest_items?(st.player, WHITE_FABRIC_1)
          i0 = st.get_memo_state_ex(1) + Rnd.rand(100) + 100
          st.set_memo_state_ex(1, i0)
          if st.get_memo_state_ex(1) + i0 > 750
            give_items(st.player, BLOODED_FABRIC, 1)
            take_items(st.player, WHITE_FABRIC_1, 1)
            st.play_sound(Sound::ITEMSOUND_QUEST_MIDDLE)
            st.set_memo_state_ex(1, 0)
          end
        end
      else
        # [automatically added else]
      end

    end

    super
  end

  def on_spawn(npc)
    case npc.id
    when ARK_GUARDIAN_ELBEROTH
      npc.variables[I_QUEST0] = false
      npc.broadcast_packet(NpcSay.new(npc.l2id, Say2::NPC_ALL, npc.id, NpcString::THAT_DOESNT_BELONG_TO_YOU_DONT_TOUCH_IT))
      start_quest_timer("DESPAWN", 600000, npc, nil)
    when ARK_GUARDIAN_SHADOWFANG
      npc.variables[I_QUEST0] = false
      npc.broadcast_packet(NpcSay.new(npc.l2id, Say2::NPC_ALL, npc.id, NpcString::GET_OUT_OF_MY_SIGHT_YOU_INFIDELS))
      start_quest_timer("DESPAWN", 600000, npc, nil)
    when ANGEL_KILLER
      npc.broadcast_packet(NpcSay.new(npc.l2id, Say2::NPC_ALL, npc.id, NpcString::I_HAVE_THE_KEY_WHY_DONT_YOU_COME_AND_TAKE_IT))
      start_quest_timer("DESPAWN", 600000, npc, nil)
    else
      # [automatically added else]
    end


    super
  end

  def on_talk(npc, player)
    st = get_quest_state!(player)

    if st.created?
      html = player.level >= MIN_LEVEL ? "30864-01.htm" : "30864-05.html"
    elsif st.started?
      case npc.id
      when HANELLIN
        case st.memo_state
        when 1, 2
          memo_state = st.memo_state
          if memo_state == 1 && !has_quest_items?(player, TITANS_POWERSTONE) && !has_quest_items?(player, SHELL_OF_MONSTERS)
            html = "30864-06.html"
          elsif (memo_state == 1 && has_quest_items?(player, TITANS_POWERSTONE)) || has_quest_items?(player, SHELL_OF_MONSTERS) || memo_state == 2
            if has_quest_items?(player, SHELL_OF_MONSTERS)
              take_items(player, SHELL_OF_MONSTERS, 1)
            end

            if has_quest_items?(player, TITANS_POWERSTONE)
              take_items(player, TITANS_POWERSTONE, 1)
            end

            st.memo_state = 2
            html = "30864-07.html"
          end
        when 4
          case st.get_memo_state_ex(1)
          when 0
            st.memo_state = 5
            html = "30864-09.html"
            give_items(player, HANELLINS_1ST_LETTER, 1)
            give_items(player, HANELLINS_2ND_LETTER, 1)
            give_items(player, HANELLINS_3RD_LETTER, 1)
            st.set_cond(5, true)
          when 1
            st.memo_state = 5
            html = "30864-13.html"
            give_items(player, HANELLINS_1ST_LETTER, 1)
            st.set_cond(6, true)
          when 2
            st.memo_state = 5
            html = "30864-14.html"
            give_items(player, HANELLINS_2ND_LETTER, 1)
            st.set_cond(7, true)
          when 3
            st.memo_state = 5
            html = "30864-15.html"
            give_items(player, HANELLINS_3RD_LETTER, 1)
            st.set_cond(8, true)
          else
            # [automatically added else]
          end

        when 5
          if st.get_memo_state_ex(1) % 10 == 0
            html = "30864-16.html"
          else
            case st.get_memo_state_ex(1)
            when 1
              html = "30864-17.html"
            when 2
              html = "30864-18.html"
            when 3
              html = "30864-19.html"
            else
              # [automatically added else]
            end

          end

          # Custom part
          if has_quest_items?(player, BOOK_OF_SAINT, BLOOD_OF_SAINT, BOUGH_OF_SAINT)
            take_items(player, 1, {BOOK_OF_SAINT, BLOOD_OF_SAINT, BOUGH_OF_SAINT})
            st.memo_state = 9
            html = "30864-21.html"
            st.set_cond(22, true)
          end
        when 6, 7
          html = "30864-20.html"
        when 8
          if has_quest_items?(player, BOOK_OF_SAINT, BLOOD_OF_SAINT, BOUGH_OF_SAINT)
            take_items(player, 1, {BOOK_OF_SAINT, BLOOD_OF_SAINT, BOUGH_OF_SAINT})
            st.memo_state = 9
            html = "30864-21.html"
            st.set_cond(22, true)
          else
            case st.get_memo_state_ex(1)
            when 0
              html = "30864-22.html"
            when 1
              if has_quest_items?(player, BLOOD_OF_SAINT) && !has_at_least_one_quest_item?(player, BOOK_OF_SAINT, BOUGH_OF_SAINT)
                html = "30864-33.html"
              elsif !has_quest_items?(player, BLOOD_OF_SAINT, WHITE_FABRIC_2)
                html = "30864-36.html"
              end
            when 2
              if has_quest_items?(player, BOOK_OF_SAINT) && !has_at_least_one_quest_item?(player, BLOOD_OF_SAINT, BOUGH_OF_SAINT)
                html = "30864-34.html"
              elsif !has_quest_items?(player, BOOK_OF_SAINT, WHITE_FABRIC_2)
                html = "30864-37.html"
              end
            when 3
              if has_quest_items?(player, BOUGH_OF_SAINT) && !has_at_least_one_quest_item?(player, BLOOD_OF_SAINT, BOOK_OF_SAINT)
                html = "30864-35.html"
              elsif !has_quest_items?(player, BOUGH_OF_SAINT, WHITE_FABRIC_2)
                html = "30864-38.html"
              end
            else
              # [automatically added else]
            end


            if get_quest_items_count(player, WHITE_FABRIC_2) > 1 && st.get_memo_state_ex(1) > 0
              html = "30864-40.html"
            end

            if get_quest_items_count(player, WHITE_FABRIC_2) == 1 && st.get_memo_state_ex(1) > 0 && !has_quest_items?(player, BOOK_OF_SAINT, BLOOD_OF_SAINT, BOUGH_OF_SAINT)
              give_items(player, WHITE_FABRIC_1, 1)
              take_items(player, WHITE_FABRIC_2, 1)
              st.memo_state = 10
              html = "30864-41.html"
            end
          end
        when 9
          antidote_count = get_quest_items_count(player, ANTIDOTE)
          if antidote_count < 5 || !has_quest_items?(player, GREATER_HEALING_POTION)
            html = "30864-23.html"
          elsif antidote_count >= 5 && has_quest_items?(player, GREATER_HEALING_POTION)
            if st.get_memo_state_ex(1) == 0
              html = "30864-24.html"
              give_items(player, WHITE_FABRIC_1, 1)
              st.memo_state = 10
              take_items(player, ANTIDOTE, 5)
              take_items(player, GREATER_HEALING_POTION, 1)
            else
              give_items(player, WHITE_FABRIC_2, 3)
              take_items(player, ANTIDOTE, 5)
              take_items(player, GREATER_HEALING_POTION, 1)
              st.memo_state = 10
              st.set_cond(23, true)
              html = "30864-39.html"
            end
          end
        when 10
          if get_quest_items_count(player, WHITE_FABRIC_1) == 1
            html = "30864-25.html"
          end

          if get_quest_items_count(player, WHITE_FABRIC_2) > 1 && st.get_memo_state_ex(1) > 0
            html = "30864-40.html"
          end

          if get_quest_items_count(player, WHITE_FABRIC_2) == 1 && st.get_memo_state_ex(1) > 0 && !has_quest_items?(player, BOOK_OF_SAINT, BLOOD_OF_SAINT, BOUGH_OF_SAINT)
            give_items(player, WHITE_FABRIC_1, 1)
            take_items(player, WHITE_FABRIC_2, 1)
            st.memo_state = 10
            html = "30864-41.html"
          end
        when 11
          if get_quest_items_count(player, WHITE_FABRIC_1) == 1
            if st.get_memo_state_ex(1) > 0
              case st.get_memo_state_ex(1)
              when 1
                give_adena(player, 43000, true)
              when 2
                give_adena(player, 4000, true)
              when 3
                give_adena(player, 13000, true)
              else
                # [automatically added else]
              end


              st.set_memo_state_ex(0, 12)
              st.set_memo_state_ex(1, 100)
              st.set_cond(24, true)
              html = "30864-27.html"
            elsif st.get_memo_state_ex(1) == 0
              html = "30864-28.html"
            end
          end
        when 12
          if get_quest_items_count(player, WHITE_FABRIC_1) == 1
            html = "30864-31.html"
          end
        when 13
          if get_quest_items_count(player, WHITE_FABRIC_1) == 1
            html = "30864-32.html"
          end
        when 14
          get_reward(player)
          st.memo_state = 15
          html = "30864-42.html"
        when 15
          html = "30864-43.html"
        when 16
          if has_quest_items?(player, BLOODED_FABRIC)
            give_items(player, WHITE_FABRIC_1, 9)
          else
            give_items(player, WHITE_FABRIC_1, 10)
          end

          st.memo_state = 17 # Custom line
          st.set_memo_state_ex(0, 17)
          st.set_memo_state_ex(1, 0)
          st.set_cond(26, true)
          html = "30864-44.html"
        when 17
          if has_quest_items?(player, WHITE_FABRIC_1)
            html = "30864-45.html"
          else
            blooded_fabric_count = get_quest_items_count(player, BLOODED_FABRIC)
            if blooded_fabric_count >= 10
              html = "30864-46.html"
            else
              give_adena(player, (blooded_fabric_count * 1000) + 4000, true)
              take_items(player, BLOODED_FABRIC, -1)
              st.exit_quest(true, true)
              html = "30864-48.html"
            end
          end
        when 18
          memo_state_ex = st.get_memo_state_ex(1)
          if memo_state_ex % 10 < 7
            i1 = 0
            i2 = 0
            i0 = memo_state_ex % 10
            if i0 >= 4
              i1 = i1 + 6
              i0 = i0 - 4
              i2 = i2 + 1
            end

            if i0 >= 2
              i0 = i0 - 2
              i1 = i1 + 1
              i2 = i2 + 1
            end

            if i0 >= 1
              i1 = i1 + 3
              i2 = i2 + 1
              i0 = i0 - 1
            end

            if i0 == 0
              blooded_fabric_count = get_quest_items_count(player, BLOODED_FABRIC)
              if blooded_fabric_count + i1 >= 10
                html = "30864-52.html"
              else
                html = "30864-53.html"
                if i2 == 2
                  give_adena(player, 24000, true)
                elsif i2 == 1
                  give_adena(player, 12000, true)
                end

                st.exit_quest(true, true)
              end
            end
          elsif memo_state_ex % 10 == 7
            html = "30864-54.html"
            st.set_cond(28, true)
            get_reward(player)
            st.memo_state = 19
          end
        when 19
          html = "30864-49.html"
        else
          # [automatically added else]
        end

      when IASON_HEINE
        if st.get_memo_state_ex(0) == 18
          if st.get_memo_state_ex(1) % 8 < 4
            if get_quest_items_count(player, BLOODED_FABRIC) >= 6
              take_items(player, BLOODED_FABRIC, 6)
              st.set_memo_state_ex(1, st.get_memo_state_ex(1) + 4)
              html = "30969-01.html"
            else
              html = "30969-02.html"
            end
          else
            html = "30969-03.html"
          end
        end
      when HOLY_ARK_OF_SECRECY_1
        if has_quest_items?(player, FIRST_KEY_OF_ARK)
          give_items(player, BLOOD_OF_SAINT, 1)
          st.clear_radar
          if st.get_memo_state_ex(1) % 10 == 0
            if has_quest_items?(player, BOOK_OF_SAINT, BOUGH_OF_SAINT)
              st.set_cond(21, true)
            end
          else
            st.set_cond(20, true)
          end

          take_items(player, FIRST_KEY_OF_ARK, 1)
          st.set_memo_state_ex(1, st.get_memo_state_ex(1) - 20)
          if ((st.get_memo_state_ex(1) - 20) % 100) // 10 == 0
            st.set_memo_state_ex(0, st.get_memo_state_ex(0) + 1)
          end

          if (st.get_memo_state_ex(1) - 20) % 10 == 1
            st.set_memo_state_ex(0, 8)
          end

          html = "30977-01.html"
        else
          if st.memo_state <= 8 && (st.get_memo_state_ex(1) % 100) // 10 == 0 && has_quest_items?(player, BLOOD_OF_SAINT)
            html = "30977-02.html"
          elsif st.memo_state < 8 && (st.get_memo_state_ex(1) % 100) // 10 == 1 && !has_quest_items?(player, BLOOD_OF_SAINT)
            html = "30977-03.html"
          end
        end
      when HOLY_ARK_OF_SECRECY_2
        if has_quest_items?(player, SECOND_KEY_OF_ARK)
          give_items(player, BOOK_OF_SAINT, 1)
          take_items(player, SECOND_KEY_OF_ARK, 1)
          st.clear_radar
          if st.get_memo_state_ex(1) % 10 == 0
            if has_quest_items?(player, BLOOD_OF_SAINT, BOUGH_OF_SAINT)
              st.set_cond(21, true)
            end
          else
            st.set_cond(12, true)
          end

          st.set_memo_state_ex(1, st.get_memo_state_ex(1) - 200)
          if ((st.get_memo_state_ex(1) - 200) % 1000) // 100 == 0
            st.set_memo_state_ex(0, st.get_memo_state_ex(0) + 1)
          end

          if (st.get_memo_state_ex(1) - 200) % 10 == 2
            st.set_memo_state_ex(0, 8)
          end

          html = "30978-01.html"
        else
          if st.memo_state < 8 && (st.get_memo_state_ex(1) % 1000) // 100 == 1
            html = "30978-02.html"
            if st.get_memo_state_ex(1) % 10 != 0
              st.set_cond(10, true)
            end

            # TODO (Adry_85): Missing Question Mark
            st.play_sound(Sound::ITEMSOUND_QUEST_MIDDLE)
            add_spawn(ARK_GUARDIAN_ELBEROTH, *player.xyz, 0, false, 0, false) # ark_guardian_elberoth
          elsif st.memo_state <= 8 && (st.get_memo_state_ex(1) % 1000) // 100 == 0 && has_quest_items?(player, BOOK_OF_SAINT)
            html = "30978-03.html"
          end
        end
      when HOLY_ARK_OF_SECRECY_3
        if has_quest_items?(player, THIRD_KEY_OF_ARK)
          give_items(player, BOUGH_OF_SAINT, 1)
          take_items(player, THIRD_KEY_OF_ARK, 1)
          st.clear_radar
          if st.get_memo_state_ex(1) % 10 == 0
            if has_quest_items?(player, BLOOD_OF_SAINT, BOOK_OF_SAINT)
              st.set_cond(21, true)
            end
          else
            st.set_cond(16, true)
          end

          st.set_memo_state_ex(1, st.get_memo_state_ex(1) - 2000)
          if ((st.get_memo_state_ex(1) - 2000) % 10000) // 1000 == 0
            st.set_memo_state_ex(0, st.get_memo_state_ex(0) + 1)
          end

          if (st.get_memo_state_ex(1) - 2000) % 10 == 3
            st.set_memo_state_ex(0, 8)
          end

          html = "30979-01.html"
        else
          if st.memo_state < 8 && (st.get_memo_state_ex(1) % 10000) // 1000 == 1
            html = "30979-02.html"
            if st.get_memo_state_ex(1) % 10 != 0
              st.set_cond(14, true)
            end

            # TODO (Adry_85): Missing Question Mark
            st.play_sound(Sound::ITEMSOUND_QUEST_MIDDLE)
            add_spawn(ARK_GUARDIAN_SHADOWFANG, *player.xyz, 0, false, 0, false) # ark_guardian_shadowfang
          elsif st.memo_state <= 8 && (st.get_memo_state_ex(1) % 10000) // 1000 == 0 && has_quest_items?(player, BOUGH_OF_SAINT)
            html = "30979-03.html"
          end
        end
      when ARK_GUARDIANS_CORPSE
        if st.memo_state < 8 && (st.get_memo_state_ex(1) % 100) // 10 == 1 && !has_quest_items?(player, FIRST_KEY_OF_ARK) && !has_quest_items?(player, BLOOD_OF_SAINT)
          html = "30980-02.html"
          st.clear_radar
          if st.get_memo_state_ex(1) % 10 != 0
            st.set_cond(18, true)
          end

          # TODO (Adry_85): Missing Question Mark
          st.play_sound(Sound::ITEMSOUND_QUEST_MIDDLE)
          add_spawn(ANGEL_KILLER, *player.xyz, 0, false, 0, false) # angel_killer
        elsif st.memo_state < 8 && (st.get_memo_state_ex(1) % 100) // 10 == 2 && !has_quest_items?(player, FIRST_KEY_OF_ARK) && !has_quest_items?(player, BLOOD_OF_SAINT)
          give_items(player, FIRST_KEY_OF_ARK, 1)
          st.add_radar(-418, 44174, -3568)
          html = "30980-03.html"
        elsif has_at_least_one_quest_item?(player, FIRST_KEY_OF_ARK, BLOOD_OF_SAINT)
          html = "30980-01.html"
        end
      when CLAUDIA_ATHEBALDT
        if has_quest_items?(player, HANELLINS_2ND_LETTER)
          i0 = st.get_memo_state_ex(1) + 100
          if i0 % 10 == 0
            st.add_radar(181472, 7158, -2725)
          else
            st.set_cond(9, true)
          end

          st.set_memo_state_ex(1, i0)
          take_items(player, HANELLINS_2ND_LETTER, 1)
          html = "31001-01.html"
        elsif st.memo_state < 8 && (st.get_memo_state_ex(1) % 1000) // 100 == 1 && !has_quest_items?(player, SECOND_KEY_OF_ARK)
          # retail typo
          if st.get_memo_state_ex(1) % 10 == 0
            st.add_radar(181472, 7158, -2725)
          end

          html = "31001-03.html"
        elsif has_quest_items?(player, SECOND_KEY_OF_ARK)
          if st.get_memo_state_ex(1) % 10 == 0
            st.add_radar(181472, 7158, -2725)
          end

          html = "31001-04.html"
        elsif has_quest_items?(player, BOOK_OF_SAINT)
          html = "31001-05.html"
        end
      when HARNE
        if has_quest_items?(player, HANELLINS_1ST_LETTER)
          i0 = st.get_memo_state_ex(1) + 10
          if i0 % 10 == 0
            st.add_radar(2908, 44128, -2712)
          else
            st.set_cond(17, true)
          end

          st.set_memo_state_ex(1, i0)
          take_items(player, HANELLINS_1ST_LETTER, 1)
          html = "30144-01.html"
        elsif st.memo_state < 8 && (st.get_memo_state_ex(1) % 100) // 10 == 1 && !has_quest_items?(player, FIRST_KEY_OF_ARK)
          # retail typo
          if st.get_memo_state_ex(1) % 10 == 0
            st.add_radar(2908, 44128, -2712)
          end

          html = "30144-03.html"
        elsif has_quest_items?(player, FIRST_KEY_OF_ARK)
          if st.get_memo_state_ex(1) % 10 == 0
            st.add_radar(2908, 44128, -2712)
          end

          html = "30144-04.html"
        elsif has_quest_items?(player, BLOOD_OF_SAINT)
          html = "30144-05.html"
        end
      when MARTIEN
        if has_quest_items?(player, HANELLINS_3RD_LETTER)
          i0 = st.get_memo_state_ex(1) + 1000
          if i0 % 10 == 0
            st.add_radar(50693, 158674, 376)
          else
            st.set_cond(13, true)
          end

          st.set_memo_state_ex(1, i0)
          take_items(player, HANELLINS_3RD_LETTER, 1)
          html = "30645-01.html"
        elsif st.memo_state < 8 && (st.get_memo_state_ex(1) % 10000) // 1000 == 1 && !has_quest_items?(player, THIRD_KEY_OF_ARK)
          # retail typo
          if st.get_memo_state_ex(1) % 10 == 0
            st.add_radar(50693, 158674, 376)
          end

          html = "30645-03.html"
        elsif has_quest_items?(player, THIRD_KEY_OF_ARK)
          if st.get_memo_state_ex(1) % 10 == 0
            st.add_radar(50693, 158674, 376)
          end

          html = "30645-04.html"
        elsif has_quest_items?(player, BOUGH_OF_SAINT)
          html = "30645-05.html"
        end
      when SIR_GUSTAV_ATHEBALDT
        if st.get_memo_state_ex(0) == 18
          if st.get_memo_state_ex(1) % 2 == 0
            if get_quest_items_count(player, BLOODED_FABRIC) >= 3
              take_items(player, BLOODED_FABRIC, 3)
              st.set_memo_state_ex(1, st.get_memo_state_ex(1) + 1)
              html = "30760-01.html"
            else
              html = "30760-02.html"
            end
          elsif st.get_memo_state_ex(1) % 2 == 1
            html = "30760-03.html"
          end
        end
      when HARDIN
        if st.get_memo_state_ex(0) == 18
          if st.get_memo_state_ex(1) % 4 < 2
            if get_quest_items_count(player, BLOODED_FABRIC) >= 1
              take_items(player, BLOODED_FABRIC, 1)
              st.set_memo_state_ex(1, st.get_memo_state_ex(1) + 2)
              html = "30832-01.html"
            elsif get_quest_items_count(player, BLOODED_FABRIC) < 3
              html = "30832-02.html"
            end
          else
            html = "30832-03.html"
          end
        end
      else
        # [automatically added else]
      end

    end

    html || get_no_quest_msg(player)
  end

  private def get_reward(player)
    cid = player.class_id
    lvl = player.level
    if cid.treasure_hunter? || cid.plains_walker? || cid.abyss_walker? || cid.adventurer? || cid.wind_rider? || cid.ghost_hunter? || cid.male_soulbreaker? || cid.female_soulbreaker? || cid.male_soulhound? || cid.female_soulhound? || cid.inspector? || cid.judicator?
      if lvl < 69
        give_items(player, KRIS_EDGE, 1)
        give_items(player, SYNTHETIC_COKES, 2)
      else
        give_items(player, DEMONS_DAGGER_EDGE, 1)
        give_items(player, COKES, 2)
      end
    elsif cid.tyrant? || cid.grand_khavatari?
      if lvl < 69
        give_items(player, ARTHRO_NAIL_BLADE, 1)
        give_items(player, SYNTHETIC_COKES, 2)
        give_items(player, COKES, 1)
      else
        give_items(player, BELLION_CESTUS_EDGE, 1)
        give_items(player, ORIHARUKON_ORE, 2)
      end
    elsif cid.paladin? || cid.dark_avenger? || cid.prophet? || cid.temple_knight? || cid.sword_singer? || cid.shillien_knight? || cid.bladedancer? || cid.shillien_elder? || cid.phoenix_knight? || cid.hell_knight? || cid.hierophant? || cid.eva_templar? || cid.sword_muse? || cid.shillien_templar? || cid.spectral_dancer? || cid.shillien_saint?
      if lvl < 69
        give_items(player, KESHANBERK_BLADE, 1)
        give_items(player, SYNTHETIC_COKES, 2)
      else
        give_items(player, SWORD_OF_DAMASCUS_BLADE, 1)
        give_items(player, ORIHARUKON_ORE, 2)
      end
    elsif cid.hawkeye? || cid.silver_ranger? || cid.phantom_ranger? || cid.sagittarius? || cid.moonlight_sentinel? || cid.ghost_sentinel? || cid.arbalester? || cid.trickster?
      if lvl < 69
        give_items(player, DARK_ELVEN_LONGBOW_SHAFT, 1)
        give_items(player, SYNTHETIC_COKES, 2)
      else
        give_items(player, BOW_OF_PERIL_SHAFT, 1)
        give_items(player, COARSE_BONE_POWDER, 9)
      end
    elsif cid.gladiator? || cid.bishop? || cid.elder? || cid.duelist? || cid.cardinal? || cid.eva_saint?
      if lvl < 69
        give_items(player, HEAVY_WAR_AXE_HEAD, 1)
        give_items(player, SYNTHETIC_COKES, 2)
        give_items(player, COKES, 1)
      else
        give_items(player, ART_OF_BATTLE_AXE_BLADE, 1)
        give_items(player, ORIHARUKON_ORE, 2)
      end
    elsif cid.warlord? || cid.bounty_hunter? || cid.warsmith? || cid.dreadnought? || cid.fortune_seeker? || cid.maestro?
      if lvl < 63
        give_items(player, GREAT_AXE_HEAD, 1)
        give_items(player, ENRIA, 1)
        give_items(player, COKES, 1)
      else
        give_items(player, LANCE_BLADE, 1)
        give_items(player, ORIHARUKON_ORE, 2)
      end
    elsif cid.sorceror? || cid.spellsinger? || cid.overlord? || cid.archmage? || cid.mystic_muse? || cid.dominator?
      if lvl < 63
        give_items(player, SPRITES_STAFF_HEAD, 1)
        give_items(player, ORIHARUKON_ORE, 4)
        give_items(player, COARSE_BONE_POWDER, 1)
      else
        give_items(player, EVIL_SPIRIT_HEAD, 1)
        give_items(player, ANIMAL_BONE, 5)
      end
    elsif cid.necromancer? || cid.spellhowler? || cid.soultaker? || cid.storm_screamer?
      give_items(player, HELL_KNIFE_EDGE, 1)
      give_items(player, SYNTHETIC_COKES, 2)
      give_items(player, ANIMAL_BONE, 2)
    elsif cid.destroyer? || cid.titan? || cid.berserker? || cid.doombringer?
      give_items(player, GREAT_SWORD_BLADE, 1)
      give_items(player, VARNISH_OF_PURITY, 2)
      give_items(player, SYNTHETIC_COKES, 2)
    elsif cid.elemental_summoner? || cid.phantom_summoner? || cid.elemental_master? || cid.spectral_master?
      give_items(player, SWORD_OF_DAMASCUS_BLADE, 1)
      give_items(player, ENRIA, 1)
    elsif cid.warcryer? || cid.doomcryer?
      give_items(player, SWORD_OF_VALHALLA_BLADE, 1)
      give_items(player, ORIHARUKON_ORE, 1)
      give_items(player, VARNISH_OF_PURITY, 1)
    elsif cid.warlock? || cid.arcana_lord?
      give_items(player, ART_OF_BATTLE_AXE_BLADE, 1)
      give_items(player, ENRIA, 1)
    else
      give_adena(player, 49000, true)
    end
  end
end
