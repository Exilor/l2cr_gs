class Scripts::Q00223_TestOfTheChampion < Quest
  # NPCs
  private TRADER_GROOT = 30093
  private CAPTAIN_MOUEN = 30196
  private VETERAN_ASCALON = 30624
  private MASON = 30625
  # Items
  private ASCALONS_1ST_LETTER = 3277
  private MASONS_LETTER = 3278
  private IRON_ROSE_RING = 3279
  private ASCALONS_2ND_LETTER = 3280
  private WHITE_ROSE_INSIGNIA = 3281
  private GROOTS_LETTER = 3282
  private ASCALONS_3RD_LETTER = 3283
  private MOUENS_1ST_ORDER = 3284
  private MOUENS_2ND_ORDER = 3285
  private MOUENS_LETTER = 3286
  private HARPYS_EGG = 3287
  private MEDUSA_VENOM = 3288
  private WINDSUS_BILE = 3289
  private BLOODY_AXE_HEAD = 3290
  private ROAD_RATMAN_HEAD = 3291
  private LETO_LIZARDMAN_FANG = 3292
  # Reward
  private MARK_OF_CHAMPION = 3276
  private DIMENSIONAL_DIAMOND = 7562
  # Monster
  private HARPY = 20145
  private MEDUSA = 20158
  private ROAD_SCAVENGER = 20551
  private WINDSUS = 20553
  private LETO_LIZARDMAN = 20577
  private LETO_LIZARDMAN_ARCHER = 20578
  private LETO_LIZARDMAN_SOLDIER = 20579
  private LETO_LIZARDMAN_WARRIOR = 20580
  private LETO_LIZARDMAN_SHAMAN = 20581
  private LETO_LIZARDMAN_OCERLORD = 20582
  private BLOODY_AXE_ELITE = 20780
  # Quest Monster
  private HARPY_MATRIARCH = 27088
  private ROAD_COLLECTOR = 27089
  # Misc
  private MIN_LEVEL = 39

  def initialize
    super(223, self.class.simple_name, "Test Of The Champion")

    add_start_npc(VETERAN_ASCALON)
    add_talk_id(VETERAN_ASCALON, TRADER_GROOT, CAPTAIN_MOUEN, MASON)
    add_kill_id(
      HARPY, MEDUSA, WINDSUS, ROAD_SCAVENGER, LETO_LIZARDMAN,
      LETO_LIZARDMAN_ARCHER, LETO_LIZARDMAN_SOLDIER, LETO_LIZARDMAN_WARRIOR,
      LETO_LIZARDMAN_SHAMAN, LETO_LIZARDMAN_OCERLORD, BLOODY_AXE_ELITE,
      HARPY_MATRIARCH, ROAD_COLLECTOR
    )
    add_attack_id(HARPY, ROAD_SCAVENGER, BLOODY_AXE_ELITE)
    register_quest_items(
      ASCALONS_1ST_LETTER, MASONS_LETTER, IRON_ROSE_RING, ASCALONS_2ND_LETTER,
      WHITE_ROSE_INSIGNIA, GROOTS_LETTER, ASCALONS_3RD_LETTER, MOUENS_1ST_ORDER,
      MOUENS_2ND_ORDER, MOUENS_LETTER, HARPYS_EGG, MEDUSA_VENOM, WINDSUS_BILE,
      BLOODY_AXE_HEAD, ROAD_RATMAN_HEAD, LETO_LIZARDMAN_FANG
    )
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    return unless qs = get_quest_state(pc, false)

    case event
    when "ACCEPT"
      if qs.created?
        qs.start_quest
        play_sound(pc, Sound::ITEMSOUND_QUEST_MIDDLE)
        give_items(pc, ASCALONS_1ST_LETTER, 1)
        if pc.variables.get_i32("2ND_CLASS_DIAMOND_REWARD", 0) == 0
          if pc.class_id.warrior?
            give_items(pc, DIMENSIONAL_DIAMOND, 72)
          else
            give_items(pc, DIMENSIONAL_DIAMOND, 64)
          end
          pc.variables["2ND_CLASS_DIAMOND_REWARD"] = 1
          html = "30624-06a.htm"
        else
          html = "30624-06.htm"
        end
      end
    when "30624-05.htm", "30196-02.html", "30625-02.html"
      html = event
    when "30624-10.html"
      if has_quest_items?(pc, MASONS_LETTER)
        take_items(pc, MASONS_LETTER, 1)
        give_items(pc, ASCALONS_2ND_LETTER, 1)
        qs.set_cond(5, true)
        html = event
      end
    when "30624-14.html"
      if has_quest_items?(pc, GROOTS_LETTER)
        take_items(pc, GROOTS_LETTER, 1)
        give_items(pc, ASCALONS_3RD_LETTER, 1)
        qs.set_cond(9, true)
        html = event
      end
    when "30093-02.html"
      if has_quest_items?(pc, ASCALONS_2ND_LETTER)
        take_items(pc, ASCALONS_2ND_LETTER, 1)
        give_items(pc, WHITE_ROSE_INSIGNIA, 1)
        qs.set_cond(6, true)
        html = event
      end
    when "30196-03.html"
      if has_quest_items?(pc, ASCALONS_3RD_LETTER)
        take_items(pc, ASCALONS_3RD_LETTER, 1)
        give_items(pc, MOUENS_1ST_ORDER, 1)
        qs.set_cond(10, true)
        html = event
      end
    when "30196-06.html"
      if get_quest_items_count(pc, ROAD_RATMAN_HEAD) >= 10
        take_items(pc, MOUENS_1ST_ORDER, 1)
        give_items(pc, MOUENS_2ND_ORDER, 1)
        take_items(pc, ROAD_RATMAN_HEAD, -1)
        qs.set_cond(12, true)
        html = event
      end
    when "30625-03.html"
      if has_quest_items?(pc, ASCALONS_1ST_LETTER)
        take_items(pc, ASCALONS_1ST_LETTER, 1)
        give_items(pc, IRON_ROSE_RING, 1)
        qs.set_cond(2, true)
        html = event
      end
    else
      # [automatically added else]
    end


    html
  end

  def on_attack(npc, attacker, damage, is_summon)
    qs = get_quest_state(attacker, false)
    if qs && qs.started?
      case npc.id
      when HARPY
        case npc.script_value
        when 0
          npc.variables["lastAttacker"] = attacker.l2id
          if has_quest_items?(attacker, WHITE_ROSE_INSIGNIA) && get_quest_items_count(attacker, HARPYS_EGG) < 30
            if Rnd.bool
              if Rnd.rand(10) < 7
                add_attack_desire(add_spawn(HARPY_MATRIARCH, npc, true, 0, false), attacker)
              else
                add_attack_desire(add_spawn(HARPY_MATRIARCH, npc, true, 0, false), attacker)
                add_attack_desire(add_spawn(HARPY_MATRIARCH, npc, true, 0, false), attacker)
              end
            end
          end
          npc.script_value = 1
        when 1
          npc.script_value = 2
        else
          # [automatically added else]
        end

      when ROAD_SCAVENGER
        case npc.script_value
        when 0
          npc.variables["lastAttacker"] = attacker.l2id
          if has_quest_items?(attacker, MOUENS_1ST_ORDER) && get_quest_items_count(attacker, ROAD_RATMAN_HEAD) < 10
            if Rnd.bool
              if Rnd.rand(10) < 7
                add_attack_desire(add_spawn(ROAD_COLLECTOR, npc, true, 0, false), attacker)
              else
                add_attack_desire(add_spawn(ROAD_COLLECTOR, npc, true, 0, false), attacker)
                add_attack_desire(add_spawn(ROAD_COLLECTOR, npc, true, 0, false), attacker)
              end
            end
          end
          npc.script_value = 1
        when 1
          npc.script_value = 2
        else
          # [automatically added else]
        end

      when BLOODY_AXE_ELITE
        case npc.script_value
        when 0
          npc.variables["lastAttacker"] = attacker.l2id
          if has_quest_items?(attacker, IRON_ROSE_RING) && get_quest_items_count(attacker, BLOODY_AXE_HEAD) < 10
            if Rnd.bool
              add_attack_desire(add_spawn(BLOODY_AXE_ELITE, npc, true, 0, false), attacker)
            end
          end
          npc.script_value = 1
        when 1
          npc.script_value = 2
        else
          # [automatically added else]
        end

      else
        # [automatically added else]
      end

    end

    super
  end

  def on_kill(npc, killer, is_summon)
    qs = get_quest_state(killer, false)
    if qs && qs.started? && Util.in_range?(1500, npc, killer, true)
      case npc.id
      when HARPY, HARPY_MATRIARCH
        if has_quest_items?(killer, WHITE_ROSE_INSIGNIA) && get_quest_items_count(killer, HARPYS_EGG) < 30
          if get_quest_items_count(killer, HARPYS_EGG) >= 28
            give_items(killer, HARPYS_EGG, 2)
            play_sound(killer, Sound::ITEMSOUND_QUEST_MIDDLE)
            if get_quest_items_count(killer, MEDUSA_VENOM) >= 30 && get_quest_items_count(killer, WINDSUS_BILE) >= 30
              qs.set_cond(7)
            end
          else
            give_items(killer, HARPYS_EGG, 2)
            play_sound(killer, Sound::ITEMSOUND_QUEST_ITEMGET)
          end
        end
      when MEDUSA
        if has_quest_items?(killer, WHITE_ROSE_INSIGNIA) && get_quest_items_count(killer, MEDUSA_VENOM) < 30
          if get_quest_items_count(killer, MEDUSA_VENOM) >= 27
            give_items(killer, MEDUSA_VENOM, 3)
            play_sound(killer, Sound::ITEMSOUND_QUEST_MIDDLE)
            if get_quest_items_count(killer, HARPYS_EGG) >= 30 && get_quest_items_count(killer, WINDSUS_BILE) >= 30
              qs.set_cond(7)
            end
          else
            give_items(killer, MEDUSA_VENOM, 3)
            play_sound(killer, Sound::ITEMSOUND_QUEST_ITEMGET)
          end
        end
      when WINDSUS
        if has_quest_items?(killer, WHITE_ROSE_INSIGNIA) && get_quest_items_count(killer, WINDSUS_BILE) < 30
          if get_quest_items_count(killer, WINDSUS_BILE) >= 27
            give_items(killer, WINDSUS_BILE, 3)
            play_sound(killer, Sound::ITEMSOUND_QUEST_MIDDLE)
            if get_quest_items_count(killer, HARPYS_EGG) >= 30 && get_quest_items_count(killer, MEDUSA_VENOM) >= 30
              qs.set_cond(7)
            end
          else
            give_items(killer, WINDSUS_BILE, 3)
            play_sound(killer, Sound::ITEMSOUND_QUEST_ITEMGET)
          end
        end
      when ROAD_SCAVENGER, ROAD_COLLECTOR
        if has_quest_items?(killer, MOUENS_1ST_ORDER) && get_quest_items_count(killer, ROAD_RATMAN_HEAD) < 10
          if get_quest_items_count(killer, ROAD_RATMAN_HEAD) >= 9
            give_items(killer, ROAD_RATMAN_HEAD, 1)
            qs.set_cond(11, true)
          else
            give_items(killer, ROAD_RATMAN_HEAD, 1)
            play_sound(killer, Sound::ITEMSOUND_QUEST_ITEMGET)
          end
        end
      when LETO_LIZARDMAN, LETO_LIZARDMAN_ARCHER, LETO_LIZARDMAN_SOLDIER, LETO_LIZARDMAN_WARRIOR, LETO_LIZARDMAN_SHAMAN, LETO_LIZARDMAN_OCERLORD
        if has_quest_items?(killer, MOUENS_2ND_ORDER) && get_quest_items_count(killer, LETO_LIZARDMAN_FANG) < 10
          if get_quest_items_count(killer, LETO_LIZARDMAN_FANG) >= 9
            give_items(killer, LETO_LIZARDMAN_FANG, 1)
            qs.set_cond(13, true)
          else
            give_items(killer, LETO_LIZARDMAN_FANG, 1)
            play_sound(killer, Sound::ITEMSOUND_QUEST_ITEMGET)
          end
        end
      when BLOODY_AXE_ELITE
        if has_quest_items?(killer, IRON_ROSE_RING) && get_quest_items_count(killer, BLOODY_AXE_HEAD) < 10
          if get_quest_items_count(killer, BLOODY_AXE_HEAD) >= 9
            give_items(killer, BLOODY_AXE_HEAD, 1)
            qs.set_cond(3, true)
          else
            give_items(killer, BLOODY_AXE_HEAD, 1)
            play_sound(killer, Sound::ITEMSOUND_QUEST_ITEMGET)
          end
        end
      else
        # [automatically added else]
      end

    end

    super
  end

  def on_talk(npc, pc)
    qs = get_quest_state!(pc)

    if qs.created?
      if npc.id == VETERAN_ASCALON
        if pc.class_id.warrior? || pc.class_id.orc_raider?
          if pc.level >= MIN_LEVEL
            if pc.class_id.warrior?
              html = "30624-03.htm"
            else
              html = "30624-04.html"
            end
          else
            html = "30624-01.html"
          end
        else
          html = "30624-02.html"
        end
      end
    elsif qs.started?
      case npc.id
      when VETERAN_ASCALON
        if has_quest_items?(pc, ASCALONS_1ST_LETTER)
          html = "30624-07.html"
        elsif has_quest_items?(pc, IRON_ROSE_RING)
          html = "30624-08.html"
        elsif has_quest_items?(pc, MASONS_LETTER)
          html = "30624-09.html"
        elsif has_quest_items?(pc, ASCALONS_2ND_LETTER)
          html = "30624-11.html"
        elsif has_quest_items?(pc, WHITE_ROSE_INSIGNIA)
          html = "30624-12.html"
        elsif has_quest_items?(pc, GROOTS_LETTER)
          html = "30624-13.html"
        elsif has_quest_items?(pc, ASCALONS_3RD_LETTER)
          html = "30624-15.html"
        elsif has_at_least_one_quest_item?(pc, MOUENS_1ST_ORDER, MOUENS_2ND_ORDER)
          html = "30624-16.html"
        elsif has_quest_items?(pc, MOUENS_LETTER)
          give_adena(pc, 229764, true)
          give_items(pc, MARK_OF_CHAMPION, 1)
          add_exp_and_sp(pc, 1270742, 87200)
          qs.exit_quest(false, true)
          pc.send_packet(SocialAction.new(pc.l2id, 3))
          html = "30624-17.html"
        end
      when TRADER_GROOT
        if has_quest_items?(pc, ASCALONS_2ND_LETTER)
          html = "30093-01.html"
        elsif has_quest_items?(pc, WHITE_ROSE_INSIGNIA)
          if get_quest_items_count(pc, HARPYS_EGG) >= 30 && get_quest_items_count(pc, MEDUSA_VENOM) >= 30 && get_quest_items_count(pc, WINDSUS_BILE) >= 30
            take_items(pc, WHITE_ROSE_INSIGNIA, 1)
            give_items(pc, GROOTS_LETTER, 1)
            take_items(pc, HARPYS_EGG, -1)
            take_items(pc, MEDUSA_VENOM, -1)
            take_items(pc, WINDSUS_BILE, -1)
            qs.set_cond(8, true)
            html = "30093-04.html"
          else
            html = "30093-03.html"
          end
        elsif has_quest_items?(pc, GROOTS_LETTER)
          html = "30093-05.html"
        elsif has_at_least_one_quest_item?(pc, ASCALONS_3RD_LETTER, MOUENS_1ST_ORDER, MOUENS_2ND_ORDER, MOUENS_LETTER)
          html = "30093-06.html"
        end
      when CAPTAIN_MOUEN
        if has_quest_items?(pc, ASCALONS_3RD_LETTER)
          html = "30196-01.html"
        elsif has_quest_items?(pc, MOUENS_1ST_ORDER)
          if get_quest_items_count(pc, ROAD_RATMAN_HEAD) < 10
            html = "30196-04.html"
          else
            html = "30196-05.html"
          end
        elsif has_quest_items?(pc, MOUENS_2ND_ORDER)
          if get_quest_items_count(pc, LETO_LIZARDMAN_FANG) < 10
            html = "30196-07.html"
          else
            take_items(pc, MOUENS_2ND_ORDER, 1)
            give_items(pc, MOUENS_LETTER, 1)
            take_items(pc, LETO_LIZARDMAN_FANG, -1)
            qs.set_cond(14, true)
            html = "30196-08.html"
          end
        elsif has_quest_items?(pc, MOUENS_LETTER)
          html = "30196-09.html"
        end
      when MASON
        if has_quest_items?(pc, ASCALONS_1ST_LETTER)
          html = "30625-01.html"
        elsif has_quest_items?(pc, IRON_ROSE_RING)
          if get_quest_items_count(pc, BLOODY_AXE_HEAD) < 10
            html = "30625-04.html"
          else
            give_items(pc, MASONS_LETTER, 1)
            take_items(pc, IRON_ROSE_RING, 1)
            take_items(pc, BLOODY_AXE_HEAD, -1)
            qs.set_cond(4, true)
            html = "30625-05.html"
          end
        elsif has_quest_items?(pc, MASONS_LETTER)
          html = "30625-06.html"
        elsif has_at_least_one_quest_item?(pc, ASCALONS_2ND_LETTER, WHITE_ROSE_INSIGNIA, GROOTS_LETTER, ASCALONS_3RD_LETTER, MOUENS_1ST_ORDER, MOUENS_2ND_ORDER, MOUENS_LETTER)
          html = "30625-07.html"
        end
      else
        # [automatically added else]
      end

    elsif qs.completed?
      if npc.id == VETERAN_ASCALON
        html = get_already_completed_msg(pc)
      end
    end

    html || get_no_quest_msg(pc)
  end
end
