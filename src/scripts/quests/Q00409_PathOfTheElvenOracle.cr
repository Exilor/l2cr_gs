class Scripts::Q00409_PathOfTheElvenOracle < Quest
  # NPCs
  private PRIEST_MANUEL = 30293
  private ALLANA = 30424
  private PERRIN = 30428
  # Items
  private CRYSTAL_MEDALLION = 1231
  private SWINDLERS_MONEY = 1232
  private ALLANA_OF_DAIRY = 1233
  private LIZARD_CAPTAIN_ORDER = 1234
  private HALF_OF_DAIRY = 1236
  private TAMIL_NECKLACE = 1275
  # Reward
  private LEAF_OF_ORACLE = 1235
  # Misc
  private MIN_LEVEL = 18
  # Quest Monster
  private LIZARDMAN_WARRIOR = 27032
  private LIZARDMAN_SCOUT = 27033
  private LIZARDMAN_SOLDIER = 27034
  private TAMIL = 27035

  def initialize
    super(409, self.class.simple_name, "Path of the Elven Oracle")

    add_start_npc(PRIEST_MANUEL)
    add_talk_id(PRIEST_MANUEL, ALLANA, PERRIN)
    add_kill_id(TAMIL, LIZARDMAN_WARRIOR, LIZARDMAN_SCOUT, LIZARDMAN_SOLDIER)
    add_attack_id(TAMIL, LIZARDMAN_WARRIOR, LIZARDMAN_SCOUT, LIZARDMAN_SOLDIER)
    register_quest_items(
      CRYSTAL_MEDALLION, SWINDLERS_MONEY, ALLANA_OF_DAIRY,
      LIZARD_CAPTAIN_ORDER, HALF_OF_DAIRY, TAMIL_NECKLACE
    )
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    return unless qs = get_quest_state(pc, false)

    case event
    when "ACCEPT"
      if pc.class_id.elven_mage?
        if pc.level >= MIN_LEVEL
          if has_quest_items?(pc, LEAF_OF_ORACLE)
            html = "30293-04.htm"
          else
            qs.start_quest
            qs.memo_state = 1
            give_items(pc, CRYSTAL_MEDALLION, 1)
            html = "30293-05.htm"
          end
        else
          html = "30293-03.htm"
        end
      elsif pc.class_id.oracle?
        html = "30293-02a.htm"
      else
        html = "30293-02.htm"
      end
    when "30424-08.html", "30424-09.html"
      html = event
    when "30424-07.html"
      if qs.memo_state?(1)
        html = event
      end
    when "replay_1"
      npc = npc.not_nil!
      qs.memo_state = 2
      add_attack_desire(add_spawn(LIZARDMAN_WARRIOR, npc, true, 0i64, false), pc)
      add_attack_desire(add_spawn(LIZARDMAN_SCOUT, npc, true, 0i64, false), pc)
      add_attack_desire(add_spawn(LIZARDMAN_SOLDIER, npc, true, 0i64, false), pc)
    when "30428-02.html", "30428-03.html"
      if qs.memo_state?(2)
        html = event
      end
    when "replay_2"
      if qs.memo_state?(2)
        npc = npc.not_nil!
        qs.memo_state = 3
        add_attack_desire(add_spawn(TAMIL, npc, true, 0i64, true), pc)
      end
    else
      # [automatically added else]
    end


    html
  end

  def on_attack(npc, attacker, damage, is_summon)
    if get_quest_state(attacker, false)
      case npc.script_value
      when 0
        case npc.id
        when LIZARDMAN_WARRIOR
          npc.broadcast_packet(NpcSay.new(npc, Say2::NPC_ALL, NpcString::THE_SACRED_FLAME_IS_OURS))
        when LIZARDMAN_SCOUT
          npc.broadcast_packet(NpcSay.new(npc, Say2::NPC_ALL, NpcString::THE_SACRED_FLAME_IS_OURS))
        when LIZARDMAN_SOLDIER
          npc.broadcast_packet(NpcSay.new(npc, Say2::NPC_ALL, NpcString::THE_SACRED_FLAME_IS_OURS))
        when TAMIL
          npc.broadcast_packet(NpcSay.new(npc, Say2::NPC_ALL, NpcString::AS_YOU_WISH_MASTER))
        else
          # [automatically added else]
        end


        npc.script_value = 1
        npc.variables["firstAttacker"] = attacker.l2id
      when 1
        if npc.variables.get_i32("firstAttacker") != attacker.l2id
          npc.script_value = 2
        end
      else
        # [automatically added else]
      end

    end

    super
  end

  def on_kill(npc, killer, is_summon)
    qs = get_quest_state(killer, false)
    if qs && qs.started? && npc.script_value?(1) && Util.in_range?(1500, npc, killer, true)
      case npc.id
      when LIZARDMAN_WARRIOR
        unless has_quest_items?(killer, LIZARD_CAPTAIN_ORDER)
          npc.broadcast_packet(NpcSay.new(npc, Say2::NPC_ALL, NpcString::ARRGHHWE_SHALL_NEVER_SURRENDER))
          give_items(killer, LIZARD_CAPTAIN_ORDER, 1)
          qs.set_cond(3, true)
        end
      when LIZARDMAN_SCOUT, LIZARDMAN_SOLDIER
        if !has_quest_items?(killer, LIZARD_CAPTAIN_ORDER)
          give_items(killer, LIZARD_CAPTAIN_ORDER, 1)
          qs.set_cond(3, true)
        end
      when TAMIL
        if !has_quest_items?(killer, TAMIL_NECKLACE)
          give_items(killer, TAMIL_NECKLACE, 1)
          qs.set_cond(5, true)
        end
      else
        # [automatically added else]
      end

    end

    super
  end

  def on_talk(npc, pc)
    qs = get_quest_state!(pc)
    if qs.created? || qs.completed?
      if npc.id == PRIEST_MANUEL
        if !has_quest_items?(pc, LEAF_OF_ORACLE)
          html = "30293-01.htm"
        else
          html = "30293-04.htm"
        end
      end
    elsif qs.started?
      case npc.id
      when PRIEST_MANUEL
        if has_quest_items?(pc, CRYSTAL_MEDALLION)
          if !has_at_least_one_quest_item?(pc, SWINDLERS_MONEY, ALLANA_OF_DAIRY, LIZARD_CAPTAIN_ORDER, HALF_OF_DAIRY)
            if qs.memo_state?(2)
              qs.memo_state = 1
              qs.set_cond(8)
              html = "30293-09.html"
            else
              qs.memo_state = 1
              html = "30293-06.html"
            end
          elsif has_quest_items?(pc, SWINDLERS_MONEY, ALLANA_OF_DAIRY, LIZARD_CAPTAIN_ORDER)
            unless has_quest_items?(pc, HALF_OF_DAIRY)
              give_adena(pc, 163800, true)
              give_items(pc, LEAF_OF_ORACLE, 1)
              level = pc.level
              if level >= 20
                add_exp_and_sp(pc, 320534, 20392)
              elsif level == 19
                add_exp_and_sp(pc, 456128, 27090)
              else
                add_exp_and_sp(pc, 591724, 33788)
              end
              qs.exit_quest(false, true)
              pc.send_packet(SocialAction.new(pc.l2id, 3))
              qs.save_global_quest_var("1ClassQuestFinished", "1")
              html = "30293-08.html"
            end
          else
            html = "30293-07.html"
          end
        end
      when ALLANA
        if has_quest_items?(pc, CRYSTAL_MEDALLION)
          if !has_at_least_one_quest_item?(pc, SWINDLERS_MONEY, ALLANA_OF_DAIRY, LIZARD_CAPTAIN_ORDER, HALF_OF_DAIRY)
            if qs.memo_state?(2)
              html = "30424-05.html"
            elsif qs.memo_state?(1)
              qs.set_cond(2, true)
              html = "30424-01.html"
            end
          elsif !has_at_least_one_quest_item?(pc, SWINDLERS_MONEY, ALLANA_OF_DAIRY, HALF_OF_DAIRY) && has_quest_items?(pc, LIZARD_CAPTAIN_ORDER)
            qs.memo_state = 2
            give_items(pc, HALF_OF_DAIRY, 1)
            qs.set_cond(4, true)
            html = "30424-02.html"
          elsif !has_at_least_one_quest_item?(pc, SWINDLERS_MONEY, ALLANA_OF_DAIRY) && has_quest_items?(pc, LIZARD_CAPTAIN_ORDER, HALF_OF_DAIRY)
            if qs.memo_state?(3) && !has_quest_items?(pc, TAMIL_NECKLACE)
              qs.memo_state = 2
              qs.set_cond(4, true)
              html = "30424-06.html"
            else
              html = "30424-03.html"
            end
          elsif has_quest_items?(pc, SWINDLERS_MONEY, LIZARD_CAPTAIN_ORDER, HALF_OF_DAIRY) && !has_quest_items?(pc, ALLANA_OF_DAIRY)
            give_items(pc, ALLANA_OF_DAIRY, 1)
            take_items(pc, HALF_OF_DAIRY, 1)
            qs.set_cond(9, true)
            html = "30424-04.html"
          elsif has_quest_items?(pc, SWINDLERS_MONEY, LIZARD_CAPTAIN_ORDER, ALLANA_OF_DAIRY)
            qs.set_cond(7, true)
            html = "30424-05.html"
          end
        end
      when PERRIN
        if has_quest_items?(pc, CRYSTAL_MEDALLION, LIZARD_CAPTAIN_ORDER, HALF_OF_DAIRY)
          if has_quest_items?(pc, TAMIL_NECKLACE)
            give_items(pc, SWINDLERS_MONEY, 1)
            take_items(pc, TAMIL_NECKLACE, 1)
            qs.set_cond(6, true)
            html = "30428-04.html"
          elsif has_quest_items?(pc, SWINDLERS_MONEY)
            html = "30428-05.html"
          elsif qs.memo_state?(3)
            html = "30428-06.html"
          else
            html = "30428-01.html"
          end
        end
      else
        # [automatically added else]
      end

    end

    html || get_no_quest_msg(pc)
  end
end
