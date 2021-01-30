class Scripts::Q00337_AudienceWithTheLandDragon < Quest
  # NPCs
  private WAREHOUSE_CHIEF_MOKE = 30498
  private BLACKSMITH_HELTON = 30678
  private PREFECT_CHAKIRIS = 30705
  private MAGISTER_KAIENA = 30720
  private GABRIELLE = 30753
  private ANTHARAS_WATCHMAN_GILMORE = 30754
  private ANTHARAS_WATCHMAN_THEODRIC = 30755
  private MASTER_KENDRA = 30851
  private HIGH_PRIEST_ORVEN = 30857
  # Items
  private FEATHER_OF_GABRIELLE = 3852
  private MARSH_STALKER_HORN = 3853
  private MARSH_DRAKE_TALONS = 3854
  private KRANROT_SKIN = 3855
  private HAMRUT_LEG = 3856
  private REMAINS_OF_SACRAFICE = 3857
  private TOTEM_OF_LAND_DRAGON = 3858
  private FRAGMENT_OF_ABYSS_JEWEL_1ST = 3859
  private FRAGMENT_OF_ABYSS_JEWEL_2ND = 3860
  private FRAGMENT_OF_ABYSS_JEWEL_3RD = 3861
  private MARA_FANG = 3862
  private MUSFEL_FANG = 3863
  private MARK_OF_WATCHMAN = 3864
  private HERALD_OF_SLAYER = 3890
  # Reward
  private PORTAL_STONE = 3865
  # Monster
  private BLOOD_QUEEN = 18001
  private CAVE_MAIDEN = 20134
  private CAVE_KEEPER = 20246
  private CAVE_KEEPER_HOLD = 20277
  private CAVE_MAIDEN_HOLD = 20287
  private HARIT_LIZARDMAN_SHAMAN = 20644
  private HARIT_LIZARDMAN_MATRIARCH = 20645
  private HAMRUT = 20649
  private KRANROT = 20650
  private MARSH_STALKER = 20679
  private MARSH_DRAKE = 20680
  # Quest Monster
  private ABYSSAL_JEWEL_1 = 27165
  private ABYSSAL_JEWEL_2 = 27166
  private ABYSSAL_JEWEL_3 = 27167
  private JEWEL_GUARDIAN_MARA = 27168
  private JEWEL_GUARDIAN_MUSFEL = 27169
  private JEWEL_GUARDIAN_PYTON = 27170
  private GHOST_OF_OFFERING = 27171
  private HARIT_LIZARDMAN_ZEALOT = 27172
  # Misc
  private MIN_LEVEL = 50

  def initialize
    super(337, self.class.simple_name, "Audience With The Land Dragon")

    add_start_npc(GABRIELLE)
    add_talk_id(
      GABRIELLE, WAREHOUSE_CHIEF_MOKE, BLACKSMITH_HELTON, PREFECT_CHAKIRIS,
      MAGISTER_KAIENA, ANTHARAS_WATCHMAN_GILMORE, ANTHARAS_WATCHMAN_THEODRIC,
      MASTER_KENDRA, HIGH_PRIEST_ORVEN
    )
    add_kill_id(
      BLOOD_QUEEN, CAVE_MAIDEN, CAVE_KEEPER, CAVE_KEEPER_HOLD, CAVE_MAIDEN_HOLD,
      HARIT_LIZARDMAN_SHAMAN, HARIT_LIZARDMAN_MATRIARCH, HAMRUT, KRANROT,
      MARSH_STALKER, MARSH_DRAKE, ABYSSAL_JEWEL_1, ABYSSAL_JEWEL_2,
      ABYSSAL_JEWEL_3, JEWEL_GUARDIAN_MARA, JEWEL_GUARDIAN_MUSFEL,
      JEWEL_GUARDIAN_PYTON, GHOST_OF_OFFERING, HARIT_LIZARDMAN_ZEALOT
    )
    add_attack_id(ABYSSAL_JEWEL_1, ABYSSAL_JEWEL_2, ABYSSAL_JEWEL_3)
    register_quest_items(
      FEATHER_OF_GABRIELLE, MARSH_STALKER_HORN, MARSH_DRAKE_TALONS,
      KRANROT_SKIN, HAMRUT_LEG, REMAINS_OF_SACRAFICE, TOTEM_OF_LAND_DRAGON,
      FRAGMENT_OF_ABYSS_JEWEL_1ST, FRAGMENT_OF_ABYSS_JEWEL_2ND,
      FRAGMENT_OF_ABYSS_JEWEL_3RD, MARA_FANG, MUSFEL_FANG, MARK_OF_WATCHMAN,
      HERALD_OF_SLAYER
    )
  end

  def on_adv_event(event, npc, pc)
    if event == "DESPAWN"
      npc.not_nil!.delete_me
      return super
    elsif event == "DESPAWN_240"
      npc.not_nil!.delete_me
      return super
    end

    return unless pc
    unless qs = get_quest_state(pc, false)
      return
    end

    case event
    when "30753-05.htm"
      if qs.created?
        give_items(pc, FEATHER_OF_GABRIELLE, 1)
        qs.start_quest
        qs.memo_state = 20000
        html = event
      end
    when "30753-09.html"
      take_items(pc, MARK_OF_WATCHMAN, -1)
      qs.memo_state = 40000
      qs.set_cond(2, true)
      html = event
    when "30754-03.html"
      qs.memo_state = 70000
      qs.set_cond(4, true)
      html = event
    when "30755-05.html"
      if qs.memo_state?(70000)
        if has_quest_items?(pc, FRAGMENT_OF_ABYSS_JEWEL_3RD)
          give_items(pc, PORTAL_STONE, 1)
          qs.exit_quest(true, true)
          html = event
        end
      end
    when "30498-02.html", "30678-01a.html", "30753-01a.html", "30753-03.htm",
         "30753-04.htm", "30753-06a.html"
      html = event
    end


    html
  end

  def on_attack(npc, attacker, damage, is_summon)
    qs = get_quest_state(attacker, false)
    if qs && qs.started?
      case npc.id
      when ABYSSAL_JEWEL_1
        if qs.memo_state?(40000) || qs.memo_state?(40001)
          if npc.hp_percent < 80 && npc.variables.get_i32("i_quest0") == 0
            20.times do
              spwn = add_spawn(JEWEL_GUARDIAN_MARA, npc, true, 180000)
              add_attack_desire(spwn, attacker)
            end
            npc.variables["i_quest0"] = 1
            start_quest_timer("DESPAWN", 900000, npc, attacker)
          end

          if npc.hp_percent < 40
            unless has_quest_items?(attacker, FRAGMENT_OF_ABYSS_JEWEL_1ST)
              give_items(attacker, FRAGMENT_OF_ABYSS_JEWEL_1ST, 1)
              play_sound(attacker, Sound::ITEMSOUND_QUEST_ITEMGET)
              start_quest_timer("DESPAWN_240", 240000, npc, attacker)
            end
          end
        end

        if npc.hp_percent < 10
          npc.delete_me
        end
      when ABYSSAL_JEWEL_2
        if qs.memo_state?(40000) || qs.memo_state?(40010)
          if npc.hp_percent < 80 && npc.variables.get_i32("i_quest0") == 0
            20.times do
              add_attack_desire(add_spawn(JEWEL_GUARDIAN_MUSFEL, npc, true, 180000), attacker)
            end
            npc.variables["i_quest0"] = 1
            start_quest_timer("DESPAWN", 900000, npc, attacker)
          end

          if npc.hp_percent < 40
            unless has_quest_items?(attacker, FRAGMENT_OF_ABYSS_JEWEL_2ND)
              give_items(attacker, FRAGMENT_OF_ABYSS_JEWEL_2ND, 1)
              play_sound(attacker, Sound::ITEMSOUND_QUEST_ITEMGET)
              start_quest_timer("DESPAWN_240", 240000, npc, attacker)
            end
          end
        end

        if npc.hp_percent < 10
          npc.delete_me
        end
      when ABYSSAL_JEWEL_3
        if qs.memo_state?(70000)
          if npc.hp_percent < 80 && npc.variables.get_i32("i_quest0") == 0
            add_attack_desire(add_spawn(JEWEL_GUARDIAN_PYTON, npc, true, 180000), attacker)
            add_attack_desire(add_spawn(JEWEL_GUARDIAN_PYTON, npc, true, 180000), attacker)
            add_attack_desire(add_spawn(JEWEL_GUARDIAN_PYTON, npc, true, 180000), attacker)
            add_attack_desire(add_spawn(JEWEL_GUARDIAN_PYTON, npc, true, 180000), attacker)
            npc.variables["i_quest0"] = 1
          end

          if npc.hp_percent < 40
            unless has_quest_items?(attacker, FRAGMENT_OF_ABYSS_JEWEL_3RD)
              give_items(attacker, FRAGMENT_OF_ABYSS_JEWEL_3RD, 1)
              play_sound(attacker, Sound::ITEMSOUND_QUEST_ITEMGET)
            end
          end
        end

        if npc.hp_percent < 10
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
      when BLOOD_QUEEN
        case qs.memo_state
        when 21011, 21010, 21001, 21000, 20011, 20010, 20001, 20000
          unless has_quest_items?(killer, REMAINS_OF_SACRAFICE)
            8.times do
              add_spawn(GHOST_OF_OFFERING, npc, true, 180000)
            end
          end
        end

      when CAVE_MAIDEN, CAVE_KEEPER, CAVE_KEEPER_HOLD, CAVE_MAIDEN_HOLD
        if qs.memo_state?(70000) && !has_quest_items?(killer, FRAGMENT_OF_ABYSS_JEWEL_3RD)
          if Rnd.rand(5) == 0
            add_spawn(ABYSSAL_JEWEL_3, npc, true, 180000)
          end
        end
      when HARIT_LIZARDMAN_SHAMAN
        case qs.memo_state
        when 21110, 21100, 21010, 21000, 20110, 20100, 20010, 20000
          unless has_quest_items?(killer, TOTEM_OF_LAND_DRAGON)
            add_attack_desire(add_spawn(HARIT_LIZARDMAN_ZEALOT, npc, true, 180000), killer)
            add_attack_desire(add_spawn(HARIT_LIZARDMAN_ZEALOT, npc, true, 180000), killer)
            add_attack_desire(add_spawn(HARIT_LIZARDMAN_ZEALOT, npc, true, 180000), killer)
          end
        end

      when HARIT_LIZARDMAN_MATRIARCH
        case qs.memo_state
        when 21110, 21100, 21010, 21000, 20110, 20100, 20010, 20000
          unless has_quest_items?(killer, TOTEM_OF_LAND_DRAGON)
            if Rnd.rand(5) == 0
              add_attack_desire(add_spawn(HARIT_LIZARDMAN_ZEALOT, npc, true, 180000), killer)
              add_attack_desire(add_spawn(HARIT_LIZARDMAN_ZEALOT, npc, true, 180000), killer)
              add_attack_desire(add_spawn(HARIT_LIZARDMAN_ZEALOT, npc, true, 180000), killer)
            end
          end
        end

      when HAMRUT
        case qs.memo_state
        when 21101, 21100, 21001, 21000, 20101, 20100, 20001, 20000
          unless has_quest_items?(killer, HAMRUT_LEG)
            give_items(killer, HAMRUT_LEG, 1)
            play_sound(killer, Sound::ITEMSOUND_QUEST_ITEMGET)
          end
        end

      when KRANROT
        case qs.memo_state
        when 21101, 21100, 21001, 21000, 20101, 20100, 20001, 20000
          unless has_quest_items?(killer, KRANROT_SKIN)
            give_items(killer, KRANROT_SKIN, 1)
            play_sound(killer, Sound::ITEMSOUND_QUEST_ITEMGET)
          end
        end

      when MARSH_STALKER
        case qs.memo_state
        when 20111, 20110, 20101, 20100, 20011, 20010, 20001, 20000
          unless has_quest_items?(killer, MARSH_STALKER_HORN)
            give_items(killer, MARSH_STALKER_HORN, 1)
            play_sound(killer, Sound::ITEMSOUND_QUEST_ITEMGET)
          end
        end

      when MARSH_DRAKE
        case qs.memo_state
        when 20111, 20110, 20101, 20100, 20011, 20010, 20001, 20000
          unless has_quest_items?(killer, MARSH_DRAKE_TALONS)
            give_items(killer, MARSH_DRAKE_TALONS, 1)
            play_sound(killer, Sound::ITEMSOUND_QUEST_ITEMGET)
          end
        end

      when JEWEL_GUARDIAN_MARA
        if qs.memo_state?(40000) || qs.memo_state?(40001)
          unless has_quest_items?(killer, MARA_FANG)
            give_items(killer, MARA_FANG, 1)
            play_sound(killer, Sound::ITEMSOUND_QUEST_ITEMGET)
          end
        end
      when JEWEL_GUARDIAN_MUSFEL
        if qs.memo_state?(40000) || qs.memo_state?(40010)
          unless has_quest_items?(killer, MUSFEL_FANG)
            give_items(killer, MUSFEL_FANG, 1)
            play_sound(killer, Sound::ITEMSOUND_QUEST_ITEMGET)
          end
        end
      when GHOST_OF_OFFERING
        case qs.memo_state
        when 21011, 21010, 21001, 21000, 20011, 20010, 20001, 20000
          unless has_quest_items?(killer, REMAINS_OF_SACRAFICE)
            give_items(killer, REMAINS_OF_SACRAFICE, 1)
            play_sound(killer, Sound::ITEMSOUND_QUEST_ITEMGET)
          end
        end

      when HARIT_LIZARDMAN_ZEALOT
        case qs.memo_state
        when 21110, 21100, 21010, 21000, 20110, 20100, 20010, 20000
          unless has_quest_items?(killer, TOTEM_OF_LAND_DRAGON)
            give_items(killer, TOTEM_OF_LAND_DRAGON, 1)
            play_sound(killer, Sound::ITEMSOUND_QUEST_ITEMGET)
          end
        end

      end

    end

    super
  end

  def on_talk(npc, pc)
    qs = get_quest_state!(pc)
    memo_state = qs.memo_state

    if qs.created?
      if npc.id == GABRIELLE
        if pc.level < MIN_LEVEL
          html = "30753-01.htm"
        else
          html = "30753-02.htm"
        end
      end
    elsif qs.started?
      case npc.id
      when GABRIELLE
        if memo_state >= 20000 && memo_state < 30000
          html = "30753-06.html"
        elsif memo_state == 30000
          html = "30753-08.html"
        elsif memo_state >= 40000 && memo_state < 50000
          html = "30753-10.html"
        elsif memo_state == 50000
          take_items(pc, FEATHER_OF_GABRIELLE, -1)
          take_items(pc, MARK_OF_WATCHMAN, -1)
          give_items(pc, HERALD_OF_SLAYER, 1)
          qs.memo_state = 60000
          qs.set_cond(3, true)
          html = "30753-11.html"
        elsif memo_state == 60000
          html = "30753-12.html"
        elsif memo_state == 70000
          html = "30753-13.html"
        end
      when WAREHOUSE_CHIEF_MOKE
        if memo_state == 40000 || memo_state == 40001
          if has_quest_items?(pc, FRAGMENT_OF_ABYSS_JEWEL_1ST, MARA_FANG)
            take_items(pc, FRAGMENT_OF_ABYSS_JEWEL_1ST, -1)
            take_items(pc, MARA_FANG, -1)
            give_items(pc, MARK_OF_WATCHMAN, 1)
            if qs.memo_state == 40001
              qs.memo_state = 50000
            else
              qs.memo_state = 40010
            end
            html = "30498-03.html"
          else
            html = "30498-01.html"
          end
        elsif memo_state == 40010
          html = "30498-04.html"
        elsif memo_state >= 50000
          html = "30498-05.html"
        end
      when BLACKSMITH_HELTON
        if memo_state == 40000 || memo_state == 40010
          if has_quest_items?(pc, FRAGMENT_OF_ABYSS_JEWEL_2ND, MUSFEL_FANG)
            take_items(pc, FRAGMENT_OF_ABYSS_JEWEL_2ND, -1)
            take_items(pc, MUSFEL_FANG, -1)
            give_items(pc, MARK_OF_WATCHMAN, 1)
            if qs.memo_state == 40010
              qs.memo_state = 50000
            else
              qs.memo_state = 40001
            end
            html = "30678-02.html"
          else
            html = "30678-01.html"
          end
        elsif memo_state == 40001
          html = "30678-03.html"
        elsif memo_state >= 50000
          html = "30678-04.html"
        end
      when PREFECT_CHAKIRIS
        case qs.memo_state
        when 21101, 21000, 21100, 21001, 20101, 20100, 20001, 20000
          if has_quest_items?(pc, KRANROT_SKIN, HAMRUT_LEG)
            take_items(pc, KRANROT_SKIN, -1)
            take_items(pc, HAMRUT_LEG, -1)
            give_items(pc, MARK_OF_WATCHMAN, 1)
            if qs.memo_state + 10 == 21111
              qs.memo_state = 30000
            else
              qs.memo_state += 10
            end
            html = "30705-02.html"
          else
            html = "30705-01.html"
          end
        when 21110, 21011, 21010, 20111, 20110, 20011, 20010
          html = "30705-03.html"
        end

        if memo_state >= 30000
          html = "30705-04.html"
        end
      when MAGISTER_KAIENA
        case qs.memo_state
        when 20111, 20110, 20101, 20100, 20010, 20011, 20001, 20000
          if has_quest_items?(pc, MARSH_STALKER_HORN, MARSH_DRAKE_TALONS)
            take_items(pc, MARSH_STALKER_HORN, -1)
            take_items(pc, MARSH_DRAKE_TALONS, -1)
            give_items(pc, MARK_OF_WATCHMAN, 1)
            if qs.memo_state + 1000 == 21111
              qs.memo_state = 30000
            else
              qs.memo_state += 1000
            end
            html = "30720-02.html"
          else
            html = "30720-01.html"
          end
        when 21110, 21101, 21100, 21011, 21010, 21001, 21000
          html = "30720-03.html"
        end

        if memo_state >= 30000
          html = "30720-04.html"
        end
      when ANTHARAS_WATCHMAN_GILMORE
        if memo_state < 60000
          html = "30754-01.html"
        elsif memo_state == 60000
          html = "30754-02.html"
        elsif memo_state == 70000
          if has_quest_items?(pc, FRAGMENT_OF_ABYSS_JEWEL_3RD)
            html = "30754-05.html"
          else
            html = "30754-04.html"
          end
        end
      when ANTHARAS_WATCHMAN_THEODRIC
        if memo_state < 60000
          html = "30755-01.html"
        elsif memo_state == 60000
          html = "30755-02.html"
        elsif memo_state == 70000
          if !has_quest_items?(pc, FRAGMENT_OF_ABYSS_JEWEL_3RD)
            html = "30755-03.html"
          else
            html = "30755-04.html"
          end
        end
      when MASTER_KENDRA
        case qs.memo_state
        when 21110, 21100, 21010, 21000, 20110, 20100, 20010, 20000
          if !has_quest_items?(pc, TOTEM_OF_LAND_DRAGON)
            html = "30851-01.html"
          else
            take_items(pc, TOTEM_OF_LAND_DRAGON, -1)
            give_items(pc, MARK_OF_WATCHMAN, 1)
            if qs.memo_state + 1 == 21111
              qs.memo_state = 30000
            else
              qs.memo_state += 1
            end
            html = "30851-02.html"
          end
        when 21101, 21011, 21001, 20111, 20101, 20011, 20001
          html = "30851-03.html"
        end

        if memo_state >= 30000
          html = "30851-04.html"
        end
      when HIGH_PRIEST_ORVEN
        case qs.memo_state
        when 21011, 21010, 21001, 21000, 20011, 20010, 20001, 20000
          if !has_quest_items?(pc, REMAINS_OF_SACRAFICE)
            html = "30857-01.html"
          else
            take_items(pc, REMAINS_OF_SACRAFICE, -1)
            give_items(pc, MARK_OF_WATCHMAN, 1)
            if qs.memo_state + 100 == 21111
              qs.memo_state = 30000
            else
              qs.memo_state += 100
            end
            html = "30857-02.html"
          end
        when 21110, 21101, 21100, 20111, 20110, 20101, 20100
          html = "30857-03.html"
        end


        if memo_state >= 30000
          html = "30857-04.html"
        end
      end

    end

    html || get_no_quest_msg(pc)
  end
end
