class Scripts::Q00231_TestOfTheMaestro < Quest
  # NPCs
  private IRON_GATES_LOCKIRIN = 30531
  private GOLDEN_WHEELS_SPIRON = 30532
  private SILVER_SCALES_BALANKI = 30533
  private BRONZE_KEYS_KEEF = 30534
  private GRAY_PILLAR_MEMBER_FILAUR = 30535
  private BLACK_ANVILS_ARIN = 30536
  private MASTER_TOMA = 30556
  private CHIEF_CROTO = 30671
  private JAILER_DUBABAH = 30672
  private RESEARCHER_LORAIN = 30673
  # Items
  private RECOMMENDATION_OF_BALANKI = 2864
  private RECOMMENDATION_OF_FILAUR = 2865
  private RECOMMENDATION_OF_ARIN = 2866
  private LETTER_OF_SOLDER_DERACHMENT = 2868
  private PAINT_OF_KAMURU = 2869
  private NECKLACE_OF_KAMUTU = 2870
  private PAINT_OF_TELEPORT_DEVICE = 2871
  private TELEPORT_DEVICE = 2872
  private ARCHITECTURE_OF_CRUMA = 2873
  private REPORT_OF_CRUMA = 2874
  private INGREDIENTS_OF_ANTIDOTE = 2875
  private STINGER_WASP_NEEDLE = 2876
  private MARSH_SPIDERS_WEB = 2877
  private BLOOD_OF_LEECH = 2878
  private BROKEN_TELEPORT_DEVICE = 2916
  # Reward
  private MARK_OF_MAESTRO = 2867
  private DIMENSIONAL_DIAMOND = 7562
  # Monster
  private KING_BUGBEAR = 20150
  private GIANT_MIST_LEECH = 20225
  private STINGER_WASP = 20229
  private MARSH_SPIDER = 20233
  # Quest Monster
  private EVIL_EYE_LORD = 27133
  # Misc
  private MIN_LEVEL = 39

  def initialize
    super(231, self.class.simple_name, "Test Of The Maestro")

    add_start_npc(IRON_GATES_LOCKIRIN)
    add_talk_id(
      IRON_GATES_LOCKIRIN, GOLDEN_WHEELS_SPIRON, SILVER_SCALES_BALANKI,
      BRONZE_KEYS_KEEF, GRAY_PILLAR_MEMBER_FILAUR, BLACK_ANVILS_ARIN,
      MASTER_TOMA, CHIEF_CROTO, JAILER_DUBABAH, RESEARCHER_LORAIN
    )
    add_kill_id(
      KING_BUGBEAR, GIANT_MIST_LEECH, STINGER_WASP, MARSH_SPIDER, EVIL_EYE_LORD
    )
    register_quest_items(
      RECOMMENDATION_OF_BALANKI, RECOMMENDATION_OF_FILAUR,
      RECOMMENDATION_OF_ARIN, LETTER_OF_SOLDER_DERACHMENT, PAINT_OF_KAMURU,
      NECKLACE_OF_KAMUTU, PAINT_OF_TELEPORT_DEVICE, TELEPORT_DEVICE,
      ARCHITECTURE_OF_CRUMA, REPORT_OF_CRUMA, INGREDIENTS_OF_ANTIDOTE,
      STINGER_WASP_NEEDLE, MARSH_SPIDERS_WEB, BLOOD_OF_LEECH,
      BROKEN_TELEPORT_DEVICE
    )
  end

  def on_adv_event(event, npc, pc)
    return unless pc && (qs = get_quest_state(pc, false))

    case event
    when "ACCEPT"
      if qs.created?
        qs.start_quest
        qs.memo_state = 1
        play_sound(pc, Sound::ITEMSOUND_QUEST_MIDDLE)
        if pc.variables.get_i32("2ND_CLASS_DIAMOND_REWARD", 0) == 0
          give_items(pc, DIMENSIONAL_DIAMOND, 23)
          pc.variables["2ND_CLASS_DIAMOND_REWARD"] = 1
          html = "30531-04a.htm"
        else
          html = "30531-04.htm"
        end
      end
    when "30533-02.html"
      qs.memo_state = 2
      html = event
    when "30556-02.html", "30556-03.html", "30556-04.html"
      html = event
    when "30556-05.html"
      if has_quest_items?(pc, PAINT_OF_TELEPORT_DEVICE)
        give_items(pc, BROKEN_TELEPORT_DEVICE, 1)
        take_items(pc, PAINT_OF_TELEPORT_DEVICE, 1)
        pc.tele_to_location(140352, -194133, -3146)
        start_quest_timer("SPAWN_KING_BUGBEAR", 5000, npc, pc)
        html = event
      end
    when "30671-02.html"
      give_items(pc, PAINT_OF_KAMURU, 1)
      html = event
    when "30673-04.html"
      if has_quest_items?(pc, INGREDIENTS_OF_ANTIDOTE)
        if get_quest_items_count(pc, STINGER_WASP_NEEDLE) >= 10
          if get_quest_items_count(pc, MARSH_SPIDERS_WEB) >= 10
            if get_quest_items_count(pc, BLOOD_OF_LEECH) >= 10
              give_items(pc, REPORT_OF_CRUMA, 1)
              take_items(pc, STINGER_WASP_NEEDLE, -1)
              take_items(pc, MARSH_SPIDERS_WEB, -1)
              take_items(pc, BLOOD_OF_LEECH, -1)
              take_items(pc, INGREDIENTS_OF_ANTIDOTE, 1)
              html = event
            end
          end
        end
      end
    when "SPAWN_KING_BUGBEAR"
      add_attack_desire(add_spawn(KING_BUGBEAR, 140395, -194147, -3146, 0, false, 200000, false), pc)
      add_attack_desire(add_spawn(KING_BUGBEAR, 140395, -194147, -3146, 0, false, 200000, false), pc)
      add_attack_desire(add_spawn(KING_BUGBEAR, 140395, -194147, -3146, 0, false, 200000, false), pc)
    end

    html
  end

  def on_kill(npc, killer, is_summon)
    qs = get_quest_state(killer, false)
    if qs && qs.started? && Util.in_range?(1500, npc, killer, true)
      case npc.id
      when GIANT_MIST_LEECH
        if qs.memo_state?(4) && has_quest_items?(killer, INGREDIENTS_OF_ANTIDOTE)
          if get_quest_items_count(killer, BLOOD_OF_LEECH) < 10
            give_items(killer, BLOOD_OF_LEECH, 1)
            if get_quest_items_count(killer, BLOOD_OF_LEECH) >= 10
              play_sound(killer, Sound::ITEMSOUND_QUEST_MIDDLE)
            else
              play_sound(killer, Sound::ITEMSOUND_QUEST_ITEMGET)
            end
          end
        end
      when STINGER_WASP
        if qs.memo_state?(4) && has_quest_items?(killer, INGREDIENTS_OF_ANTIDOTE)
          if get_quest_items_count(killer, STINGER_WASP_NEEDLE) < 10
            give_items(killer, STINGER_WASP_NEEDLE, 1)
            if get_quest_items_count(killer, STINGER_WASP_NEEDLE) >= 10
              play_sound(killer, Sound::ITEMSOUND_QUEST_MIDDLE)
            else
              play_sound(killer, Sound::ITEMSOUND_QUEST_ITEMGET)
            end
          end
        end
      when MARSH_SPIDER
        if qs.memo_state?(4) && has_quest_items?(killer, INGREDIENTS_OF_ANTIDOTE)
          if get_quest_items_count(killer, MARSH_SPIDERS_WEB) < 10
            give_items(killer, MARSH_SPIDERS_WEB, 1)
            if get_quest_items_count(killer, MARSH_SPIDERS_WEB) >= 10
              play_sound(killer, Sound::ITEMSOUND_QUEST_MIDDLE)
            else
              play_sound(killer, Sound::ITEMSOUND_QUEST_ITEMGET)
            end
          end
        end
      when EVIL_EYE_LORD
        if qs.memo_state?(2) && has_quest_items?(killer, PAINT_OF_KAMURU)
          unless has_quest_items?(killer, NECKLACE_OF_KAMUTU)
            give_items(killer, NECKLACE_OF_KAMUTU, 1)
            play_sound(killer, Sound::ITEMSOUND_QUEST_MIDDLE)
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
      if npc.id == IRON_GATES_LOCKIRIN
        if pc.class_id.artisan?
          if pc.level >= MIN_LEVEL
            html = "30531-03.htm"
          else
            html = "30531-01.html"
          end
        else
          html = "30531-02.html"
        end
      end
    elsif qs.started?
      case npc.id
      when IRON_GATES_LOCKIRIN
        if memo_state >= 1 && !has_quest_items?(pc, RECOMMENDATION_OF_BALANKI, RECOMMENDATION_OF_FILAUR, RECOMMENDATION_OF_ARIN)
          html = "30531-05.html"
        elsif has_quest_items?(pc, RECOMMENDATION_OF_BALANKI, RECOMMENDATION_OF_FILAUR, RECOMMENDATION_OF_ARIN)
          give_adena(pc, 372_154, true)
          give_items(pc, MARK_OF_MAESTRO, 1)
          add_exp_and_sp(pc, 2_085_244, 141_240)
          qs.exit_quest(false, true)
          pc.send_packet(SocialAction.new(pc.l2id, 3))
          html = "30531-06.html"
        end
      when GOLDEN_WHEELS_SPIRON
        html = "30532-01.html"
      when SILVER_SCALES_BALANKI
        if memo_state == 1 && !has_quest_items?(pc, RECOMMENDATION_OF_BALANKI)
          html = "30533-01.html"
        elsif memo_state == 2
          if !has_quest_items?(pc, LETTER_OF_SOLDER_DERACHMENT)
            html = "30533-03.html"
          else
            give_items(pc, RECOMMENDATION_OF_BALANKI, 1)
            take_items(pc, LETTER_OF_SOLDER_DERACHMENT, 1)
            qs.memo_state = 1
            if has_quest_items?(pc, RECOMMENDATION_OF_ARIN, RECOMMENDATION_OF_FILAUR)
              qs.set_cond(2, true)
            end
            html = "30533-04.html"
          end
        elsif has_quest_items?(pc, RECOMMENDATION_OF_BALANKI)
          html = "30533-05.html"
        end
      when BRONZE_KEYS_KEEF
        html = "30534-01.html"
      when GRAY_PILLAR_MEMBER_FILAUR
        if memo_state == 1 && !has_quest_items?(pc, RECOMMENDATION_OF_FILAUR)
          give_items(pc, ARCHITECTURE_OF_CRUMA, 1)
          qs.memo_state = 4
          html = "30535-01.html"
        elsif memo_state == 4
          if has_quest_items?(pc, ARCHITECTURE_OF_CRUMA) && !has_quest_items?(pc, REPORT_OF_CRUMA)
            html = "30535-02.html"
          elsif has_quest_items?(pc, REPORT_OF_CRUMA) && !has_quest_items?(pc, ARCHITECTURE_OF_CRUMA)
            give_items(pc, RECOMMENDATION_OF_FILAUR, 1)
            take_items(pc, REPORT_OF_CRUMA, 1)
            qs.memo_state = 1
            if has_quest_items?(pc, RECOMMENDATION_OF_BALANKI, RECOMMENDATION_OF_ARIN)
              qs.set_cond(2, true)
            end
            html = "30535-03.html"
          end
        elsif has_quest_items?(pc, RECOMMENDATION_OF_FILAUR)
          html = "30535-04.html"
        end
      when BLACK_ANVILS_ARIN
        if memo_state == 1 && !has_quest_items?(pc, RECOMMENDATION_OF_ARIN)
          give_items(pc, PAINT_OF_TELEPORT_DEVICE, 1)
          qs.memo_state = 3
          html = "30536-01.html"
        elsif memo_state == 3
          if has_quest_items?(pc, PAINT_OF_TELEPORT_DEVICE) && !has_quest_items?(pc, TELEPORT_DEVICE)
            html = "30536-02.html"
          elsif get_quest_items_count(pc, TELEPORT_DEVICE) >= 5
            give_items(pc, RECOMMENDATION_OF_ARIN, 1)
            take_items(pc, TELEPORT_DEVICE, -1)
            qs.memo_state = 1
            if has_quest_items?(pc, RECOMMENDATION_OF_BALANKI, RECOMMENDATION_OF_FILAUR)
              qs.set_cond(2, true)
            end
            html = "30536-03.html"
          end
        elsif has_quest_items?(pc, RECOMMENDATION_OF_ARIN)
          html = "30536-04.html"
        end
      when MASTER_TOMA
        if memo_state == 3
          if has_quest_items?(pc, PAINT_OF_TELEPORT_DEVICE)
            html = "30556-01.html"
          elsif has_quest_items?(pc, BROKEN_TELEPORT_DEVICE)
            give_items(pc, TELEPORT_DEVICE, 5)
            take_items(pc, BROKEN_TELEPORT_DEVICE, 1)
            html = "30556-06.html"
          elsif get_quest_items_count(pc, TELEPORT_DEVICE) == 5
            html = "30556-07.html"
          end
        end
      when CHIEF_CROTO
        if memo_state == 2 && !has_at_least_one_quest_item?(pc, PAINT_OF_KAMURU, NECKLACE_OF_KAMUTU, LETTER_OF_SOLDER_DERACHMENT)
          html = "30671-01.html"
        elsif has_quest_items?(pc, PAINT_OF_KAMURU) && !has_quest_items?(pc, NECKLACE_OF_KAMUTU)
          html = "30671-03.html"
        elsif has_quest_items?(pc, NECKLACE_OF_KAMUTU)
          give_items(pc, LETTER_OF_SOLDER_DERACHMENT, 1)
          take_items(pc, NECKLACE_OF_KAMUTU, 1)
          take_items(pc, PAINT_OF_KAMURU, 1)
          html = "30671-04.html"
        elsif has_quest_items?(pc, LETTER_OF_SOLDER_DERACHMENT)
          html = "30671-05.html"
        end
      when JAILER_DUBABAH
        if has_quest_items?(pc, PAINT_OF_KAMURU)
          html = "30672-01.html"
        end
      when RESEARCHER_LORAIN
        if memo_state == 4
          if has_quest_items?(pc, ARCHITECTURE_OF_CRUMA) && !has_at_least_one_quest_item?(pc, INGREDIENTS_OF_ANTIDOTE, REPORT_OF_CRUMA)
            give_items(pc, INGREDIENTS_OF_ANTIDOTE, 1)
            take_items(pc, ARCHITECTURE_OF_CRUMA, 1)
            html = "30673-01.html"
          elsif has_quest_items?(pc, INGREDIENTS_OF_ANTIDOTE) && !has_quest_items?(pc, REPORT_OF_CRUMA)
            if get_quest_items_count(pc, STINGER_WASP_NEEDLE) >= 10 && get_quest_items_count(pc, MARSH_SPIDERS_WEB) >= 10 && get_quest_items_count(pc, BLOOD_OF_LEECH) >= 10
              html = "30673-03.html"
            else
              html = "30673-02.html"
            end
          elsif has_quest_items?(pc, REPORT_OF_CRUMA)
            html = "30673-05.html"
          end
        end
      end
    elsif qs.completed?
      if npc.id == IRON_GATES_LOCKIRIN
        html = get_already_completed_msg(pc)
      end
    end

    html || get_no_quest_msg(pc)
  end
end
