class Scripts::Q00236_SeedsOfChaos < Quest
  # NPCs
  private KURSTIN = 31387
  private MYSTERIOU_WIZARD = 31522
  private HIERARCH_KEKROPUS = 32138
  private VICE_HIERARCH_MAO = 32190
  private KATENAR = 32235
  private HARKILGAMED = 32236
  private RODENPICULA = 32237
  private ROCK = 32238
  private MOTHER_NORNIL = 32239
  private KATENAR_A = 32332
  private KATENAR_B = 32333
  private HARKILGAMED_A = 32334
  # Items
  private STAR_OF_DESTINY = 5011
  private SHINING_MEDALLION = 9743
  private BLOOD_JEWEL = 9744
  private BLACK_ECHO_CRYSTAL = 9745
  # Reward
  private SCROLL_ENCHANT_WEAPON_A_GRADE = 729
  # Monster
  private NEEDLE_STAKATO_DRONE = 21516
  private SHOUT_OF_SPLENDOR = 21532
  private ALLIANCE_OF_SPLENDOR = 21533
  private ALLIANCE_OF_SPLENDOR_1 = 21534
  private SIGNET_OF_SPLENDOR = 21535
  private CROWN_OF_SPLENDOR = 21536
  private FANG_OF_SPLENDOR = 21537
  private FANG_OF_SPLENDOR_1 = 21538
  private WAILINGOF_SPLENDOR = 21539
  private WAILINGOF_SPLENDOR_1 = 21540
  private VAMPIRE_WIZARD = 21588
  private VAMPIRE_WIZARD_A = 21589
  # Misc
  private MIN_LEVEL = 75

  def initialize
    super(236, self.class.simple_name, "Seeds Of Chaos")

    add_start_npc(HIERARCH_KEKROPUS)
    add_talk_id(
      HIERARCH_KEKROPUS, KURSTIN, MYSTERIOU_WIZARD, VICE_HIERARCH_MAO, KATENAR,
      HARKILGAMED, RODENPICULA, ROCK, MOTHER_NORNIL, KATENAR_A, KATENAR_B,
      HARKILGAMED_A
    )
    add_kill_id(
      NEEDLE_STAKATO_DRONE, SHOUT_OF_SPLENDOR, ALLIANCE_OF_SPLENDOR,
      ALLIANCE_OF_SPLENDOR_1, SIGNET_OF_SPLENDOR, CROWN_OF_SPLENDOR,
      FANG_OF_SPLENDOR, FANG_OF_SPLENDOR_1, WAILINGOF_SPLENDOR,
      WAILINGOF_SPLENDOR_1, VAMPIRE_WIZARD, VAMPIRE_WIZARD_A
    )
    add_spawn_id(KATENAR, HARKILGAMED, KATENAR_A, KATENAR_B, HARKILGAMED_A)
    register_quest_items(SHINING_MEDALLION, BLOOD_JEWEL, BLACK_ECHO_CRYSTAL)
  end

  def on_adv_event(event, npc, pc)
    if event == "KATENAR_120"
      npc = npc.not_nil!
      c0 = npc.variables.get_object("player0", L2PcInstance?)
      npc0 = npc.variables.get_object("npc0", L2Npc?)
      if npc0
        if npc0.variables.get_bool("SPAWNED")
          npc0.variables["SPAWNED"] = false
          if c0
            npc.broadcast_packet(NpcSay.new(npc, Say2::NPC_ALL, NpcString::HMM_WHERE_DID_MY_FRIEND_GO))
          end
        end
      end
      npc.delete_me
      return super
    elsif "HARKILGAMED_120" == event
      npc = npc.not_nil!
      npc0 = npc.variables.get_object("npc0", L2Npc?)
      if npc0
        if npc0.variables.get_bool("SPAWNED")
          npc0.variables["SPAWNED"] = false
          npc.broadcast_packet(NpcSay.new(npc, Say2::NPC_ALL, NpcString::GRAAAH_WERE_BEING_ATTACKED))
        end
      end
      npc.delete_me
      return super
    elsif "KATENAR_A_120" == event
      npc = npc.not_nil!
      c0 = npc.variables.get_object("player0", L2PcInstance?)
      npc0 = npc.variables.get_object("npc0", L2Npc?)
      if npc0
        if npc0.variables.get_bool("SPAWNED")
          npc0.variables["SPAWNED"] = false
          if c0
            npc.broadcast_packet(NpcSay.new(npc, Say2::NPC_ALL, NpcString::HMM_WHERE_DID_MY_FRIEND_GO))
          end
        end
      end
      npc.delete_me
      return super
    elsif "KATENAR_B_120" == event
      npc = npc.not_nil!
      c0 = npc.variables.get_object("player0", L2PcInstance?)
      npc0 = npc.variables.get_object("npc0", L2Npc?)
      if npc0
        if npc0.variables.get_bool("SPAWNED")
          npc0.variables["SPAWNED"] = false
          if c0
            npc.broadcast_packet(NpcSay.new(npc, Say2::NPC_ALL, NpcString::HMM_WHERE_DID_MY_FRIEND_GO))
          end
        end
      end
      npc.delete_me
      return super
    elsif "HARKILGAMED_A_120" == event
      npc = npc.not_nil!
      npc0 = npc.variables.get_object("npc0", L2Npc?)
      if npc0
        if npc0.variables.get_bool("SPAWNED")
          npc0.variables["SPAWNED"] = false
          npc.broadcast_packet(NpcSay.new(npc, Say2::NPC_ALL, NpcString::GRAAAH_WERE_BEING_ATTACKED))
        end
      end
      npc.delete_me

      return super
    end

    return unless pc
    return unless qs = get_quest_state(pc, false)

    case event
    when "32138-04.htm"
      if qs.created?
        qs.memo_state = 1
        qs.start_quest
        html = event
      end
    when "32138-03.htm"
      if pc.level >= MIN_LEVEL && pc.race.kamael? && has_quest_items?(pc, STAR_OF_DESTINY)
        html = event
      end
    when "32138-12.html"
      if qs.memo_state?(30)
        qs.memo_state = 40
        qs.set_cond(15, true)
        html = event
      end
    when "31387-03.html"
      if qs.memo_state?(11)
        take_items(pc, BLOOD_JEWEL, -1)
        qs.memo_state = 12
        html = event
      end
    when "31387-05a.html"
      if qs.memo_state?(12)
        if pc.quest_completed?(Q00025_HidingBehindTheTruth.simple_name)
          html = event
        else
          html = "31387-05b.html"
        end
      end
    when "31387-10.html"
      if qs.memo_state?(12)
        qs.memo_state = 20
        qs.set_memo_state_ex(1, 1)
        qs.set_cond(11, true)
        html = event
      elsif qs.memo_state?(20) && qs.get_memo_state_ex(1) == 1
        html = event
      end
    when "31522-04a.html"
      if qs.memo_state?(1)
        html = event
      end
    when "31522-05a.html"
      if qs.memo_state?(1)
        qs.memo_state = 2
        qs.set_cond(2, true)
        html = event
      end
    when "31522-05b.html"
      if qs.memo_state?(1)
        qs.memo_state = 3
        qs.set_memo_state_ex(1, 0)
        qs.set_cond(6, true)
        html = event
      end
    when "31522-09a.html"
      if qs.memo_state?(2) && has_quest_items?(pc, BLACK_ECHO_CRYSTAL)
        take_items(pc, BLACK_ECHO_CRYSTAL, -1)
        qs.memo_state = 6
        qs.set_cond(4, true)
        html = event
      end
    when "31522-12a.html"
      if qs.memo_state?(6)
        npc = npc.not_nil!
        if !npc.variables.get_bool("SPAWNED", false)
          npc.variables["SPAWNED"] = true
          npc.variables["PLAYER_ID"] = pc.l2id
          katenar = add_spawn(KATENAR, pc.x + 10, pc.y + 10, pc.z, +10, false, 0)
          katenar.variables["npc0"] = npc
          katenar.variables["player0"] = pc
          html = event
        elsif npc.variables.get_i32("PLAYER_ID") == pc.l2id
          html = "31522-13a.html"
        else
          html = "31522-14a.html"
        end
      end
    when "31522-09b.html"
      if qs.memo_state?(3) && qs.get_memo_state_ex(1) == 2
        npc = npc.not_nil!
        if !npc.variables.get_bool("SPAWNED", false)
          npc.variables["SPAWNED"] = true
          npc.variables["PLAYER_ID"] = pc.l2id
          katenar = add_spawn(KATENAR_A, pc.x + 10, pc.y + 10, pc.z, +10, false, 0)
          katenar.variables["npc0"] = npc
          katenar.variables["player0"] = pc
          html = event
        elsif npc.variables.get_i32("PLAYER_ID") == pc.l2id
          html = "31522-10b.html"
        else
          html = "31522-11b.html"
        end
      end
    when "31522-14b.html"
      if qs.memo_state?(7) && has_quest_items?(pc, BLOOD_JEWEL)
        npc = npc.not_nil!
        if !npc.variables.get_bool("SPAWNED", false)
          npc.variables["SPAWNED"] = true
          npc.variables["PLAYER_ID"] = pc.l2id
          katenar = add_spawn(KATENAR_B, pc.x + 10, pc.y + 10, pc.z, +10, false, 0)
          katenar.variables["npc0"] = npc
          katenar.variables["player0"] = pc
          html = event
        elsif npc.variables.get_i32("PLAYER_ID") == pc.l2id
          html = "31522-15b.html"
        else
          html = "31522-15bz.html"
        end
      end
    when "32235-09a.html"
      if qs.memo_state?(6)
        qs.memo_state = 20
        qs.set_memo_state_ex(1, 0)
        qs.set_cond(5, true)
        html = event
      end
    when "32236-07.html"
      if qs.memo_state?(20)
        npc = npc.not_nil!
        c0 = npc.variables.get_object("player0", L2PcInstance?)
        if c0
          qs.memo_state = 21
          qs.set_memo_state_ex(1, 0)
          qs.set_cond(12, true)
        end
        html = event
      end
    when "32237-10.html"
      if qs.memo_state?(40)
        html = event
      end
    when "32237-11.html"
      if qs.memo_state?(40)
        qs.memo_state = 42
        qs.set_cond(17, true)
        html = event
      end
    when "32237-13.html"
      if qs.memo_state?(43)
        qs.memo_state = 44
        qs.set_cond(19, true)
        html = event
      end
    when "32237-17.html"
      if qs.memo_state?(45)
        give_items(pc, SCROLL_ENCHANT_WEAPON_A_GRADE, 1)
        take_items(pc, STAR_OF_DESTINY, 1)
        qs.exit_quest(false, true)
        html = event
      end
    when "32238-02.html"
      if qs.memo_state?(20)
        npc = npc.not_nil!
        if !npc.variables.get_bool("SPAWNED", false)
          npc.variables["SPAWNED"] = true
          npc.variables["PLAYER_ID"] = pc.l2id
          kamael = add_spawn(HARKILGAMED, 71722, -78853, -4464, 0, false, 0)
          kamael.variables["npc0"] = npc
          kamael.variables["player0"] = pc
          html = event
        elsif npc.variables.get_i32("PLAYER_ID") == pc.l2id
          html = "32238-03.html"
        else
          html = "32238-04z.html"
        end
      end
    when "32238-06.html"
      if qs.memo_state?(22)
        npc = npc.not_nil!
        if !npc.variables.get_bool("SPAWNED", false)
          npc.variables["SPAWNED"] = true
          npc.variables["PLAYER_ID"] = pc.l2id
          kamael = add_spawn(HARKILGAMED_A, 71722, -78853, -4464, 0, false, 0)
          kamael.variables["npc0"] = npc
          kamael.variables["player0"] = pc
          html = event
        elsif npc.variables.get_i32("PLAYER_ID") == pc.l2id
          html = "32238-07.html"
        else
          html = "32238-08.html"
        end
      end
    when "32239-04.html"
      if qs.memo_state?(42)
        qs.memo_state = 43
        qs.set_cond(18, true)
        html = event
      end
    when "32239-08.html"
      if qs.memo_state?(44)
        qs.memo_state = 45
        qs.set_cond(20, true)
        html = event
      end
    when "32332-05b.html"
      if qs.memo_state?(3) && qs.get_memo_state_ex(1) == 2
        npc = npc.not_nil!
        c0 = npc.variables.get_object("player0", L2PcInstance?)
        if c0
          qs.memo_state = 7
          qs.set_memo_state_ex(1, 0)
          qs.set_cond(8, true)
        end
        html = event
      end
    when "32334-17.html"
      if qs.memo_state?(22)
        npc = npc.not_nil!
        c0 = npc.variables.get_object("player0", L2PcInstance?)
        if c0
          take_items(pc, SHINING_MEDALLION, -1)
          qs.memo_state = 30
          qs.set_cond(14, true)
        end
        html = event
      end
    when "KEITNAR_DESPAWN"
      if qs.memo_state?(20) && qs.get_memo_state_ex(1) == 0
        npc = npc.not_nil!
        c0 = npc.variables.get_object("player0", L2PcInstance?)
        npc0 = npc.variables.get_object("npc0", L2Npc?)
        if pc == c0
          if npc0
            npc0.variables["SPAWNED"] = false
          end
          npc.broadcast_packet(NpcSay.new(npc, Say2::NPC_ALL, NpcString::BEST_OF_LUCK_WITH_YOUR_FUTURE_ENDEAVOURS))
          npc.delete_me
        end
      end
    when "HARKILGAMED_DESPAWN"
      if qs.memo_state?(21)
        npc = npc.not_nil!
        c0 = npc.variables.get_object("player0", L2PcInstance?)
        npc0 = npc.variables.get_object("npc0", L2Npc?)
        if pc == c0
          if npc0
            npc0.variables["SPAWNED"] = false
          end
          npc.broadcast_packet(NpcSay.new(npc, Say2::NPC_ALL, NpcString::IN_THAT_CASE_I_WISH_YOU_GOOD_LUCK))
          npc.delete_me
        end
      end
    when "KEITNAR_A_DESPAWN"
      npc = npc.not_nil!
      c0 = npc.variables.get_object("player0", L2PcInstance?)
      npc0 = npc.variables.get_object("npc0", L2Npc?)
      if pc == c0
        if npc0
          npc0.variables["SPAWNED"] = false
        end
        npc.broadcast_packet(NpcSay.new(npc, Say2::NPC_ALL, NpcString::BEST_OF_LUCK_WITH_YOUR_FUTURE_ENDEAVOURS))
        npc.delete_me
      end
    when "KEITNAR_B_DESPAWN"
      npc = npc.not_nil!
      if qs.memo_state?(11) && has_quest_items?(pc, BLOOD_JEWEL)
        c0 = npc.variables.get_object("player0", L2PcInstance?)
        npc0 = npc.variables.get_object("npc0", L2Npc?)
        if pc == c0
          if npc0
            npc0.variables["SPAWNED"] = false
          end
          npc.broadcast_packet(NpcSay.new(npc, Say2::NPC_ALL, NpcString::BEST_OF_LUCK_WITH_YOUR_FUTURE_ENDEAVOURS))
          npc.delete_me
        end
      end
    when "HARKILGAMED_A_DESPAWN"
      if qs.memo_state?(30)
        npc = npc.not_nil!
        c0 = npc.variables.get_object("player0", L2PcInstance?)
        npc0 = npc.variables.get_object("npc0", L2Npc?)
        if pc == c0
          if npc0
            npc0.variables["SPAWNED"] = false
          end
          npc.broadcast_packet(NpcSay.new(npc, Say2::NPC_ALL, NpcString::SAFE_TRAVELS))
          npc.delete_me
        end
      end
    when "31387-02.html",  "31387-04.html",  "31387-06.html",  "31387-07.html",
         "31387-08.html",  "31522-02.html",  "31522-03.html",  "31522-04b.html",
         "31522-08a.html", "31522-11a.html", "32138-02.html",  "32138-07.html",
         "32138-08.html",  "32138-09.html",  "32138-10.html",  "32138-11.html",
         "32235-02a.html", "32235-03a.html", "32235-04a.html", "32235-05a.html",
         "32235-06a.html", "32235-08a.html", "32236-03.html",  "32236-04.html",
         "32236-05.html",  "32236-06.html",  "32237-02.html",  "32237-03.html",
         "32237-04.html",  "32237-05.html",  "32237-06.html",  "32237-07.html",
         "32237-08.html",  "32237-16.html",  "32237-18.html",  "32239-03.html",
         "32239-07.html",  "32332-02b.html", "32332-03b.html", "32332-04b.html",
         "32334-10.html",  "32334-11.html",  "32334-12.html",  "32334-13.html",
         "32334-14.html",  "32334-15.html",  "32334-16.html"
      html = event
    end


    html
  end

  def on_kill(npc, killer, is_summon)
    qs = get_quest_state(killer, false)
    if qs && qs.started? && Util.in_range?(1500, npc, killer, true)
      case npc.id
      when NEEDLE_STAKATO_DRONE
        if qs.memo_state?(2) && !has_quest_items?(killer, BLACK_ECHO_CRYSTAL)
          if Rnd.rand(100) < 20
            give_items(killer, BLACK_ECHO_CRYSTAL, 1)
            qs.set_cond(3, true)
          end
        end
      when SHOUT_OF_SPLENDOR, ALLIANCE_OF_SPLENDOR, ALLIANCE_OF_SPLENDOR_1, SIGNET_OF_SPLENDOR, CROWN_OF_SPLENDOR, FANG_OF_SPLENDOR, FANG_OF_SPLENDOR_1, WAILINGOF_SPLENDOR, WAILINGOF_SPLENDOR_1
        if qs.memo_state?(21) && get_quest_items_count(killer, SHINING_MEDALLION) < 62
          if Rnd.rand(100) < 70
            give_items(killer, SHINING_MEDALLION, 1)
            if get_quest_items_count(killer, SHINING_MEDALLION) == 62
              qs.memo_state = 22
              qs.set_cond(13, true)
            else
              play_sound(killer, Sound::ITEMSOUND_QUEST_ITEMGET)
            end
          end
        end
      when VAMPIRE_WIZARD, VAMPIRE_WIZARD_A
        if qs.memo_state?(7) && !has_quest_items?(killer, BLOOD_JEWEL)
          if Rnd.rand(100) < 8
            give_items(killer, BLOOD_JEWEL, 1)
            qs.set_cond(9, true)
          end
        end
      end

    end

    super
  end

  def on_talk(npc, pc)
    qs = get_quest_state!(pc)

    if qs.created?
      if npc.id == HIERARCH_KEKROPUS
        if pc.level >= MIN_LEVEL
          if pc.race.kamael?
            if has_quest_items?(pc, STAR_OF_DESTINY)
              html = "32138-01.htm"
            else
              html = "32138-01x.html"
            end
          else
            html = "32138-01y.html"
          end
        else
          html = "32138-01z.html"
        end
      end
    elsif qs.started?
      case npc.id
      when HIERARCH_KEKROPUS
        case qs.memo_state
        when 1
          html = "32138-05.html"
        when 30
          html = "32138-06.html"
        when 40
          html = "32138-13.html"
        end

      when KURSTIN
        case qs.memo_state
        when 11
          html = "31387-01.html"
        when 12
          html = "31387-04.html"
        when 20
          if qs.get_memo_state_ex(1) == 1
            html = "31387-11.html"
          end
        end

      when MYSTERIOU_WIZARD
        case qs.memo_state
        when 1
          html = "31522-01.html"
        when 2
          if !has_quest_items?(pc, BLACK_ECHO_CRYSTAL)
            html = "31522-06a.html"
          else
            html = "31522-07a.html"
          end
        when 6
          html = "31522-10a.html"
        when 20
          if qs.get_memo_state_ex(1) == 0
            html = "31522-15a.html"
          end
        when 3
          if qs.get_memo_state_ex(1) == 0
            qs.set_memo_state_ex(1, 1)
            html = "31522-06b.html"
          elsif qs.get_memo_state_ex(1) == 1
            qs.set_memo_state_ex(1, 2)
            qs.set_cond(7, true)
            html = "31522-07b.html"
          elsif qs.get_memo_state_ex(1) == 2
            html = "31522-08b.html"
          end
        when 7
          if !has_quest_items?(pc, BLOOD_JEWEL)
            html = "31522-12b.html"
          else
            html = "31522-13b.html"
          end
        when 11
          html = "31522-16b.html"
        end

      when VICE_HIERARCH_MAO
        if qs.memo_state >= 40 && qs.memo_state <= 45
          html = "32190-01.html"
        end
      when KATENAR
        case qs.memo_state
        when 6
          c0 = npc.variables.get_object("player0", L2PcInstance?)
          npc0 = npc.variables.get_object("npc0", L2Npc?).not_nil!
          npc0.variables["SPAWNED"] = false
          if pc == c0
            html = "32235-01a.html"
          else
            html = "32235-01z.html"
          end
        when 20
          if qs.get_memo_state_ex(1) == 0
            html = "32235-09z.html"
          end
        end

      when HARKILGAMED
        case qs.memo_state
        when 20
          c0 = npc.variables.get_object("player0", L2PcInstance?)
          npc0 = npc.variables.get_object("npc0", L2Npc?).not_nil!
          npc0.variables["SPAWNED"] = false
          if pc == c0
            html = "32236-01.html"
          else
            html = "32236-02.html"
          end
        when 21
          html = "32236-07z.html"
        when 22
          html = "32236-08z.html"
        end

      when RODENPICULA
        case qs.memo_state
        when 40
          html = "32237-01.html"
        when 42
          html = "32237-11a.html"
        when 43
          html = "32237-12.html"
        when 44
          html = "32237-14.html"
        when 45
          html = "32237-15.html"
        end

      when ROCK
        case qs.memo_state
        when 20
          html = "32238-01.html"
        when 21
          html = "32238-04.html"
        when 22
          html = "32238-05.html"
        when 30
          html = "32238-09.html"
        end

      when MOTHER_NORNIL
        case qs.memo_state
        when 40
          html = "32239-01.html"
        when 42
          html = "32239-02.html"
        when 43
          html = "32239-05.html"
        when 44
          html = "32239-06.html"
        when 45
          html = "32239-09.html"
        end

      when KATENAR_A
        case qs.memo_state
        when 3
          if qs.get_memo_state_ex(1) == 2
            c0 = npc.variables.get_object("player0", L2PcInstance?)
            npc0 = npc.variables.get_object("npc0", L2Npc?).not_nil!
            npc0.variables["SPAWNED"] = false
            if pc == c0
              html = "32332-01b.html"
            else
              html = "32332-01z.html"
            end
          end
        when 7
          if !has_quest_items?(pc, BLOOD_JEWEL)
            html = "32332-05z.html"
          end
        end

      when KATENAR_B
        case qs.memo_state
        when 7
          if has_quest_items?(pc, BLOOD_JEWEL)
            c0 = npc.variables.get_object("player0", L2PcInstance?)
            npc0 = npc.variables.get_object("npc0", L2Npc?).not_nil!
            npc0.variables["SPAWNED"] = false
            if pc == c0
              qs.memo_state = 11
              qs.set_cond(10, true)
              html = "32333-06bz.html"
            else
              qs.memo_state = 11
              qs.set_cond(10, true)
              html = "32333-06b.html"
            end
          end
        when 11
          html = "32333-06b.html"
        end

      when HARKILGAMED_A
        case qs.memo_state
        when 22
          c0 = npc.variables.get_object("player0", L2PcInstance?)
          npc0 = npc.variables.get_object("npc0", L2Npc?).not_nil!
          npc0.variables["SPAWNED"] = false
          if pc == c0
            html = "32334-08.html"
          else
            html = "32334-09.html"
          end
        when 30
          html = "32334-18.html"
        end

      end

    elsif qs.completed?
      if npc.id == HIERARCH_KEKROPUS
        html = get_already_completed_msg(pc)
      end
    end

    html || get_no_quest_msg(pc)
  end

  def on_spawn(npc)
    case npc.id
    when KATENAR
      c0 = npc.variables.get_object("player0", L2PcInstance?)
      start_quest_timer("KATENAR_120", 120000, npc, nil)
      if c0
        npc.broadcast_packet(NpcSay.new(npc, Say2::NPC_ALL, NpcString::S1_FINALLY_WE_MEET).add_string_parameter(c0.appearance.visible_name))
      end
    when HARKILGAMED
      start_quest_timer("HARKILGAMED_120", 120000, npc, nil)
      npc.broadcast_packet(NpcSay.new(npc, Say2::NPC_ALL, NpcString::HMM_IS_SOMEONE_APPROACHING))
    when KATENAR_A
      c0 = npc.variables.get_object("player0", L2PcInstance?)
      start_quest_timer("KATENAR_A_120", 120000, npc, nil)
      if c0
        npc.broadcast_packet(NpcSay.new(npc, Say2::NPC_ALL, NpcString::S1_DID_YOU_WAIT_FOR_LONG).add_string_parameter(c0.appearance.visible_name))
      end
    when KATENAR_B
      c0 = npc.variables.get_object("player0", L2PcInstance?)
      start_quest_timer("KATENAR_B_120", 120000, npc, nil)
      if c0
        npc.broadcast_packet(NpcSay.new(npc, Say2::NPC_ALL, NpcString::DID_YOU_BRING_WHAT_I_ASKED_S1).add_string_parameter(c0.appearance.visible_name))
      end
    when HARKILGAMED_A
      c0 = npc.variables.get_object("player0", L2PcInstance?)
      start_quest_timer("HARKILGAMED_A_120", 120000, npc, nil)
      if c0
        npc.broadcast_packet(NpcSay.new(npc, Say2::NPC_ALL, NpcString::S1_HAS_EVERYTHING_BEEN_FOUND).add_string_parameter(c0.appearance.visible_name))
      end
    end


    super
  end
end
