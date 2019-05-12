class Scripts::Q00222_TestOfTheDuelist < Quest
  # NPC
  private DUELIST_KAIEN = 30623
  # Items
  private ORDER_GLUDIO = 2763
  private ORDER_DION = 2764
  private ORDER_GIRAN = 2765
  private ORDER_OREN = 2766
  private ORDER_ADEN = 2767
  private PUNCHERS_SHARD = 2768
  private NOBLE_ANTS_FEELER = 2769
  private DRONES_CHITIN = 2770
  private DEAD_SEEKER_FANG = 2771
  private OVERLORD_NECKLACE = 2772
  private FETTERED_SOULS_CHAIN = 2773
  private CHIEDS_AMULET = 2774
  private ENCHANTED_EYE_MEAT = 2775
  private TAMRIN_ORCS_RING = 2776
  private TAMRIN_ORCS_ARROW = 2777
  private FINAL_ORDER = 2778
  private EXCUROS_SKIN = 2779
  private KRATORS_SHARD = 2780
  private GRANDIS_SKIN = 2781
  private TIMAK_ORCS_BELT = 2782
  private LAKINS_MACE = 2783
  # Reward
  private MARK_OF_DUELIST = 2762
  private DIMENSIONAL_DIAMOND = 7562
  # Monster
  private PUNCHER = 20085
  private NOBLE_ANT_LEADER = 20090
  private DEAD_SEEKER = 20202
  private EXCURO = 20214
  private KRATOR = 20217
  private MARSH_STAKATO_DRONE = 20234
  private BREKA_ORC_OVERLORD = 20270
  private FETTERED_SOUL = 20552
  private GRANDIS = 20554
  private ENCHANTED_MONSTEREYE = 20564
  private LETO_LIZARDMAN_OVERLORD = 20582
  private TIMAK_ORC_OVERLORD = 20588
  private TAMLIN_ORC = 20601
  private TAMLIN_ORC_ARCHER = 20602
  private LAKIN = 20604
  # Misc
  private MIN_LEVEL = 39

  def initialize
    super(222, self.class.simple_name, "Test Of The Duelist")

    add_start_npc(DUELIST_KAIEN)
    add_talk_id(DUELIST_KAIEN)
    add_kill_id(
      PUNCHER, NOBLE_ANT_LEADER, DEAD_SEEKER, EXCURO, KRATOR,
      MARSH_STAKATO_DRONE, BREKA_ORC_OVERLORD, FETTERED_SOUL, GRANDIS,
      ENCHANTED_MONSTEREYE, LETO_LIZARDMAN_OVERLORD, TIMAK_ORC_OVERLORD,
      TAMLIN_ORC, TAMLIN_ORC_ARCHER, LAKIN
    )
    register_quest_items(
      ORDER_GLUDIO, ORDER_DION, ORDER_GIRAN, ORDER_OREN, ORDER_ADEN,
      PUNCHERS_SHARD, NOBLE_ANTS_FEELER, DRONES_CHITIN, DEAD_SEEKER_FANG,
      OVERLORD_NECKLACE, FETTERED_SOULS_CHAIN, CHIEDS_AMULET,
      ENCHANTED_EYE_MEAT, TAMRIN_ORCS_RING, TAMRIN_ORCS_ARROW, FINAL_ORDER,
      EXCUROS_SKIN, KRATORS_SHARD, GRANDIS_SKIN, TIMAK_ORCS_BELT, LAKINS_MACE
    )
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    return unless qs = get_quest_state(pc, false)

    case event
    when "ACCEPT"
      if qs.created?
        qs.start_quest
        qs.memo_state = 1
        give_items(pc, ORDER_GLUDIO, 1)
        give_items(pc, ORDER_DION, 1)
        give_items(pc, ORDER_GIRAN, 1)
        give_items(pc, ORDER_OREN, 1)
        give_items(pc, ORDER_ADEN, 1)
        play_sound(pc, Sound::ITEMSOUND_QUEST_MIDDLE)
        if pc.variables.get_i32("2ND_CLASS_DIAMOND_REWARD", 0) == 0
          if pc.class_id.palus_knight?
            give_items(pc, DIMENSIONAL_DIAMOND, 104)
          else
            give_items(pc, DIMENSIONAL_DIAMOND, 72)
          end
          pc.variables["2ND_CLASS_DIAMOND_REWARD"] = 1
          html = "30623-07a.htm"
        else
          html = "30623-07.htm"
        end
      end
    when "30623-04.htm"
      if pc.race.orc?
        html = "30623-05.htm"
      else
        html = event
      end
    when "30623-06.htm", "30623-07.html", "30623-09.html", "30623-10.html", "30623-11.html", "30623-12.html", "30623-15.html"
      html = event
    when "30623-08.html"
      qs.set_cond(2, true)
      html = event
    when "30623-16.html"
      take_items(pc, PUNCHERS_SHARD, -1)
      take_items(pc, NOBLE_ANTS_FEELER, -1)
      take_items(pc, DEAD_SEEKER_FANG, -1)
      take_items(pc, DRONES_CHITIN, -1)
      take_items(pc, OVERLORD_NECKLACE, -1)
      take_items(pc, FETTERED_SOULS_CHAIN, -1)
      take_items(pc, CHIEDS_AMULET, -1)
      take_items(pc, ENCHANTED_EYE_MEAT, -1)
      take_items(pc, TAMRIN_ORCS_RING, -1)
      take_items(pc, TAMRIN_ORCS_ARROW, -1)
      take_items(pc, ORDER_GLUDIO, 1)
      take_items(pc, ORDER_DION, 1)
      take_items(pc, ORDER_GIRAN, 1)
      take_items(pc, ORDER_OREN, 1)
      take_items(pc, ORDER_ADEN, 1)
      give_items(pc, FINAL_ORDER, 1)
      qs.memo_state = 2
      qs.set_cond(4, true)
      html = event
    end

    return html
  end

  def on_kill(npc, killer, is_summon)
    qs = get_quest_state(killer, false)
    if qs && qs.started? && Util.in_range?(1500, npc, killer, true)
      case npc.id
      when PUNCHER
        if qs.memo_state?(1) && has_quest_items?(killer, ORDER_GLUDIO)
          i0 = qs.get_memo_state_ex(1)
          qs.set_memo_state_ex(1, i0 + 1)
          if give_item_randomly(killer, npc, PUNCHERS_SHARD, 1, 10, 1.0, true) && get_quest_items_count(killer, NOBLE_ANTS_FEELER, DRONES_CHITIN, DEAD_SEEKER_FANG, OVERLORD_NECKLACE, FETTERED_SOULS_CHAIN, CHIEDS_AMULET, ENCHANTED_EYE_MEAT, TAMRIN_ORCS_RING, TAMRIN_ORCS_ARROW) == 90
            if i0 >= 9
              qs.set_cond(3)
            end
            qs.set_memo_state_ex(1, 0)
          end
        end
      when NOBLE_ANT_LEADER
        if qs.memo_state?(1) && has_quest_items?(killer, ORDER_GLUDIO)
          i0 = qs.get_memo_state_ex(1)
          qs.set_memo_state_ex(1, i0 + 1)
          if give_item_randomly(killer, npc, NOBLE_ANTS_FEELER, 1, 10, 1.0, true) && get_quest_items_count(killer, PUNCHERS_SHARD, DRONES_CHITIN, DEAD_SEEKER_FANG, OVERLORD_NECKLACE, FETTERED_SOULS_CHAIN, CHIEDS_AMULET, ENCHANTED_EYE_MEAT, TAMRIN_ORCS_RING, TAMRIN_ORCS_ARROW) == 90
            if i0 >= 9
              qs.set_cond(3)
            end
            qs.set_memo_state_ex(1, 0)
          end
        end
      when DEAD_SEEKER
        if qs.memo_state?(1) && has_quest_items?(killer, ORDER_DION)
          i0 = qs.get_memo_state_ex(1)
          qs.set_memo_state_ex(1, i0 + 1)
          if give_item_randomly(killer, npc, DEAD_SEEKER_FANG, 1, 10, 1.0, true) && get_quest_items_count(killer, PUNCHERS_SHARD, NOBLE_ANTS_FEELER, DRONES_CHITIN, OVERLORD_NECKLACE, FETTERED_SOULS_CHAIN, CHIEDS_AMULET, ENCHANTED_EYE_MEAT, TAMRIN_ORCS_RING, TAMRIN_ORCS_ARROW) == 90
            if i0 >= 9
              qs.set_cond(3)
            end
            qs.set_memo_state_ex(1, 0)
          end
        end
      when EXCURO
        if qs.memo_state?(2) && has_quest_items?(killer, FINAL_ORDER)
          i0 = qs.get_memo_state_ex(1)
          qs.set_memo_state_ex(1, i0 + 1)
          if give_item_randomly(killer, npc, EXCUROS_SKIN, 1, 3, 1.0, true) && get_quest_items_count(killer, KRATORS_SHARD, LAKINS_MACE, GRANDIS_SKIN, TIMAK_ORCS_BELT) == 12
            if i0 >= 5
              qs.set_cond(5)
            end
            qs.set_memo_state_ex(1, 0)
          end
        end
      when KRATOR
        if qs.memo_state?(2) && has_quest_items?(killer, FINAL_ORDER)
          i0 = qs.get_memo_state_ex(1)
          qs.set_memo_state_ex(1, i0 + 1)
          if give_item_randomly(killer, npc, KRATORS_SHARD, 1, 3, 1.0, true) && get_quest_items_count(killer, EXCUROS_SKIN, LAKINS_MACE, GRANDIS_SKIN, TIMAK_ORCS_BELT) == 12
            if i0 >= 5
              qs.set_cond(5)
            end
            qs.set_memo_state_ex(1, 0)
          end
        end
      when MARSH_STAKATO_DRONE
        if qs.memo_state?(1) && has_quest_items?(killer, ORDER_DION)
          i0 = qs.get_memo_state_ex(1)
          qs.set_memo_state_ex(1, i0 + 1)
          if give_item_randomly(killer, npc, DRONES_CHITIN, 1, 10, 1.0, true) && get_quest_items_count(killer, PUNCHERS_SHARD, NOBLE_ANTS_FEELER, DEAD_SEEKER_FANG, OVERLORD_NECKLACE, FETTERED_SOULS_CHAIN, CHIEDS_AMULET, ENCHANTED_EYE_MEAT, TAMRIN_ORCS_RING, TAMRIN_ORCS_ARROW) == 90
            if i0 >= 9
              qs.set_cond(3)
            end
            qs.set_memo_state_ex(1, 0)
          end
        end
      when BREKA_ORC_OVERLORD
        if qs.memo_state?(1) && has_quest_items?(killer, ORDER_GIRAN)
          i0 = qs.get_memo_state_ex(1)
          qs.set_memo_state_ex(1, i0 + 1)
          if give_item_randomly(killer, npc, OVERLORD_NECKLACE, 1, 10, 1.0, true) && get_quest_items_count(killer, PUNCHERS_SHARD, NOBLE_ANTS_FEELER, DRONES_CHITIN, DEAD_SEEKER_FANG, FETTERED_SOULS_CHAIN, CHIEDS_AMULET, ENCHANTED_EYE_MEAT, TAMRIN_ORCS_RING, TAMRIN_ORCS_ARROW) == 90
            if i0 >= 9
              qs.set_cond(3)
            end
            qs.set_memo_state_ex(1, 0)
          end
        end
      when FETTERED_SOUL
        if qs.memo_state?(1) && has_quest_items?(killer, ORDER_GIRAN)
          i0 = qs.get_memo_state_ex(1)
          qs.set_memo_state_ex(1, i0 + 1)
          if give_item_randomly(killer, npc, FETTERED_SOULS_CHAIN, 1, 10, 1.0, true) && get_quest_items_count(killer, PUNCHERS_SHARD, NOBLE_ANTS_FEELER, DRONES_CHITIN, DEAD_SEEKER_FANG, OVERLORD_NECKLACE, CHIEDS_AMULET, ENCHANTED_EYE_MEAT, TAMRIN_ORCS_RING, TAMRIN_ORCS_ARROW) == 90
            if i0 >= 9
              qs.set_cond(3)
            end
            qs.set_memo_state_ex(1, 0)
          end
        end
      when GRANDIS
        if qs.memo_state?(2) && has_quest_items?(killer, FINAL_ORDER)
          i0 = qs.get_memo_state_ex(1)
          qs.set_memo_state_ex(1, i0 + 1)
          if give_item_randomly(killer, npc, GRANDIS_SKIN, 1, 3, 1.0, true) && get_quest_items_count(killer, EXCUROS_SKIN, KRATORS_SHARD, LAKINS_MACE, TIMAK_ORCS_BELT) == 12
            if i0 >= 5
              qs.set_cond(5)
            end
            qs.set_memo_state_ex(1, 0)
          end
        end
      when ENCHANTED_MONSTEREYE
        if qs.memo_state?(1) && has_quest_items?(killer, ORDER_OREN)
          i0 = qs.get_memo_state_ex(1)
          qs.set_memo_state_ex(1, i0 + 1)
          if give_item_randomly(killer, npc, ENCHANTED_EYE_MEAT, 1, 10, 1.0, true) && get_quest_items_count(killer, PUNCHERS_SHARD, NOBLE_ANTS_FEELER, DRONES_CHITIN, DEAD_SEEKER_FANG, OVERLORD_NECKLACE, FETTERED_SOULS_CHAIN, CHIEDS_AMULET, TAMRIN_ORCS_RING, TAMRIN_ORCS_ARROW) == 90
            if i0 >= 9
              qs.set_cond(3)
            end
            qs.set_memo_state_ex(1, 0)
          end
        end
      when LETO_LIZARDMAN_OVERLORD
        if qs.memo_state?(1) && has_quest_items?(killer, ORDER_OREN)
          i0 = qs.get_memo_state_ex(1)
          qs.set_memo_state_ex(1, i0 + 1)
          if give_item_randomly(killer, npc, CHIEDS_AMULET, 1, 10, 1.0, true) && get_quest_items_count(killer, PUNCHERS_SHARD, NOBLE_ANTS_FEELER, DRONES_CHITIN, DEAD_SEEKER_FANG, OVERLORD_NECKLACE, FETTERED_SOULS_CHAIN, ENCHANTED_EYE_MEAT, TAMRIN_ORCS_RING, TAMRIN_ORCS_ARROW) == 90
            if i0 >= 9
              qs.set_cond(3)
            end
            qs.set_memo_state_ex(1, 0)
          end
        end
      when TIMAK_ORC_OVERLORD
        if qs.memo_state?(2) && has_quest_items?(killer, FINAL_ORDER)
          i0 = qs.get_memo_state_ex(1)
          qs.set_memo_state_ex(1, i0 + 1)
          if give_item_randomly(killer, npc, TIMAK_ORCS_BELT, 1, 3, 1.0, true) && get_quest_items_count(killer, EXCUROS_SKIN, KRATORS_SHARD, LAKINS_MACE, GRANDIS_SKIN) == 12
            if i0 >= 5
              qs.set_cond(5)
            end
            qs.set_memo_state_ex(1, 0)
          end
        end
      when TAMLIN_ORC
        if qs.memo_state?(1) && has_quest_items?(killer, ORDER_ADEN)
          i0 = qs.get_memo_state_ex(1)
          qs.set_memo_state_ex(1, i0 + 1)
          if give_item_randomly(killer, npc, TAMRIN_ORCS_RING, 1, 10, 1.0, true) && get_quest_items_count(killer, PUNCHERS_SHARD, NOBLE_ANTS_FEELER, DRONES_CHITIN, DEAD_SEEKER_FANG, OVERLORD_NECKLACE, FETTERED_SOULS_CHAIN, CHIEDS_AMULET, ENCHANTED_EYE_MEAT, TAMRIN_ORCS_ARROW) == 90
            if i0 >= 9
              qs.set_cond(3)
            end
            qs.set_memo_state_ex(1, 0)
          end
        end
      when TAMLIN_ORC_ARCHER
        if qs.memo_state?(1) && has_quest_items?(killer, ORDER_ADEN)
          i0 = qs.get_memo_state_ex(1)
          qs.set_memo_state_ex(1, i0 + 1)
          if give_item_randomly(killer, npc, TAMRIN_ORCS_ARROW, 1, 10, 1.0, true) && get_quest_items_count(killer, PUNCHERS_SHARD, NOBLE_ANTS_FEELER, DRONES_CHITIN, DEAD_SEEKER_FANG, OVERLORD_NECKLACE, FETTERED_SOULS_CHAIN, CHIEDS_AMULET, ENCHANTED_EYE_MEAT, TAMRIN_ORCS_RING) == 90
            if i0 >= 9
              qs.set_cond(3)
            end
            qs.set_memo_state_ex(1, 0)
          end
        end
      when LAKIN
        if qs.memo_state?(2) && has_quest_items?(killer, FINAL_ORDER)
          i0 = qs.get_memo_state_ex(1)
          qs.set_memo_state_ex(1, i0 + 1)
          if give_item_randomly(killer, npc, LAKINS_MACE, 1, 3, 1.0, true) && get_quest_items_count(killer, EXCUROS_SKIN, KRATORS_SHARD, GRANDIS_SKIN, TIMAK_ORCS_BELT) == 12
            if i0 >= 5
              qs.set_cond(5)
            end
            qs.set_memo_state_ex(1, 0)
          end
        end
      end
    end

    super
  end

  def on_talk(npc, pc)
    qs = get_quest_state!(pc)

    if qs.created?
      if pc.class_id.warrior? || pc.class_id.elven_knight? || pc.class_id.palus_knight? || pc.class_id.orc_monk?
        if pc.level >= MIN_LEVEL
          html = "30623-03.htm"
        else
          html = "30623-01.html"
        end
      else
        html = "30623-02.html"
      end
    elsif qs.started?
      if has_quest_items?(pc, ORDER_GLUDIO, ORDER_DION, ORDER_GIRAN, ORDER_OREN, ORDER_ADEN)
        if get_quest_items_count(pc, PUNCHERS_SHARD, NOBLE_ANTS_FEELER, DRONES_CHITIN, DEAD_SEEKER_FANG, OVERLORD_NECKLACE, FETTERED_SOULS_CHAIN, CHIEDS_AMULET, ENCHANTED_EYE_MEAT, TAMRIN_ORCS_RING, TAMRIN_ORCS_ARROW) == 100
          html = "30623-13.html"
        else
          html = "30623-14.html"
        end
      elsif has_quest_items?(pc, FINAL_ORDER)
        if get_quest_items_count(pc, EXCUROS_SKIN, KRATORS_SHARD, LAKINS_MACE, GRANDIS_SKIN, TIMAK_ORCS_BELT) == 15
          give_adena(pc, 161806, true)
          give_items(pc, MARK_OF_DUELIST, 1)
          add_exp_and_sp(pc, 894888, 61408)
          qs.exit_quest(false, true)
          pc.send_packet(SocialAction.new(pc.l2id, 3))
          html = "30623-18.html"
        else
          html = "30623-17.html"
        end
      end
    elsif qs.completed?
      html = get_already_completed_msg(pc)
    end

    html || get_no_quest_msg(pc)
  end
end
