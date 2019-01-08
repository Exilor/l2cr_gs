class Quests::Q00229_TestOfWitchcraft < Quest
  # NPCs
  private GROCER_LARA = 30063
  private TRADER_ALEXANDRIA = 30098
  private MAGISTER_IKER = 30110
  private PRIEST_VADIN = 30188
  private TRADER_NESTLE = 30314
  private SIR_KLAUS_VASPER = 30417
  private LEOPOLD = 30435
  private MAGISTER_KAIRA = 30476
  private SHADOW_ORIM = 30630
  private WARDEN_RODERIK = 30631
  private WARDEN_ENDRIGO = 30632
  private FISHER_EVERT = 30633
  # Items
  private SWORD_OF_BINDING = 3029
  private ORIMS_DIAGRAM = 3308
  private ALEXANDRIAS_BOOK = 3309
  private IKERS_LIST = 3310
  private DIRE_WYRM_FANG = 3311
  private LETO_LIZARDMAN_CHARM = 3312
  private ENCHANTED_STONE_GOLEM_HEARTSTONE = 3313
  private LARAS_MEMO = 3314
  private NESTLES_MEMO = 3315
  private LEOPOLDS_JOURNAL = 3316
  private AKLANTOTH_1ST_GEM = 3317
  private AKLANTOTH_2ND_GEM = 3318
  private AKLANTOTH_3RD_GEM = 3319
  private AKLANTOTH_4TH_GEM = 3320
  private AKLANTOTH_5TH_GEM = 3321
  private AKLANTOTH_6TH_GEM = 3322
  private BRIMSTONE_1ST = 3323
  private ORIMS_INSTRUCTIONS = 3324
  private ORIMS_1ST_LETTER = 3325
  private ORIMS_2ND_LETTER = 3326
  private SIR_VASPERS_LETTER = 3327
  private VADINS_CRUCIFIX = 3328
  private TAMLIN_ORC_AMULET = 3329
  private VADINS_SANCTIONS = 3330
  private IKERS_AMULET = 3331
  private SOULTRAP_CRYSTAL = 3332
  private PURGATORY_KEY = 3333
  private ZERUEL_BIND_CRYSTAL = 3334
  private BRIMSTONE_2ND = 3335
  # Reward
  private MARK_OF_WITCHCRAFT = 3307
  private DIMENSIONAL_DIAMOND = 7562
  # Monster
  private DIRE_WYRM = 20557
  private ENCHANTED_STONE_GOLEM = 20565
  private LETO_LIZARDMAN = 20577
  private LETO_LIZARDMAN_ARCHER = 20578
  private LETO_LIZARDMAN_SOLDIER = 20579
  private LETO_LIZARDMAN_WARRIOR = 20580
  private LETO_LIZARDMAN_SHAMAN = 20581
  private LETO_LIZARDMAN_OVERLORD = 20582
  private TAMLIN_ORC = 20601
  private TAMLIN_ORC_ARCHER = 20602
  # Quest Monster
  private NAMELESS_REVENANT = 27099
  private SKELETAL_MERCENARY = 27100
  private DREVANUL_PRINCE_ZERUEL = 27101
  # Misc
  private MIN_LEVEL = 39
  # Locations
  private DREVANUL_PRINCE_ZERUEL_SPAWN = Location.new(13395, 169807, -3708)

  def initialize
    super(229, self.class.simple_name, "Test Of Witchcraft")

    add_start_npc(SHADOW_ORIM)
    add_talk_id(SHADOW_ORIM, GROCER_LARA, TRADER_ALEXANDRIA, MAGISTER_IKER, PRIEST_VADIN, TRADER_NESTLE, SIR_KLAUS_VASPER, LEOPOLD, MAGISTER_KAIRA, WARDEN_RODERIK, WARDEN_ENDRIGO, FISHER_EVERT)
    add_kill_id(DIRE_WYRM, ENCHANTED_STONE_GOLEM, LETO_LIZARDMAN, LETO_LIZARDMAN_ARCHER, LETO_LIZARDMAN_SOLDIER, LETO_LIZARDMAN_WARRIOR, LETO_LIZARDMAN_SHAMAN, LETO_LIZARDMAN_OVERLORD, TAMLIN_ORC, TAMLIN_ORC_ARCHER, NAMELESS_REVENANT, SKELETAL_MERCENARY, DREVANUL_PRINCE_ZERUEL)
    add_attack_id(NAMELESS_REVENANT, SKELETAL_MERCENARY, DREVANUL_PRINCE_ZERUEL)
    register_quest_items(SWORD_OF_BINDING, ORIMS_DIAGRAM, ALEXANDRIAS_BOOK, IKERS_LIST, DIRE_WYRM_FANG, LETO_LIZARDMAN_CHARM, ENCHANTED_STONE_GOLEM_HEARTSTONE, LARAS_MEMO, NESTLES_MEMO, LEOPOLDS_JOURNAL, AKLANTOTH_1ST_GEM, AKLANTOTH_2ND_GEM, AKLANTOTH_3RD_GEM, AKLANTOTH_4TH_GEM, AKLANTOTH_5TH_GEM, AKLANTOTH_6TH_GEM, BRIMSTONE_1ST, ORIMS_INSTRUCTIONS, ORIMS_1ST_LETTER, ORIMS_2ND_LETTER, SIR_VASPERS_LETTER, VADINS_CRUCIFIX, TAMLIN_ORC_AMULET, VADINS_SANCTIONS, IKERS_AMULET, SOULTRAP_CRYSTAL, PURGATORY_KEY, ZERUEL_BIND_CRYSTAL, BRIMSTONE_2ND)
  end

  def on_adv_event(event, npc, player)
    return unless player
    return unless qs = get_quest_state(player, false)

    case event
    when "ACCEPT"
      if qs.created?
        qs.start_quest
        play_sound(player, Sound::ITEMSOUND_QUEST_MIDDLE)
        give_items(player, ORIMS_DIAGRAM, 1)
        if player.variables.get_i32("2ND_CLASS_DIAMOND_REWARD", 0) == 0
          if player.class_id.wizard?
            give_items(player, DIMENSIONAL_DIAMOND, 122)
          else
            give_items(player, DIMENSIONAL_DIAMOND, 104)
          end
          player.variables["2ND_CLASS_DIAMOND_REWARD"] = 1
          htmltext = "30630-08a.htm"
        else
          htmltext = "30630-08.htm"
        end
      end
    when "30630-04.htm", "30630-06.htm", "30630-07.htm", "30630-12.htm",
         "30630-13.htm", "30630-20.htm", "30630-21.htm", "30098-02.htm",
         "30110-02.htm", "30417-02.htm"
      htmltext = event
    when "30630-14.htm"
      if has_quest_items?(player, ALEXANDRIAS_BOOK)
        npc = npc.not_nil!
        take_items(player, ALEXANDRIAS_BOOK, 1)
        take_items(player, AKLANTOTH_1ST_GEM, 1)
        take_items(player, AKLANTOTH_2ND_GEM, 1)
        take_items(player, AKLANTOTH_3RD_GEM, 1)
        take_items(player, AKLANTOTH_4TH_GEM, 1)
        take_items(player, AKLANTOTH_5TH_GEM, 1)
        take_items(player, AKLANTOTH_6TH_GEM, 1)
        give_items(player, BRIMSTONE_1ST, 1)
        qs.set_cond(4, true)
        add_spawn(DREVANUL_PRINCE_ZERUEL, npc, true, 0, false)
        htmltext = event
      end
    when "30630-16.htm"
      if has_quest_items?(player, BRIMSTONE_1ST)
        take_items(player, BRIMSTONE_1ST, 1)
        give_items(player, ORIMS_INSTRUCTIONS, 1)
        give_items(player, ORIMS_1ST_LETTER, 1)
        give_items(player, ORIMS_2ND_LETTER, 1)
        qs.set_cond(6, true)
        htmltext = event
      end
    when "30630-22.htm"
      if has_quest_items?(player, ZERUEL_BIND_CRYSTAL)
        give_adena(player, 372154, true)
        give_items(player, MARK_OF_WITCHCRAFT, 1)
        add_exp_and_sp(player, 2058244, 141240)
        qs.exit_quest(false, true)
        player.send_packet(SocialAction.new(player.l2id, 3))
        htmltext = event
      end
    when "30063-02.htm"
      give_items(player, LARAS_MEMO, 1)
      htmltext = event
    when "30098-03.htm"
      if has_quest_items?(player, ORIMS_DIAGRAM)
        take_items(player, ORIMS_DIAGRAM, 1)
        give_items(player, ALEXANDRIAS_BOOK, 1)
        qs.set_cond(2, true)
        htmltext = event
      end
    when "30110-03.htm"
      give_items(player, IKERS_LIST, 1)
      htmltext = event
    when "30110-08.htm"
      take_items(player, ORIMS_2ND_LETTER, 1)
      give_items(player, IKERS_AMULET, 1)
      give_items(player, SOULTRAP_CRYSTAL, 1)
      if has_quest_items?(player, SWORD_OF_BINDING)
        qs.set_cond(7, true)
      end
      htmltext = event
    when "30314-02.htm"
      give_items(player, NESTLES_MEMO, 1)
      htmltext = event
    when "30417-03.htm"
      if has_quest_items?(player, ORIMS_1ST_LETTER)
        take_items(player, ORIMS_1ST_LETTER, 1)
        give_items(player, SIR_VASPERS_LETTER, 1)
        htmltext = event
      end
    when "30435-02.htm"
      if has_quest_items?(player, NESTLES_MEMO)
        take_items(player, NESTLES_MEMO, 1)
        give_items(player, LEOPOLDS_JOURNAL, 1)
        htmltext = event
      end
    when "30476-02.htm"
      give_items(player, AKLANTOTH_2ND_GEM, 1)
      if has_quest_items?(player, AKLANTOTH_1ST_GEM, AKLANTOTH_3RD_GEM, AKLANTOTH_4TH_GEM, AKLANTOTH_5TH_GEM, AKLANTOTH_6TH_GEM)
        qs.set_cond(3, true)
      end
      htmltext = event
    when "30633-02.htm"
      npc = npc.not_nil!
      give_items(player, BRIMSTONE_2ND, 1)
      qs.set_cond(9, true)
      if npc.summoned_npc_count < 1
        add_spawn(npc, DREVANUL_PRINCE_ZERUEL, DREVANUL_PRINCE_ZERUEL_SPAWN, false, 0)
      end
      htmltext = event
    end

    htmltext
  end

  def on_attack(npc, attacker, damage, is_summon)
    qs = get_quest_state(attacker, false)
    if qs && qs.started?
      case npc.id
      when NAMELESS_REVENANT
        if npc.script_value?(0) && has_quest_items?(attacker, ALEXANDRIAS_BOOK, LARAS_MEMO) && !has_quest_items?(attacker, AKLANTOTH_3RD_GEM)
          npc.script_value=(1)
          npc.broadcast_packet(NpcSay.new(npc, Say2::NPC_ALL, NpcString::I_ABSOLUTELY_CANNOT_GIVE_IT_TO_YOU_IT_IS_MY_PRECIOUS_JEWEL))
        end
      when SKELETAL_MERCENARY
        if npc.script_value?(0) && has_quest_items?(attacker, LEOPOLDS_JOURNAL) && !has_quest_items?(attacker, AKLANTOTH_4TH_GEM, AKLANTOTH_5TH_GEM, AKLANTOTH_6TH_GEM)
          npc.script_value=(1)
          npc.broadcast_packet(NpcSay.new(npc, Say2::NPC_ALL, NpcString::I_ABSOLUTELY_CANNOT_GIVE_IT_TO_YOU_IT_IS_MY_PRECIOUS_JEWEL))
        end
      when DREVANUL_PRINCE_ZERUEL
        if has_quest_items?(attacker, BRIMSTONE_1ST)
          npc.broadcast_packet(NpcSay.new(npc, Say2::NPC_ALL, NpcString::ILL_TAKE_YOUR_LIVES_LATER))
          npc.delete_me
          qs.set_cond(5, true)
        elsif has_quest_items?(attacker, ORIMS_INSTRUCTIONS, BRIMSTONE_2ND, SWORD_OF_BINDING, SOULTRAP_CRYSTAL)
          if npc.script_value?(0) && check_weapon(attacker)
            npc.script_value=(1)
            npc.broadcast_packet(NpcSay.new(npc, Say2::NPC_ALL, NpcString::THAT_SWORD_IS_REALLY))
          end
        end
      end
    end

    super
  end

  def on_kill(npc, killer, is_summon)
    qs = get_quest_state(killer, false)
    if qs && qs.started? && Util.in_range?(1500, npc, killer, true)
      case npc.id
      when DIRE_WYRM
        if has_quest_items?(killer, ALEXANDRIAS_BOOK, IKERS_LIST)
          if get_quest_items_count(killer, DIRE_WYRM_FANG) < 20
            give_items(killer, DIRE_WYRM_FANG, 1)
            if get_quest_items_count(killer, DIRE_WYRM_FANG) >= 20
              play_sound(killer, Sound::ITEMSOUND_QUEST_MIDDLE)
            else
              play_sound(killer, Sound::ITEMSOUND_QUEST_ITEMGET)
            end
          end
        end
      when ENCHANTED_STONE_GOLEM
        if has_quest_items?(killer, ALEXANDRIAS_BOOK, IKERS_LIST)
          if get_quest_items_count(killer, ENCHANTED_STONE_GOLEM_HEARTSTONE) < 20
            give_items(killer, ENCHANTED_STONE_GOLEM_HEARTSTONE, 1)
            if get_quest_items_count(killer, ENCHANTED_STONE_GOLEM_HEARTSTONE) >= 20
              play_sound(killer, Sound::ITEMSOUND_QUEST_MIDDLE)
            else
              play_sound(killer, Sound::ITEMSOUND_QUEST_ITEMGET)
            end
          end
        end
      when LETO_LIZARDMAN,
           LETO_LIZARDMAN_ARCHER,
           LETO_LIZARDMAN_SOLDIER,
           LETO_LIZARDMAN_WARRIOR,
           LETO_LIZARDMAN_SHAMAN,
           LETO_LIZARDMAN_OVERLORD
        if has_quest_items?(killer, ALEXANDRIAS_BOOK, IKERS_LIST)
          if get_quest_items_count(killer, LETO_LIZARDMAN_CHARM) < 20
            give_items(killer, LETO_LIZARDMAN_CHARM, 1)
            if get_quest_items_count(killer, LETO_LIZARDMAN_CHARM) >= 20
              play_sound(killer, Sound::ITEMSOUND_QUEST_MIDDLE)
            else
              play_sound(killer, Sound::ITEMSOUND_QUEST_ITEMGET)
            end
          end
        end
      when TAMLIN_ORC, TAMLIN_ORC_ARCHER
        if has_quest_items?(killer, VADINS_CRUCIFIX)
          if (rand(100) < 50) && (get_quest_items_count(killer, TAMLIN_ORC_AMULET) < 20)
            give_items(killer, TAMLIN_ORC_AMULET, 1)
            if get_quest_items_count(killer, TAMLIN_ORC_AMULET) >= 20
              play_sound(killer, Sound::ITEMSOUND_QUEST_MIDDLE)
            else
              play_sound(killer, Sound::ITEMSOUND_QUEST_ITEMGET)
            end
          end
        end
      when NAMELESS_REVENANT
        if has_quest_items?(killer, ALEXANDRIAS_BOOK, LARAS_MEMO) && !has_quest_items?(killer, AKLANTOTH_3RD_GEM)
          take_items(killer, LARAS_MEMO, 1)
          give_items(killer, AKLANTOTH_3RD_GEM, 1)
          play_sound(killer, Sound::ITEMSOUND_QUEST_ITEMGET)
          if has_quest_items?(killer, AKLANTOTH_1ST_GEM, AKLANTOTH_2ND_GEM, AKLANTOTH_4TH_GEM, AKLANTOTH_5TH_GEM, AKLANTOTH_6TH_GEM)
            qs.set_cond(3)
          end
        end
      when SKELETAL_MERCENARY
        if has_quest_items?(killer, LEOPOLDS_JOURNAL) && !has_quest_items?(killer, AKLANTOTH_4TH_GEM, AKLANTOTH_5TH_GEM, AKLANTOTH_6TH_GEM)
          if !has_quest_items?(killer, AKLANTOTH_4TH_GEM)
            give_items(killer, AKLANTOTH_4TH_GEM, 1)
            play_sound(killer, Sound::ITEMSOUND_QUEST_ITEMGET)
          elsif !has_quest_items?(killer, AKLANTOTH_5TH_GEM)
            give_items(killer, AKLANTOTH_5TH_GEM, 1)
            play_sound(killer, Sound::ITEMSOUND_QUEST_ITEMGET)
          elsif !has_quest_items?(killer, AKLANTOTH_6TH_GEM)
            take_items(killer, LEOPOLDS_JOURNAL, 1)
            give_items(killer, AKLANTOTH_6TH_GEM, 1)
            play_sound(killer, Sound::ITEMSOUND_QUEST_ITEMGET)
            if has_quest_items?(killer, AKLANTOTH_1ST_GEM, AKLANTOTH_2ND_GEM, AKLANTOTH_3RD_GEM)
              qs.set_cond(3)
            end
          end
        end
      when DREVANUL_PRINCE_ZERUEL
        if has_quest_items?(killer, ORIMS_INSTRUCTIONS, BRIMSTONE_2ND, SWORD_OF_BINDING, SOULTRAP_CRYSTAL)
          if npc.killing_blow_weapon == SWORD_OF_BINDING
            npc.broadcast_packet(NpcSay.new(npc, Say2::NPC_ALL, NpcString::NO_I_HAVENT_COMPLETELY_FINISHED_THE_COMMAND_FOR_DESTRUCTION_AND_SLAUGHTER_YET))
            take_items(killer, SOULTRAP_CRYSTAL, 1)
            give_items(killer, PURGATORY_KEY, 1)
            give_items(killer, ZERUEL_BIND_CRYSTAL, 1)
            take_items(killer, BRIMSTONE_2ND, 1)
            play_sound(killer, Sound::ITEMSOUND_QUEST_ITEMGET)
            qs.set_cond(10)
          end
        end
      end
    end

    super
  end

  def on_talk(npc, player)
    qs = get_quest_state!(player)
    htmltext = get_no_quest_msg(player)
    if qs.created?
      if npc.id == SHADOW_ORIM
        if player.class_id.wizard? || player.class_id.knight? || player.class_id.palus_knight?
          if player.level >= MIN_LEVEL
            if player.class_id.wizard?
              htmltext = "30630-03.htm"
            else
              htmltext = "30630-05.htm"
            end
          else
            htmltext = "30630-02.htm"
          end
        else
          htmltext = "30630-01.htm"
        end
      end
    elsif qs.started?
      case npc.id
      when SHADOW_ORIM
        if has_quest_items?(player, ORIMS_DIAGRAM)
          htmltext = "30630-09.htm"
        elsif has_quest_items?(player, ALEXANDRIAS_BOOK)
          if has_quest_items?(player, AKLANTOTH_1ST_GEM, AKLANTOTH_2ND_GEM, AKLANTOTH_3RD_GEM, AKLANTOTH_4TH_GEM, AKLANTOTH_5TH_GEM, AKLANTOTH_6TH_GEM)
            htmltext = "30630-11.htm"
          else
            htmltext = "30630-10.htm"
          end
        elsif has_quest_items?(player, BRIMSTONE_1ST)
          htmltext = "30630-15.htm"
        elsif has_quest_items?(player, ORIMS_INSTRUCTIONS) && !has_at_least_one_quest_item?(player, SWORD_OF_BINDING, SOULTRAP_CRYSTAL)
          htmltext = "30630-17.htm"
        end
        if has_quest_items?(player, SWORD_OF_BINDING, SOULTRAP_CRYSTAL)
          qs.set_cond(8, true)
          htmltext = "30630-18.htm"
        elsif has_quest_items?(player, SWORD_OF_BINDING, ZERUEL_BIND_CRYSTAL)
          htmltext = "30630-19.htm"
        end
      when GROCER_LARA
        if has_quest_items?(player, ALEXANDRIAS_BOOK)
          if !has_at_least_one_quest_item?(player, LARAS_MEMO, AKLANTOTH_3RD_GEM)
            htmltext = "30063-01.htm"
          elsif !has_quest_items?(player, AKLANTOTH_3RD_GEM) && has_quest_items?(player, LARAS_MEMO)
            htmltext = "30063-03.htm"
          elsif !has_quest_items?(player, LARAS_MEMO) && has_quest_items?(player, AKLANTOTH_3RD_GEM)
            htmltext = "30063-04.htm"
          end
        elsif has_at_least_one_quest_item?(player, BRIMSTONE_1ST, ORIMS_INSTRUCTIONS)
          htmltext = "30063-05.htm"
        end
      when TRADER_ALEXANDRIA
        if has_quest_items?(player, ORIMS_DIAGRAM)
          htmltext = "30098-01.htm"
        elsif has_quest_items?(player, ALEXANDRIAS_BOOK)
          htmltext = "30098-04.htm"
        elsif has_quest_items?(player, ORIMS_INSTRUCTIONS, BRIMSTONE_1ST)
          htmltext = "30098-05.htm"
        end
      when MAGISTER_IKER
        if has_quest_items?(player, ALEXANDRIAS_BOOK)
          if !has_at_least_one_quest_item?(player, IKERS_LIST, AKLANTOTH_1ST_GEM)
            htmltext = "30110-01.htm"
          elsif has_quest_items?(player, IKERS_LIST)
            if (get_quest_items_count(player, DIRE_WYRM_FANG) >= 20) && (get_quest_items_count(player, LETO_LIZARDMAN_CHARM) >= 20) && (get_quest_items_count(player, ENCHANTED_STONE_GOLEM_HEARTSTONE) >= 20)
              take_items(player, IKERS_LIST, 1)
              take_items(player, DIRE_WYRM_FANG, -1)
              take_items(player, LETO_LIZARDMAN_CHARM, -1)
              take_items(player, ENCHANTED_STONE_GOLEM_HEARTSTONE, -1)
              give_items(player, AKLANTOTH_1ST_GEM, 1)
              if has_quest_items?(player, AKLANTOTH_2ND_GEM, AKLANTOTH_3RD_GEM, AKLANTOTH_4TH_GEM, AKLANTOTH_5TH_GEM, AKLANTOTH_6TH_GEM)
                qs.set_cond(3, true)
              end
              htmltext = "30110-05.htm"
            else
              htmltext = "30110-04.htm"
            end
          elsif !has_quest_items?(player, IKERS_LIST) && has_quest_items?(player, AKLANTOTH_1ST_GEM)
            htmltext = "30110-06.htm"
          end
        elsif has_quest_items?(player, ORIMS_INSTRUCTIONS)
          if !has_at_least_one_quest_item?(player, SOULTRAP_CRYSTAL, ZERUEL_BIND_CRYSTAL)
            htmltext = "30110-07.htm"
          elsif !has_quest_items?(player, ZERUEL_BIND_CRYSTAL) && has_quest_items?(player, SOULTRAP_CRYSTAL)
            htmltext = "30110-09.htm"
          elsif !has_quest_items?(player, SOULTRAP_CRYSTAL) && has_quest_items?(player, ZERUEL_BIND_CRYSTAL)
            htmltext = "30110-10.htm"
          end
        end
      when PRIEST_VADIN
        if has_quest_items?(player, ORIMS_INSTRUCTIONS, SIR_VASPERS_LETTER)
          take_items(player, SIR_VASPERS_LETTER, 1)
          give_items(player, VADINS_CRUCIFIX, 1)
          htmltext = "30188-01.htm"
        elsif has_quest_items?(player, VADINS_CRUCIFIX)
          if get_quest_items_count(player, TAMLIN_ORC_AMULET) < 20
            htmltext = "30188-02.htm"
          else
            take_items(player, VADINS_CRUCIFIX, 1)
            take_items(player, TAMLIN_ORC_AMULET, -1)
            give_items(player, VADINS_SANCTIONS, 1)
            htmltext = "30188-03.htm"
          end
        elsif has_quest_items?(player, ORIMS_INSTRUCTIONS)
          if has_quest_items?(player, VADINS_SANCTIONS)
            htmltext = "30188-04.htm"
          elsif has_quest_items?(player, SWORD_OF_BINDING)
            htmltext = "30188-05.htm"
          end
        end
      when TRADER_NESTLE
        if has_quest_items?(player, ALEXANDRIAS_BOOK)
          if !has_at_least_one_quest_item?(player, LEOPOLDS_JOURNAL, NESTLES_MEMO, AKLANTOTH_4TH_GEM, AKLANTOTH_5TH_GEM, AKLANTOTH_6TH_GEM)
            htmltext = "30314-01.htm"
          elsif has_quest_items?(player, NESTLES_MEMO) && !has_quest_items?(player, LEOPOLDS_JOURNAL)
            htmltext = "30314-03.htm"
          elsif !has_quest_items?(player, NESTLES_MEMO) && has_at_least_one_quest_item?(player, LEOPOLDS_JOURNAL, AKLANTOTH_4TH_GEM, AKLANTOTH_5TH_GEM, AKLANTOTH_6TH_GEM)
            htmltext = "30314-04.htm"
          end
        end
      when SIR_KLAUS_VASPER
        if has_quest_items?(player, ORIMS_INSTRUCTIONS)
          if has_quest_items?(player, ORIMS_1ST_LETTER)
            htmltext = "30417-01.htm"
          elsif has_quest_items?(player, SIR_VASPERS_LETTER)
            htmltext = "30417-04.htm"
          elsif has_quest_items?(player, VADINS_SANCTIONS)
            give_items(player, SWORD_OF_BINDING, 1)
            take_items(player, VADINS_SANCTIONS, 1)
            if has_quest_items?(player, SOULTRAP_CRYSTAL)
              qs.set_cond(7, true)
            end
            htmltext = "30417-05.htm"
          elsif has_quest_items?(player, SWORD_OF_BINDING)
            htmltext = "30417-06.htm"
          end
        end
      when LEOPOLD
        if has_quest_items?(player, ALEXANDRIAS_BOOK)
          if has_quest_items?(player, NESTLES_MEMO) && !has_quest_items?(player, LEOPOLDS_JOURNAL)
            htmltext = "30435-01.htm"
          elsif has_quest_items?(player, LEOPOLDS_JOURNAL) && !has_quest_items?(player, NESTLES_MEMO)
            htmltext = "30435-03.htm"
          elsif has_quest_items?(player, AKLANTOTH_4TH_GEM, AKLANTOTH_5TH_GEM, AKLANTOTH_6TH_GEM)
            htmltext = "30435-04.htm"
          end
        elsif has_at_least_one_quest_item?(player, BRIMSTONE_1ST, ORIMS_INSTRUCTIONS)
          htmltext = "30435-05.htm"
        end
      when MAGISTER_KAIRA
        if has_quest_items?(player, ALEXANDRIAS_BOOK)
          if !has_quest_items?(player, AKLANTOTH_2ND_GEM)
            htmltext = "30476-01.htm"
          else
            htmltext = "30476-03.htm"
          end
        elsif has_at_least_one_quest_item?(player, BRIMSTONE_1ST, ORIMS_INSTRUCTIONS)
          htmltext = "30476-04.htm"
        end
      when WARDEN_RODERIK
        if has_quest_items?(player, ALEXANDRIAS_BOOK) && has_at_least_one_quest_item?(player, LARAS_MEMO, AKLANTOTH_3RD_GEM)
          htmltext = "30631-01.htm"
        end
      when WARDEN_ENDRIGO
        if has_quest_items?(player, ALEXANDRIAS_BOOK) && has_at_least_one_quest_item?(player, LARAS_MEMO, AKLANTOTH_3RD_GEM)
          htmltext = "30632-01.htm"
        end
      when FISHER_EVERT
        if has_quest_items?(player, ORIMS_INSTRUCTIONS)
          if has_quest_items?(player, SOULTRAP_CRYSTAL, SWORD_OF_BINDING) && !has_quest_items?(player, BRIMSTONE_2ND)
            htmltext = "30633-01.htm"
          elsif has_quest_items?(player, SOULTRAP_CRYSTAL, BRIMSTONE_2ND) && !has_quest_items?(player, ZERUEL_BIND_CRYSTAL)
            if npc.summoned_npc_count < 1
              add_spawn(npc, DREVANUL_PRINCE_ZERUEL, DREVANUL_PRINCE_ZERUEL_SPAWN, false, 0)
            end
            htmltext = "30633-02.htm"
          elsif has_quest_items?(player, ZERUEL_BIND_CRYSTAL) && !has_at_least_one_quest_item?(player, SOULTRAP_CRYSTAL, BRIMSTONE_2ND)
            htmltext = "30633-03.htm"
          end
        end
      end
    elsif qs.completed?
      if npc.id == SHADOW_ORIM
        htmltext = get_already_completed_msg(player)
      end
    end

    htmltext
  end

  private def check_weapon(player)
    weapon = player.active_weapon_instance?
    !!weapon && weapon.id == SWORD_OF_BINDING
  end
end
