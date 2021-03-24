class Scripts::Q00064_CertifiedBerserker < Quest
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
    add_talk_id(
      MASTER_ORKURUS, MASTER_ENTIENS, MASTER_TENAIN, CARAVANER_GORT, HARKILGAMED
    )
    add_kill_id(
      DEAD_SEEKER, MARSH_STAKATO_DRONE, BREKA_ORC, BREKA_ORC_ARCHER,
      BREKA_ORC_SHAMAN, BREKA_ORC_OVERLORD, BREKA_ORC_WARRIOR, ROAD_SCAVENGER,
      DIVINE_EMISSARY
    )
    register_quest_items(
      BREKA_ORC_HEAD, MESSAGE_PLATE, REPORT_EAST, REPORT_NORTH,
      HARKILGAMEDS_LETTER, TENAINS_RECOMMENDATION
    )
  end

  def on_adv_event(event, npc, pc)
    return unless pc && (qs = get_quest_state(pc, false))

    case event
    when "ACCEPT"
      if qs.created?
        qs.start_quest
        qs.memo_state = 1
        if pc.variables.get_i32("2ND_CLASS_DIAMOND_REWARD", 0) == 0
          give_items(pc, DIMENSIONAL_DIAMOND, 48)
          pc.variables["2ND_CLASS_DIAMOND_REWARD"] = 1
          html = "32207-06.htm"
        else
          html = "32207-06a.htm"
        end
      end
    when "32207-10.html"
      if qs.memo_state?(11)
        html = event
      end
    when "32207-11.html"
      if qs.memo_state?(11)
        give_adena(pc, 63_104, true)
        give_items(pc, ORKURUS_RECOMMENDATION, 1)
        add_exp_and_sp(pc, 349_006, 23_948)
        qs.exit_quest(false, true)
        pc.send_packet(SocialAction.new(pc.l2id, 3))
        html = event
      end
    when "32215-02.html"
      if qs.memo_state?(1)
        qs.memo_state = 2
        qs.set_cond(2, true)
        html = event
      end
    when "32215-07.html", "32215-08.html", "32215-09.html"
      if qs.memo_state?(5)
        html = event
      end
    when "32215-10.html"
      if qs.memo_state?(5)
        take_items(pc, MESSAGE_PLATE, 1)
        qs.memo_state = 6
        qs.set_cond(8, true)
        html = event
      end
    when "32215-15.html"
      if qs.memo_state?(10)
        take_items(pc, HARKILGAMEDS_LETTER, 1)
        give_items(pc, TENAINS_RECOMMENDATION, 1)
        qs.memo_state = 11
        qs.set_cond(14, true)
        html = event
      end
    when "32252-02.html"
      if qs.memo_state?(3)
        qs.memo_state = 4
        qs.set_cond(5, true)
        html = event
      end
    when "32253-02.html"
      if qs.memo_state?(9)
        give_items(pc, HARKILGAMEDS_LETTER, 1)
        qs.memo_state = 10
        qs.set_cond(13, true)
        html = event
      end
    end

    html
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
             kamael = add_spawn(HARKILGAMED, npc, true, 60_000)
            kamael.broadcast_packet(NpcSay.new(kamael, Say2::NPC_ALL, NpcString::S1_DID_YOU_COME_TO_HELP_ME).add_string_parameter(killer.appearance.visible_name))
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
      if npc.id == MASTER_ORKURUS
        if pc.race.kamael?
          if pc.class_id.trooper?
            if pc.level >= MIN_LEVEL
              html = "32207-01.htm"
            else
              html = "32207-02.html"
            end
          else
            html = "32207-03.html"
          end
        else
          html = "32207-04.html"
        end
      end
    elsif qs.started?
      case npc.id
      when MASTER_ORKURUS
        if memo_state == 1
          html = "32207-07.html"
        elsif memo_state >= 2 && memo_state < 11
          html = "32207-08.html"
        elsif memo_state == 11
          html = "32207-09.html"
        end
      when MASTER_ENTIENS
        if memo_state == 6
          qs.memo_state = 7
          qs.set_cond(9, true)
          pc.radar.add_marker(27956, 106003, -3831)
          pc.radar.add_marker(50568, 152408, -2656)
          html = "32200-01.html"
        elsif memo_state == 7
          if !has_quest_items?(pc, REPORT_EAST, REPORT_NORTH)
            html = "32200-02.html"
          else
            take_items(pc, REPORT_EAST, 1)
            take_items(pc, REPORT_NORTH, 1)
            qs.memo_state = 8
            qs.set_cond(11, true)
            html = "32200-03.html"
          end
        elsif memo_state == 8
          html = "32200-04.html"
        end
      when MASTER_TENAIN
        if memo_state == 1
          html = "32215-01.html"
        elsif memo_state == 2
          if get_quest_items_count(pc, BREKA_ORC_HEAD) < 20
            html = "32215-03.html"
          else
            take_items(pc, BREKA_ORC_HEAD, -1)
            qs.memo_state = 3
            qs.set_cond(4, true)
            html = "32215-04.html"
          end
        elsif memo_state == 3
          html = "32215-05.html"
        elsif memo_state == 5
          html = "32215-06.html"
        elsif memo_state == 6
          html = "32215-11.html"
        elsif memo_state == 8
          qs.memo_state = 9
          qs.set_cond(12, true)
          html = "32215-12.html"
        elsif memo_state == 9
          html = "32215-13.html"
        elsif memo_state == 10
          html = "32215-14.html"
        elsif memo_state == 11
          html = "32215-16.html"
        end
      when CARAVANER_GORT
        if memo_state == 3
          html = "32252-01.html"
        elsif memo_state == 4
          if !has_quest_items?(pc, MESSAGE_PLATE)
            html = "32252-03.html"
          else
            qs.memo_state = 5
            qs.set_cond(7, true)
            html = "32252-04.html"
          end
        elsif memo_state == 5
          html = "32252-05.html"
        end
      when HARKILGAMED
        if memo_state == 9
          html = "32253-01.html"
        elsif memo_state == 10
          html = "32253-03.html"
        end
      end
    elsif qs.completed?
      if npc.id == MASTER_ORKURUS
        html = "32207-05.html"
      end
    end

    html || get_no_quest_msg(pc)
  end
end
