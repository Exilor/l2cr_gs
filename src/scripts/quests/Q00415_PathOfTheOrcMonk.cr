class Scripts::Q00415_PathOfTheOrcMonk < Quest
  # NPCs
  private PREFECT_KASMAN = 30501
  private GANTAKI_ZU_URUTU = 30587
  private KHAVATARI_ROSHEEK = 30590
  private KHAVATARI_TORUKU = 30591
  private SEER_MOIRA = 31979
  private KHAVATARI_AREN = 32056
  # Items
  private POMEGRANATE = 1593
  private LEATHER_POUCH_1ST = 1594
  private LEATHER_POUCH_2ND = 1595
  private LEATHER_POUCH_3RD = 1596
  private LEATHER_POUCH_1ST_FULL = 1597
  private LEATHER_POUCH_2ND_FULL = 1598
  private LEATHER_POUCH_3RD_FULL = 1599
  private KASHA_BEAR_CLAW = 1600
  private KASHA_BLADE_SPIDER_TALON = 1601
  private SCARLET_SALAMANDER_SCALE = 1602
  private FIERY_SPIRIT_SCROLL = 1603
  private ROSHEEKS_LETTER = 1604
  private GANTAKIS_LETTRT_OF_RECOMMENDATION = 1605
  private FIG = 1606
  private LEATHER_POUCH_4TF = 1607
  private LEATHER_POUCH_4TF_FULL = 1608
  private VUKU_ORK_TUSK = 1609
  private RATMAN_FANG = 1610
  private LANGK_LIZARDMAN_TOOTH = 1611
  private FELIM_LIZARDMAN_TOOTH = 1612
  private IRON_WILL_SCROLL = 1613
  private TORUKUS_LETTER = 1614
  private KASHA_SPIDERS_TOOTH = 8545
  private HORN_OF_BAAR_DRE_VANUL = 8546
  # Reward
  private KHAVATARI_TOTEM = 1615
  # Monster
  private FELIM_LIZARDMAN_WARRIOR = 20014
  private VUKU_ORC_FIGHTER = 20017
  private LANGK_LIZZARDMAN_WARRIOR = 20024
  private RATMAN_WARRIOR = 20359
  private SCARLET_SALAMANDER = 20415
  private KASHA_FANG_SPIDER = 20476
  private KASHA_BLADE_SPIDER = 20478
  private KASHA_BEAR = 20479
  private BAAR_DRE_VANUL = 21118
  # Misc
  private MIN_LEVEL = 18

  def initialize
    super(415, self.class.simple_name, "Path Of The Orc Monk")

    add_start_npc(GANTAKI_ZU_URUTU)
    add_talk_id(
      GANTAKI_ZU_URUTU, PREFECT_KASMAN, KHAVATARI_ROSHEEK, KHAVATARI_TORUKU,
      SEER_MOIRA, KHAVATARI_AREN
    )
    add_attack_id(
      FELIM_LIZARDMAN_WARRIOR, VUKU_ORC_FIGHTER, LANGK_LIZZARDMAN_WARRIOR,
      RATMAN_WARRIOR, SCARLET_SALAMANDER, KASHA_FANG_SPIDER,
      KASHA_BLADE_SPIDER, KASHA_BEAR, BAAR_DRE_VANUL
    )
    add_kill_id(
      FELIM_LIZARDMAN_WARRIOR, VUKU_ORC_FIGHTER, LANGK_LIZZARDMAN_WARRIOR,
      RATMAN_WARRIOR, SCARLET_SALAMANDER, KASHA_FANG_SPIDER,
      KASHA_BLADE_SPIDER, KASHA_BEAR, BAAR_DRE_VANUL
    )
    register_quest_items(
      POMEGRANATE, LEATHER_POUCH_1ST, LEATHER_POUCH_2ND, LEATHER_POUCH_3RD,
      LEATHER_POUCH_1ST_FULL, LEATHER_POUCH_2ND_FULL, LEATHER_POUCH_3RD_FULL,
      KASHA_BEAR_CLAW, KASHA_BLADE_SPIDER_TALON, SCARLET_SALAMANDER_SCALE,
      FIERY_SPIRIT_SCROLL, ROSHEEKS_LETTER, GANTAKIS_LETTRT_OF_RECOMMENDATION,
      FIG, LEATHER_POUCH_4TF, LEATHER_POUCH_4TF_FULL, VUKU_ORK_TUSK,
      RATMAN_FANG, LANGK_LIZARDMAN_TOOTH, FELIM_LIZARDMAN_TOOTH,
      IRON_WILL_SCROLL, TORUKUS_LETTER, KASHA_SPIDERS_TOOTH,
      HORN_OF_BAAR_DRE_VANUL
    )
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    return unless qs = get_quest_state(pc, false)

    case event
    when "ACCEPT"
      if pc.class_id.orc_fighter?
        if pc.level >= MIN_LEVEL
          if has_quest_items?(pc, KHAVATARI_TOTEM)
            html = "30587-04.htm"
          else
            html = "30587-05.htm"
          end
        else
          html = "30587-03.htm"
        end
      elsif pc.class_id.orc_monk?
        html = "30587-02a.htm"
      else
        html = "30587-02.htm"
      end
    when "30587-06.htm"
      qs.start_quest
      give_items(pc, POMEGRANATE, 1)
      html = event
    when "30587-09b.html"
      if has_quest_items?(pc, FIERY_SPIRIT_SCROLL, ROSHEEKS_LETTER)
        take_items(pc, ROSHEEKS_LETTER, 1)
        give_items(pc, GANTAKIS_LETTRT_OF_RECOMMENDATION, 1)
        qs.set_cond(9)
        html = event
      end
    when "30587-09c.html"
      if has_quest_items?(pc, FIERY_SPIRIT_SCROLL, ROSHEEKS_LETTER)
        take_items(pc, ROSHEEKS_LETTER, 1)
        qs.memo_state = 2
        qs.set_cond(14)
        html = event
      end
    when "31979-02.html"
      if qs.memo_state?(5)
        html = event
      end
    when "31979-03.html"
      if qs.memo_state?(5)
        give_adena(pc, 81900, true)
        give_items(pc, KHAVATARI_TOTEM, 1)
        level = pc.level
        if level >= 20
          add_exp_and_sp(pc, 160267, 12646)
        elsif level == 19
          add_exp_and_sp(pc, 228064, 15995)
        else
          add_exp_and_sp(pc, 295862, 19344)
        end
        qs.exit_quest(false, true)
        pc.send_packet(SocialAction.new(pc.l2id, 3))
        qs.save_global_quest_var("1ClassQuestFinished", "1")
        html = event
      end
    when "31979-04.html"
      if qs.memo_state?(5)
        qs.set_cond(20)
        html = event
      end
    when "32056-02.html"
      if qs.memo_state?(2)
        html = event
      end
    when "32056-03.html"
      if qs.memo_state?(2)
        qs.memo_state = 3
        qs.set_cond(15)
        html = event
      end
    when "32056-08.html"
      if qs.memo_state?(4) && get_quest_items_count(pc, HORN_OF_BAAR_DRE_VANUL) >= 1
        take_items(pc, HORN_OF_BAAR_DRE_VANUL, -1)
        qs.memo_state = 5
        qs.set_cond(19)
        html = event
      end
    end


    html
  end

  def on_attack(npc, attacker, damage, is_summon)
    qs = get_quest_state(attacker, false)
    if qs && qs.started?
      case npc.script_value
      when 0
        if !check_weapon(attacker)
          npc.script_value = 2
        else
          npc.script_value = 1
          npc.variables["Q00415_last_attacker"] = attacker.l2id
        end
      when 1
        if (npc.variables.get_i32("Q00415_last_attacker") != attacker.l2id) || !check_weapon(attacker)
          npc.script_value = 2
        end
      end

    end

    super
  end

  def on_kill(npc, killer, is_summon)
    qs = get_quest_state(killer, false)
    if qs && qs.started? && npc.script_value?(1) && Util.in_range?(1500, npc, killer, true)
      item_count = get_quest_items_count(killer, RATMAN_FANG, LANGK_LIZARDMAN_TOOTH, FELIM_LIZARDMAN_TOOTH, VUKU_ORK_TUSK)
      case npc.id
      when FELIM_LIZARDMAN_WARRIOR
        if has_quest_items?(killer, LEATHER_POUCH_4TF) && get_quest_items_count(killer, FELIM_LIZARDMAN_TOOTH) < 3
          if item_count >= 11
            take_items(killer, LEATHER_POUCH_4TF, 1)
            give_items(killer, LEATHER_POUCH_4TF_FULL, 1)
            take_items(killer, VUKU_ORK_TUSK, -1)
            take_items(killer, RATMAN_FANG, -1)
            take_items(killer, LANGK_LIZARDMAN_TOOTH, -1)
            take_items(killer, FELIM_LIZARDMAN_TOOTH, -1)
            qs.set_cond(12, true)
          else
            give_items(killer, FELIM_LIZARDMAN_TOOTH, 1)
            play_sound(killer, Sound::ITEMSOUND_QUEST_ITEMGET)
          end
        end
      when VUKU_ORC_FIGHTER
        if has_quest_items?(killer, LEATHER_POUCH_4TF) && get_quest_items_count(killer, VUKU_ORK_TUSK) < 3
          if item_count >= 11
            take_items(killer, LEATHER_POUCH_4TF, 1)
            give_items(killer, LEATHER_POUCH_4TF_FULL, 1)
            take_items(killer, VUKU_ORK_TUSK, -1)
            take_items(killer, RATMAN_FANG, -1)
            take_items(killer, LANGK_LIZARDMAN_TOOTH, -1)
            take_items(killer, FELIM_LIZARDMAN_TOOTH, -1)
            qs.set_cond(12, true)
          else
            give_items(killer, VUKU_ORK_TUSK, 1)
            play_sound(killer, Sound::ITEMSOUND_QUEST_ITEMGET)
          end
        end
      when LANGK_LIZZARDMAN_WARRIOR
        if has_quest_items?(killer, LEATHER_POUCH_4TF) && get_quest_items_count(killer, LANGK_LIZARDMAN_TOOTH) < 3
          if item_count >= 11
            take_items(killer, LEATHER_POUCH_4TF, 1)
            give_items(killer, LEATHER_POUCH_4TF_FULL, 1)
            take_items(killer, VUKU_ORK_TUSK, -1)
            take_items(killer, RATMAN_FANG, -1)
            take_items(killer, LANGK_LIZARDMAN_TOOTH, -1)
            take_items(killer, FELIM_LIZARDMAN_TOOTH, -1)
            qs.set_cond(12, true)
          else
            give_items(killer, LANGK_LIZARDMAN_TOOTH, 1)
            play_sound(killer, Sound::ITEMSOUND_QUEST_ITEMGET)
          end
        end
      when RATMAN_WARRIOR
        if has_quest_items?(killer, LEATHER_POUCH_4TF) && get_quest_items_count(killer, RATMAN_FANG) < 3
          if item_count >= 11
            take_items(killer, LEATHER_POUCH_4TF, 1)
            give_items(killer, LEATHER_POUCH_4TF_FULL, 1)
            take_items(killer, VUKU_ORK_TUSK, -1)
            take_items(killer, RATMAN_FANG, -1)
            take_items(killer, LANGK_LIZARDMAN_TOOTH, -1)
            take_items(killer, FELIM_LIZARDMAN_TOOTH, -1)
            qs.set_cond(12, true)
          else
            give_items(killer, RATMAN_FANG, 1)
            play_sound(killer, Sound::ITEMSOUND_QUEST_ITEMGET)
          end
        end
      when SCARLET_SALAMANDER
        if has_quest_items?(killer, LEATHER_POUCH_3RD)
          if get_quest_items_count(killer, SCARLET_SALAMANDER_SCALE) == 4
            take_items(killer, LEATHER_POUCH_3RD, 1)
            give_items(killer, LEATHER_POUCH_3RD_FULL, 1)
            take_items(killer, SCARLET_SALAMANDER_SCALE, -1)
            qs.set_cond(7, true)
          else
            give_items(killer, SCARLET_SALAMANDER_SCALE, 1)
            play_sound(killer, Sound::ITEMSOUND_QUEST_ITEMGET)
          end
        end
      when KASHA_FANG_SPIDER
        if qs.memo_state?(3) && get_quest_items_count(killer, KASHA_SPIDERS_TOOTH) < 6
          if Rnd.rand(100) < 70
            give_items(killer, KASHA_SPIDERS_TOOTH, 1)
            if get_quest_items_count(killer, KASHA_SPIDERS_TOOTH) >= 6
              qs.set_cond(16, true)
            else
              play_sound(killer, Sound::ITEMSOUND_QUEST_ITEMGET)
            end
          end
        end
      when KASHA_BLADE_SPIDER
        if has_quest_items?(killer, LEATHER_POUCH_2ND)
          if get_quest_items_count(killer, KASHA_BLADE_SPIDER_TALON) == 4
            take_items(killer, LEATHER_POUCH_2ND, 1)
            give_items(killer, LEATHER_POUCH_2ND_FULL, 1)
            take_items(killer, KASHA_BLADE_SPIDER_TALON, -1)
            qs.set_cond(5, true)
          else
            give_items(killer, KASHA_BLADE_SPIDER_TALON, 1)
            play_sound(killer, Sound::ITEMSOUND_QUEST_ITEMGET)
          end
        elsif qs.memo_state?(3) && get_quest_items_count(killer, KASHA_SPIDERS_TOOTH) < 6
          if Rnd.rand(100) < 70
            give_items(killer, KASHA_SPIDERS_TOOTH, 1)
            if get_quest_items_count(killer, KASHA_SPIDERS_TOOTH) == 6
              qs.set_cond(16, true)
            else
              play_sound(killer, Sound::ITEMSOUND_QUEST_ITEMGET)
            end
          end
        end
      when KASHA_BEAR
        if has_quest_items?(killer, LEATHER_POUCH_1ST)
          if get_quest_items_count(killer, KASHA_BEAR_CLAW) == 4
            take_items(killer, LEATHER_POUCH_1ST, 1)
            give_items(killer, LEATHER_POUCH_1ST_FULL, 1)
            take_items(killer, KASHA_BEAR_CLAW, -1)
            qs.set_cond(3, true)
          else
            give_items(killer, KASHA_BEAR_CLAW, 1)
            play_sound(killer, Sound::ITEMSOUND_QUEST_ITEMGET)
          end
        end
      when BAAR_DRE_VANUL
        if qs.memo_state?(4) && !has_quest_items?(killer, HORN_OF_BAAR_DRE_VANUL)
          if Rnd.rand(100) < 90
            give_items(killer, HORN_OF_BAAR_DRE_VANUL, 1)
            qs.set_cond(18, true)
          end
        end
      end

    end

    super
  end

  def on_talk(npc, pc)
    qs = get_quest_state!(pc)
    memo_state = qs.memo_state

    if qs.created? || qs.completed?
      if npc.id == GANTAKI_ZU_URUTU
        html = "30587-01.htm"
      end
    elsif qs.started?
      case npc.id
      when GANTAKI_ZU_URUTU
         letter_count = get_quest_items_count(pc, LEATHER_POUCH_1ST, LEATHER_POUCH_2ND, LEATHER_POUCH_3RD, LEATHER_POUCH_1ST_FULL, LEATHER_POUCH_2ND_FULL, LEATHER_POUCH_3RD_FULL)
        if memo_state == 2
          html = "30587-09c.html"
        elsif has_quest_items?(pc, POMEGRANATE) && !has_at_least_one_quest_item?(pc, FIERY_SPIRIT_SCROLL, GANTAKIS_LETTRT_OF_RECOMMENDATION, ROSHEEKS_LETTER) && letter_count == 0
          html = "30587-07.html"
        elsif !has_at_least_one_quest_item?(pc, FIERY_SPIRIT_SCROLL, POMEGRANATE, GANTAKIS_LETTRT_OF_RECOMMENDATION, ROSHEEKS_LETTER) && letter_count == 1
          html = "30587-08.html"
        elsif has_quest_items?(pc, FIERY_SPIRIT_SCROLL, ROSHEEKS_LETTER) && !has_at_least_one_quest_item?(pc, POMEGRANATE, GANTAKIS_LETTRT_OF_RECOMMENDATION) && letter_count == 0
          html = "30587-09a.html"
        elsif memo_state < 2
          if has_quest_items?(pc, FIERY_SPIRIT_SCROLL, GANTAKIS_LETTRT_OF_RECOMMENDATION) && !has_at_least_one_quest_item?(pc, POMEGRANATE, ROSHEEKS_LETTER) && letter_count == 0
            html = "30587-10.html"
          elsif has_quest_items?(pc, FIERY_SPIRIT_SCROLL) && !has_at_least_one_quest_item?(pc, POMEGRANATE, GANTAKIS_LETTRT_OF_RECOMMENDATION, ROSHEEKS_LETTER) && letter_count == 0
            html = "30587-11.html"
          end
        end
      when PREFECT_KASMAN
        if has_quest_items?(pc, GANTAKIS_LETTRT_OF_RECOMMENDATION)
          take_items(pc, GANTAKIS_LETTRT_OF_RECOMMENDATION, 1)
          give_items(pc, FIG, 1)
          qs.set_cond(10)
          html = "30501-01.html"
        elsif has_quest_items?(pc, FIG) && !has_at_least_one_quest_item?(pc, LEATHER_POUCH_4TF, LEATHER_POUCH_4TF_FULL)
          html = "30501-02.html"
        elsif !has_quest_items?(pc, FIG) && has_at_least_one_quest_item?(pc, LEATHER_POUCH_4TF, LEATHER_POUCH_4TF_FULL)
          html = "30501-03.html"
        elsif has_quest_items?(pc, IRON_WILL_SCROLL)
          give_adena(pc, 163800, true)
          give_items(pc, KHAVATARI_TOTEM, 1)
          level = pc.level
          if level >= 20
            add_exp_and_sp(pc, 320534, 25292)
          elsif level == 19
            add_exp_and_sp(pc, 456128, 31990)
          else
            add_exp_and_sp(pc, 591724, 38688)
          end
          qs.exit_quest(false, true)
          pc.send_packet(SocialAction.new(pc.l2id, 3))
          qs.save_global_quest_var("1ClassQuestFinished", "1")
          html = "30501-04.html"
        end
      when KHAVATARI_ROSHEEK
        if has_quest_items?(pc, POMEGRANATE)
          take_items(pc, POMEGRANATE, 1)
          give_items(pc, LEATHER_POUCH_1ST, 1)
          qs.set_cond(2)
          html = "30590-01.html"
        elsif has_quest_items?(pc, LEATHER_POUCH_1ST) && !has_quest_items?(pc, LEATHER_POUCH_1ST_FULL)
          html = "30590-02.html"
        elsif !has_quest_items?(pc, LEATHER_POUCH_1ST) && has_quest_items?(pc, LEATHER_POUCH_1ST_FULL)
          give_items(pc, LEATHER_POUCH_2ND, 1)
          take_items(pc, LEATHER_POUCH_1ST_FULL, 1)
          qs.set_cond(4)
          html = "30590-03.html"
        elsif has_quest_items?(pc, LEATHER_POUCH_2ND) && !has_quest_items?(pc, LEATHER_POUCH_2ND_FULL)
          html = "30590-04.html"
        elsif !has_quest_items?(pc, LEATHER_POUCH_2ND) && has_quest_items?(pc, LEATHER_POUCH_2ND_FULL)
          give_items(pc, LEATHER_POUCH_3RD, 1)
          take_items(pc, LEATHER_POUCH_2ND_FULL, 1)
          qs.set_cond(6)
          html = "30590-05.html"
        elsif has_quest_items?(pc, LEATHER_POUCH_3RD) && !has_quest_items?(pc, LEATHER_POUCH_3RD_FULL)
          html = "30590-06.html"
        elsif !has_quest_items?(pc, LEATHER_POUCH_3RD) && has_quest_items?(pc, LEATHER_POUCH_3RD_FULL)
          take_items(pc, LEATHER_POUCH_3RD_FULL, 1)
          give_items(pc, FIERY_SPIRIT_SCROLL, 1)
          give_items(pc, ROSHEEKS_LETTER, 1)
          qs.set_cond(8)
          html = "30590-07.html"
        elsif has_quest_items?(pc, ROSHEEKS_LETTER, FIERY_SPIRIT_SCROLL)
          html = "30590-08.html"
        elsif !has_quest_items?(pc, ROSHEEKS_LETTER) && has_quest_items?(pc, FIERY_SPIRIT_SCROLL)
          html = "30590-09.html"
        end
      when KHAVATARI_TORUKU
        if has_quest_items?(pc, FIG)
          take_items(pc, FIG, 1)
          give_items(pc, LEATHER_POUCH_4TF, 1)
          qs.set_cond(11)
          html = "30591-01.html"
        elsif has_quest_items?(pc, LEATHER_POUCH_4TF) && !has_quest_items?(pc, LEATHER_POUCH_4TF_FULL)
          html = "30591-02.html"
        elsif !has_quest_items?(pc, LEATHER_POUCH_4TF) && has_quest_items?(pc, LEATHER_POUCH_4TF_FULL)
          take_items(pc, LEATHER_POUCH_4TF_FULL, 1)
          give_items(pc, IRON_WILL_SCROLL, 1)
          give_items(pc, TORUKUS_LETTER, 1)
          qs.set_cond(13)
          html = "30591-03.html"
        elsif has_quest_items?(pc, IRON_WILL_SCROLL, TORUKUS_LETTER)
          html = "30591-04.html"
        end
      when SEER_MOIRA
        if memo_state == 5
          html = "31979-01.html"
        end
      when KHAVATARI_AREN
        if memo_state == 2
          html = "32056-01.html"
        elsif memo_state == 3
          if get_quest_items_count(pc, KASHA_SPIDERS_TOOTH) < 6
            html = "32056-04.html"
          else
            take_items(pc, KASHA_SPIDERS_TOOTH, -1)
            qs.memo_state = 4
            qs.set_cond(17)
            html = "32056-05.html"
          end
        elsif memo_state == 4
          if !has_quest_items?(pc, HORN_OF_BAAR_DRE_VANUL)
            html = "32056-06.html"
          else
            html = "32056-07.html"
          end
        elsif memo_state == 5
          html = "32056-09.html"
        end
      end

    end

    html || get_no_quest_msg(pc)
  end

  private def check_weapon(pc)
    return true unless weapon = pc.active_weapon_instance
    weapon.item_type.in?(WeaponType::FIST, WeaponType::DUALFIST)
  end
end
