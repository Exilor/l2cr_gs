class Scripts::Q00065_CertifiedSoulBreaker < Quest
  # NPCs
  private CAPTAIN_LUCAS = 30071
  private JACOB = 30073
  private GUARD_HARLAN = 30074
  private GUARD_XABER = 30075
  private GUARD_LIAM = 30076
  private GUARD_VESA = 30123
  private GUARD_ZEROME = 30124
  private WHARF_MANAGER_FELTON = 30879
  private KEKROPUS = 32138
  private VICE_HIERARCH_CASCA = 32139
  private GRAND_MASTER_HOLST = 32199
  private GRAND_MASTER_VITUS = 32213
  private GRAND_MASTER_MELDINA = 32214
  private KATENAR = 32242
  private CARGO_BOX = 32243
  private SUSPICIOUS_MAN = 32244
  # Items
  private SEALED_DOCUMENT = 9803
  private WYRM_HEART = 9804
  private KEKROPUS_RECOMMENDATION = 9805
  # Reward
  private DIMENSIONAL_DIAMOND = 7562
  private SOUL_BREAKER_CERTIFICATE = 9806
  # Monster
  private WYRM = 20176
  # Quest Monster
  private GUARDIAN_ANGEL = 27332
  # Misc
  private MIN_LEVEL = 39
  # Locations
  private SUSPICIOUS_SPAWN = Location.new(16489, 146249, -3112)
  private MOVE_TO = Location.new(16490, 145839, -3080)

  def initialize
    super(65, self.class.simple_name, "Certified Soul Breaker")

    add_start_npc(GRAND_MASTER_VITUS)
    add_talk_id(
      GRAND_MASTER_VITUS, CAPTAIN_LUCAS, JACOB, GUARD_HARLAN, GUARD_XABER,
      GUARD_LIAM, GUARD_VESA, GUARD_ZEROME, WHARF_MANAGER_FELTON, KEKROPUS,
      VICE_HIERARCH_CASCA, GRAND_MASTER_HOLST, GRAND_MASTER_MELDINA, KATENAR,
      CARGO_BOX, SUSPICIOUS_MAN
    )
    add_kill_id(WYRM, GUARDIAN_ANGEL)
    add_spawn_id(GUARDIAN_ANGEL, SUSPICIOUS_MAN)
    register_quest_items(SEALED_DOCUMENT, WYRM_HEART, KEKROPUS_RECOMMENDATION)
  end

  def on_adv_event(event, npc, pc)
    if event == "DESPAWN_5"
      npc.try &.delete_me
      return super
    elsif event == "DESPAWN_70"
      npc = npc.not_nil!
      npc0 = npc.variables.get_object("npc0", L2Npc?)
      c0 = npc.variables.get_object("player0", L2PcInstance?)
      if npc0
        if npc0.variables.get_bool("SPAWNED")
          npc0.variables["SPAWNED"] = false
          if c0
            npc.broadcast_packet(NpcSay.new(npc, Say2::NPC_ALL, NpcString::S1_I_WILL_BE_BACK_SOON_STAY_THERE_AND_DONT_YOU_DARE_WANDER_OFF).add_string_parameter(c0.appearance.visible_name))
          end
        end
      end

      npc.delete_me
      return super
    end

    return unless pc
    return unless qs = get_quest_state(pc, false)

    case event
    when "ACCEPT"
      if qs.created?
        qs.start_quest
        qs.memo_state = 1
        if pc.variables.get_i32("2ND_CLASS_DIAMOND_REWARD", 0) == 0
          give_items(pc, DIMENSIONAL_DIAMOND, 47)
          pc.variables["2ND_CLASS_DIAMOND_REWARD"] = 1
          html = "32213-05.htm"
        else
          html = "32213-06.htm"
        end
      end
    when "32213-09.html"
      html = event
    when "32213-04.htm"
      if pc.level >= MIN_LEVEL && pc.in_category?(CategoryType::KAMAEL_SECOND_CLASS_GROUP)
        html = event
      end
    when "30071-02.html"
      if qs.memo_state?(7)
        qs.memo_state = 8
        qs.set_cond(8, true)
        html = event
      end
    when "30879-02.html"
      if qs.memo_state?(11)
        html = event
      end
    when "30879-03.html"
      if qs.memo_state?(11)
        qs.memo_state = 12
        qs.set_cond(12, true)
        html = event
      end
    when "32138-02.html", "32138-03.html"
      if qs.memo_state?(1)
        html = event
      end
    when "32138-04.html"
      if qs.memo_state?(1)
        qs.memo_state = 2
        qs.set_cond(2, true)
        html = event
      end
    when "32138-07.html"
      if qs.memo_state?(21)
        qs.memo_state = 22
        qs.set_cond(15, true)
        html = event
      end
    when "32138-10.html", "32138-11.html"
      if qs.memo_state?(23)
        html = event
      end
    when "32138-12.html"
      if qs.memo_state?(23)
        take_items(pc, WYRM_HEART, -1)
        give_items(pc, KEKROPUS_RECOMMENDATION, 1)
        qs.memo_state = 24
        qs.set_cond(17, true)
        html = event
      end
    when "32139-02.html"
      if qs.memo_state?(2)
        qs.memo_state = 3
        qs.set_cond(3, true)
        html = event
      end
    when "32139-04.html"
      if qs.memo_state?(3)
        qs.memo_state = 4
        qs.set_cond(4, true)
        html = event
      end
    when "32139-07.html"
      if qs.memo_state?(14)
        html = event
      end
    when "32139-08.html"
      if qs.memo_state?(14)
        take_items(pc, SEALED_DOCUMENT, -1)
        qs.memo_state = 21
        qs.set_cond(14, true)
        html = event
      end
    when "32199-02.html"
      if qs.memo_state?(4)
        qs.memo_state = 5
        qs.set_cond(5, true)
        add_spawn(npc, SUSPICIOUS_MAN, SUSPICIOUS_SPAWN, false, 0)
        html = event
      end
    when "32214-02.html"
      if qs.memo_state?(10)
        qs.memo_state = 11
        qs.set_cond(11, true)
        html = event
      end
    else
      # [automatically added else]
    end

    html
  end

  def on_kill(npc, killer, is_summon)
    qs = get_quest_state(killer, false)
    if qs && qs.started? && Util.in_range?(1500, npc, killer, true)
      case npc.id
      when WYRM
        if qs.memo_state?(22)
          if give_item_randomly(killer, npc, WYRM_HEART, 1, 10, 0.20, true)
            qs.memo_state = 23
            qs.set_cond(16, true)
          end
        end
      when GUARDIAN_ANGEL
        c0 = npc.variables.get_object("player0", L2PcInstance?)
        npc0 = npc.variables.get_object("npc0", L2Npc?)
        if killer == c0
          if c0
            if qs.memo_state?(12)
              katenar = add_spawn(KATENAR, killer.x + 20, killer.y + 20, killer.z, 0, false, 0)
              katenar.variables["player0"] = killer
              katenar.variables["npc0"] = npc
              qs.memo_state = 13
              npc.broadcast_packet(NpcSay.new(npc, Say2::NPC_ALL, NpcString::GRR_IVE_BEEN_HIT))
            end
          end
        else
          if npc0
            if npc0.variables.get_bool("SPAWNED")
              npc0.variables["SPAWNED"] = false
            end
          end
          npc.broadcast_packet(NpcSay.new(npc, Say2::NPC_ALL, NpcString::GRR_WHO_ARE_YOU_AND_WHY_HAVE_YOU_STOPPED_ME))
        end
      else
        # [automatically added else]
      end
    end

    super
  end

  def on_talk(npc, pc)
    qs = get_quest_state!(pc)
    memo_state = qs.memo_state

    if qs.created?
      if npc.id == GRAND_MASTER_VITUS
        if pc.race.kamael?
          if pc.level >= MIN_LEVEL && pc.in_category?(CategoryType::KAMAEL_SECOND_CLASS_GROUP)
            html = "32213-01.htm"
          else
            html = "32213-03.html"
          end
        else
          html = "32213-02.html"
        end
      end
    elsif qs.started?
      case npc.id
      when GRAND_MASTER_VITUS
        if memo_state == 1
          html = "32213-07.html"
        elsif memo_state > 1 && memo_state < 24
          html = "32213-08.html"
        elsif memo_state == 24
          give_adena(pc, 71194, true)
          give_items(pc, SOUL_BREAKER_CERTIFICATE, 1)
          add_exp_and_sp(pc, 393750, 27020)
          qs.exit_quest(false, true)
          pc.send_packet(SocialAction.new(pc.l2id, 3))
          html = "32213-10.html"
        end
      when CAPTAIN_LUCAS
        if memo_state == 7
          html = "30071-01.html"
        elsif memo_state == 8
          html = "30071-03.html"
        end
      when JACOB
        if memo_state == 6
          if qs.get_memo_state_ex(1) == 0
            qs.set_memo_state_ex(1, 10)
            html = "30073-01.html"
          elsif qs.get_memo_state_ex(1) == 10
            html = "30073-01a.html"
          elsif qs.get_memo_state_ex(1) == 1
            qs.memo_state = 7
            qs.set_memo_state_ex(1, 0)
            qs.set_cond(7, true)
            html = "30073-02.html"
          end
        elsif memo_state == 7
          html = "30073-03.html"
        end
      when GUARD_HARLAN
        if memo_state == 6
          if qs.get_memo_state_ex(1) == 0
            qs.set_memo_state_ex(1, 1)
            html = "30074-01.html"
          elsif qs.get_memo_state_ex(1) == 1
            html = "30074-01a.html"
          elsif qs.get_memo_state_ex(1) == 10
            qs.memo_state = 7
            qs.set_memo_state_ex(1, 0)
            qs.set_cond(7, true)
            html = "30074-02.html"
          end
        elsif memo_state == 7
          html = "30074-03.html"
        end
      when GUARD_XABER
        if memo_state == 8
          if qs.get_memo_state_ex(1) == 0
            qs.set_memo_state_ex(1, 1)
            html = "30075-01.html"
          elsif qs.get_memo_state_ex(1) == 1
            html = "30075-01a.html"
          elsif qs.get_memo_state_ex(1) == 10
            qs.memo_state = 9
            qs.set_memo_state_ex(1, 0)
            qs.set_cond(9, true)
            html = "30075-02.html"
          end
        elsif memo_state == 9
          html = "30075-03.html"
        end
      when GUARD_LIAM
        if memo_state == 8
          if qs.get_memo_state_ex(1) == 0
            qs.set_memo_state_ex(1, 10)
            html = "30076-01.html"
          elsif qs.get_memo_state_ex(1) == 10
            html = "30076-01a.html"
          elsif qs.get_memo_state_ex(1) == 1
            qs.memo_state = 9
            qs.set_memo_state_ex(1, 0)
            qs.set_cond(9, true)
            html = "30076-02.html"
          end
        elsif memo_state == 9
          html = "30076-03.html"
        end
      when GUARD_VESA
        if memo_state == 9
          if qs.get_memo_state_ex(1) == 0
            qs.set_memo_state_ex(1, 10)
            html = "30123-01.html"
          elsif qs.get_memo_state_ex(1) == 10
            html = "30123-01.html"
          elsif qs.get_memo_state_ex(1) == 1
            qs.memo_state = 10
            qs.set_memo_state_ex(1, 0)
            qs.set_cond(10, true)
            html = "30123-02.html"
          end
        elsif memo_state == 10
          html = "30123-03.html"
        end
      when GUARD_ZEROME
        if memo_state == 9
          if qs.get_memo_state_ex(1) == 0
            qs.set_memo_state_ex(1, 1)
            html = "30124-01.html"
          elsif qs.get_memo_state_ex(1) == 1
            html = "30124-01.html"
          elsif qs.get_memo_state_ex(1) == 10
            qs.memo_state = 10
            qs.set_memo_state_ex(1, 0)
            qs.set_cond(10, true)
            html = "30124-02.html"
          end
        elsif memo_state == 10
          html = "30124-03.html"
        end
      when WHARF_MANAGER_FELTON
        if memo_state == 11
          html = "30879-01.html"
        elsif memo_state == 12
          html = "30879-04.html"
        end
      when KEKROPUS
        if memo_state == 1
          html = get_htm(pc, "32138-01.html")
          html = html.gsub("%name1%", pc.name)
        elsif memo_state == 2
          html = "32138-05.html"
        elsif memo_state == 21
          html = "32138-06.html"
        elsif memo_state == 22
          html = "32138-08.html"
        elsif memo_state == 23
          html = "32138-09.html"
        elsif memo_state == 24
          html = "32138-13.html"
        end
      when VICE_HIERARCH_CASCA
        if memo_state == 2
          html = "32139-01.html"
        elsif memo_state == 3
          html = "32139-03.html"
        elsif memo_state == 4
          html = "32139-05.html"
        elsif memo_state == 14
          html = "32139-06.html"
        elsif memo_state == 21
          html = "32139-09.html"
        end
      when GRAND_MASTER_HOLST
        if memo_state == 4
          html = "32199-01.html"
        elsif memo_state == 5
          qs.memo_state = 6
          qs.set_memo_state_ex(1, 0) # L2J says there's something custom about this
          qs.set_cond(6, true)
          html = "32199-03.html"
        elsif memo_state == 6
          html = "32199-04.html"
        end
      when GRAND_MASTER_MELDINA
        if memo_state == 10
          html = "32214-01.html"
        elsif memo_state == 11
          html = "32214-03.html"
        end
      when CARGO_BOX
        if memo_state == 12
          if !npc.variables.get_bool("SPAWNED", false)
            npc.variables["SPAWNED"] = true
            npc.variables["PLAYER_ID"] = pc.l2id
            angel = add_spawn(GUARDIAN_ANGEL, 36110, 191921, -3712, 0, true, 0, false)
            angel.variables["npc0"] = npc
            angel.variables["player0"] = pc
            add_attack_desire(angel, pc)
            html = "32243-01.html"
          elsif npc.variables.get_i32("PLAYER_ID") == pc.l2id
            html = "32243-03.html"
          else
            html = "32243-02.html"
          end
        elsif memo_state == 13
          if !npc.variables.get_bool("SPAWNED", false)
            npc.variables["SPAWNED"] = true
            npc.variables["PLAYER_ID"] = pc.l2id
            katenar = add_spawn(KATENAR, 36110, 191921, -3712, 0, false, 0)
            katenar.variables["player0"] = pc
            katenar.variables["npc0"] = npc
            html = "32243-06.html"
          elsif npc.variables.get_i32("PLAYER_ID") == pc.l2id
            html = "32243-04.html"
          else
            html = "32243-05.html"
          end
        elsif memo_state == 14
          html = "32243-07.html"
        end
      else
        # [automatically added else]
      end
    elsif qs.completed?
      if npc.id == GRAND_MASTER_VITUS
        html = get_already_completed_msg(pc)
      end
    end

    html || get_no_quest_msg(pc)
  end

  def on_spawn(npc)
    if npc.id == SUSPICIOUS_MAN
      start_quest_timer("DESPAWN_5", 5000, npc, nil)
      npc.broadcast_packet(NpcSay.new(npc, Say2::NPC_ALL, NpcString::DRATS_HOW_COULD_I_BE_SO_WRONG))
      npc.running = true
      npc.set_intention(AI::MOVE_TO, MOVE_TO)
    elsif npc.id == GUARDIAN_ANGEL
      start_quest_timer("DESPAWN_70", 70000, npc, nil)
      if c0 = npc.variables.get_object("player0", L2PcInstance?)
        npc.broadcast_packet(NpcSay.new(npc, Say2::NPC_ALL, NpcString::S1_STEP_BACK_FROM_THE_CONFOUNDED_BOX_I_WILL_TAKE_IT_MYSELF).add_string_parameter(c0.appearance.visible_name))
      end
    end

    super
  end
end
