class Quests::Q00064_CertifiedBerserker < Quest
  # NPCs
  private MASTER_ENTIENS = 32200
  private MASTER_ORKURUS = 32207
  private MASTER_TENAIN = 32215
  private CARAVANER_GORT = 32252
  private HARKILGAMED = 32253
  # Items
  private BREKA_ORC_HEAD = 9754
  private MESSAGE_PLATE = 9755
  private REPORT_EAST = 9756
  private REPORT_NORTH = 9757
  private HARKILGAMEDS_LETTER = 9758
  private TENAINS_RECOMMENDATION = 9759
  # Reward
  private DIMENSIONAL_DIAMOND = 7562
  private ORKURUS_RECOMMENDATION = 9760
  # Monster
  private DEAD_SEEKER = 20202
  private MARSH_STAKATO_DRONE = 20234
  private BREKA_ORC = 20267
  private BREKA_ORC_ARCHER = 20268
  private BREKA_ORC_SHAMAN = 20269
  private BREKA_ORC_OVERLORD = 20270
  private BREKA_ORC_WARRIOR = 20271
  private ROAD_SCAVENGER = 20551
  # Quest Monster
  private DIVINE_EMISSARY = 27323
  # Misc
  private MIN_LEVEL = 39

  def initialize
    super(64, self.class.simple_name, "Certified Berserker")

    add_start_npc(MASTER_ORKURUS)
    add_talk_id(MASTER_ORKURUS, MASTER_ENTIENS, MASTER_TENAIN, CARAVANER_GORT, HARKILGAMED)
    add_kill_id(DEAD_SEEKER, MARSH_STAKATO_DRONE, BREKA_ORC, BREKA_ORC_ARCHER, BREKA_ORC_SHAMAN, BREKA_ORC_OVERLORD, BREKA_ORC_WARRIOR, ROAD_SCAVENGER, DIVINE_EMISSARY)
    register_quest_items(BREKA_ORC_HEAD, MESSAGE_PLATE, REPORT_EAST, REPORT_NORTH, HARKILGAMEDS_LETTER, TENAINS_RECOMMENDATION)
  end

  def on_adv_event(event, npc, player)
    return unless player
    return unless qs = get_quest_state(player, false)

    case event
    when "ACCEPT"
      if qs.created?
        qs.start_quest
        qs.memo_state = 1
        if player.variables.get_i32("2ND_CLASS_DIAMOND_REWARD", 0) == 0
          give_items(player, DIMENSIONAL_DIAMOND, 48)
          player.variables["2ND_CLASS_DIAMOND_REWARD"] = 1
          htmltext = "32207-06.htm"
        else
          htmltext = "32207-06a.htm"
        end
      end
    when "32207-10.html"
      if qs.memo_state?(11)
        htmltext = event
      end
    when "32207-11.html"
      if qs.memo_state?(11)
        give_adena(player, 63104, true)
        give_items(player, ORKURUS_RECOMMENDATION, 1)
        add_exp_and_sp(player, 349006, 23948)
        qs.exit_quest(false, true)
        player.send_packet(SocialAction.new(player.l2id, 3))
        htmltext = event
      end
    when "32215-02.html"
      if qs.memo_state?(1)
        qs.memo_state = 2
        qs.set_cond(2, true)
        htmltext = event
      end
    when "32215-07.html", "32215-08.html", "32215-09.html"
      if qs.memo_state?(5)
        htmltext = event
      end
    when "32215-10.html"
      if qs.memo_state?(5)
        take_items(player, MESSAGE_PLATE, 1)
        qs.memo_state = 6
        qs.set_cond(8, true)
        htmltext = event
      end
    when "32215-15.html"
      if qs.memo_state?(10)
        take_items(player, HARKILGAMEDS_LETTER, 1)
        give_items(player, TENAINS_RECOMMENDATION, 1)
        qs.memo_state = 11
        qs.set_cond(14, true)
        htmltext = event
      end
    when "32252-02.html"
      if qs.memo_state?(3)
        qs.memo_state = 4
        qs.set_cond(5, true)
        htmltext = event
      end
    when "32253-02.html"
      if qs.memo_state?(9)
        give_items(player, HARKILGAMEDS_LETTER, 1)
        qs.memo_state = 10
        qs.set_cond(13, true)
        htmltext = event
      end
    end

    htmltext
  end

  def on_kill(npc, killer, is_summon)
    qs = get_quest_state(killer, false)
    if qs && qs.started? && Util.in_range?(1500, npc, killer, true)
      case npc.id
      when DEAD_SEEKER
        if qs.memo_state?(7) && !has_quest_items?(killer, REPORT_EAST)
          if Rnd.rand(100) < 20
            give_items(killer, REPORT_EAST, 1)
            if has_quest_items?(killer, REPORT_NORTH)
              qs.set_cond(10, true)
            else
              play_sound(killer, Sound::ITEMSOUND_QUEST_ITEMGET)
            end
          end
        end
      when MARSH_STAKATO_DRONE
        if qs.memo_state?(7) && !has_quest_items?(killer, REPORT_NORTH)
          if Rnd.rand(100) < 20
            give_items(killer, REPORT_NORTH, 1)
            if has_quest_items?(killer, REPORT_EAST)
              qs.set_cond(10, true)
            else
              play_sound(killer, Sound::ITEMSOUND_QUEST_ITEMGET)
            end
          end
        end
      when BREKA_ORC, BREKA_ORC_ARCHER, BREKA_ORC_SHAMAN, BREKA_ORC_OVERLORD, BREKA_ORC_WARRIOR
        if qs.memo_state?(2) && get_quest_items_count(killer, BREKA_ORC_HEAD) < 20
          if get_quest_items_count(killer, BREKA_ORC_HEAD) >= 19
            give_items(killer, BREKA_ORC_HEAD, 1)
            qs.set_cond(3, true)
          else
            give_items(killer, BREKA_ORC_HEAD, 1)
            play_sound(killer, Sound::ITEMSOUND_QUEST_ITEMGET)
          end
        end
      when ROAD_SCAVENGER
        if qs.memo_state?(4) && !has_quest_items?(killer, MESSAGE_PLATE)
          if Rnd.rand(100) < 20
            give_items(killer, MESSAGE_PLATE, 1)
            qs.set_cond(6, true)
          end
        end
      when DIVINE_EMISSARY
        if qs.memo_state?(9)
          if Rnd.rand(100) < 20
             kamael = add_spawn(HARKILGAMED, npc, true, 60000)
            kamael.broadcast_packet(NpcSay.new(kamael, Say2::NPC_ALL, NpcString::S1_DID_YOU_COME_TO_HELP_ME).add_string_parameter(killer.appearance.visible_name))
            play_sound(killer, Sound::ITEMSOUND_QUEST_MIDDLE)
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
      if npc.id == MASTER_ORKURUS
        if player.race.kamael?
          if player.class_id.trooper?
            if player.level >= MIN_LEVEL
              htmltext = "32207-01.htm"
            else
              htmltext = "32207-02.html"
            end
          else
            htmltext = "32207-03.html"
          end
        else
          htmltext = "32207-04.html"
        end
      end
    elsif qs.started?
      case npc.id
      when MASTER_ORKURUS
        if memo_state == 1
          htmltext = "32207-07.html"
        elsif memo_state >= 2 && memo_state < 11
          htmltext = "32207-08.html"
        elsif memo_state == 11
          htmltext = "32207-09.html"
        end
      when MASTER_ENTIENS
        if memo_state == 6
          qs.memo_state = 7
          qs.set_cond(9, true)
          player.radar.add_marker(27956, 106003, -3831)
          player.radar.add_marker(50568, 152408, -2656)
          htmltext = "32200-01.html"
        elsif memo_state == 7
          if !has_quest_items?(player, REPORT_EAST, REPORT_NORTH)
            htmltext = "32200-02.html"
          else
            take_items(player, REPORT_EAST, 1)
            take_items(player, REPORT_NORTH, 1)
            qs.memo_state = 8
            qs.set_cond(11, true)
            htmltext = "32200-03.html"
          end
        elsif memo_state == 8
          htmltext = "32200-04.html"
        end
      when MASTER_TENAIN
        if memo_state == 1
          htmltext = "32215-01.html"
        elsif memo_state == 2
          if get_quest_items_count(player, BREKA_ORC_HEAD) < 20
            htmltext = "32215-03.html"
          else
            take_items(player, BREKA_ORC_HEAD, -1)
            qs.memo_state = 3
            qs.set_cond(4, true)
            htmltext = "32215-04.html"
          end
        elsif memo_state == 3
          htmltext = "32215-05.html"
        elsif memo_state == 5
          htmltext = "32215-06.html"
        elsif memo_state == 6
          htmltext = "32215-11.html"
        elsif memo_state == 8
          qs.memo_state = 9
          qs.set_cond(12, true)
          htmltext = "32215-12.html"
        elsif memo_state == 9
          htmltext = "32215-13.html"
        elsif memo_state == 10
          htmltext = "32215-14.html"
        elsif memo_state == 11
          htmltext = "32215-16.html"
        end
      when CARAVANER_GORT
        if memo_state == 3
          htmltext = "32252-01.html"
        elsif memo_state == 4
          if !has_quest_items?(player, MESSAGE_PLATE)
            htmltext = "32252-03.html"
          else
            qs.memo_state = 5
            qs.set_cond(7, true)
            htmltext = "32252-04.html"
          end
        elsif memo_state == 5
          htmltext = "32252-05.html"
        end
      when HARKILGAMED
        if memo_state == 9
          htmltext = "32253-01.html"
        elsif memo_state == 10
          htmltext = "32253-03.html"
        end
      end
    elsif qs.completed?
      if npc.id == MASTER_ORKURUS
        htmltext = "32207-05.html"
      end
    end

    htmltext
  end
end
