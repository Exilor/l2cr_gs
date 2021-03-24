class Scripts::Q00230_TestOfTheSummoner < Quest
  private record MonsterData, crystal_of_in_progress : Int32,
    crystal_of_victory : Int32, npc_string : NpcString

  # NPCs
  private GROCER_LARA = 30063
  private HIGH_SUMMONER_GALATEA = 30634
  private SUMMONER_ALMORS = 30635
  private SUMMONER_CAMONIELL = 30636
  private SUMMONER_BELTHUS = 30637
  private SUMMONER_BASILLA = 30638
  private SUMMONER_CELESTIEL = 30639
  private SUMMONER_BRYNTHEA = 30640
  # Items
  private LETO_LIZARDMAN_AMULET = 3337
  private SAC_OF_RED_SPORES = 3338
  private KARUL_BUGBEAR_TOTEM = 3339
  private SHARDS_OF_MANASHEN = 3340
  private BREKA_ORC_TOTEM = 3341
  private CRIMSON_BLOODSTONE = 3342
  private TALONS_OF_TYRANT = 3343
  private WINGS_OF_DRONEANT = 3344
  private TUSK_OF_WINDSUS = 3345
  private FANGS_OF_WYRM = 3346
  private LARAS_1ST_LIST = 3347
  private LARAS_2ND_LIST = 3348
  private LARAS_3RD_LIST = 3349
  private LARAS_4TH_LIST = 3350
  private LARAS_5TH_LIST = 3351
  private GALATEAS_LETTER = 3352
  private BEGINNERS_ARCANA = 3353
  private ALMORS_ARCANA = 3354
  private CAMONIELL_ARCANA = 3355
  private BELTHUS_ARCANA = 3356
  private BASILLIA_ARCANA = 3357
  private CELESTIEL_ARCANA = 3358
  private BRYNTHEA_ARCANA = 3359
  private CRYSTAL_OF_STARTING_1ST = 3360
  private CRYSTAL_OF_INPROGRESS_1ST = 3361
  private CRYSTAL_OF_FOUL_1ST = 3362
  private CRYSTAL_OF_DEFEAT_1ST = 3363
  private CRYSTAL_OF_VICTORY_1ST = 3364
  private CRYSTAL_OF_STARTING_2ND = 3365
  private CRYSTAL_OF_INPROGRESS_2ND = 3366
  private CRYSTAL_OF_FOUL_2ND = 3367
  private CRYSTAL_OF_DEFEAT_2ND = 3368
  private CRYSTAL_OF_VICTORY_2ND = 3369
  private CRYSTAL_OF_STARTING_3RD = 3370
  private CRYSTAL_OF_INPROGRESS_3RD = 3371
  private CRYSTAL_OF_FOUL_3RD = 3372
  private CRYSTAL_OF_DEFEAT_3RD = 3373
  private CRYSTAL_OF_VICTORY_3RD = 3374
  private CRYSTAL_OF_STARTING_4TH = 3375
  private CRYSTAL_OF_INPROGRESS_4TH = 3376
  private CRYSTAL_OF_FOUL_4TH = 3377
  private CRYSTAL_OF_DEFEAT_4TH = 3378
  private CRYSTAL_OF_VICTORY_4TH = 3379
  private CRYSTAL_OF_STARTING_5TH = 3380
  private CRYSTAL_OF_INPROGRESS_5TH = 3381
  private CRYSTAL_OF_FOUL_5TH = 3382
  private CRYSTAL_OF_DEFEAT_5TH = 3383
  private CRYSTAL_OF_VICTORY_5TH = 3384
  private CRYSTAL_OF_STARTING_6TH = 3385
  private CRYSTAL_OF_INPROGRESS_6TH = 3386
  private CRYSTAL_OF_FOUL_6TH = 3387
  private CRYSTAL_OF_DEFEAT_6TH = 3388
  private CRYSTAL_OF_VICTORY_6TH = 3389
  # Reward
  private MARK_OF_SUMMONER = 3336
  private DIMENSIONAL_DIAMOND = 7562
  # Monster
  private NOBLE_ANT = 20089
  private NOBLE_ANT_LEADER = 20090
  private WYRM = 20176
  private TYRANT = 20192
  private TYRANT_KINGPIN = 20193
  private BREKA_ORC = 20267
  private BREKA_ORC_ARCHER = 20268
  private BREKA_ORC_SHAMAN = 20269
  private BREKA_ORC_OVERLORD = 20270
  private BREKA_ORC_WARRIOR = 20271
  private FETTERED_SOUL = 20552
  private WINDSUS = 20553
  private GIANT_FUNGUS = 20555
  private MANASHEN_GARGOYLE = 20563
  private LETO_LIZARDMAN = 20577
  private LETO_LIZARDMAN_ARCHER = 20578
  private LETO_LIZARDMAN_SOLDIER = 20579
  private LETO_LIZARDMAN_WARRIOR = 20580
  private LETO_LIZARDMAN_SHAMAN = 20581
  private LETO_LIZARDMAN_OVERLORD = 20582
  private KARUL_BUGBEAR = 20600
  # Quest Monster
  private PAKO_THE_CAT = 27102
  private UNICORN_RACER = 27103
  private SHADOW_TUREN = 27104
  private MIMI_THE_CAT = 27105
  private UNICORN_PHANTASM = 27106
  private SILHOUETTE_TILFO = 27107

  private REDUCTION_IN_RECOVERY_TIME = SkillHolder.new(4126)
  private MONSTERS = {
    PAKO_THE_CAT => MonsterData.new(
      CRYSTAL_OF_INPROGRESS_1ST,
      CRYSTAL_OF_VICTORY_1ST,
      NpcString::IM_SORRY_LORD
    ),
    UNICORN_RACER => MonsterData.new(
      CRYSTAL_OF_INPROGRESS_3RD,
      CRYSTAL_OF_VICTORY_3RD,
      NpcString::I_LOSE
    ),
    SHADOW_TUREN => MonsterData.new(
      CRYSTAL_OF_INPROGRESS_5TH,
      CRYSTAL_OF_VICTORY_5TH,
      NpcString::UGH_I_LOST
    ),
    MIMI_THE_CAT => MonsterData.new(
      CRYSTAL_OF_INPROGRESS_2ND,
      CRYSTAL_OF_VICTORY_2ND,
      NpcString::LOST_SORRY_LORD
    ),
    UNICORN_PHANTASM => MonsterData.new(
      CRYSTAL_OF_INPROGRESS_4TH,
      CRYSTAL_OF_VICTORY_4TH,
      NpcString::I_LOSE
    ),
    SILHOUETTE_TILFO => MonsterData.new(
      CRYSTAL_OF_INPROGRESS_6TH,
      CRYSTAL_OF_VICTORY_6TH,
      NpcString::UGH_CAN_THIS_BE_HAPPENING
    )
  }

  private MIN_LEVEL = 39

  def initialize
    super(230, self.class.simple_name, "Test Of The Summoner")

    add_start_npc(HIGH_SUMMONER_GALATEA)
    add_talk_id(
      HIGH_SUMMONER_GALATEA, GROCER_LARA, SUMMONER_ALMORS, SUMMONER_CAMONIELL,
      SUMMONER_BELTHUS, SUMMONER_BASILLA, SUMMONER_CELESTIEL,
      SUMMONER_BRYNTHEA
    )
    add_kill_id(
      NOBLE_ANT, NOBLE_ANT_LEADER, WYRM, TYRANT, TYRANT_KINGPIN, BREKA_ORC,
      BREKA_ORC_ARCHER, BREKA_ORC_SHAMAN, BREKA_ORC_OVERLORD,
      BREKA_ORC_WARRIOR, FETTERED_SOUL, WINDSUS, GIANT_FUNGUS,
      MANASHEN_GARGOYLE, LETO_LIZARDMAN, LETO_LIZARDMAN_ARCHER,
      LETO_LIZARDMAN_SOLDIER, LETO_LIZARDMAN_WARRIOR, LETO_LIZARDMAN_SHAMAN,
      LETO_LIZARDMAN_OVERLORD, KARUL_BUGBEAR
    )
    add_kill_id(MONSTERS.keys)
    add_attack_id(
      PAKO_THE_CAT, UNICORN_RACER, SHADOW_TUREN, MIMI_THE_CAT,
      UNICORN_PHANTASM, SILHOUETTE_TILFO
    )
    register_quest_items(
      LETO_LIZARDMAN_AMULET, SAC_OF_RED_SPORES, KARUL_BUGBEAR_TOTEM,
      SHARDS_OF_MANASHEN, BREKA_ORC_TOTEM, CRIMSON_BLOODSTONE,
      TALONS_OF_TYRANT, WINGS_OF_DRONEANT, TUSK_OF_WINDSUS, FANGS_OF_WYRM,
      LARAS_1ST_LIST, LARAS_2ND_LIST, LARAS_3RD_LIST, LARAS_4TH_LIST,
      LARAS_5TH_LIST, GALATEAS_LETTER, BEGINNERS_ARCANA, ALMORS_ARCANA,
      CAMONIELL_ARCANA, BELTHUS_ARCANA, BASILLIA_ARCANA, CELESTIEL_ARCANA,
      BRYNTHEA_ARCANA, CRYSTAL_OF_STARTING_1ST, CRYSTAL_OF_INPROGRESS_1ST,
      CRYSTAL_OF_FOUL_1ST, CRYSTAL_OF_DEFEAT_1ST, CRYSTAL_OF_VICTORY_1ST,
      CRYSTAL_OF_STARTING_2ND, CRYSTAL_OF_INPROGRESS_2ND, CRYSTAL_OF_FOUL_2ND,
      CRYSTAL_OF_DEFEAT_2ND, CRYSTAL_OF_VICTORY_2ND, CRYSTAL_OF_STARTING_3RD,
      CRYSTAL_OF_INPROGRESS_3RD, CRYSTAL_OF_FOUL_3RD, CRYSTAL_OF_DEFEAT_3RD,
      CRYSTAL_OF_VICTORY_3RD, CRYSTAL_OF_STARTING_4TH,
      CRYSTAL_OF_INPROGRESS_4TH, CRYSTAL_OF_FOUL_4TH, CRYSTAL_OF_DEFEAT_4TH,
      CRYSTAL_OF_VICTORY_4TH, CRYSTAL_OF_STARTING_5TH,
      CRYSTAL_OF_INPROGRESS_5TH, CRYSTAL_OF_FOUL_5TH, CRYSTAL_OF_DEFEAT_5TH,
      CRYSTAL_OF_VICTORY_5TH, CRYSTAL_OF_STARTING_6TH,
      CRYSTAL_OF_INPROGRESS_6TH, CRYSTAL_OF_FOUL_6TH, CRYSTAL_OF_DEFEAT_6TH,
      CRYSTAL_OF_VICTORY_6TH
    )
  end

  def on_adv_event(event, npc, pc)
    case event
    when "DESPAWN"
      npc = npc.not_nil!
      npc.delete_me
    when "KILLED_ATTACKER"
      npc = npc.not_nil!
      summon = npc.variables.get_object("ATTACKER", L2Summon?)
      if summon && summon.dead?
        npc.delete_me
      else
        start_quest_timer("KILLED_ATTACKER", 5000, npc, nil)
      end
    end


    # For NPC-only timers, player is nil and no further checks or actions are required.
    return unless pc && (qs = get_quest_state(pc, false))

    case event
    when "ACCEPT"
      if qs.created?
        qs.start_quest
        play_sound(pc, Sound::ITEMSOUND_QUEST_MIDDLE)
        give_items(pc, GALATEAS_LETTER, 1)
        if pc.variables.get_i32("2ND_CLASS_DIAMOND_REWARD", 0) == 0
          give_items(pc, DIMENSIONAL_DIAMOND, 122)
          pc.variables["2ND_CLASS_DIAMOND_REWARD"] = 1
          html = "30634-08a.htm"
        else
          html = "30634-08.htm"
        end
      end
    when "30634-04.htm", "30634-05.htm", "30634-06.htm", "30634-07.htm", "30634-11.html", "30634-11a.html", "30634-11b.html", "30634-11c.html", "30634-11d.html"
      html = event
    when "30063-02.html"
      case Rnd.rand(5)
      when 0
        give_items(pc, LARAS_1ST_LIST, 1)
      when 1
        give_items(pc, LARAS_2ND_LIST, 1)
      when 2
        give_items(pc, LARAS_3RD_LIST, 1)
      when 3
        give_items(pc, LARAS_4TH_LIST, 1)
      when 4
        give_items(pc, LARAS_5TH_LIST, 1)
      end

      qs.set_cond(2, true)
      take_items(pc, GALATEAS_LETTER, 1)
      html = event
    when "30063-04.html"
      case Rnd.rand(5)
      when 0
        give_items(pc, LARAS_1ST_LIST, 1)
      when 1
        give_items(pc, LARAS_2ND_LIST, 1)
      when 2
        give_items(pc, LARAS_3RD_LIST, 1)
      when 3
        give_items(pc, LARAS_4TH_LIST, 1)
      when 4
        give_items(pc, LARAS_5TH_LIST, 1)
      end

      html = event
    when "30635-03.html"
      if has_quest_items?(pc, BEGINNERS_ARCANA)
        html = event
      else
        html = "30635-02.html"
      end
    when "30635-04.html"
      add_skill_cast_desire(npc.not_nil!, pc, REDUCTION_IN_RECOVERY_TIME, 1000000)
      take_items(pc, BEGINNERS_ARCANA, 1)
      give_items(pc, CRYSTAL_OF_STARTING_1ST, 1)
      take_items(pc, CRYSTAL_OF_FOUL_1ST, 1)
      take_items(pc, CRYSTAL_OF_DEFEAT_1ST, 1)
      html = event
    when "30636-03.html"
      if has_quest_items?(pc, BEGINNERS_ARCANA)
        html = event
      else
        html = "30636-02.html"
      end
    when "30636-04.html"
      add_skill_cast_desire(npc.not_nil!, pc, REDUCTION_IN_RECOVERY_TIME, 1000000)
      take_items(pc, BEGINNERS_ARCANA, 1)
      give_items(pc, CRYSTAL_OF_STARTING_3RD, 1)
      take_items(pc, CRYSTAL_OF_FOUL_3RD, 1)
      take_items(pc, CRYSTAL_OF_DEFEAT_3RD, 1)
      html = event
    when "30637-03.html"
      if has_quest_items?(pc, BEGINNERS_ARCANA)
        html = event
      else
        html = "30637-02.html"
      end
    when "30637-04.html"
      add_skill_cast_desire(npc.not_nil!, pc, REDUCTION_IN_RECOVERY_TIME, 1000000)
      take_items(pc, BEGINNERS_ARCANA, 1)
      give_items(pc, CRYSTAL_OF_STARTING_5TH, 1)
      take_items(pc, CRYSTAL_OF_FOUL_5TH, 1)
      take_items(pc, CRYSTAL_OF_DEFEAT_5TH, 1)
      html = event
    when "30638-03.html"
      if has_quest_items?(pc, BEGINNERS_ARCANA)
        html = event
      else
        html = "30638-02.html"
      end
    when "30638-04.html"
      add_skill_cast_desire(npc.not_nil!, pc, REDUCTION_IN_RECOVERY_TIME, 1000000)
      take_items(pc, BEGINNERS_ARCANA, 1)
      give_items(pc, CRYSTAL_OF_STARTING_2ND, 1)
      take_items(pc, CRYSTAL_OF_FOUL_2ND, 1)
      take_items(pc, CRYSTAL_OF_DEFEAT_2ND, 1)
      html = event
    when "30639-03.html"
      if has_quest_items?(pc, BEGINNERS_ARCANA)
        html = event
      else
        html = "30639-02.html"
      end
    when "30639-04.html"
      add_skill_cast_desire(npc.not_nil!, pc, REDUCTION_IN_RECOVERY_TIME, 1000000)
      take_items(pc, BEGINNERS_ARCANA, 1)
      give_items(pc, CRYSTAL_OF_STARTING_4TH, 1)
      take_items(pc, CRYSTAL_OF_FOUL_4TH, 1)
      take_items(pc, CRYSTAL_OF_DEFEAT_4TH, 1)
      html = event
    when "30640-03.html"
      if has_quest_items?(pc, BEGINNERS_ARCANA)
        html = event
      else
        html = "30640-02.html"
      end
    when "30640-04.html"
      add_skill_cast_desire(npc.not_nil!, pc, REDUCTION_IN_RECOVERY_TIME, 1000000)
      take_items(pc, BEGINNERS_ARCANA, 1)
      give_items(pc, CRYSTAL_OF_STARTING_6TH, 1)
      take_items(pc, CRYSTAL_OF_FOUL_6TH, 1)
      take_items(pc, CRYSTAL_OF_DEFEAT_6TH, 1)
      html = event
    end

    html
  end

  def on_attack(npc, attacker, damage, is_summon)
    case npc.id
    when PAKO_THE_CAT
      case npc.script_value
      when 0
        if is_summon
          npc.variables["ATTACKER"] = attacker.summon
          npc.script_value = 1
          start_quest_timer("DESPAWN", 120_000, npc, nil)
          start_quest_timer("KILLED_ATTACKER", 5000, npc, nil)

          qs = get_quest_state(attacker, false)
          if has_quest_items?(attacker, CRYSTAL_OF_STARTING_1ST) && qs && qs.started?
            Broadcast.to_known_players(npc, NpcSay.new(npc.l2id, Say2::NPC_ALL, npc.template.display_id, NpcString::WHHIISSHH))
            take_items(attacker, CRYSTAL_OF_STARTING_1ST, -1)
            give_items(attacker, CRYSTAL_OF_INPROGRESS_1ST, 1)
            add_attack_desire(npc, attacker.summon.not_nil!, 100000)
          end
        end
      when 1
        if !is_summon || npc.variables.get_object("ATTACKER", L2Summon?) != attacker.summon
          qs = get_quest_state(attacker, false)
          unless has_quest_items?(attacker, CRYSTAL_OF_STARTING_1ST)
            if has_quest_items?(attacker, CRYSTAL_OF_INPROGRESS_1ST)
              if qs && qs.started?
                npc.script_value = 2
                ns = NpcSay.new(npc.l2id, Say2::NPC_ALL, npc.template.display_id, NpcString::RULE_VIOLATION)
                Broadcast.to_known_players(npc, ns)
                take_items(attacker, CRYSTAL_OF_INPROGRESS_1ST, -1)
                give_items(attacker, CRYSTAL_OF_FOUL_1ST, 1)
                take_items(attacker, CRYSTAL_OF_STARTING_1ST, -1)
              end
            end
          end
          npc.delete_me
        end
      end
    when UNICORN_RACER
      case npc.script_value
      when 0
        if is_summon
          npc.variables["ATTACKER"] = attacker.summon
          npc.script_value = 1
          start_quest_timer("DESPAWN", 120_000, npc, nil)
          start_quest_timer("KILLED_ATTACKER", 5000, npc, nil)

          qs = get_quest_state(attacker, false)
          if has_quest_items?(attacker, CRYSTAL_OF_STARTING_3RD) && qs && qs.started?
            Broadcast.to_known_players(npc, NpcSay.new(npc.l2id, Say2::NPC_ALL, npc.template.display_id, NpcString::START_DUEL))
            take_items(attacker, CRYSTAL_OF_STARTING_3RD, -1)
            give_items(attacker, CRYSTAL_OF_INPROGRESS_3RD, 1)
            add_attack_desire(npc, attacker.summon.not_nil!, 100000)
          end
        end
      when 1
        if !is_summon || npc.variables.get_object("ATTACKER", L2Summon?) != attacker.summon
          qs = get_quest_state(attacker, false)
          unless has_quest_items?(attacker, CRYSTAL_OF_STARTING_3RD)
            if has_quest_items?(attacker, CRYSTAL_OF_INPROGRESS_3RD)
              if qs && qs.started?
                npc.script_value = 2
                ns = NpcSay.new(npc.l2id, Say2::NPC_ALL, npc.template.display_id, NpcString::RULE_VIOLATION)
                Broadcast.to_known_players(npc, ns)
                take_items(attacker, CRYSTAL_OF_INPROGRESS_3RD, -1)
                give_items(attacker, CRYSTAL_OF_FOUL_3RD, 1)
                take_items(attacker, CRYSTAL_OF_STARTING_3RD, -1)
              end
            end
          end
          npc.delete_me
        end
      end
    when SHADOW_TUREN
      case npc.script_value
      when 0
        if is_summon
          npc.variables["ATTACKER"] = attacker.summon
          npc.script_value = 1
          start_quest_timer("DESPAWN", 120_000, npc, nil)
          start_quest_timer("KILLED_ATTACKER", 5000, npc, nil)

          qs = get_quest_state(attacker, false)
          if has_quest_items?(attacker, CRYSTAL_OF_STARTING_5TH)
            if qs && qs.started?
              Broadcast.to_known_players(npc, NpcSay.new(npc.l2id, Say2::NPC_ALL, npc.template.display_id, NpcString::SO_SHALL_WE_START))
              take_items(attacker, CRYSTAL_OF_STARTING_5TH, -1)
              give_items(attacker, CRYSTAL_OF_INPROGRESS_5TH, 1)
              add_attack_desire(npc, attacker.summon.not_nil!, 100000)
            end
          end
        end
      when 1
        if !is_summon || npc.variables.get_object("ATTACKER", L2Summon?) != attacker.summon
          qs = get_quest_state(attacker, false)
          unless has_quest_items?(attacker, CRYSTAL_OF_STARTING_5TH)
            if has_quest_items?(attacker, CRYSTAL_OF_INPROGRESS_5TH)
              if qs && qs.started?
                npc.script_value = 2
                ns = NpcSay.new(npc.l2id, Say2::NPC_ALL, npc.template.display_id, NpcString::RULE_VIOLATION)
                Broadcast.to_known_players(npc, ns)
                take_items(attacker, CRYSTAL_OF_INPROGRESS_5TH, -1)
                give_items(attacker, CRYSTAL_OF_FOUL_5TH, 1)
                take_items(attacker, CRYSTAL_OF_STARTING_5TH, -1)
              end
            end
          end
          npc.delete_me
        end
      end
    when MIMI_THE_CAT
      case npc.script_value
      when 0
        if is_summon
          npc.variables["ATTACKER"] = attacker.summon
          npc.script_value = 1
          start_quest_timer("DESPAWN", 120_000, npc, nil)
          start_quest_timer("KILLED_ATTACKER", 5000, npc, nil)

          qs = get_quest_state(attacker, false)
          if has_quest_items?(attacker, CRYSTAL_OF_STARTING_2ND) && qs && qs.started?
            Broadcast.to_known_players(npc, NpcSay.new(npc.l2id, Say2::NPC_ALL, npc.template.display_id, NpcString::WHISH_FIGHT))
            take_items(attacker, CRYSTAL_OF_STARTING_2ND, -1)
            give_items(attacker, CRYSTAL_OF_INPROGRESS_2ND, 1)
            add_attack_desire(npc, attacker.summon.not_nil!, 100000)
          end
        end
      when 1
        if !is_summon || npc.variables.get_object("ATTACKER", L2Summon?) != attacker.summon
          qs = get_quest_state(attacker, false)
          unless has_quest_items?(attacker, CRYSTAL_OF_STARTING_2ND)
            if has_quest_items?(attacker, CRYSTAL_OF_INPROGRESS_2ND)
              if qs && qs.started?
                npc.script_value = 2
                ns = NpcSay.new(npc.l2id, Say2::NPC_ALL, npc.template.display_id, NpcString::RULE_VIOLATION)
                Broadcast.to_known_players(npc, ns)
                take_items(attacker, CRYSTAL_OF_INPROGRESS_2ND, -1)
                give_items(attacker, CRYSTAL_OF_FOUL_2ND, 1)
                take_items(attacker, CRYSTAL_OF_STARTING_2ND, -1)
              end
            end
          end
          npc.delete_me
        end
      end
    when UNICORN_PHANTASM
      case npc.script_value
      when 0
        if is_summon
          npc.variables["ATTACKER"] = attacker.summon
          npc.script_value = 1
          start_quest_timer("DESPAWN", 120_000, npc, nil)
          start_quest_timer("KILLED_ATTACKER", 5000, npc, nil)

          qs = get_quest_state(attacker, false)
          if has_quest_items?(attacker, CRYSTAL_OF_STARTING_4TH)
            if qs && qs.started?
              Broadcast.to_known_players(npc, NpcSay.new(npc.l2id, Say2::NPC_ALL, npc.template.display_id, NpcString::START_DUEL))
              take_items(attacker, CRYSTAL_OF_STARTING_4TH, -1)
              give_items(attacker, CRYSTAL_OF_INPROGRESS_4TH, 1)
              add_attack_desire(npc, attacker.summon.not_nil!, 100000)
            end
          end
        end
      when 1
        if !is_summon || npc.variables.get_object("ATTACKER", L2Summon?) != attacker.summon
          qs = get_quest_state(attacker, false)
          unless has_quest_items?(attacker, CRYSTAL_OF_STARTING_4TH)
            if has_quest_items?(attacker, CRYSTAL_OF_INPROGRESS_4TH)
              if qs && qs.started?
                npc.script_value = 2
                ns = NpcSay.new(npc.l2id, Say2::NPC_ALL, npc.template.display_id, NpcString::RULE_VIOLATION)
                Broadcast.to_known_players(npc, ns)
                take_items(attacker, CRYSTAL_OF_INPROGRESS_4TH, -1)
                give_items(attacker, CRYSTAL_OF_FOUL_4TH, 1)
                take_items(attacker, CRYSTAL_OF_STARTING_4TH, -1)
              end
            end
          end
          npc.delete_me
        end
      end
    when SILHOUETTE_TILFO
      case npc.script_value
      when 0
        if is_summon
          npc.variables["ATTACKER"] = attacker.summon
          npc.script_value = 1
          start_quest_timer("DESPAWN", 120_000, npc, nil)
          start_quest_timer("KILLED_ATTACKER", 5000, npc, nil)

          qs = get_quest_state(attacker, false)
          if has_quest_items?(attacker, CRYSTAL_OF_STARTING_6TH)
            if qs && qs.started?
              Broadcast.to_known_players(npc, NpcSay.new(npc.l2id, Say2::NPC_ALL, npc.template.display_id, NpcString::ILL_WALK_ALL_OVER_YOU))
              take_items(attacker, CRYSTAL_OF_STARTING_6TH, -1)
              give_items(attacker, CRYSTAL_OF_INPROGRESS_6TH, 1)
              add_attack_desire(npc, attacker.summon.not_nil!, 100000)
            end
          end
        end
      when 1
        if !is_summon || npc.variables.get_object("ATTACKER", L2Summon?) != attacker.summon
          qs = get_quest_state(attacker, false)
          unless has_quest_items?(attacker, CRYSTAL_OF_STARTING_6TH)
            if has_quest_items?(attacker, CRYSTAL_OF_INPROGRESS_6TH)
              if qs && qs.started?
                npc.script_value = 2
                ns = NpcSay.new(npc.l2id, Say2::NPC_ALL, npc.template.display_id, NpcString::RULE_VIOLATION)
                Broadcast.to_known_players(npc, ns)
                take_items(attacker, CRYSTAL_OF_INPROGRESS_6TH, -1)
                give_items(attacker, CRYSTAL_OF_FOUL_6TH, 1)
                take_items(attacker, CRYSTAL_OF_STARTING_6TH, -1)
              end
            end
          end
          npc.delete_me
        end
      end
    end

    super
  end

  def on_kill(npc, killer, is_summon)
    qs = get_quest_state(killer, false)

    if qs && qs.started? && Util.in_range?(1500, npc, killer, true)
      case npc.id
      when NOBLE_ANT, NOBLE_ANT_LEADER
        unless has_quest_items?(killer, GALATEAS_LETTER)
          if has_quest_items?(killer, LARAS_5TH_LIST)
            give_item_randomly(killer, npc, WINGS_OF_DRONEANT, 2, 30, 1.0, true)
          end
        end
      when WYRM
        unless has_quest_items?(killer, GALATEAS_LETTER)
          if has_quest_items?(killer, LARAS_5TH_LIST)
            give_item_randomly(killer, npc, FANGS_OF_WYRM, 3, 30, 1.0, true)
          end
        end
      when TYRANT, TYRANT_KINGPIN
        unless has_quest_items?(killer, GALATEAS_LETTER)
          if has_quest_items?(killer, LARAS_4TH_LIST)
            give_item_randomly(killer, npc, TALONS_OF_TYRANT, 3, 30, 1.0, true)
          end
        end
      when BREKA_ORC, BREKA_ORC_ARCHER, BREKA_ORC_WARRIOR
        unless has_quest_items?(killer, GALATEAS_LETTER)
          if has_quest_items?(killer, LARAS_3RD_LIST)
            give_item_randomly(killer, npc, BREKA_ORC_TOTEM, 1, 30, 1.0, true)
          end
        end
      when BREKA_ORC_SHAMAN, BREKA_ORC_OVERLORD
        unless has_quest_items?(killer, GALATEAS_LETTER)
          if has_quest_items?(killer, LARAS_3RD_LIST)
            give_item_randomly(killer, npc, BREKA_ORC_TOTEM, 2, 30, 1.0, true)
          end
        end
      when FETTERED_SOUL
        unless has_quest_items?(killer, GALATEAS_LETTER)
          if has_quest_items?(killer, LARAS_3RD_LIST)
            give_item_randomly(killer, npc, CRIMSON_BLOODSTONE, 6, 30, 1.0, true)
          end
        end
      when WINDSUS
        unless has_quest_items?(killer, GALATEAS_LETTER)
          if has_quest_items?(killer, LARAS_4TH_LIST)
            give_item_randomly(killer, npc, TUSK_OF_WINDSUS, 3, 30, 1.0, true)
          end
        end
      when GIANT_FUNGUS
        unless has_quest_items?(killer, GALATEAS_LETTER)
          if has_quest_items?(killer, LARAS_1ST_LIST)
            give_item_randomly(killer, npc, SAC_OF_RED_SPORES, 2, 30, 1.0, true)
          end
        end
      when MANASHEN_GARGOYLE
        unless has_quest_items?(killer, GALATEAS_LETTER)
          if has_quest_items?(killer, LARAS_2ND_LIST)
            give_item_randomly(killer, npc, SHARDS_OF_MANASHEN, 2, 30, 1.0, true)
          end
        end
      when LETO_LIZARDMAN, LETO_LIZARDMAN_ARCHER, LETO_LIZARDMAN_SOLDIER,
           LETO_LIZARDMAN_WARRIOR
        unless has_quest_items?(killer, GALATEAS_LETTER)
          if has_quest_items?(killer, LARAS_1ST_LIST)
            give_item_randomly(killer, npc, LETO_LIZARDMAN_AMULET, 1, 30, 1.0, true)
          end
        end
      when LETO_LIZARDMAN_SHAMAN, LETO_LIZARDMAN_OVERLORD
        unless has_quest_items?(killer, GALATEAS_LETTER)
          if has_quest_items?(killer, LARAS_1ST_LIST)
            give_item_randomly(killer, npc, LETO_LIZARDMAN_AMULET, 2, 30, 1.0, true)
          end
        end
      when KARUL_BUGBEAR
        unless has_quest_items?(killer, GALATEAS_LETTER)
          if has_quest_items?(killer, LARAS_2ND_LIST)
            give_item_randomly(killer, npc, KARUL_BUGBEAR_TOTEM, 2, 30, 1.0, true)
          end
        end
      when SILHOUETTE_TILFO, UNICORN_PHANTASM, MIMI_THE_CAT, SHADOW_TUREN,
           UNICORN_RACER, PAKO_THE_CAT
        data = MONSTERS[npc.id]
        if has_quest_items?(killer, data.crystal_of_in_progress)
          npc.broadcast_packet(NpcSay.new(npc, Say2::NPC_ALL, data.npc_string))
          take_items(killer, data.crystal_of_in_progress, 1)
          give_items(killer, data.crystal_of_victory, 1)
          play_sound(killer, Sound::ITEMSOUND_QUEST_MIDDLE)
        end
      end
    end

    super
  end

  def on_talk(npc, pc)
    qs = get_quest_state!(pc)

    if qs.created?
      if npc.id == HIGH_SUMMONER_GALATEA
        if pc.class_id.wizard? || pc.class_id.elven_wizard? || pc.class_id.dark_wizard?
          if pc.level >= MIN_LEVEL
            html = "30634-03.htm"
          else
            html = "30634-02.html"
          end
        else
          html = "30634-01.html"
        end
      end
    elsif qs.started?
      case npc.id
      when HIGH_SUMMONER_GALATEA
        if has_quest_items?(pc, GALATEAS_LETTER)
          html = "30634-09.html"
        elsif !has_quest_items?(pc, GALATEAS_LETTER)
          if !has_quest_items?(pc, ALMORS_ARCANA, BASILLIA_ARCANA, CAMONIELL_ARCANA, CELESTIEL_ARCANA, BELTHUS_ARCANA, BRYNTHEA_ARCANA) && !has_quest_items?(pc, BEGINNERS_ARCANA)
            html = "30634-10.html"
          elsif !has_quest_items?(pc, ALMORS_ARCANA, BASILLIA_ARCANA, CAMONIELL_ARCANA, CELESTIEL_ARCANA, BELTHUS_ARCANA, BRYNTHEA_ARCANA) && has_quest_items?(pc, BEGINNERS_ARCANA)
            html = "30634-11.html"
          elsif has_quest_items?(pc, ALMORS_ARCANA, BASILLIA_ARCANA, CAMONIELL_ARCANA, CELESTIEL_ARCANA, BELTHUS_ARCANA, BRYNTHEA_ARCANA)
            give_adena(pc, 300_960, true)
            give_items(pc, MARK_OF_SUMMONER, 1)
            add_exp_and_sp(pc, 1_664_494, 114_220)
            qs.exit_quest(false, true)
            pc.send_packet(SocialAction.new(pc.l2id, 3))
            html = "30634-12.html"
          end
        end
      when GROCER_LARA
        if has_quest_items?(pc, GALATEAS_LETTER)
          html = "30063-01.html"
        elsif !has_quest_items?(pc, GALATEAS_LETTER)
          if !has_at_least_one_quest_item?(pc, LARAS_1ST_LIST, LARAS_2ND_LIST, LARAS_3RD_LIST, LARAS_4TH_LIST, LARAS_5TH_LIST)
            html = "30063-03.html"
          elsif has_quest_items?(pc, LARAS_1ST_LIST)
            if get_quest_items_count(pc, LETO_LIZARDMAN_AMULET) >= 30 && get_quest_items_count(pc, SAC_OF_RED_SPORES) >= 30
              take_items(pc, LETO_LIZARDMAN_AMULET, -1)
              take_items(pc, SAC_OF_RED_SPORES, -1)
              take_items(pc, LARAS_1ST_LIST, 1)
              give_items(pc, BEGINNERS_ARCANA, 2)
              qs.set_cond(3, true)
              html = "30063-06.html"
            else
              html = "30063-05.html"
            end
          elsif has_quest_items?(pc, LARAS_2ND_LIST)
            if get_quest_items_count(pc, KARUL_BUGBEAR_TOTEM) >= 30 && get_quest_items_count(pc, SHARDS_OF_MANASHEN) >= 30
              take_items(pc, KARUL_BUGBEAR_TOTEM, -1)
              take_items(pc, SHARDS_OF_MANASHEN, -1)
              take_items(pc, LARAS_2ND_LIST, 1)
              give_items(pc, BEGINNERS_ARCANA, 2)
              qs.set_cond(3, true)
              html = "30063-08.html"
            else
              html = "30063-07.html"
            end
          elsif has_quest_items?(pc, LARAS_3RD_LIST)
            if get_quest_items_count(pc, BREKA_ORC_TOTEM) >= 30 && get_quest_items_count(pc, CRIMSON_BLOODSTONE) >= 30
              take_items(pc, BREKA_ORC_TOTEM, -1)
              take_items(pc, CRIMSON_BLOODSTONE, -1)
              take_items(pc, LARAS_3RD_LIST, 1)
              give_items(pc, BEGINNERS_ARCANA, 2)
              qs.set_cond(3, true)
              html = "30063-10.html"
            else
              html = "30063-09.html"
            end
          elsif has_quest_items?(pc, LARAS_4TH_LIST)
            if get_quest_items_count(pc, TALONS_OF_TYRANT) >= 30 && get_quest_items_count(pc, TUSK_OF_WINDSUS) >= 30
              take_items(pc, TALONS_OF_TYRANT, -1)
              take_items(pc, TUSK_OF_WINDSUS, -1)
              take_items(pc, LARAS_4TH_LIST, 1)
              give_items(pc, BEGINNERS_ARCANA, 2)
              qs.set_cond(3, true)
              html = "30063-12.html"
            else
              html = "30063-11.html"
            end
          elsif has_quest_items?(pc, LARAS_5TH_LIST)
            if get_quest_items_count(pc, WINGS_OF_DRONEANT) >= 30 && get_quest_items_count(pc, FANGS_OF_WYRM) >= 30
              take_items(pc, WINGS_OF_DRONEANT, -1)
              take_items(pc, FANGS_OF_WYRM, -1)
              take_items(pc, LARAS_5TH_LIST, 1)
              give_items(pc, BEGINNERS_ARCANA, 2)
              qs.set_cond(3, true)
              html = "30063-14.html"
            else
              html = "30063-13.html"
            end
          end
        end
      when SUMMONER_ALMORS
        if !has_quest_items?(pc, ALMORS_ARCANA)
          if !has_at_least_one_quest_item?(pc, CRYSTAL_OF_STARTING_1ST, CRYSTAL_OF_INPROGRESS_1ST, CRYSTAL_OF_FOUL_1ST, CRYSTAL_OF_DEFEAT_1ST, CRYSTAL_OF_VICTORY_1ST)
            html = "30635-01.html"
          elsif !has_at_least_one_quest_item?(pc, CRYSTAL_OF_STARTING_1ST, CRYSTAL_OF_INPROGRESS_1ST, CRYSTAL_OF_FOUL_1ST, CRYSTAL_OF_VICTORY_1ST) && has_quest_items?(pc, CRYSTAL_OF_DEFEAT_1ST)
            html = "30635-05.html"
          elsif !has_at_least_one_quest_item?(pc, CRYSTAL_OF_STARTING_1ST, CRYSTAL_OF_INPROGRESS_1ST, CRYSTAL_OF_DEFEAT_1ST, CRYSTAL_OF_VICTORY_1ST) && has_quest_items?(pc, CRYSTAL_OF_FOUL_1ST)
            html = "30635-06.html"
          elsif !has_at_least_one_quest_item?(pc, CRYSTAL_OF_STARTING_1ST, CRYSTAL_OF_INPROGRESS_1ST, CRYSTAL_OF_FOUL_1ST, CRYSTAL_OF_DEFEAT_1ST) && has_quest_items?(pc, CRYSTAL_OF_VICTORY_1ST)
            give_items(pc, ALMORS_ARCANA, 1)
            take_items(pc, CRYSTAL_OF_VICTORY_1ST, 1)
            if has_quest_items?(pc, BASILLIA_ARCANA, CAMONIELL_ARCANA, CELESTIEL_ARCANA, BELTHUS_ARCANA, BRYNTHEA_ARCANA)
              qs.set_cond(4, true)
            end
            html = "30635-07.html"
          elsif !has_at_least_one_quest_item?(pc, CRYSTAL_OF_INPROGRESS_1ST, CRYSTAL_OF_FOUL_1ST, CRYSTAL_OF_DEFEAT_1ST, CRYSTAL_OF_VICTORY_1ST) && has_quest_items?(pc, CRYSTAL_OF_STARTING_1ST)
            html = "30635-08.html"
          elsif !has_at_least_one_quest_item?(pc, CRYSTAL_OF_STARTING_1ST, CRYSTAL_OF_FOUL_1ST, CRYSTAL_OF_DEFEAT_1ST, CRYSTAL_OF_VICTORY_1ST) && has_quest_items?(pc, CRYSTAL_OF_INPROGRESS_1ST)
            html = "30635-09.html"
          end
        else
          html = "30635-10.html"
        end
      when SUMMONER_CAMONIELL
        if !has_quest_items?(pc, CAMONIELL_ARCANA)
          if !has_at_least_one_quest_item?(pc, CRYSTAL_OF_STARTING_3RD, CRYSTAL_OF_INPROGRESS_3RD, CRYSTAL_OF_FOUL_3RD, CRYSTAL_OF_DEFEAT_3RD, CRYSTAL_OF_VICTORY_3RD)
            html = "30636-01.html"
          elsif !has_at_least_one_quest_item?(pc, CRYSTAL_OF_STARTING_3RD, CRYSTAL_OF_INPROGRESS_3RD, CRYSTAL_OF_FOUL_3RD, CRYSTAL_OF_VICTORY_3RD) && has_quest_items?(pc, CRYSTAL_OF_DEFEAT_3RD)
            html = "30636-05.html"
          elsif !has_at_least_one_quest_item?(pc, CRYSTAL_OF_STARTING_3RD, CRYSTAL_OF_INPROGRESS_3RD, CRYSTAL_OF_DEFEAT_3RD, CRYSTAL_OF_VICTORY_3RD) && has_quest_items?(pc, CRYSTAL_OF_FOUL_3RD)
            html = "30636-06.html"
          elsif !has_at_least_one_quest_item?(pc, CRYSTAL_OF_STARTING_3RD, CRYSTAL_OF_INPROGRESS_3RD, CRYSTAL_OF_FOUL_3RD, CRYSTAL_OF_DEFEAT_3RD) && has_quest_items?(pc, CRYSTAL_OF_VICTORY_3RD)
            give_items(pc, CAMONIELL_ARCANA, 1)
            take_items(pc, CRYSTAL_OF_VICTORY_3RD, 1)
            if has_quest_items?(pc, ALMORS_ARCANA, BASILLIA_ARCANA, CELESTIEL_ARCANA, BELTHUS_ARCANA, BRYNTHEA_ARCANA)
              qs.set_cond(4, true)
            end
            html = "30636-07.html"
          elsif !has_at_least_one_quest_item?(pc, CRYSTAL_OF_INPROGRESS_3RD, CRYSTAL_OF_FOUL_3RD, CRYSTAL_OF_DEFEAT_3RD, CRYSTAL_OF_VICTORY_3RD) && has_quest_items?(pc, CRYSTAL_OF_STARTING_3RD)
            html = "30636-08.html"
          elsif !has_at_least_one_quest_item?(pc, CRYSTAL_OF_STARTING_3RD, CRYSTAL_OF_FOUL_3RD, CRYSTAL_OF_DEFEAT_3RD, CRYSTAL_OF_VICTORY_3RD) && has_quest_items?(pc, CRYSTAL_OF_INPROGRESS_3RD)
            html = "30636-09.html"
          end
        else
          html = "30636-10.html"
        end
      when SUMMONER_BELTHUS
        if !has_quest_items?(pc, BELTHUS_ARCANA)
          if !has_at_least_one_quest_item?(pc, CRYSTAL_OF_STARTING_5TH, CRYSTAL_OF_INPROGRESS_5TH, CRYSTAL_OF_FOUL_5TH, CRYSTAL_OF_DEFEAT_5TH, CRYSTAL_OF_VICTORY_5TH)
            html = "30637-01.html"
          elsif !has_at_least_one_quest_item?(pc, CRYSTAL_OF_STARTING_5TH, CRYSTAL_OF_INPROGRESS_5TH, CRYSTAL_OF_FOUL_5TH, CRYSTAL_OF_VICTORY_5TH) && has_quest_items?(pc, CRYSTAL_OF_DEFEAT_5TH)
            html = "30637-05.html"
          elsif !has_at_least_one_quest_item?(pc, CRYSTAL_OF_STARTING_5TH, CRYSTAL_OF_INPROGRESS_5TH, CRYSTAL_OF_DEFEAT_5TH, CRYSTAL_OF_VICTORY_5TH) && has_quest_items?(pc, CRYSTAL_OF_FOUL_5TH)
            html = "30637-06.html"
          elsif !has_at_least_one_quest_item?(pc, CRYSTAL_OF_STARTING_5TH, CRYSTAL_OF_INPROGRESS_5TH, CRYSTAL_OF_FOUL_5TH, CRYSTAL_OF_DEFEAT_5TH) && has_quest_items?(pc, CRYSTAL_OF_VICTORY_5TH)
            give_items(pc, BELTHUS_ARCANA, 1)
            take_items(pc, CRYSTAL_OF_VICTORY_5TH, 1)
            if has_quest_items?(pc, ALMORS_ARCANA, BASILLIA_ARCANA, CAMONIELL_ARCANA, CELESTIEL_ARCANA, BRYNTHEA_ARCANA)
              qs.set_cond(4, true)
            end
            html = "30637-07.html"
          elsif !has_at_least_one_quest_item?(pc, CRYSTAL_OF_INPROGRESS_5TH, CRYSTAL_OF_FOUL_5TH, CRYSTAL_OF_DEFEAT_5TH, CRYSTAL_OF_VICTORY_5TH) && has_quest_items?(pc, CRYSTAL_OF_STARTING_5TH)
            html = "30637-08.html"
          elsif !has_at_least_one_quest_item?(pc, CRYSTAL_OF_STARTING_5TH, CRYSTAL_OF_FOUL_5TH, CRYSTAL_OF_DEFEAT_5TH, CRYSTAL_OF_VICTORY_5TH) && has_quest_items?(pc, CRYSTAL_OF_INPROGRESS_5TH)
            html = "30637-09.html"
          end
        else
          html = "30637-10.html"
        end
      when SUMMONER_BASILLA
        if !has_quest_items?(pc, BASILLIA_ARCANA)
          if !has_at_least_one_quest_item?(pc, CRYSTAL_OF_STARTING_2ND, CRYSTAL_OF_INPROGRESS_2ND, CRYSTAL_OF_FOUL_2ND, CRYSTAL_OF_DEFEAT_2ND, CRYSTAL_OF_VICTORY_2ND)
            html = "30638-01.html"
          elsif !has_at_least_one_quest_item?(pc, CRYSTAL_OF_STARTING_2ND, CRYSTAL_OF_INPROGRESS_2ND, CRYSTAL_OF_FOUL_2ND, CRYSTAL_OF_VICTORY_2ND) && has_quest_items?(pc, CRYSTAL_OF_DEFEAT_2ND)
            html = "30638-05.html"
          elsif !has_at_least_one_quest_item?(pc, CRYSTAL_OF_STARTING_2ND, CRYSTAL_OF_INPROGRESS_2ND, CRYSTAL_OF_DEFEAT_2ND, CRYSTAL_OF_VICTORY_2ND) && has_quest_items?(pc, CRYSTAL_OF_FOUL_2ND)
            html = "30638-06.html"
          elsif !has_at_least_one_quest_item?(pc, CRYSTAL_OF_STARTING_2ND, CRYSTAL_OF_INPROGRESS_2ND, CRYSTAL_OF_FOUL_2ND, CRYSTAL_OF_DEFEAT_2ND) && has_quest_items?(pc, CRYSTAL_OF_VICTORY_2ND)
            give_items(pc, BASILLIA_ARCANA, 1)
            take_items(pc, CRYSTAL_OF_VICTORY_2ND, 1)
            if has_quest_items?(pc, ALMORS_ARCANA, CAMONIELL_ARCANA, CELESTIEL_ARCANA, BELTHUS_ARCANA, BRYNTHEA_ARCANA)
              qs.set_cond(4, true)
            end
            html = "30638-07.html"
          elsif !has_at_least_one_quest_item?(pc, CRYSTAL_OF_INPROGRESS_2ND, CRYSTAL_OF_FOUL_2ND, CRYSTAL_OF_DEFEAT_2ND, CRYSTAL_OF_VICTORY_2ND) && has_quest_items?(pc, CRYSTAL_OF_STARTING_2ND)
            html = "30638-08.html"
          elsif !has_at_least_one_quest_item?(pc, CRYSTAL_OF_STARTING_2ND, CRYSTAL_OF_FOUL_2ND, CRYSTAL_OF_DEFEAT_2ND, CRYSTAL_OF_VICTORY_2ND) && has_quest_items?(pc, CRYSTAL_OF_INPROGRESS_2ND)
            html = "30638-09.html"
          end
        else
          html = "30638-10.html"
        end
      when SUMMONER_CELESTIEL
        if !has_quest_items?(pc, CELESTIEL_ARCANA)
          if !has_at_least_one_quest_item?(pc, CRYSTAL_OF_STARTING_4TH, CRYSTAL_OF_INPROGRESS_4TH, CRYSTAL_OF_FOUL_4TH, CRYSTAL_OF_DEFEAT_4TH, CRYSTAL_OF_VICTORY_4TH)
            html = "30639-01.html"
          elsif !has_at_least_one_quest_item?(pc, CRYSTAL_OF_STARTING_4TH, CRYSTAL_OF_INPROGRESS_4TH, CRYSTAL_OF_FOUL_4TH, CRYSTAL_OF_VICTORY_4TH) && has_quest_items?(pc, CRYSTAL_OF_DEFEAT_4TH)
            html = "30639-05.html"
          elsif !has_at_least_one_quest_item?(pc, CRYSTAL_OF_STARTING_4TH, CRYSTAL_OF_INPROGRESS_4TH, CRYSTAL_OF_DEFEAT_4TH, CRYSTAL_OF_VICTORY_4TH) && has_quest_items?(pc, CRYSTAL_OF_FOUL_4TH)
            html = "30639-06.html"
          elsif !has_at_least_one_quest_item?(pc, CRYSTAL_OF_STARTING_4TH, CRYSTAL_OF_INPROGRESS_4TH, CRYSTAL_OF_FOUL_4TH, CRYSTAL_OF_DEFEAT_4TH) && has_quest_items?(pc, CRYSTAL_OF_VICTORY_4TH)
            give_items(pc, CELESTIEL_ARCANA, 1)
            take_items(pc, CRYSTAL_OF_VICTORY_4TH, 1)
            if (has_quest_items?(pc, ALMORS_ARCANA, BASILLIA_ARCANA, CAMONIELL_ARCANA, BELTHUS_ARCANA, BRYNTHEA_ARCANA))
              qs.set_cond(4, true)
            end
            html = "30639-07.html"
          elsif !has_at_least_one_quest_item?(pc, CRYSTAL_OF_INPROGRESS_4TH, CRYSTAL_OF_FOUL_4TH, CRYSTAL_OF_DEFEAT_4TH, CRYSTAL_OF_VICTORY_4TH) && has_quest_items?(pc, CRYSTAL_OF_STARTING_4TH)
            html = "30639-08.html"
          elsif !has_at_least_one_quest_item?(pc, CRYSTAL_OF_STARTING_4TH, CRYSTAL_OF_FOUL_4TH, CRYSTAL_OF_DEFEAT_4TH, CRYSTAL_OF_VICTORY_4TH) && has_quest_items?(pc, CRYSTAL_OF_INPROGRESS_4TH)
            html = "30639-09.html"
          end
        else
          html = "30639-10.html"
        end
      when SUMMONER_BRYNTHEA
        if !has_quest_items?(pc, BRYNTHEA_ARCANA)
          if !has_at_least_one_quest_item?(pc, CRYSTAL_OF_STARTING_6TH, CRYSTAL_OF_INPROGRESS_6TH, CRYSTAL_OF_FOUL_6TH, CRYSTAL_OF_DEFEAT_6TH, CRYSTAL_OF_VICTORY_6TH)
            html = "30640-01.html"
          elsif !has_at_least_one_quest_item?(pc, CRYSTAL_OF_STARTING_6TH, CRYSTAL_OF_INPROGRESS_6TH, CRYSTAL_OF_FOUL_6TH, CRYSTAL_OF_VICTORY_6TH) && has_quest_items?(pc, CRYSTAL_OF_DEFEAT_6TH)
            html = "30640-05.html"
          elsif !has_at_least_one_quest_item?(pc, CRYSTAL_OF_STARTING_6TH, CRYSTAL_OF_INPROGRESS_6TH, CRYSTAL_OF_DEFEAT_6TH, CRYSTAL_OF_VICTORY_6TH) && has_quest_items?(pc, CRYSTAL_OF_FOUL_6TH)
            html = "30640-06.html"
          elsif !has_at_least_one_quest_item?(pc, CRYSTAL_OF_STARTING_6TH, CRYSTAL_OF_INPROGRESS_6TH, CRYSTAL_OF_FOUL_6TH, CRYSTAL_OF_DEFEAT_6TH) && has_quest_items?(pc, CRYSTAL_OF_VICTORY_6TH)
            give_items(pc, BRYNTHEA_ARCANA, 1)
            take_items(pc, CRYSTAL_OF_VICTORY_6TH, 1)
            if has_quest_items?(pc, ALMORS_ARCANA, BASILLIA_ARCANA, CAMONIELL_ARCANA, CELESTIEL_ARCANA, BELTHUS_ARCANA)
              qs.set_cond(4, true)
            end
            html = "30640-07.html"
          elsif !has_at_least_one_quest_item?(pc, CRYSTAL_OF_INPROGRESS_6TH, CRYSTAL_OF_FOUL_6TH, CRYSTAL_OF_DEFEAT_6TH, CRYSTAL_OF_VICTORY_6TH) && has_quest_items?(pc, CRYSTAL_OF_STARTING_6TH)
            html = "30640-08.html"
          elsif !has_at_least_one_quest_item?(pc, CRYSTAL_OF_STARTING_6TH, CRYSTAL_OF_FOUL_6TH, CRYSTAL_OF_DEFEAT_6TH, CRYSTAL_OF_VICTORY_6TH) && has_quest_items?(pc, CRYSTAL_OF_INPROGRESS_6TH)
            html = "30640-09.html"
          end
        else
          html = "30640-10.html"
        end
      end
    elsif qs.completed?
      if npc.id == HIGH_SUMMONER_GALATEA
        html = get_already_completed_msg(pc)
      end
    end

    html || get_no_quest_msg(pc)
  end
end
