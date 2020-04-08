class Scripts::Q00401_PathOfTheWarrior < Quest
  # NPCs
  private MASTER_AURON = 30010
  private TRADER_SIMPLON = 30253
  # Items
  private AURONS_LETTER = 1138
  private WARRIOR_GUILD_MARK = 1139
  private RUSTED_BRONZE_SWORD1 = 1140
  private RUSTED_BRONZE_SWORD2 = 1141
  private RUSTED_BRONZE_SWORD3 = 1142
  private SIMPLONS_LETTER = 1143
  private VENOMOUS_SPIDERS_LEG = 1144
  # Reward
  private MEDALLION_OF_WARRIOR = 1145
  # Monster
  private TRACKER_SKELETON = 20035
  private VENOMOUS_SPIDERS = 20038
  private TRACKER_SKELETON_LEADER = 20042
  private ARACHNID_TRACKER = 20043
  # Misc
  private MIN_LEVEL = 18

  def initialize
    super(401, self.class.simple_name, "Path Of The Warrior")

    add_start_npc(MASTER_AURON)
    add_talk_id(MASTER_AURON, TRADER_SIMPLON)
    add_attack_id(VENOMOUS_SPIDERS, ARACHNID_TRACKER)
    add_kill_id(
      TRACKER_SKELETON, VENOMOUS_SPIDERS, TRACKER_SKELETON_LEADER,
      ARACHNID_TRACKER
    )
    register_quest_items(
      AURONS_LETTER, WARRIOR_GUILD_MARK, RUSTED_BRONZE_SWORD1,
      RUSTED_BRONZE_SWORD2, RUSTED_BRONZE_SWORD3, SIMPLONS_LETTER,
      VENOMOUS_SPIDERS_LEG
    )
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    return unless qs = get_quest_state(pc, false)

    case event
    when "ACCEPT"
      if pc.class_id.fighter?
        if pc.level >= MIN_LEVEL
          if has_quest_items?(pc, MEDALLION_OF_WARRIOR)
            "30010-04.htm"
          else
            "30010-05.htm"
          end
        else
          "30010-02.htm"
        end
      elsif pc.class_id.warrior?
        "30010-02a.htm"
      else
        "30010-03.htm"
      end
    when "30010-06.htm"
      unless has_quest_items?(pc, AURONS_LETTER)
        qs.start_quest
        give_items(pc, AURONS_LETTER, 1)
        event
      end
    when "30010-10.html"
      event
    when "30010-11.html"
      if has_quest_items?(pc, SIMPLONS_LETTER, RUSTED_BRONZE_SWORD2)
        take_items(pc, RUSTED_BRONZE_SWORD2, 1)
        give_items(pc, RUSTED_BRONZE_SWORD3, 1)
        take_items(pc, SIMPLONS_LETTER, 1)
        qs.set_cond(5, true)
        event
      end
    when "30253-02.html"
      if has_quest_items?(pc, AURONS_LETTER)
        take_items(pc, AURONS_LETTER, 1)
        give_items(pc, WARRIOR_GUILD_MARK, 1)
        qs.set_cond(2, true)
        event
      end
    else
      # automatically added
    end

  end

  def on_attack(npc, attacker, damage, is_summon)
    if qs = get_quest_state(attacker, false)
      case npc.script_value
      when 0
        npc.variables["lastAttacker"] = attacker.l2id
        if check_weapon(attacker)
          npc.script_value = 1
        else
          npc.script_value = 2
        end
      when 1
        if !check_weapon(attacker)
          npc.script_value = 2
        elsif npc.variables.get_i32("lastAttacker") != attacker.l2id
          npc.script_value = 2
        end
      else
        # automatically added
      end

    end

    super
  end

  def on_kill(npc, killer, is_summon)
    qs = get_quest_state(killer, false)

    if qs && qs.started? && Util.in_range?(1500, npc, killer, true)
      case npc.id
      when TRACKER_SKELETON, TRACKER_SKELETON_LEADER
        if has_quest_items?(killer, WARRIOR_GUILD_MARK)
          if get_quest_items_count(killer, RUSTED_BRONZE_SWORD1) < 10
            if Rnd.rand(10) < 4
              give_items(killer, RUSTED_BRONZE_SWORD1, 1)

              if get_quest_items_count(killer, RUSTED_BRONZE_SWORD1) == 10
                qs.set_cond(3, true)
              else
                play_sound(killer, Sound::ITEMSOUND_QUEST_ITEMGET)
              end
            end
          end
        end
      when VENOMOUS_SPIDERS, ARACHNID_TRACKER
        if get_quest_items_count(killer, VENOMOUS_SPIDERS_LEG) < 20 && npc.script_value?(1)
          give_items(killer, VENOMOUS_SPIDERS_LEG, 1)

          if get_quest_items_count(killer, VENOMOUS_SPIDERS_LEG) == 20
            qs.set_cond(6, true)
          else
            play_sound(killer, Sound::ITEMSOUND_QUEST_ITEMGET)
          end
        end
      else
        # automatically added
      end

    end

    super
  end

  def on_talk(npc, pc)
    qs = get_quest_state!(pc)
    html = get_no_quest_msg(pc)

    if qs.created? || qs.completed?
      if npc.id == MASTER_AURON
        html = "30010-01.htm"
      end
    elsif qs.started?
      case npc.id
      when MASTER_AURON
        if has_quest_items?(pc, AURONS_LETTER)
          html = "30010-07.html"
        elsif has_quest_items?(pc, WARRIOR_GUILD_MARK)
          html = "30010-08.html"
        elsif has_quest_items?(pc, SIMPLONS_LETTER, RUSTED_BRONZE_SWORD2) && !has_at_least_one_quest_item?(pc, WARRIOR_GUILD_MARK, AURONS_LETTER)
          html = "30010-09.html"
        elsif has_quest_items?(pc, RUSTED_BRONZE_SWORD3) && !has_at_least_one_quest_item?(pc, WARRIOR_GUILD_MARK, AURONS_LETTER)
          if get_quest_items_count(pc, VENOMOUS_SPIDERS_LEG) < 20
            html = "30010-12.html"
          else
            give_adena(pc, 163_800, true)
            give_items(pc, MEDALLION_OF_WARRIOR, 1)
            if pc.level >= 20
              add_exp_and_sp(pc, 320534, 21012)
            elsif pc.level == 19
              add_exp_and_sp(pc, 456128, 27710)
            else
              add_exp_and_sp(pc, 160267, 34408)
            end
            qs.exit_quest(false, true)
            pc.send_packet(SocialAction.new(pc.l2id, 3))
            qs.save_global_quest_var("1ClassQuestFinished", "1")
            html = "30010-13.html"
          end
        end
      when TRADER_SIMPLON
        if has_quest_items?(pc, AURONS_LETTER)
          html = "30253-01.html"
        elsif has_quest_items?(pc, WARRIOR_GUILD_MARK)
          if !has_quest_items?(pc, RUSTED_BRONZE_SWORD1)
            html = "30253-03.html"
          elsif get_quest_items_count(pc, RUSTED_BRONZE_SWORD1) < 10
            html = "30253-04.html"
          else
            take_items(pc, WARRIOR_GUILD_MARK, 1)
            take_items(pc, RUSTED_BRONZE_SWORD1, -1)
            give_items(pc, RUSTED_BRONZE_SWORD2, 1)
            give_items(pc, SIMPLONS_LETTER, 1)
            qs.set_cond(4, true)
            html = "30253-05.html"
          end
        elsif has_quest_items?(pc, SIMPLONS_LETTER)
          html = "30253-06.html"
        end
      else
        # automatically added
      end

    end

    html
  end

  private def check_weapon(pc)
    return false unless weapon = pc.active_weapon_instance
    weapon.id == RUSTED_BRONZE_SWORD3
  end
end
