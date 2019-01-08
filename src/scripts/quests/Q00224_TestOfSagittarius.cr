class Quests::Q00224_TestOfSagittarius < Quest
  # NPCs
  private PREFECT_VOKIAN = 30514
  private SAGITTARIUS_HAMIL = 30626
  private SIR_ARON_TANFORD = 30653
  private GUILD_PRESIDENT_BERNARD = 30702
  private MAGISTER_GAUEN = 30717
  # Items
  private WOODEN_ARROW = 17
  private CRESCENT_MOON_BOW = 3028
  private BERNARDS_INTRODUCTION = 3294
  private HAMILS_1ST_LETTER = 3295
  private HAMILS_2ND_LETTER = 3296
  private HAMILS_3RD_LETTER = 3297
  private HUNTERS_1ST_RUNE = 3298
  private HUNTERS_2ND_RUNE = 3299
  private TALISMAN_OF_KADESH = 3300
  private TALISMAN_OF_SNAKE = 3301
  private MITHRIL_CLIP = 3302
  private STAKATO_CHITIN = 3303
  private REINFORCED_BOWSTRING = 3304
  private MANASHENS_HORN = 3305
  private BLOOD_OF_LIZARDMAN = 3306
  # Reward
  private MARK_OF_SAGITTARIUS = 3293
  private DIMENSIONAL_DIAMOND = 7562
  # Monster
  private ANT = 20079
  private ANT_CAPTAIN = 20080
  private ANT_OVERSEER = 20081
  private ANT_RECRUIT = 20082
  private ANT_PATROL = 20084
  private ANT_GUARD = 20086
  private NOBLE_ANT = 20089
  private NOBLE_ANT_LEADER = 20090
  private MARSH_STAKATO_WORKER = 20230
  private MARSH_STAKATO_SOLDIER = 20232
  private MARSH_SPIDER = 20233
  private MARSH_STAKATO_DRONE = 20234
  private BREKA_ORC_SHAMAN = 20269
  private BREKA_ORC_OVERLORD = 20270
  private ROAD_SCAVENGER = 20551
  private MANASHEN_GARGOYLE = 20563
  private LETO_LIZARDMAN = 20577
  private LETO_LIZARDMAN_ARCHER = 20578
  private LETO_LIZARDMAN_SOLDIER = 20579
  private LETO_LIZARDMAN_WARRIOR = 20580
  private LETO_LIZARDMAN_SHAMAN = 20581
  private LETO_LIZARDMAN_OVERLORD = 20582
  # Quest Monster
  private SERPENT_DEMON_KADESH = 27090
  # Misc
  private MIN_LEVEL = 39

  def initialize
    super(224, self.class.simple_name, "Test Of Sagittarius")

    add_start_npc(GUILD_PRESIDENT_BERNARD)
    add_talk_id(GUILD_PRESIDENT_BERNARD, PREFECT_VOKIAN, SAGITTARIUS_HAMIL, SIR_ARON_TANFORD, MAGISTER_GAUEN)
    add_kill_id(ANT, ANT_CAPTAIN, ANT_OVERSEER, ANT_RECRUIT, ANT_PATROL, ANT_GUARD, NOBLE_ANT, NOBLE_ANT_LEADER, MARSH_STAKATO_WORKER, MARSH_STAKATO_SOLDIER, MARSH_SPIDER, MARSH_STAKATO_DRONE, BREKA_ORC_SHAMAN, BREKA_ORC_OVERLORD, ROAD_SCAVENGER, MANASHEN_GARGOYLE, LETO_LIZARDMAN, LETO_LIZARDMAN_ARCHER, LETO_LIZARDMAN_SOLDIER, LETO_LIZARDMAN_WARRIOR, LETO_LIZARDMAN_SHAMAN, LETO_LIZARDMAN_OVERLORD, SERPENT_DEMON_KADESH)
    register_quest_items(CRESCENT_MOON_BOW, BERNARDS_INTRODUCTION, HAMILS_1ST_LETTER, HAMILS_2ND_LETTER, HAMILS_3RD_LETTER, HUNTERS_1ST_RUNE, HUNTERS_2ND_RUNE, TALISMAN_OF_KADESH, TALISMAN_OF_SNAKE, MITHRIL_CLIP, STAKATO_CHITIN, REINFORCED_BOWSTRING, MANASHENS_HORN, BLOOD_OF_LIZARDMAN)
  end

  def on_adv_event(event, npc, player)
    return unless player
    return unless qs = get_quest_state(player, false)

    case event
    when "ACCEPT"
      if qs.created?
        qs.start_quest
        qs.memo_state = 1
        play_sound(player, Sound::ITEMSOUND_QUEST_MIDDLE)
        give_items(player, BERNARDS_INTRODUCTION, 1)
        if player.variables.get_i32("2ND_CLASS_DIAMOND_REWARD", 0) == 0
          give_items(player, DIMENSIONAL_DIAMOND, 96)
          player.variables["2ND_CLASS_DIAMOND_REWARD"] = 1
          htmltext = "30702-04a.htm"
        else
          htmltext = "30702-04.htm"
        end
      end
    when "30514-02.html"
      if has_quest_items?(player, HAMILS_2ND_LETTER)
        take_items(player, HAMILS_2ND_LETTER, 1)
        qs.memo_state = 6
        qs.set_cond(6, true)
        htmltext = event
      end
    when "30626-02.html", "30626-06.html"
      htmltext = event
    when "30626-03.html"
      if has_quest_items?(player, BERNARDS_INTRODUCTION)
        take_items(player, BERNARDS_INTRODUCTION, 1)
        give_items(player, HAMILS_1ST_LETTER, 1)
        qs.memo_state = 2
        qs.set_cond(2, true)
        htmltext = event
      end
    when "30626-07.html"
      if get_quest_items_count(player, HUNTERS_1ST_RUNE) >= 10
        give_items(player, HAMILS_2ND_LETTER, 1)
        take_items(player, HUNTERS_1ST_RUNE, -1)
        qs.memo_state = 5
        qs.set_cond(5, true)
        htmltext = event
      end
    when "30653-02.html"
      if has_quest_items?(player, HAMILS_1ST_LETTER)
        take_items(player, HAMILS_1ST_LETTER, 1)
        qs.memo_state = 3
        qs.set_cond(3, true)
        htmltext = event
      end
    end

    htmltext
  end

  def on_kill(npc, killer, is_summon)
    qs = get_quest_state(killer, false)
    if qs && qs.started? && Util.in_range?(1500, npc, killer, true)
      case npc.id
      when ANT, ANT_CAPTAIN, ANT_OVERSEER, ANT_RECRUIT, ANT_PATROL,
           ANT_GUARD, NOBLE_ANT, NOBLE_ANT_LEADER
        if qs.memo_state?(3) && get_quest_items_count(killer, HUNTERS_1ST_RUNE) < 10
          if get_quest_items_count(killer, HUNTERS_1ST_RUNE) == 9
            give_items(killer, HUNTERS_1ST_RUNE, 1)
            qs.memo_state = 4
            qs.set_cond(4, true)
          else
            give_items(killer, HUNTERS_1ST_RUNE, 1)
            play_sound(killer, Sound::ITEMSOUND_QUEST_ITEMGET)
          end
        end
      when MARSH_STAKATO_WORKER, MARSH_STAKATO_SOLDIER, MARSH_STAKATO_DRONE
        if qs.memo_state?(10) && !has_quest_items?(killer, STAKATO_CHITIN)
          if has_quest_items?(killer, MITHRIL_CLIP, REINFORCED_BOWSTRING, MANASHENS_HORN)
            give_items(killer, STAKATO_CHITIN, 1)
            qs.memo_state = 11
            qs.set_cond(11, true)
          else
            give_items(killer, STAKATO_CHITIN, 1)
            play_sound(killer, Sound::ITEMSOUND_QUEST_ITEMGET)
          end
        end
      when MARSH_SPIDER
        if qs.memo_state?(10) && !has_quest_items?(killer, REINFORCED_BOWSTRING)
          if has_quest_items?(killer, MITHRIL_CLIP, MANASHENS_HORN, STAKATO_CHITIN)
            give_items(killer, REINFORCED_BOWSTRING, 1)
            qs.memo_state = 11
            qs.set_cond(11, true)
          else
            give_items(killer, REINFORCED_BOWSTRING, 1)
            play_sound(killer, Sound::ITEMSOUND_QUEST_ITEMGET)
          end
        end
      when BREKA_ORC_SHAMAN, BREKA_ORC_OVERLORD
        if qs.memo_state?(6) && get_quest_items_count(killer, HUNTERS_2ND_RUNE) < 10
          if get_quest_items_count(killer, HUNTERS_2ND_RUNE) == 9
            give_items(killer, HUNTERS_2ND_RUNE, 1)
            give_items(killer, TALISMAN_OF_SNAKE, 1)
            qs.memo_state = 7
            qs.set_cond(7, true)
          else
            give_items(killer, HUNTERS_2ND_RUNE, 1)
            play_sound(killer, Sound::ITEMSOUND_QUEST_ITEMGET)
          end
        end
      when ROAD_SCAVENGER
        if qs.memo_state?(10) && !has_quest_items?(killer, MITHRIL_CLIP)
          if has_quest_items?(killer, REINFORCED_BOWSTRING, MANASHENS_HORN, STAKATO_CHITIN)
            give_items(killer, MITHRIL_CLIP, 1)
            qs.memo_state = 11
            qs.set_cond(11, true)
          else
            give_items(killer, MITHRIL_CLIP, 1)
            play_sound(killer, Sound::ITEMSOUND_QUEST_ITEMGET)
          end
        end
      when MANASHEN_GARGOYLE
        if qs.memo_state?(10) && !has_quest_items?(killer, MANASHENS_HORN)
          if has_quest_items?(killer, MITHRIL_CLIP, REINFORCED_BOWSTRING, STAKATO_CHITIN)
            give_items(killer, MANASHENS_HORN, 1)
            qs.memo_state = 11
            qs.set_cond(11, true)
          else
            give_items(killer, MANASHENS_HORN, 1)
            play_sound(killer, Sound::ITEMSOUND_QUEST_ITEMGET)
          end
        end
      when LETO_LIZARDMAN,
           LETO_LIZARDMAN_ARCHER,
           LETO_LIZARDMAN_SOLDIER,
           LETO_LIZARDMAN_WARRIOR,
           LETO_LIZARDMAN_SHAMAN,
           LETO_LIZARDMAN_OVERLORD
        if qs.memo_state?(13) && get_quest_items_count(killer, BLOOD_OF_LIZARDMAN) < 140
          if (get_quest_items_count(killer, BLOOD_OF_LIZARDMAN) - 10) * 5 > Rnd.rand(100)
            add_spawn(SERPENT_DEMON_KADESH, npc, true, 300000)
            take_items(killer, BLOOD_OF_LIZARDMAN, -1)
            play_sound(killer, Sound::ITEMSOUND_QUEST_BEFORE_BATTLE)
          else
            give_items(killer, BLOOD_OF_LIZARDMAN, 1)
            play_sound(killer, Sound::ITEMSOUND_QUEST_ITEMGET)
          end
        end
      when SERPENT_DEMON_KADESH
        if qs.memo_state?(13) && !has_quest_items?(killer, TALISMAN_OF_KADESH)
          if npc.killing_blow_weapon == CRESCENT_MOON_BOW
            give_items(killer, TALISMAN_OF_KADESH, 1)
            qs.memo_state = 14
            qs.set_cond(14, true)
          else
            add_spawn(SERPENT_DEMON_KADESH, npc, true, 300000)
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
      if npc.id == GUILD_PRESIDENT_BERNARD
        if player.class_id.rogue? || player.class_id.elven_scout? || player.class_id.assassin?
          if player.level >= MIN_LEVEL
            htmltext = "30702-03.htm"
          else
            htmltext = "30702-01.html"
          end
        else
          htmltext = "30702-02.html"
        end
      end
    elsif qs.started?
      case npc.id
      when GUILD_PRESIDENT_BERNARD
        if has_quest_items?(player, BERNARDS_INTRODUCTION)
          htmltext = "30702-05.html"
        end
      when PREFECT_VOKIAN
        if memo_state == 5
          if has_quest_items?(player, HAMILS_2ND_LETTER)
            htmltext = "30514-01.html"
          end
        elsif memo_state == 6
          htmltext = "30514-03.html"
        elsif memo_state == 7
          if has_quest_items?(player, TALISMAN_OF_SNAKE)
            take_items(player, TALISMAN_OF_SNAKE, 1)
            qs.memo_state = 8
            qs.set_cond(8, true)
            htmltext = "30514-04.html"
          end
        elsif memo_state == 8
          htmltext = "30514-05.html"
        end
      when SAGITTARIUS_HAMIL
        if memo_state == 1
          if has_quest_items?(player, BERNARDS_INTRODUCTION)
            htmltext = "30626-01.html"
          end
        elsif memo_state == 2
          if has_quest_items?(player, HAMILS_1ST_LETTER)
            htmltext = "30626-04.html"
          end
        elsif memo_state == 4
          if get_quest_items_count(player, HUNTERS_1ST_RUNE) == 10
            htmltext = "30626-05.html"
          end
        elsif memo_state == 5
          if has_quest_items?(player, HAMILS_2ND_LETTER)
            htmltext = "30626-08.html"
          end
        elsif memo_state == 8
          give_items(player, HAMILS_3RD_LETTER, 1)
          take_items(player, HUNTERS_2ND_RUNE, -1)
          qs.memo_state = 9
          qs.set_cond(9, true)
          htmltext = "30626-09.html"
        elsif memo_state == 9
          if has_quest_items?(player, HAMILS_3RD_LETTER)
            htmltext = "30626-10.html"
          end
        elsif memo_state == 12
          if has_quest_items?(player, CRESCENT_MOON_BOW)
            qs.set_cond(13, true)
            qs.memo_state = 13
            htmltext = "30626-11.html"
          end
        elsif memo_state == 13
          htmltext = "30626-12.html"
        elsif memo_state == 14
          if has_quest_items?(player, TALISMAN_OF_KADESH)
            give_adena(player, 161806, true)
            give_items(player, MARK_OF_SAGITTARIUS, 1)
            add_exp_and_sp(player, 894888, 61408)
            qs.exit_quest(false, true)
            player.send_packet(SocialAction.new(player.l2id, 3))
            htmltext = "30626-13.html"
          end
        end
      when SIR_ARON_TANFORD
        if memo_state == 2
          if has_quest_items?(player, HAMILS_1ST_LETTER)
            htmltext = "30653-01.html"
          end
        elsif memo_state == 3
          htmltext = "30653-03.html"
        end
      when MAGISTER_GAUEN
        if memo_state == 9
          if has_quest_items?(player, HAMILS_3RD_LETTER)
            take_items(player, HAMILS_3RD_LETTER, 1)
            qs.memo_state = 10
            qs.set_cond(10, true)
            htmltext = "30717-01.html"
          end
        elsif memo_state == 10
          htmltext = "30717-03.html"
        elsif memo_state == 12
          htmltext = "30717-04.html"
        elsif memo_state == 11
          if has_quest_items?(player, STAKATO_CHITIN, MITHRIL_CLIP, REINFORCED_BOWSTRING, MANASHENS_HORN)
            give_items(player, WOODEN_ARROW, 10)
            give_items(player, CRESCENT_MOON_BOW, 1)
            take_items(player, MITHRIL_CLIP, 1)
            take_items(player, STAKATO_CHITIN, 1)
            take_items(player, REINFORCED_BOWSTRING, 1)
            take_items(player, MANASHENS_HORN, 1)
            qs.memo_state = 12
            qs.set_cond(12, true)
            htmltext = "30717-02.html"
          end
        end
      end
    elsif qs.completed?
      if npc.id == GUILD_PRESIDENT_BERNARD
        htmltext = get_already_completed_msg(player)
      end
    end

    htmltext
  end
end
