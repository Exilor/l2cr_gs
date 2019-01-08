class Quests::Q00217_TestimonyOfTrust < Quest
  # NPCs
  private HIGH_PRIEST_BIOTIN = 30031
  private HIERARCH_ASTERIOS = 30154
  private HIGH_PRIEST_HOLLINT = 30191
  private TETRARCH_THIFIELL = 30358
  private MAGISTER_CLAYTON = 30464
  private SEER_MANAKIA = 30515
  private IRON_GATES_LOCKIRIN = 30531
  private FLAME_LORD_KAKAI = 30565
  private MAESTRO_NIKOLA = 30621
  private CARDINAL_SERESIN = 30657
  # Items
  private LETTER_TO_ELF = 2735
  private LETTER_TO_DARKELF = 2736
  private LETTER_TO_DWARF = 2737
  private LETTER_TO_ORC = 2738
  private LETTER_TO_SERESIN = 2739
  private SCROLL_OF_DARKELF_TRUST = 2740
  private SCROLL_OF_ELF_TRUST = 2741
  private SCROLL_OF_DWARF_TRUST = 2742
  private SCROLL_OF_ORC_TRUST = 2743
  private RECOMMENDATION_OF_HOLLIN = 2744
  private ORDER_OF_ASTERIOS = 2745
  private BREATH_OF_WINDS = 2746
  private SEED_OF_VERDURE = 2747
  private LETTER_OF_THIFIELL = 2748
  private BLOOD_OF_GUARDIAN_BASILISK = 2749
  private GIANT_APHID = 2750
  private STAKATOS_FLUIDS = 2751
  private BASILISK_PLASMA = 2752
  private HONEY_DEW = 2753
  private STAKATO_ICHOR = 2754
  private ORDER_OF_CLAYTON = 2755
  private PARASITE_OF_LOTA = 2756
  private LETTER_TO_MANAKIA = 2757
  private LETTER_OF_MANAKIA = 2758
  private LETTER_TO_NICHOLA = 2759
  private ORDER_OF_NICHOLA = 2760
  private HEART_OF_PORTA = 2761
  # Reward
  private MARK_OF_TRUST = 2734
  private DIMENSIONAL_DIAMOND = 7562
  # Monster
  private DRYAD = 20013
  private DRYAD_ELDER = 20019
  private LIREIN = 20036
  private LIREIN_ELDER = 20044
  private ANT_RECRUIT = 20082
  private ANT_PATROL = 20084
  private ANT_GUARD = 20086
  private ANT_SOLDIER = 20087
  private ANT_WARRIOR_CAPTAIN = 20088
  private MARSH_STAKATO = 20157
  private PORTA = 20213
  private MARSH_STAKATO_WORKER = 20230
  private MARSH_STAKATO_SOLDIER = 20232
  private MARSH_STAKATO_DRONE = 20234
  private GUARDIAN_BASILISK = 20550
  private WINDSUS = 20553
  # Quest Monster
  private LUELL_OF_ZEPHYR_WINDS = 27120
  private ACTEA_OF_VERDANT_WILDS = 27121
  # Misc
  private MIN_LEVEL = 37

  def initialize
    super(217, self.class.simple_name, "Testimony Of Trust")

    add_start_npc(HIGH_PRIEST_HOLLINT)
    add_talk_id(HIGH_PRIEST_HOLLINT, HIGH_PRIEST_BIOTIN, HIERARCH_ASTERIOS, TETRARCH_THIFIELL, MAGISTER_CLAYTON, SEER_MANAKIA, IRON_GATES_LOCKIRIN, FLAME_LORD_KAKAI, MAESTRO_NIKOLA, CARDINAL_SERESIN)
    add_kill_id(DRYAD, DRYAD_ELDER, LIREIN, LIREIN_ELDER, ANT_RECRUIT, ANT_PATROL, ANT_GUARD, ANT_SOLDIER, ANT_WARRIOR_CAPTAIN, MARSH_STAKATO, PORTA, MARSH_STAKATO_WORKER, MARSH_STAKATO_SOLDIER, MARSH_STAKATO_DRONE, GUARDIAN_BASILISK, WINDSUS, LUELL_OF_ZEPHYR_WINDS, ACTEA_OF_VERDANT_WILDS)
    register_quest_items(LETTER_TO_ELF, LETTER_TO_DARKELF, LETTER_TO_DWARF, LETTER_TO_ORC, LETTER_TO_SERESIN, SCROLL_OF_DARKELF_TRUST, SCROLL_OF_ELF_TRUST, SCROLL_OF_DWARF_TRUST, SCROLL_OF_ORC_TRUST, RECOMMENDATION_OF_HOLLIN, ORDER_OF_ASTERIOS, BREATH_OF_WINDS, SEED_OF_VERDURE, LETTER_OF_THIFIELL, BLOOD_OF_GUARDIAN_BASILISK, GIANT_APHID, STAKATOS_FLUIDS, BASILISK_PLASMA, HONEY_DEW, STAKATO_ICHOR, ORDER_OF_CLAYTON, PARASITE_OF_LOTA, LETTER_TO_MANAKIA, LETTER_OF_MANAKIA, LETTER_TO_NICHOLA, ORDER_OF_NICHOLA, HEART_OF_PORTA)
  end

  def on_adv_event(event, npc, player)
    return unless player
    qs = get_quest_state(player, false)
    if qs.nil?
      return
    end

    htmltext = nil
    case event
    when "ACCEPT"
      if qs.created?
        qs.start_quest
        qs.memo_state = 1
        give_items(player, LETTER_TO_ELF, 1)
        give_items(player, LETTER_TO_DARKELF, 1)
        play_sound(player, Sound::ITEMSOUND_QUEST_MIDDLE)
        if player.variables.get_i32("2ND_CLASS_DIAMOND_REWARD", 0) == 0
          give_items(player, DIMENSIONAL_DIAMOND, 96)
          player.variables["2ND_CLASS_DIAMOND_REWARD"] = 1
          htmltext = "30191-04a.htm"
        else
          htmltext = "30191-04.htm"
        end
      end
    when "30154-02.html", "30657-02.html"
      htmltext = event
    when "30154-03.html"
      if has_quest_items?(player, LETTER_TO_ELF)
        take_items(player, LETTER_TO_ELF, 1)
        give_items(player, ORDER_OF_ASTERIOS, 1)
        qs.memo_state = 2
        qs.set_cond(2, true)
        htmltext = event
      end
    when "30358-02.html"
      if has_quest_items?(player, LETTER_TO_DARKELF)
        take_items(player, LETTER_TO_DARKELF, 1)
        give_items(player, LETTER_OF_THIFIELL, 1)
        qs.memo_state = 5
        qs.set_cond(5, true)
        htmltext = event
      end
    when "30515-02.html"
      if has_quest_items?(player, LETTER_TO_MANAKIA)
        take_items(player, LETTER_TO_MANAKIA, 1)
        qs.memo_state = 11
        qs.set_cond(14, true)
        htmltext = event
      end
    when "30531-02.html"
      if has_quest_items?(player, LETTER_TO_DWARF)
        take_items(player, LETTER_TO_DWARF, 1)
        give_items(player, LETTER_TO_NICHOLA, 1)
        qs.memo_state = 15
        qs.set_cond(18, true)
        htmltext = event
      end
    when "30565-02.html"
      if has_quest_items?(player, LETTER_TO_ORC)
        take_items(player, LETTER_TO_ORC, 1)
        give_items(player, LETTER_TO_MANAKIA, 1)
        qs.memo_state = 10
        qs.set_cond(13, true)
        htmltext = event
      end
    when "30621-02.html"
      if has_quest_items?(player, LETTER_TO_NICHOLA)
        take_items(player, LETTER_TO_NICHOLA, 1)
        give_items(player, ORDER_OF_NICHOLA, 1)
        qs.memo_state = 16
        qs.set_cond(19, true)
        htmltext = event
      end
    when "30657-03.html"
      if qs.memo_state?(8) && has_quest_items?(player, LETTER_TO_SERESIN)
        give_items(player, LETTER_TO_DWARF, 1)
        give_items(player, LETTER_TO_ORC, 1)
        take_items(player, LETTER_TO_SERESIN, 1)
        qs.memo_state = 9
        qs.set_cond(12, true)
        htmltext = event
      end
    end

    htmltext
  end

  def on_kill(npc, killer, is_summon)
    qs = get_quest_state(killer, false)
    if qs && qs.started? && Util.in_range?(1500, npc, killer, true)
      case npc.id
      when DRYAD, DRYAD_ELDER
        if qs.memo_state?(2)
          flag = killer.variables.get_i32("flag", +1)
          if Rnd.rand(100) < (flag * 33)
            add_spawn(ACTEA_OF_VERDANT_WILDS, npc, true, 200000)
            play_sound(killer, Sound::ITEMSOUND_QUEST_BEFORE_BATTLE)
          end
        end
      when LIREIN, LIREIN_ELDER
        if qs.memo_state?(2)
          flag = killer.variables.get_i32("flag", +1)
          if Rnd.rand(100) < (flag * 33)
            add_spawn(LUELL_OF_ZEPHYR_WINDS, npc, true, 200000)
            play_sound(killer, Sound::ITEMSOUND_QUEST_BEFORE_BATTLE)
          end
        end
      when ANT_RECRUIT, ANT_GUARD
        if qs.memo_state?(6) && (get_quest_items_count(killer, GIANT_APHID) < 5) && has_quest_items?(killer, ORDER_OF_CLAYTON) && !has_quest_items?(killer, HONEY_DEW)
          if get_quest_items_count(killer, GIANT_APHID) >= 4
            give_items(killer, HONEY_DEW, 1)
            take_items(killer, GIANT_APHID, -1)
            play_sound(killer, Sound::ITEMSOUND_QUEST_MIDDLE)
            if has_quest_items?(killer, BASILISK_PLASMA, STAKATO_ICHOR)
              qs.set_cond(7)
            end
          else
            give_items(killer, GIANT_APHID, 1)
            play_sound(killer, Sound::ITEMSOUND_QUEST_ITEMGET)
          end
        end
      when ANT_PATROL, ANT_SOLDIER, ANT_WARRIOR_CAPTAIN
        if qs.memo_state?(6) && (get_quest_items_count(killer, GIANT_APHID) < 10) && has_quest_items?(killer, ORDER_OF_CLAYTON) && !has_quest_items?(killer, HONEY_DEW)
          if get_quest_items_count(killer, GIANT_APHID) >= 4
            give_items(killer, HONEY_DEW, 1)
            take_items(killer, GIANT_APHID, -1)
            play_sound(killer, Sound::ITEMSOUND_QUEST_MIDDLE)
            if has_quest_items?(killer, BASILISK_PLASMA, STAKATO_ICHOR)
              qs.set_cond(7)
            end
          else
            give_items(killer, GIANT_APHID, 1)
            play_sound(killer, Sound::ITEMSOUND_QUEST_ITEMGET)
          end
        end
      when MARSH_STAKATO, MARSH_STAKATO_WORKER
        if qs.memo_state?(6) && (get_quest_items_count(killer, STAKATOS_FLUIDS) < 10) && has_quest_items?(killer, ORDER_OF_CLAYTON) && !has_quest_items?(killer, STAKATO_ICHOR)
          if get_quest_items_count(killer, STAKATOS_FLUIDS) >= 4
            give_items(killer, STAKATO_ICHOR, 1)
            take_items(killer, STAKATOS_FLUIDS, -1)
            play_sound(killer, Sound::ITEMSOUND_QUEST_MIDDLE)
            if has_quest_items?(killer, BASILISK_PLASMA, HONEY_DEW)
              qs.set_cond(7)
            end
          else
            give_items(killer, STAKATOS_FLUIDS, 1)
            play_sound(killer, Sound::ITEMSOUND_QUEST_ITEMGET)
          end
        end
      when MARSH_STAKATO_SOLDIER, MARSH_STAKATO_DRONE
        if qs.memo_state?(6) && (get_quest_items_count(killer, STAKATOS_FLUIDS) < 5) && has_quest_items?(killer, ORDER_OF_CLAYTON) && !has_quest_items?(killer, STAKATO_ICHOR)
          if get_quest_items_count(killer, STAKATOS_FLUIDS) >= 4
            give_items(killer, STAKATO_ICHOR, 1)
            take_items(killer, STAKATOS_FLUIDS, -1)
            play_sound(killer, Sound::ITEMSOUND_QUEST_MIDDLE)
            if has_quest_items?(killer, BASILISK_PLASMA, HONEY_DEW)
              qs.set_cond(7)
            end
          else
            give_items(killer, STAKATOS_FLUIDS, 1)
            play_sound(killer, Sound::ITEMSOUND_QUEST_ITEMGET)
          end
        end
      when PORTA
        if qs.memo_state?(16) && !has_quest_items?(killer, HEART_OF_PORTA)
          give_items(killer, HEART_OF_PORTA, 1)
          if has_quest_items?(killer, HEART_OF_PORTA)
            qs.set_cond(20, true)
          end
        end
      when GUARDIAN_BASILISK
        if qs.memo_state?(6) && (get_quest_items_count(killer, BLOOD_OF_GUARDIAN_BASILISK) < 10) && has_quest_items?(killer, ORDER_OF_CLAYTON) && !has_quest_items?(killer, BASILISK_PLASMA)
          if get_quest_items_count(killer, BLOOD_OF_GUARDIAN_BASILISK) >= 4
            give_items(killer, BASILISK_PLASMA, 1)
            take_items(killer, BLOOD_OF_GUARDIAN_BASILISK, -1)
            play_sound(killer, Sound::ITEMSOUND_QUEST_MIDDLE)
            if has_quest_items?(killer, STAKATO_ICHOR, HONEY_DEW)
              qs.set_cond(7)
            end
          else
            give_items(killer, BLOOD_OF_GUARDIAN_BASILISK, 1)
            play_sound(killer, Sound::ITEMSOUND_QUEST_ITEMGET)
          end
        end
      when WINDSUS
        if qs.memo_state?(11) && (get_quest_items_count(killer, PARASITE_OF_LOTA) < 10)
          give_items(killer, PARASITE_OF_LOTA, 2)
          if get_quest_items_count(killer, PARASITE_OF_LOTA) == 10
            qs.memo_state = 12
            qs.set_cond(15, true)
          else
            play_sound(killer, Sound::ITEMSOUND_QUEST_ITEMGET)
          end
        end
      when LUELL_OF_ZEPHYR_WINDS
        if qs.memo_state?(2) && !has_quest_items?(killer, BREATH_OF_WINDS)
          if has_quest_items?(killer, SEED_OF_VERDURE)
            give_items(killer, BREATH_OF_WINDS, 1)
            qs.memo_state = 3
            qs.set_cond(3, true)
          else
            give_items(killer, BREATH_OF_WINDS, 1)
            play_sound(killer, Sound::ITEMSOUND_QUEST_ITEMGET)
          end
        end
      when ACTEA_OF_VERDANT_WILDS
        if qs.memo_state?(2) && !has_quest_items?(killer, SEED_OF_VERDURE)
          if has_quest_items?(killer, BREATH_OF_WINDS)
            give_items(killer, SEED_OF_VERDURE, 1)
            qs.memo_state = 3
            play_sound(killer, Sound::ITEMSOUND_QUEST_MIDDLE)
          else
            give_items(killer, SEED_OF_VERDURE, 1)
            play_sound(killer, Sound::ITEMSOUND_QUEST_ITEMGET)
          end
        end
      end
    end

    super
  end

  def on_talk(npc, player)
    qs = get_quest_state!(player)
    memo_state = qs.memo_state
    htmltext = get_no_quest_msg(player)
    if qs.created?
      if npc.id == HIGH_PRIEST_HOLLINT
        if player.race.human? && player.level >= MIN_LEVEL && player.in_category?(CategoryType::HUMAN_2ND_GROUP)
          htmltext = "30191-03.htm"
        elsif player.race.human? && player.level >= MIN_LEVEL && player.in_category?(CategoryType::FIRST_CLASS_GROUP)
          htmltext = "30191-01a.html"
        elsif player.race.human? && player.level >= MIN_LEVEL
          htmltext = "30191-01b.html"
        elsif player.race.human?
          htmltext = "30191-01.html"
        else
          htmltext = "30191-02.html"
        end
      end
    elsif qs.started?
      case npc.id
      when HIGH_PRIEST_HOLLINT
        if memo_state == 7
          if has_quest_items?(player, SCROLL_OF_ELF_TRUST, SCROLL_OF_DARKELF_TRUST)
            give_items(player, LETTER_TO_SERESIN, 1)
            take_items(player, SCROLL_OF_DARKELF_TRUST, 1)
            take_items(player, SCROLL_OF_ELF_TRUST, 1)
            qs.memo_state = 8
            qs.set_cond(10, true)
            htmltext = "30191-05.html"
          end
        elsif memo_state == 18
          if has_quest_items?(player, SCROLL_OF_DWARF_TRUST, SCROLL_OF_ORC_TRUST)
            take_items(player, SCROLL_OF_DWARF_TRUST, 1)
            take_items(player, SCROLL_OF_ORC_TRUST, 1)
            give_items(player, RECOMMENDATION_OF_HOLLIN, 1)
            qs.memo_state = 19
            qs.set_cond(23, true)
            htmltext = "30191-06.html"
          end
        elsif memo_state == 19
          htmltext = "30191-07.html"
        elsif memo_state == 1
          htmltext = "30191-08.html"
        elsif memo_state == 8
          htmltext = "30191-09.html"
        end
      when HIGH_PRIEST_BIOTIN
        if memo_state == 19
          if has_quest_items?(player, RECOMMENDATION_OF_HOLLIN)
            give_adena(player, 252212, true)
            give_items(player, MARK_OF_TRUST, 1)
            add_exp_and_sp(player, 1390298, 92782)
            qs.exit_quest(false, true)
            player.send_packet(SocialAction.new(player.l2id, 3))
            htmltext = "30031-01.html"
          end
        end
      when HIERARCH_ASTERIOS
        if memo_state == 1
          if has_quest_items?(player, LETTER_TO_ELF)
            htmltext = "30154-01.html"
          end
        elsif memo_state == 2
          if has_quest_items?(player, ORDER_OF_ASTERIOS)
            htmltext = "30154-04.html"
          end
        elsif memo_state == 3
          if has_quest_items?(player, BREATH_OF_WINDS, SEED_OF_VERDURE)
            give_items(player, SCROLL_OF_ELF_TRUST, 1)
            take_items(player, ORDER_OF_ASTERIOS, 1)
            take_items(player, BREATH_OF_WINDS, 1)
            take_items(player, SEED_OF_VERDURE, 1)
            qs.memo_state = 4
            qs.set_cond(4, true)
            htmltext = "30154-05.html"
          end
        elsif memo_state == 4
          htmltext = "30154-06.html"
        end
      when TETRARCH_THIFIELL
        if memo_state == 4
          if has_quest_items?(player, LETTER_TO_DARKELF)
            htmltext = "30358-01.html"
          end
        elsif memo_state == 6
          if has_quest_items?(player, ORDER_OF_CLAYTON) && ((get_quest_items_count(player, STAKATO_ICHOR) + get_quest_items_count(player, HONEY_DEW) + get_quest_items_count(player, BASILISK_PLASMA)) == 3)
            give_items(player, SCROLL_OF_DARKELF_TRUST, 1)
            take_items(player, BASILISK_PLASMA, -1)
            take_items(player, HONEY_DEW, -1)
            take_items(player, STAKATO_ICHOR, -1)
            take_items(player, ORDER_OF_CLAYTON, 1)
            qs.memo_state = 7
            qs.set_cond(9, true)
            htmltext = "30358-03.html"
          end
        elsif memo_state == 7
          htmltext = "30358-04.html"
        elsif memo_state == 5
          htmltext = "30358-05.html"
        end
      when MAGISTER_CLAYTON
        if memo_state == 5
          if has_quest_items?(player, LETTER_OF_THIFIELL)
            take_items(player, LETTER_OF_THIFIELL, 1)
            give_items(player, ORDER_OF_CLAYTON, 1)
            qs.memo_state = 6
            qs.set_cond(6, true)
            htmltext = "30464-01.html"
          end
        elsif memo_state == 6
          if has_quest_items?(player, ORDER_OF_CLAYTON) && ((get_quest_items_count(player, STAKATO_ICHOR) + get_quest_items_count(player, HONEY_DEW) + get_quest_items_count(player, BASILISK_PLASMA)) < 3)
            htmltext = "30464-02.html"
          else
            qs.set_cond(8, true)
            htmltext = "30464-03.html"
          end
        end
      when SEER_MANAKIA
        if has_quest_items?(player, LETTER_TO_MANAKIA)
          htmltext = "30515-01.html"
        elsif memo_state == 11
          htmltext = "30515-03.html"
        elsif memo_state == 12
          if get_quest_items_count(player, PARASITE_OF_LOTA) == 10
            take_items(player, PARASITE_OF_LOTA, -1)
            give_items(player, LETTER_OF_MANAKIA, 1)
            qs.memo_state = 13
            qs.set_cond(16, true)
            htmltext = "30515-04.html"
          end
        elsif memo_state == 13
          htmltext = "30515-05.html"
        end
      when IRON_GATES_LOCKIRIN
        if memo_state == 14
          if has_quest_items?(player, LETTER_TO_DWARF)
            htmltext = "30531-01.html"
          end
        elsif memo_state == 15
          htmltext = "30531-03.html"
        elsif memo_state == 17
          give_items(player, SCROLL_OF_DWARF_TRUST, 1)
          qs.memo_state = 18
          qs.set_cond(22, true)
          htmltext = "30531-04.html"
        elsif memo_state == 18
          htmltext = "30531-05.html"
        end
      when FLAME_LORD_KAKAI
        if memo_state == 9
          if has_quest_items?(player, LETTER_TO_ORC)
            htmltext = "30565-01.html"
          end
        elsif memo_state == 10
          htmltext = "30565-03.html"
        elsif memo_state == 13
          give_items(player, SCROLL_OF_ORC_TRUST, 1)
          take_items(player, LETTER_OF_MANAKIA, 1)
          qs.memo_state = 14
          qs.set_cond(17, true)
          htmltext = "30565-04.html"
        elsif memo_state == 14
          htmltext = "30565-05.html"
        end
      when MAESTRO_NIKOLA
        if memo_state == 15
          if has_quest_items?(player, LETTER_TO_NICHOLA)
            htmltext = "30621-01.html"
          end
        elsif memo_state == 16
          if !has_quest_items?(player, HEART_OF_PORTA)
            htmltext = "30621-03.html"
          else
            take_items(player, ORDER_OF_NICHOLA, 1)
            take_items(player, HEART_OF_PORTA, 1)
            qs.memo_state = 17
            qs.set_cond(21, true)
            htmltext = "30621-04.html"
          end
        elsif memo_state == 17
          htmltext = "30621-05.html"
        end
      when CARDINAL_SERESIN
        if memo_state == 8
          if has_quest_items?(player, LETTER_TO_SERESIN)
            htmltext = "30657-01.html"
          end
        elsif memo_state == 9
          htmltext = "30657-04.html"
        elsif memo_state == 18
          htmltext = "30657-05.html"
        end
      end
    elsif qs.completed?
      if npc.id == HIGH_PRIEST_HOLLINT
        htmltext = get_already_completed_msg(player)
      end
    end

    htmltext
  end
end
