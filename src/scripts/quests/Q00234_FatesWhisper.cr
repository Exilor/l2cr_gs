class Scripts::Q00234_FatesWhisper < Quest
  # NPCs
  private ZENKIN = 30178
  private CLIFF = 30182
  private MASTER_KASPAR = 30833
  private HEAD_BLACKSMITH_FERRIS = 30847
  private MAESTRO_LEORIN = 31002
  private COFFER_OF_THE_DEAD = 31027
  private CHEST_OF_KERNON = 31028
  private CHEST_OF_GOLKONDA = 31029
  private CHEST_OF_HALLATE = 31030
  # Quest Items
  private Q_BLOODY_FABRIC_Q0234 = 14361
  private Q_WHITE_FABRIC_Q0234 = 14362
  private Q_STAR_OF_DESTINY = 5011
  private Q_PIPETTE_KNIFE = 4665
  private Q_REIRIAS_SOULORB = 4666
  private Q_INFERNIUM_SCEPTER_1 = 4667
  private Q_INFERNIUM_SCEPTER_2 = 4668
  private Q_INFERNIUM_SCEPTER_3 = 4669
  private Q_MAESTRO_REORINS_HAMMER = 4670
  private Q_MAESTRO_REORINS_MOLD = 4671
  private Q_INFERNIUM_VARNISH = 4672
  private Q_RED_PIPETTE_KNIFE = 4673
  # Other Items
  private CRYSTAL_B = 1460
  # Monsters
  private PLATINUM_TRIBE_GRUNT = 20823
  private PLATINUM_TRIBE_ARCHER = 20826
  private PLATINUM_TRIBE_WARRIOR = 20827
  private PLATINUM_TRIBE_SHAMAN = 20828
  private PLATINUM_TRIBE_LORD = 20829
  private GUARDIAN_ANGEL = 20830
  private SEAL_ANGEL = 20831
  private SEAL_ANGEL_R = 20860

  private DOMB_DEATH_CABRIO = 25035
  private KERNON = 25054
  private GOLKONDA_LONGHORN = 25126
  private HALLATE_THE_DEATH_LORD = 25220
  private BAIUM = 29020

  # B-grade
  private SWORD_OF_DAMASCUS = 79
  private SWORD_OF_DAMASCUS_FOCUS = 4717
  private SWORD_OF_DAMASCUS_CRT_DAMAGE = 4718
  private SWORD_OF_DAMASCUS_HASTE = 4719
  private HAZARD_BOW = 287
  private HAZARD_BOW_GUIDENCE = 4828
  private HAZARD_BOW_QUICKRECOVERY = 4829
  private HAZARD_BOW_CHEAPSHOT = 4830
  private LANCIA = 97
  private LANCIA_ANGER = 4858
  private LANCIA_CRT_STUN = 4859
  private LANCIA_LONGBLOW = 4860
  private ART_OF_BATTLE_AXE = 175
  private ART_OF_BATTLE_AXE_HEALTH = 4753
  private ART_OF_BATTLE_AXE_RSK_FOCUS = 4754
  private ART_OF_BATTLE_AXE_HASTE = 4755
  private STAFF_OF_EVIL_SPRIT = 210
  private STAFF_OF_EVIL_SPRIT_MAGICFOCUS = 4900
  private STAFF_OF_EVIL_SPRIT_MAGICBLESSTHEBODY = 4901
  private STAFF_OF_EVIL_SPRIT_MAGICPOISON = 4902
  private DEMONS_SWORD = 234
  private DEMONS_SWORD_CRT_BLEED = 4780
  private DEMONS_SWORD_CRT_POISON = 4781
  private DEMONS_SWORD_MIGHTMOTAL = 4782
  private BELLION_CESTUS = 268
  private BELLION_CESTUS_CRT_DRAIN = 4804
  private BELLION_CESTUS_CRT_POISON = 4805
  private BELLION_CESTUS_RSK_HASTE = 4806
  private DEADMANS_GLORY = 171
  private DEADMANS_GLORY_ANGER = 4750
  private DEADMANS_GLORY_HEALTH = 4751
  private DEADMANS_GLORY_HASTE = 4752
  private SAMURAI_LONGSWORD_SAMURAI_LONGSWORD = 2626
  private GUARDIANS_SWORD = 7883
  private GUARDIANS_SWORD_CRT_DRAIN = 8105
  private GUARDIANS_SWORD_HEALTH = 8106
  private GUARDIANS_SWORD_CRT_BLEED = 8107
  private TEARS_OF_WIZARD = 7889
  private TEARS_OF_WIZARD_ACUMEN = 8117
  private TEARS_OF_WIZARD_MAGICPOWER = 8118
  private TEARS_OF_WIZARD_UPDOWN = 8119
  private STAR_BUSTER = 7901
  private STAR_BUSTER_HEALTH = 8132
  private STAR_BUSTER_HASTE = 8133
  private STAR_BUSTER_RSK_FOCUS = 8134
  private BONE_OF_KAIM_VANUL = 7893
  private BONE_OF_KAIM_VANUL_MANAUP = 8144
  private BONE_OF_KAIM_VANUL_MAGICSILENCE = 8145
  private BONE_OF_KAIM_VANUL_UPDOWN = 8146
  # A-grade
  private TALLUM_BLADE = 80
  private CARNIUM_BOW = 288
  private HALBARD = 98
  private ELEMENTAL_SWORD = 150
  private DASPARIONS_STAFF = 212
  private BLOODY_ORCHID = 235
  private BLOOD_TORNADO = 269
  private METEOR_SHOWER = 2504
  private KSHANBERK_KSHANBERK = 5233
  private INFERNO_MASTER = 7884
  private EYE_OF_SOUL = 7894
  private HAMMER_OF_DESTROYER = 7899

  def initialize
    super(234, self.class.simple_name, "Fate's Whisper")

    add_start_npc(MAESTRO_LEORIN)
    add_talk_id(
      ZENKIN, CLIFF, MASTER_KASPAR, HEAD_BLACKSMITH_FERRIS, MAESTRO_LEORIN
    )
    add_talk_id(
      COFFER_OF_THE_DEAD, CHEST_OF_KERNON, CHEST_OF_HALLATE, CHEST_OF_GOLKONDA
    )

    add_kill_id(
      PLATINUM_TRIBE_GRUNT, PLATINUM_TRIBE_ARCHER, PLATINUM_TRIBE_WARRIOR,
      PLATINUM_TRIBE_SHAMAN, PLATINUM_TRIBE_LORD, GUARDIAN_ANGEL, SEAL_ANGEL,
      SEAL_ANGEL_R
    )
    add_kill_id(
      DOMB_DEATH_CABRIO, KERNON, GOLKONDA_LONGHORN, HALLATE_THE_DEATH_LORD
    )

    add_spawn_id(
      COFFER_OF_THE_DEAD, CHEST_OF_KERNON, CHEST_OF_HALLATE, CHEST_OF_GOLKONDA
    )
    add_attack_id(BAIUM)
    register_quest_items(
      Q_BLOODY_FABRIC_Q0234, Q_WHITE_FABRIC_Q0234, Q_PIPETTE_KNIFE,
      Q_REIRIAS_SOULORB, Q_INFERNIUM_SCEPTER_1, Q_INFERNIUM_SCEPTER_2,
      Q_INFERNIUM_SCEPTER_3, Q_MAESTRO_REORINS_HAMMER, Q_MAESTRO_REORINS_MOLD,
      Q_INFERNIUM_VARNISH, Q_RED_PIPETTE_KNIFE
    )
  end

  def on_spawn(npc)
    case npc.id
    when COFFER_OF_THE_DEAD
      start_quest_timer("23401", 1000 * 120, npc, nil)
    when CHEST_OF_KERNON
      start_quest_timer("23402", 1000 * 120, npc, nil)
    when CHEST_OF_HALLATE
      start_quest_timer("23403", 1000 * 120, npc, nil)
    when CHEST_OF_GOLKONDA
      start_quest_timer("23404", 1000 * 120, npc, nil)
    else
      # automatically added
    end


    super
  end

  def on_talk(npc, pc)
    qs = get_quest_state!(pc)

    case npc.id
    when ZENKIN
      case qs.memo_state
      when 6
        return "30178-01.html"
      when 7
        return "30178-03.html"
      when 8
        return "30178-04.html"
      else
        # automatically added
      end

    when CLIFF
      if qs.memo_state?(4) && !qs.has_quest_items?(Q_INFERNIUM_VARNISH)
        return "30182-01.html"
      end
      if qs.memo_state?(4) && qs.has_quest_items?(Q_INFERNIUM_VARNISH)
        return "30182-05.html"
      end
      if qs.memo_state >= 5
        return "30182-06.html"
      end
    when MASTER_KASPAR
      if qs.memo_state?(7)
        return "30833-01.html"
      end

      bloody_fabric_count = qs.get_quest_items_count(Q_BLOODY_FABRIC_Q0234)
      white_fabric_count = qs.get_quest_items_count(Q_WHITE_FABRIC_Q0234)
      white_bloody_fabric_count = bloody_fabric_count + white_fabric_count
      if qs.memo_state?(8) && !qs.has_quest_items?(Q_RED_PIPETTE_KNIFE)
        if white_bloody_fabric_count <= 0
          return "30833-03.html"
        end
      end
      if qs.memo_state?(8) && qs.has_quest_items?(Q_RED_PIPETTE_KNIFE)
        if white_bloody_fabric_count <= 0
          qs.give_items(Q_MAESTRO_REORINS_MOLD, 1)
          qs.take_items(Q_RED_PIPETTE_KNIFE, 1)
          qs.memo_state = 9
          qs.set_cond(10, true)
          qs.show_question_mark(234)
          return "30833-04.html"
        end
      end
      if qs.memo_state?(8) && !qs.has_quest_items?(Q_RED_PIPETTE_KNIFE)
        if bloody_fabric_count < 30 && white_bloody_fabric_count >= 30
          return "30833-03c.html"
        end
      end
      if qs.memo_state?(8) && !qs.has_quest_items?(Q_RED_PIPETTE_KNIFE)
        if bloody_fabric_count >= 30 && white_bloody_fabric_count >= 30
          qs.give_items(Q_MAESTRO_REORINS_MOLD, 1)
          qs.take_items(Q_BLOODY_FABRIC_Q0234, -1)
          qs.memo_state = 9
          qs.set_cond(10, true)
          qs.show_question_mark(234)
          return "30833-03d.html"
        end
      end
      if qs.memo_state?(8) && !qs.has_quest_items?(Q_RED_PIPETTE_KNIFE)
        if white_bloody_fabric_count < 30 && white_bloody_fabric_count > 0
          qs.give_items(Q_WHITE_FABRIC_Q0234, 30 - white_fabric_count)
          qs.take_items(Q_BLOODY_FABRIC_Q0234, -1)
          return "30833-03e.html"
        end
      end
      if qs.memo_state >= 9
        return "30833-05.html"
      end
    when HEAD_BLACKSMITH_FERRIS
      if qs.memo_state?(5)
        if qs.has_quest_items?(Q_MAESTRO_REORINS_HAMMER)
          return "30847-02.html"
        end
        qs.give_items(Q_MAESTRO_REORINS_HAMMER, 1)
        return "30847-01.html"
      end
      if qs.memo_state >= 6
        return "30847-03.html"
      end
    when MAESTRO_LEORIN
      if qs.created? && pc.level >= 75
        return "31002-01.htm"
      end
      if qs.created? && pc.level < 75
        return "31002-01a.htm"
      end
      if qs.completed?
        return get_already_completed_msg(pc)
      end
      if qs.memo_state?(1) && !qs.has_quest_items?(Q_REIRIAS_SOULORB)
        return "31002-09.html"
      end
      if qs.memo_state?(1) && qs.has_quest_items?(Q_REIRIAS_SOULORB)
        return "31002-10.html"
      end
      if qs.memo_state?(2) && !qs.has_quest_items?(Q_INFERNIUM_SCEPTER_1, Q_INFERNIUM_SCEPTER_2, Q_INFERNIUM_SCEPTER_3)
        return "31002-12.html"
      end
      if qs.memo_state?(2) && qs.has_quest_items?(Q_INFERNIUM_SCEPTER_1, Q_INFERNIUM_SCEPTER_2, Q_INFERNIUM_SCEPTER_3)
        return "31002-13.html"
      end
      if qs.memo_state?(4) && !qs.has_quest_items?(Q_INFERNIUM_VARNISH)
        return "31002-15.html"
      end
      if qs.memo_state?(4) && qs.has_quest_items?(Q_INFERNIUM_VARNISH)
        return "31002-16.html"
      end
      if qs.memo_state?(5) && !qs.has_quest_items?(Q_MAESTRO_REORINS_HAMMER)
        return "31002-18.html"
      end
      if qs.memo_state?(5) && qs.has_quest_items?(Q_MAESTRO_REORINS_HAMMER)
        return "31002-19.html"
      end
      if qs.memo_state < 9 && qs.memo_state >= 6
        return "31002-21.html"
      end
      if qs.memo_state?(9) && qs.has_quest_items?(Q_MAESTRO_REORINS_MOLD)
        return "31002-22.html"
      end
      if qs.memo_state?(10) && qs.get_quest_items_count(CRYSTAL_B) < 984
        return "31002-24.html"
      end
      if qs.memo_state?(10) && qs.get_quest_items_count(CRYSTAL_B) >= 984
        return "31002-25.html"
      end

      case qs.memo_state
      when 11
        if has_at_least_one_quest_item?(pc, SWORD_OF_DAMASCUS, SWORD_OF_DAMASCUS_FOCUS, SWORD_OF_DAMASCUS_CRT_DAMAGE, SWORD_OF_DAMASCUS_HASTE)
          return "31002-35.html"
        end
        return "31002-35a.html"
      when 12
        if has_at_least_one_quest_item?(pc, HAZARD_BOW_GUIDENCE, HAZARD_BOW_QUICKRECOVERY, HAZARD_BOW_CHEAPSHOT, HAZARD_BOW)
          return "31002-36.html"
        end
        return "31002-36a.html"
      when 13
        if has_at_least_one_quest_item?(pc, LANCIA_ANGER, LANCIA_CRT_STUN, LANCIA_LONGBLOW, LANCIA)
          return "31002-37.html"
        end
        return "31002-37a.html"
      when 14
        if has_at_least_one_quest_item?(pc, ART_OF_BATTLE_AXE_HEALTH, ART_OF_BATTLE_AXE_RSK_FOCUS, ART_OF_BATTLE_AXE_HASTE, ART_OF_BATTLE_AXE)
          return "31002-38.html"
        end
        return "31002-38a.html"
      when 15
        if has_at_least_one_quest_item?(pc, STAFF_OF_EVIL_SPRIT_MAGICFOCUS, STAFF_OF_EVIL_SPRIT_MAGICBLESSTHEBODY, STAFF_OF_EVIL_SPRIT_MAGICPOISON, STAFF_OF_EVIL_SPRIT)
          return "31002-39.html"
        end
        return "31002-39a.html"
      when 16
        if has_at_least_one_quest_item?(pc, DEMONS_SWORD_CRT_BLEED, DEMONS_SWORD_CRT_POISON, DEMONS_SWORD_MIGHTMOTAL, DEMONS_SWORD)
          return "31002-40.html"
        end
        return "31002-40a.html"
      when 17
        if has_at_least_one_quest_item?(pc, BELLION_CESTUS_CRT_DRAIN, BELLION_CESTUS_CRT_POISON, BELLION_CESTUS_RSK_HASTE, BELLION_CESTUS)
          return "31002-41.html"
        end
        return "31002-41a.html"
      when 18
        if has_at_least_one_quest_item?(pc, DEADMANS_GLORY_ANGER, DEADMANS_GLORY_HEALTH, DEADMANS_GLORY_HASTE, DEADMANS_GLORY)
          return "31002-42.html"
        end
        return "31002-42a.html"
      when 19
        if has_at_least_one_quest_item?(pc, SAMURAI_LONGSWORD_SAMURAI_LONGSWORD)
          return "31002-43.html"
        end
        return "31002-43a.html"
      when 41
        if has_at_least_one_quest_item?(pc, GUARDIANS_SWORD, GUARDIANS_SWORD_CRT_DRAIN, GUARDIANS_SWORD_HEALTH, GUARDIANS_SWORD_CRT_BLEED)
          return "31002-43b.html"
        end
        return "31002-43c.html"
      when 42
        if has_at_least_one_quest_item?(pc, TEARS_OF_WIZARD, TEARS_OF_WIZARD_ACUMEN, TEARS_OF_WIZARD_MAGICPOWER, TEARS_OF_WIZARD_UPDOWN)
          return "31002-43d.html"
        end
        return "31002-43e.html"
      when 43
        if has_at_least_one_quest_item?(pc, STAR_BUSTER, STAR_BUSTER_HEALTH, STAR_BUSTER_HASTE, STAR_BUSTER_RSK_FOCUS)
          return "31002-43f.html"
        end
        return "31002-43g.html"
      when 44
        if has_at_least_one_quest_item?(pc, BONE_OF_KAIM_VANUL, BONE_OF_KAIM_VANUL_MANAUP, BONE_OF_KAIM_VANUL_MAGICSILENCE, BONE_OF_KAIM_VANUL_UPDOWN)
          return "31002-43h.html"
        end
        return "31002-43i.html"
      else
        # automatically added
      end

    when COFFER_OF_THE_DEAD
      if qs.memo_state?(1) && !qs.has_quest_items?(Q_REIRIAS_SOULORB)
        qs.give_items(Q_REIRIAS_SOULORB, 1)
        qs.play_sound(Sound::ITEMSOUND_QUEST_ITEMGET)
        return "31027-01.html"
      end
      if qs.memo_state > 1 || qs.has_quest_items?(Q_REIRIAS_SOULORB)
        return "31027-02.html"
      end
    when CHEST_OF_KERNON
      if qs.memo_state?(2) && !qs.has_quest_items?(Q_INFERNIUM_SCEPTER_1)
        qs.give_items(Q_INFERNIUM_SCEPTER_1, 1)
        qs.play_sound(Sound::ITEMSOUND_QUEST_ITEMGET)
        return "31028-01.html"
      end
      if !qs.memo_state?(2) || qs.has_quest_items?(Q_INFERNIUM_SCEPTER_1)
        return "31028-02.html"
      end
    when CHEST_OF_GOLKONDA
      if qs.memo_state?(2) && !qs.has_quest_items?(Q_INFERNIUM_SCEPTER_2)
        qs.give_items(Q_INFERNIUM_SCEPTER_2, 1)
        qs.play_sound(Sound::ITEMSOUND_QUEST_ITEMGET)
        return "31029-01.html"
      end
      if !qs.memo_state?(2) || qs.has_quest_items?(Q_INFERNIUM_SCEPTER_2)
        return "31029-02.html"
      end
    when CHEST_OF_HALLATE
      if qs.memo_state?(2) && !qs.has_quest_items?(Q_INFERNIUM_SCEPTER_3)
        qs.give_items(Q_INFERNIUM_SCEPTER_3, 1)
        qs.play_sound(Sound::ITEMSOUND_QUEST_ITEMGET)
        return "31030-01.html"
      end
      if !qs.memo_state?(2) || qs.has_quest_items?(Q_INFERNIUM_SCEPTER_3)
        return "31030-02.html"
      end
    else
      # automatically added
    end


    get_no_quest_msg(pc)
  end

  def on_adv_event(event, npc, pc)
    npc = npc.not_nil!

    unless pc
      case event
      when "23401", "23402", "23403", "23404"
        npc.decay_me
      else
        # automatically added
      end

      return super
    end

    unless qs = get_quest_state(pc, false)
      return
    end

    html = nil

    if event == "QUEST_ACCEPTED"
      qs.memo_state = 1
      qs.start_quest
      qs.show_question_mark(234)
      qs.play_sound(Sound::ITEMSOUND_QUEST_ACCEPT)
      return "31002-06.html"
    end
    if event.includes?(".htm")
      return event
    end

    npc_id = npc.id
    event_id = event.to_i

    case npc_id
    when ZENKIN
      case event_id
      when 1
        qs.memo_state = 7
        qs.set_cond(6)
        qs.show_question_mark(234)
        qs.play_sound(Sound::ITEMSOUND_QUEST_MIDDLE)
        return "30178-02.html"
      else
        # automatically added
      end

    when CLIFF
      case event_id
      when 1
        return "30182-02.html"
      when 2
        return "30182-03.html"
      when 3
        if qs.memo_state?(4) && !qs.has_quest_items?(Q_INFERNIUM_VARNISH)
          qs.give_items(Q_INFERNIUM_VARNISH, 1)
          return "30182-04.html"
        end
      else
        # automatically added
      end

    when MASTER_KASPAR
      case event_id
      when 1
        if qs.memo_state?(7)
          return "30833-02.html"
        end
      when 2
        if qs.memo_state?(7)
          qs.give_items(Q_PIPETTE_KNIFE, 1)
          qs.memo_state = 8
          qs.set_cond(7, true)
          qs.show_question_mark(234)
          return "30833-03a.html"
        end
      when 3
        if qs.memo_state?(7)
          qs.give_items(Q_WHITE_FABRIC_Q0234, 30)
          qs.memo_state = 8
          qs.set_cond(8, true)
          qs.show_question_mark(234)
          return "30833-03b.html"
        end
      else
        # automatically added
      end

    when MAESTRO_LEORIN
      case event_id
      when 1
        return "31002-02.htm"
      when 2
        return "31002-03.html"
      when 3
        return "31002-04.html"
      when 4
        if !qs.completed? && pc.level >= 75
          return "31002-05.html"
        end
      when 5
        if qs.memo_state?(1) && qs.has_quest_items?(Q_REIRIAS_SOULORB)
          qs.take_items(Q_REIRIAS_SOULORB, 1)
          qs.memo_state = 2
          qs.set_cond(2, true)
          qs.show_question_mark(234)
          return "31002-11.html"
        end
      when 6
        if qs.memo_state?(2) && qs.has_quest_items?(Q_INFERNIUM_SCEPTER_1, Q_INFERNIUM_SCEPTER_2, Q_INFERNIUM_SCEPTER_3)
          qs.take_items(Q_INFERNIUM_SCEPTER_1, -1)
          qs.take_items(Q_INFERNIUM_SCEPTER_2, -1)
          qs.take_items(Q_INFERNIUM_SCEPTER_3, -1)
          qs.memo_state = 4
          qs.set_cond(3, true)
          qs.show_question_mark(234)
          return "31002-14.html"
        end
      when 7
        if qs.memo_state?(4) && qs.has_quest_items?(Q_INFERNIUM_VARNISH)
          qs.take_items(Q_INFERNIUM_VARNISH, 1)
          qs.memo_state = 5
          qs.set_cond(4, true)
          qs.show_question_mark(234)
          return "31002-17.html"
        end
      when 8
        if qs.memo_state?(5) && qs.has_quest_items?(Q_MAESTRO_REORINS_HAMMER)
          qs.take_items(Q_MAESTRO_REORINS_HAMMER, 1)
          qs.memo_state = 6
          qs.set_cond(5, true)
          qs.show_question_mark(234)
          return "31002-20.html"
        end
      when 9
        if qs.memo_state?(9) && qs.has_quest_items?(Q_MAESTRO_REORINS_MOLD)
          qs.take_items(Q_MAESTRO_REORINS_MOLD, 1)
          qs.memo_state = 10
          qs.set_cond(11, true)
          qs.show_question_mark(234)
          return "31002-23.html"
        end
      when 10
        if qs.memo_state?(10)
          if qs.get_quest_items_count(CRYSTAL_B) >= 984
            qs.take_items(CRYSTAL_B, 984)
            qs.memo_state = 11
            qs.set_cond(12, true)
            qs.show_question_mark(234)
            return "31002-26.html"
          end
          return "31002-34.html"
        end
      when 11
        if qs.memo_state?(10)
          if qs.get_quest_items_count(CRYSTAL_B) >= 984
            qs.take_items(CRYSTAL_B, 984)
            qs.memo_state = 19
            qs.set_cond(12, true)
            qs.show_question_mark(234)
            return "31002-26a.html"
          end
          return "31002-34.html"
        end
      when 12
        if qs.memo_state?(10)
          if qs.get_quest_items_count(CRYSTAL_B) >= 984
            qs.take_items(CRYSTAL_B, 984)
            qs.memo_state = 12
            qs.set_cond(12, true)
            qs.show_question_mark(234)
            return "31002-27.html"
          end
          return "31002-34.html"
        end
      when 13
        if qs.memo_state?(10)
          if qs.get_quest_items_count(CRYSTAL_B) >= 984
            qs.take_items(CRYSTAL_B, 984)
            qs.memo_state = 13
            qs.set_cond(12, true)
            qs.show_question_mark(234)
            return "31002-28.html"
          end
          return "31002-34.html"
        end
      when 14
        if qs.memo_state?(10)
          if qs.get_quest_items_count(CRYSTAL_B) >= 984
            qs.take_items(CRYSTAL_B, 984)
            qs.memo_state = 14
            qs.set_cond(12, true)
            qs.show_question_mark(234)
            return "31002-29.html"
          end
          return "31002-34.html"
        end
      when 15
        if qs.memo_state?(10)
          if qs.get_quest_items_count(CRYSTAL_B) >= 984
            qs.take_items(CRYSTAL_B, 984)
            qs.memo_state = 15
            qs.set_cond(12, true)
            qs.show_question_mark(234)
            return "31002-30.html"
          end
          return "31002-34.html"
        end
      when 16
        if qs.memo_state?(10)
          if qs.get_quest_items_count(CRYSTAL_B) >= 984
            qs.take_items(CRYSTAL_B, 984)
            qs.memo_state = 16
            qs.set_cond(12, true)
            qs.show_question_mark(234)
            return "31002-31.html"
          end
          return "31002-34.html"
        end
      when 17
        if qs.memo_state?(10)
          if qs.get_quest_items_count(CRYSTAL_B) >= 984
            qs.take_items(CRYSTAL_B, 984)
            qs.memo_state = 17
            qs.set_cond(12, true)
            qs.show_question_mark(234)
            return "31002-32.html"
          end
          return "31002-34.html"
        end
      when 18
        if qs.memo_state?(10)
          if qs.get_quest_items_count(CRYSTAL_B) >= 984
            qs.take_items(CRYSTAL_B, 984)
            qs.memo_state = 18
            qs.set_cond(12, true)
            qs.show_question_mark(234)
            return "31002-33.html"
          end
          return "31002-34.html"
        end
      when 41
        if qs.memo_state?(10)
          if qs.get_quest_items_count(CRYSTAL_B) >= 984
            qs.take_items(CRYSTAL_B, 984)
            qs.memo_state = 41
            qs.set_cond(12, true)
            qs.show_question_mark(234)
            return "31002-33a.html"
          end
          return "31002-34.html"
        end
      when 42
        if qs.memo_state?(10)
          if qs.get_quest_items_count(CRYSTAL_B) >= 984
            qs.take_items(CRYSTAL_B, 984)
            qs.memo_state = 42
            qs.set_cond(12, true)
            qs.show_question_mark(234)
            return "31002-33b.html"
          end
          return "31002-34.html"
        end
      when 43
        if qs.memo_state?(10)
          if qs.get_quest_items_count(CRYSTAL_B) >= 984
            qs.take_items(CRYSTAL_B, 984)
            qs.memo_state = 43
            qs.set_cond(12, true)
            qs.show_question_mark(234)
            return "31002-33c.html"
          end
          return "31002-34.html"
        end
      when 44
        if qs.memo_state?(10)
          if qs.get_quest_items_count(CRYSTAL_B) >= 984
            qs.take_items(CRYSTAL_B, 984)
            qs.memo_state = 44
            qs.set_cond(12, true)
            qs.show_question_mark(234)
            return "31002-33d.html"
          end
          return "31002-34.html"
        end
      when 21
        if calculate_reward(qs, pc, TALLUM_BLADE)
          return "31002-44.html"
        end
      when 22
        if calculate_reward(qs, pc, CARNIUM_BOW)
          return "31002-44.html"
        end
      when 23
        if calculate_reward(qs, pc, HALBARD)
          return "31002-44.html"
        end
      when 24
        if calculate_reward(qs, pc, ELEMENTAL_SWORD)
          return "31002-44.html"
        end
      when 25
        if calculate_reward(qs, pc, DASPARIONS_STAFF)
          return "31002-44.html"
        end
      when 26
        if calculate_reward(qs, pc, BLOODY_ORCHID)
          return "31002-44.html"
        end
      when 27
        if calculate_reward(qs, pc, BLOOD_TORNADO)
          return "31002-44.html"
        end
      when 28
        if calculate_reward(qs, pc, METEOR_SHOWER)
          return "31002-44.html"
        end
      when 29
        if calculate_reward(qs, pc, KSHANBERK_KSHANBERK)
          return "31002-44.html"
        end
      when 30
        if calculate_reward(qs, pc, INFERNO_MASTER)
          return "31002-44.html"
        end
      when 31
        if calculate_reward(qs, pc, EYE_OF_SOUL)
          return "31002-44.html"
        end
      when 32
        if calculate_reward(qs, pc, HAMMER_OF_DESTROYER)
          return "31002-44.html"
        end
      else
        # automatically added
      end

    else
      # automatically added
    end


    html
  end

  private def calculate_reward(qs, pc, reward) : Bool
    case qs.memo_state
    when 11
      get_reward(qs, pc, SWORD_OF_DAMASCUS, SWORD_OF_DAMASCUS_FOCUS, SWORD_OF_DAMASCUS_CRT_DAMAGE, SWORD_OF_DAMASCUS_HASTE, reward)
    when 12
      get_reward(qs, pc, HAZARD_BOW, HAZARD_BOW_GUIDENCE, HAZARD_BOW_QUICKRECOVERY, HAZARD_BOW_CHEAPSHOT, reward)
    when 13
      get_reward(qs, pc, LANCIA, LANCIA_ANGER, LANCIA_CRT_STUN, LANCIA_LONGBLOW, reward)
    when 14
      get_reward(qs, pc, ART_OF_BATTLE_AXE, ART_OF_BATTLE_AXE_HEALTH, ART_OF_BATTLE_AXE_RSK_FOCUS, ART_OF_BATTLE_AXE_HASTE, reward)
    when 15
      get_reward(qs, pc, STAFF_OF_EVIL_SPRIT, STAFF_OF_EVIL_SPRIT_MAGICFOCUS, STAFF_OF_EVIL_SPRIT_MAGICBLESSTHEBODY, STAFF_OF_EVIL_SPRIT_MAGICPOISON, reward)
    when 16
      get_reward(qs, pc, DEMONS_SWORD, DEMONS_SWORD_CRT_BLEED, DEMONS_SWORD_CRT_POISON, DEMONS_SWORD_MIGHTMOTAL, reward)
    when 17
      get_reward(qs, pc, BELLION_CESTUS, BELLION_CESTUS_CRT_DRAIN, BELLION_CESTUS_CRT_POISON, BELLION_CESTUS_RSK_HASTE, reward)
    when 18
      get_reward(qs, pc, DEADMANS_GLORY, DEADMANS_GLORY_ANGER, DEADMANS_GLORY_HEALTH, DEADMANS_GLORY_HASTE, reward)
    when 19
      get_reward(qs, pc, SAMURAI_LONGSWORD_SAMURAI_LONGSWORD, 0, 0, 0, reward)
    when 41
      get_reward(qs, pc, GUARDIANS_SWORD, GUARDIANS_SWORD_CRT_DRAIN, GUARDIANS_SWORD_HEALTH, GUARDIANS_SWORD_CRT_BLEED, reward)
    when 42
      get_reward(qs, pc, TEARS_OF_WIZARD, TEARS_OF_WIZARD_ACUMEN, TEARS_OF_WIZARD_MAGICPOWER, TEARS_OF_WIZARD_UPDOWN, reward)
    when 43
      get_reward(qs, pc, STAR_BUSTER, STAR_BUSTER_HEALTH, STAR_BUSTER_HASTE, STAR_BUSTER_RSK_FOCUS, reward)
    when 44
      get_reward(qs, pc, BONE_OF_KAIM_VANUL, BONE_OF_KAIM_VANUL_MANAUP, BONE_OF_KAIM_VANUL_MAGICSILENCE, BONE_OF_KAIM_VANUL_UPDOWN, reward)
    else
      false
    end
  end

  private def get_reward(qs, pc, item1, item2, item3, item4, reward)
    if has_at_least_one_quest_item?(pc, item1, item2, item3, item4)
      qs.give_items(reward, 1)
      qs.give_items(Q_STAR_OF_DESTINY, 1)
      if qs.has_quest_items?(item1)
        qs.take_items(item1, 1)
      elsif qs.has_quest_items?(item2)
        qs.take_items(item2, 1)
      elsif qs.has_quest_items?(item3)
        qs.take_items(item3, 1)
      elsif qs.has_quest_items?(item4)
        qs.take_items(item4, 1)
      end
      qs.exit_quest(false, true)
      pc.broadcast_social_action(3)
      return true
    end

    false
  end

  def on_kill(npc, killer, is_summon)
    case npc.id
    when DOMB_DEATH_CABRIO
      add_spawn(COFFER_OF_THE_DEAD, npc.location)
      return super
    when KERNON
      add_spawn(CHEST_OF_KERNON, npc.location)
      return super
    when GOLKONDA_LONGHORN
      add_spawn(CHEST_OF_GOLKONDA, npc.location)
      return super
    when HALLATE_THE_DEATH_LORD
      add_spawn(CHEST_OF_HALLATE, npc.location)
      return super
    else
      # automatically added
    end


    qs = get_random_party_member_state(killer, -1, 2, npc)
    if qs
      case npc.id
      when PLATINUM_TRIBE_GRUNT, PLATINUM_TRIBE_ARCHER, PLATINUM_TRIBE_WARRIOR,
           PLATINUM_TRIBE_SHAMAN, PLATINUM_TRIBE_LORD, GUARDIAN_ANGEL,
           SEAL_ANGEL, SEAL_ANGEL_R
        give_item_randomly(qs.player, npc, Q_BLOODY_FABRIC_Q0234, 1, 0, 1, false)
        qs.take_items(Q_WHITE_FABRIC_Q0234, 1)
        if qs.get_quest_items_count(Q_BLOODY_FABRIC_Q0234) >= 29
          qs.set_cond(9, true)
          qs.show_question_mark(234)
        else
          qs.play_sound(Sound::ITEMSOUND_QUEST_ITEMGET)
        end
      else
        # automatically added
      end

    end

    super
  end

  def on_attack(npc, attacker, damage, is_summon)
    qs = get_quest_state(attacker, false)
    if qs && npc.id == BAIUM
      weapon = attacker.active_weapon_item
      if weapon && weapon.id == Q_PIPETTE_KNIFE
        qs.take_items(Q_PIPETTE_KNIFE, 1)
        qs.give_items(Q_RED_PIPETTE_KNIFE, 1)
        qs.play_sound(Sound::ITEMSOUND_QUEST_ITEMGET)
        npc.broadcast_packet(NpcSay.new(npc.l2id, Say2::ALL, npc.id, NpcString::WHO_DARES_TO_TRY_AND_STEAL_MY_NOBLE_BLOOD))
      end
    end

    super
  end

  def check_party_member(qs, npc) : Bool
    qs.has_quest_items?(Q_WHITE_FABRIC_Q0234) && qs.memo_state?(8)
  end
end