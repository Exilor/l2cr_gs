class Quests::Q00417_PathOfTheScavenger < Quest
  # NPCs
  private WAREHOUSE_KEEPER_RAUT = 30316
  private TRADER_SHARI = 30517
  private TRADER_MION = 30519
  private COLLECTOR_PIPI = 30524
  private HEAD_BLACKSMITH_BRONK = 30525
  private PRIEST_OF_THE_EARTH_ZIMENF = 30538
  private MASTER_TOMA = 30556
  private TORAI = 30557
  private WAREHOUSE_CHIEF_YASENI = 31958
  # Items
  private PIPPIS_LETTER_OF_RECOMMENDATION = 1643
  private ROUTS_TELEPORT_SCROLL = 1644
  private SUCCUBUS_UNDIES = 1645
  private MIONS_LETTER = 1646
  private BRONKS_INGOT = 1647
  private SHARIS_AXE = 1648
  private ZIMENFS_POTION = 1649
  private BRONKS_PAY = 1650
  private SHARIS_PAY = 1651
  private ZIMENFS_PAY = 1652
  private BEAR_PICTURE = 1653
  private TARANTULA_PICTURE = 1654
  private HONEY_JAR = 1655
  private BEAD = 1656
  private BEAD_PARCEL = 1657
  private BEAD_PARCEL2 = 8543
  # Reward
  private RING_OF_RAVEN = 1642
  # Monster
  private HUNTER_TARANTULA = 20403
  private PLUNDER_TARANTULA = 20508
  private HUNTER_BEAR = 20777
  # Quest Monster
  private HONEY_BEAR = 27058
  # Skill
  private SPOIL = 254
  # Misc
  private MIN_LEVEL = 18
  private FIRST_ATTACKER = "FIRST_ATTACKER"
  private FLAG = "FLAG"

  def initialize
    super(417, self.class.simple_name, "Path Of The Scavenger")

    add_start_npc(COLLECTOR_PIPI)
    add_talk_id(
      COLLECTOR_PIPI, WAREHOUSE_KEEPER_RAUT, TRADER_MION, TRADER_SHARI,
      HEAD_BLACKSMITH_BRONK, PRIEST_OF_THE_EARTH_ZIMENF, MASTER_TOMA, TORAI,
      WAREHOUSE_CHIEF_YASENI
    )
    add_attack_id(HUNTER_TARANTULA, PLUNDER_TARANTULA, HUNTER_BEAR, HONEY_BEAR)
    add_kill_id(HUNTER_TARANTULA, PLUNDER_TARANTULA, HUNTER_BEAR, HONEY_BEAR)
    register_quest_items(
      PIPPIS_LETTER_OF_RECOMMENDATION, ROUTS_TELEPORT_SCROLL, SUCCUBUS_UNDIES,
      MIONS_LETTER, BRONKS_INGOT, SHARIS_AXE, ZIMENFS_POTION, BRONKS_PAY,
      SHARIS_PAY, ZIMENFS_PAY, BEAR_PICTURE, TARANTULA_PICTURE, HONEY_JAR,
      BEAD, BEAD_PARCEL, BEAD_PARCEL2
    )
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
      if player.class_id.dwarven_fighter?
        if player.level >= MIN_LEVEL
          if has_quest_items?(player, RING_OF_RAVEN)
            htmltext = "30524-04.htm"
          else
            qs.start_quest
            qs.set_memo_state_ex(1, 0)
            give_items(player, PIPPIS_LETTER_OF_RECOMMENDATION, 1)
            htmltext = "30524-05.htm"
          end
        else
          htmltext = "30524-02.htm"
        end
      elsif player.class_id.scavenger?
        htmltext = "30524-02a.htm"
      else
        htmltext = "30524-08.htm"
      end
    when "30524-03.html", "30557-02.html", "30519-06.html"
      htmltext = event
    when "reply_1"
      if has_quest_items?(player, PIPPIS_LETTER_OF_RECOMMENDATION)
        take_items(player, PIPPIS_LETTER_OF_RECOMMENDATION, 1)
        case Rnd.rand(3)
        when 0
          give_items(player, ZIMENFS_POTION, 1)
          htmltext = "30519-02.html"
        when 1
          give_items(player, SHARIS_AXE, 1)
          htmltext = "30519-03.html"
        when 2
          give_items(player, BRONKS_INGOT, 1)
          htmltext = "30519-04.html"
        end
      end
    when "30519-07.html"
      qs.set_memo_state_ex(1, qs.get_memo_state_ex(1) + 1)
      htmltext = event
    when "reply_2"
      case Rnd.rand(2)
      when 0
        htmltext = "30519-06.html"
      when 1
        htmltext = "30519-11.html"
      end
    when "reply_3"
      if (qs.get_memo_state_ex(1) % 10) < 2
        qs.set_memo_state_ex(1, qs.get_memo_state_ex(1) + 1)
        htmltext = "30519-07.html"
      elsif ((qs.get_memo_state_ex(1) % 10) == 2) && qs.memo_state?(0)
        htmltext = "30519-07.html"
      elsif ((qs.get_memo_state_ex(1) % 10) == 2) && qs.memo_state?(1)
        qs.set_memo_state_ex(1, qs.get_memo_state_ex(1) + 1)
        htmltext = "30519-09.html"
      elsif ((qs.get_memo_state_ex(1) % 10) >= 3) && qs.memo_state?(1)
        give_items(player, MIONS_LETTER, 1)
        take_items(player, SHARIS_AXE, 1)
        take_items(player, ZIMENFS_POTION, 1)
        take_items(player, BRONKS_INGOT, 1)
        qs.set_cond(4, true)
        htmltext = "30519-10.html"
      end
    when "reply_4"
      take_items(player, ZIMENFS_PAY, 1)
      take_items(player, SHARIS_PAY, 1)
      take_items(player, BRONKS_PAY, 1)
      case Rnd.rand(3)
      when 0
        give_items(player, ZIMENFS_POTION, 1)
        htmltext = "30519-02.html"
      when 1
        give_items(player, SHARIS_AXE, 1)
        htmltext = "30519-03.html"
      when 2
        give_items(player, BRONKS_INGOT, 1)
        htmltext = "30519-04.html"
      end
    when "30556-05b.html"
      if has_quest_items?(player, TARANTULA_PICTURE) && get_quest_items_count(player, BEAD) >= 20
        take_items(player, TARANTULA_PICTURE, 1)
        take_items(player, BEAD, -1)
        give_items(player, BEAD_PARCEL, 1)
        qs.set_cond(9, true)
        htmltext = event
      end
    when "30556-06b.html"
      if has_quest_items?(player, TARANTULA_PICTURE) && get_quest_items_count(player, BEAD) >= 20
        take_items(player, TARANTULA_PICTURE, 1)
        take_items(player, BEAD, -1)
        give_items(player, BEAD_PARCEL2, 1)
        qs.memo_state=(2)
        qs.set_cond(12, true)
        htmltext = event
      end
    when "30316-02.html"
      if has_quest_items?(player, BEAD_PARCEL)
        take_items(player, BEAD_PARCEL, 1)
        give_items(player, ROUTS_TELEPORT_SCROLL, 1)
        qs.set_cond(10, true)
        htmltext = event
      end
    when "30316-03.html"
      if has_quest_items?(player, BEAD_PARCEL)
        give_items(player, ROUTS_TELEPORT_SCROLL, 1)
        take_items(player, BEAD_PARCEL, 1)
        qs.set_cond(10, true)
        htmltext = event
      end
    when "30557-03.html"
      if has_quest_items?(player, ROUTS_TELEPORT_SCROLL)
        take_items(player, ROUTS_TELEPORT_SCROLL, 1)
        give_items(player, SUCCUBUS_UNDIES, 1)
        qs.set_cond(11, true)
        npc.not_nil!.delete_me
        htmltext = event
      end
    when "31958-02.html"
      if qs.memo_state?(2) && has_quest_items?(player, BEAD_PARCEL2)
        give_adena(player, 163800, true)
        give_items(player, RING_OF_RAVEN, 1)
        level = player.level
        if level >= 20
          add_exp_and_sp(player, 320534, 35412)
        elsif level == 19
          add_exp_and_sp(player, 456128, 42110)
        else
          add_exp_and_sp(player, 591724, 48808)
        end
        qs.exit_quest(false, true)
        player.send_packet(SocialAction.new(player.l2id, 3))
        qs.save_global_quest_var("1ClassQuestFinished", "1")
        htmltext = event
      end
    end

    htmltext
  end

  def on_attack(npc, attacker, damage, is_summon, skill)
    qs = get_quest_state(attacker, false)
    if qs && qs.started?
      case npc.id
      when HUNTER_BEAR
        case npc.script_value
        when 0
          npc.script_value = 1
          npc.variables[FIRST_ATTACKER] = attacker.l2id
        when 1
          if npc.variables.get_i32(FIRST_ATTACKER) != attacker.l2id
            npc.script_value = 2
          end
        end
      when HUNTER_TARANTULA, PLUNDER_TARANTULA, HONEY_BEAR
        if npc.script_value?(0)
          npc.script_value = 1
          npc.variables[FIRST_ATTACKER] = attacker.l2id
        end

        # TODO: This should be skill parameter and not last skill casted.
        if attacker.last_skill_cast && attacker.last_skill_cast.not_nil!.id == SPOIL
          npc.script_value = 2
          attacker.last_skill_cast = nil # Reset last skill cast.
        else
        end
      end
    end

    super
  end

  def on_kill(npc, killer, is_summon)
    qs = get_quest_state(killer, false)
    if qs && qs.started? && Util.in_range?(1500, npc, killer, true) && npc.attackable?
      first_attacker = killer.l2id == npc.variables.get_i32(FIRST_ATTACKER)
      case npc.id
      when HUNTER_BEAR
        if npc.script_value?(1) && first_attacker && has_quest_items?(killer, BEAR_PICTURE) && get_quest_items_count(killer, HONEY_JAR) < 5
          flag = qs.get_int(FLAG)
          if flag > 0 && Rnd.rand(100) < 20 * flag
            add_spawn(HONEY_BEAR, npc, true, 0, true)
            qs.set(FLAG, 0)
          else
            qs.set(FLAG, flag + 1)
          end
        end
      when HONEY_BEAR
        if npc.script_value?(2) && first_attacker && npc.spoiled? && has_quest_items?(killer, BEAR_PICTURE)
          if give_item_randomly(killer, npc, HONEY_JAR, 1, 5, 1.0, true)
            qs.set_cond(6)
          end
        end
      when HUNTER_TARANTULA, PLUNDER_TARANTULA
        if npc.script_value?(2) && first_attacker && npc.spoiled? && has_quest_items?(killer, TARANTULA_PICTURE)
          if give_item_randomly(killer, npc, BEAD, 1, 20, 1.0, true)
            qs.set_cond(8)
          end
        end
      end
    end

    super
  end

  def on_talk(npc, player)
    qs = get_quest_state!(player)
    htmltext = get_no_quest_msg(player)
    if qs.created? || qs.completed?
      if npc.id == COLLECTOR_PIPI
        htmltext = "30524-01.htm"
      end
    elsif qs.started?
      case npc.id
      when COLLECTOR_PIPI
        if has_quest_items?(player, PIPPIS_LETTER_OF_RECOMMENDATION)
          htmltext = "30524-06.html"
        else
          htmltext = "30524-07.html"
        end
      when TRADER_MION
        if has_quest_items?(player, PIPPIS_LETTER_OF_RECOMMENDATION)
          qs.set_cond(2, true)
          htmltext = "30519-01.html"
        elsif (get_quest_items_count(player, SHARIS_AXE) + get_quest_items_count(player, BRONKS_INGOT) + get_quest_items_count(player, ZIMENFS_POTION)) == 1
          if qs.get_memo_state_ex(1) % 10 == 0
            htmltext = "30519-05.html"
          elsif qs.get_memo_state_ex(1) % 10 > 0
            htmltext = "30519-08.html"
          end
        elsif (get_quest_items_count(player, SHARIS_PAY) + get_quest_items_count(player, BRONKS_PAY) + get_quest_items_count(player, ZIMENFS_PAY)) == 1
          if qs.get_memo_state_ex(1) < 50
            htmltext = "30519-12.html"
          else
            give_items(player, MIONS_LETTER, 1)
            take_items(player, SHARIS_PAY, 1)
            take_items(player, ZIMENFS_PAY, 1)
            take_items(player, BRONKS_PAY, 1)
            qs.set_cond(4, true)
            htmltext = "30519-15.html"
          end
        elsif has_quest_items?(player, MIONS_LETTER)
          htmltext = "30519-13.html"
        elsif has_at_least_one_quest_item?(player, BEAR_PICTURE, TARANTULA_PICTURE, BEAD_PARCEL, ROUTS_TELEPORT_SCROLL, SUCCUBUS_UNDIES)
          htmltext = "30519-14.html"
        end
      when TRADER_SHARI
        if has_quest_items?(player, SHARIS_AXE)
          if qs.get_memo_state_ex(1) < 20
            take_items(player, SHARIS_AXE, 1)
            give_items(player, SHARIS_PAY, 1)
            qs.set_memo_state_ex(1, qs.get_memo_state_ex(1) + 10)
            htmltext = "30517-01.html"
          else
            take_items(player, SHARIS_AXE, 1)
            give_items(player, SHARIS_PAY, 1)
            qs.memo_state=(1)
            qs.set_memo_state_ex(1, qs.get_memo_state_ex(1) + 10)
            qs.set_cond(3, true)
            htmltext = "30517-02.html"
          end
        elsif has_quest_items?(player, SHARIS_PAY)
          htmltext = "30517-03.html"
        end
      when HEAD_BLACKSMITH_BRONK
        if has_quest_items?(player, BRONKS_INGOT)
          if qs.get_memo_state_ex(1) < 20
            take_items(player, BRONKS_INGOT, 1)
            give_items(player, BRONKS_PAY, 1)
            qs.set_memo_state_ex(1, qs.get_memo_state_ex(1) + 10)
            htmltext = "30525-01.html"
          else
            take_items(player, BRONKS_INGOT, 1)
            give_items(player, BRONKS_PAY, 1)
            qs.memo_state=(1)
            qs.set_memo_state_ex(1, qs.get_memo_state_ex(1) + 10)
            qs.set_cond(3, true)
            htmltext = "30525-02.html"
          end
        elsif has_quest_items?(player, BRONKS_PAY)
          htmltext = "30525-03.html"
        end
      when PRIEST_OF_THE_EARTH_ZIMENF
        if has_quest_items?(player, ZIMENFS_POTION)
          if qs.get_memo_state_ex(1) < 20
            take_items(player, ZIMENFS_POTION, 1)
            give_items(player, ZIMENFS_PAY, 1)
            qs.set_memo_state_ex(1, qs.get_memo_state_ex(1) + 10)
            htmltext = "30538-01.html"
          else
            take_items(player, ZIMENFS_POTION, 1)
            give_items(player, ZIMENFS_PAY, 1)
            qs.memo_state=(1)
            qs.set_memo_state_ex(1, qs.get_memo_state_ex(1) + 10)
            qs.set_cond(3, true)
            htmltext = "30538-02.html"
          end
        elsif has_quest_items?(player, ZIMENFS_PAY)
          htmltext = "30538-03.html"
        end
      when MASTER_TOMA
        if has_quest_items?(player, MIONS_LETTER)
          take_items(player, MIONS_LETTER, 1)
          give_items(player, BEAR_PICTURE, 1)
          qs.set_cond(5, true)
          qs.set(FLAG, 0)
          htmltext = "30556-01.html"
        elsif has_quest_items?(player, BEAR_PICTURE)
          if get_quest_items_count(player, HONEY_JAR) < 5
            htmltext = "30556-02.html"
          else
            take_items(player, BEAR_PICTURE, 1)
            give_items(player, TARANTULA_PICTURE, 1)
            take_items(player, HONEY_JAR, -1)
            qs.set_cond(7, true)
            htmltext = "30556-03.html"
          end
        elsif has_quest_items?(player, TARANTULA_PICTURE)
          if get_quest_items_count(player, BEAD) < 20
            htmltext = "30556-04.html"
          else
            htmltext = "30556-05a.html"
          end
        elsif has_quest_items?(player, BEAD_PARCEL) && !has_quest_items?(player, BEAD_PARCEL2)
          htmltext = "30556-06a.html"
        elsif has_quest_items?(player, BEAD_PARCEL2) && !has_quest_items?(player, BEAD_PARCEL) && qs.memo_state?(2)
          htmltext = "30556-06c.html"
        elsif has_at_least_one_quest_item?(player, ROUTS_TELEPORT_SCROLL, SUCCUBUS_UNDIES)
          htmltext = "30556-07.html"
        end
      when WAREHOUSE_KEEPER_RAUT
        if has_quest_items?(player, BEAD_PARCEL)
          htmltext = "30316-01.html"
        elsif has_quest_items?(player, ROUTS_TELEPORT_SCROLL)
          htmltext = "30316-04.html"
        elsif has_quest_items?(player, SUCCUBUS_UNDIES)
          give_adena(player, 81900, true)
          give_items(player, RING_OF_RAVEN, 1)
          level = player.level
          if level >= 20
            add_exp_and_sp(player, 160267, 17706)
          elsif level == 19
            add_exp_and_sp(player, 228064, 21055)
          else
            add_exp_and_sp(player, 295862, 24404)
          end
          qs.exit_quest(false, true)
          player.send_packet(SocialAction.new(player.l2id, 3))
          qs.save_global_quest_var("1ClassQuestFinished", "1")
          htmltext = "30316-05.html"
        end
      when TORAI
        if has_quest_items?(player, ROUTS_TELEPORT_SCROLL)
          htmltext = "30557-01.html"
        end
      when WAREHOUSE_CHIEF_YASENI
        if has_quest_items?(player, BEAD_PARCEL2) && !has_quest_items?(player, BEAD_PARCEL) && qs.memo_state?(2)
          htmltext = "31958-01.html"
        end
      end
    end

    htmltext
  end
end
