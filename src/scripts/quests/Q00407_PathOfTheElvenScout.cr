class Quests::Q00407_PathOfTheElvenScout < Quest
  # NPCs
  private MASTER_REORIA = 30328
  private GUARD_BABENCO = 30334
  private GUARD_MORETTI = 30337
  private PRIAS = 30426
  # Items
  private REISAS_LETTER = 1207
  private PRIASS_1ND_TORN_LETTER = 1208
  private PRIASS_2ND_TORN_LETTER = 1209
  private PRIASS_3ND_TORN_LETTER = 1210
  private PRIASS_4ND_TORN_LETTER = 1211
  private MORETTIES_HERB = 1212
  private MORETTIS_LETTER = 1214
  private PRIASS_LETTER = 1215
  private HONORARY_GUARD = 1216
  private REISAS_RECOMMENDATION = 1217
  private RUSTED_KEY = 1293
  # Monster
  private OL_MAHUM_PATROL = 20053
  # Quest Monster
  private OL_MAHUM_SENTRY = 27031
  # Misc
  private MIN_LEVEL = 18

  def initialize
    super(407, self.class.simple_name, "Path of the Elven Scout")

    add_start_npc(MASTER_REORIA)
    add_talk_id(MASTER_REORIA, GUARD_BABENCO, GUARD_MORETTI, PRIAS)
    add_kill_id(OL_MAHUM_PATROL, OL_MAHUM_SENTRY)
    add_attack_id(OL_MAHUM_PATROL, OL_MAHUM_SENTRY)
    register_quest_items(REISAS_LETTER, PRIASS_1ND_TORN_LETTER, PRIASS_2ND_TORN_LETTER, PRIASS_3ND_TORN_LETTER, PRIASS_4ND_TORN_LETTER, MORETTIES_HERB, MORETTIS_LETTER, PRIASS_LETTER, HONORARY_GUARD, RUSTED_KEY)
  end

  def on_adv_event(event, npc, player)
    return unless player
    return unless qs = get_quest_state(player, false)

    case event
    when "ACCEPT"
      if player.class_id.elven_fighter?
        if player.level >= MIN_LEVEL
          if has_quest_items?(player, REISAS_RECOMMENDATION)
            htmltext = "30328-04.htm"
          else
            qs.start_quest
            qs.unset("variable")
            give_items(player, REISAS_LETTER, 1)
            htmltext = "30328-05.htm"
          end
        else
          htmltext = "30328-03.htm"
        end
      elsif player.class_id.elven_scout?
        htmltext = "30328-02a.htm"
      else
        htmltext = "30328-02.htm"
      end
    when "30337-02.html"
      htmltext = event
    when "30337-03.html"
      if has_quest_items?(player, REISAS_LETTER)
        take_items(player, REISAS_LETTER, -1)
        qs.set("variable", 1)
        qs.set_cond(2, true)
        htmltext = event
      end
    end

    htmltext
  end

  def on_attack(npc, attacker, damage, is_summon)
    qs = get_quest_state(attacker, false)

    if qs && qs.started?
      npc.script_value = attacker.l2id
    end

    super
  end

  def on_kill(npc, killer, is_summon)
    if npc.script_value?(killer.l2id) && Util.in_range?(1500, npc, killer, false)
      return unless qs = get_quest_state(killer, false)

      if npc.id == OL_MAHUM_SENTRY
        if qs.cond?(5) && Rnd.rand(10) < 6
          if has_quest_items?(qs.player, MORETTIES_HERB, MORETTIS_LETTER) && !has_quest_items?(qs.player, RUSTED_KEY)
            give_items(qs.player, RUSTED_KEY, 1)
            qs.set_cond(6, true)
          end
        end
      elsif qs.cond?(2)
        has1stLetter = has_quest_items?(qs.player, PRIASS_1ND_TORN_LETTER)
        has2ndLetter = has_quest_items?(qs.player, PRIASS_2ND_TORN_LETTER)
        has3rdLetter = has_quest_items?(qs.player, PRIASS_3ND_TORN_LETTER)
        has4thLetter = has_quest_items?(qs.player, PRIASS_4ND_TORN_LETTER)

        if !(has1stLetter && has2ndLetter && has3rdLetter && has4thLetter)
          if !has1stLetter
            give_letter_and_check_state(PRIASS_1ND_TORN_LETTER, qs)
          elsif !has2ndLetter
            give_letter_and_check_state(PRIASS_2ND_TORN_LETTER, qs)
          elsif !has3rdLetter
            give_letter_and_check_state(PRIASS_3ND_TORN_LETTER, qs)
          elsif !has4thLetter
            give_letter_and_check_state(PRIASS_4ND_TORN_LETTER, qs)
          end
        end
      end
    end

    return super
  end

  private def give_letter_and_check_state(letter_id, qs)
    give_items(qs.player, letter_id, 1)

    if get_quest_items_count(qs.player, PRIASS_1ND_TORN_LETTER, PRIASS_2ND_TORN_LETTER, PRIASS_3ND_TORN_LETTER, PRIASS_4ND_TORN_LETTER) >= 4
      qs.set_cond(3, true)
    else
      play_sound(qs.player, Sound::ITEMSOUND_QUEST_ITEMGET)
    end
  end

  def on_talk(npc, player)
    qs = get_quest_state!(player)
    htmltext = get_no_quest_msg(player)
    if qs.created? || qs.completed?
      if npc.id == MASTER_REORIA
        htmltext = "30328-01.htm"
      end
    elsif qs.started?
      case npc.id
      when MASTER_REORIA
        if has_quest_items?(player, REISAS_LETTER)
          htmltext = "30328-06.html"
        elsif qs.get_int("variable") == 1 && !has_at_least_one_quest_item?(player, REISAS_LETTER, HONORARY_GUARD)
          htmltext = "30328-08.html"
        elsif has_quest_items?(player, HONORARY_GUARD)
          take_items(player, HONORARY_GUARD, -1)
          give_items(player, REISAS_RECOMMENDATION, 1)
          level = player.level
          if level >= 20
            add_exp_and_sp(player, 320534, 19932)
          elsif level == 19
            add_exp_and_sp(player, 456128, 26630)
          else
            add_exp_and_sp(player, 591724, 33328)
          end
          give_adena(player, 163800, true)
          qs.exit_quest(false, true)
          player.send_packet(SocialAction.new(player.l2id, 3))
          qs.save_global_quest_var("1ClassQuestFinished", "1")
          htmltext = "30328-07.html"
        end
      when GUARD_BABENCO
        if qs.get_int("variable") == 1
          htmltext = "30334-01.html"
        end
      when GUARD_MORETTI
        letter_count = get_quest_items_count(player, PRIASS_1ND_TORN_LETTER, PRIASS_2ND_TORN_LETTER, PRIASS_3ND_TORN_LETTER, PRIASS_4ND_TORN_LETTER)
        if has_quest_items?(player, REISAS_LETTER) && letter_count == 0
          htmltext = "30337-01.html"
        elsif qs.get_int("variable") == 1 && !has_at_least_one_quest_item?(player, MORETTIS_LETTER, PRIASS_LETTER, HONORARY_GUARD)
          if letter_count == 0
            htmltext = "30337-04.html"
          elsif letter_count < 4
            htmltext = "30337-05.html"
          else
            take_items(player, -1, [PRIASS_1ND_TORN_LETTER, PRIASS_2ND_TORN_LETTER, PRIASS_3ND_TORN_LETTER, PRIASS_4ND_TORN_LETTER])
            give_items(player, MORETTIES_HERB, 1)
            give_items(player, MORETTIS_LETTER, 1)
            qs.set_cond(4, true)
            htmltext = "30337-06.html"
          end
        elsif has_quest_items?(player, PRIASS_LETTER)
          take_items(player, PRIASS_LETTER, -1)
          give_items(player, HONORARY_GUARD, 1)
          qs.set_cond(8, true)
          htmltext = "30337-07.html"
        elsif has_quest_items?(player, MORETTIES_HERB, MORETTIS_LETTER)
          htmltext = "30337-09.html"
        elsif has_quest_items?(player, HONORARY_GUARD)
          htmltext = "30337-08.html"
        end
      when PRIAS
        if has_quest_items?(player, MORETTIS_LETTER, MORETTIES_HERB)
          if !has_quest_items?(player, RUSTED_KEY)
            qs.set_cond(5, true)
            htmltext = "30426-01.html"
          else
            take_items(player, -1, [RUSTED_KEY, MORETTIES_HERB, MORETTIS_LETTER])
            give_items(player, PRIASS_LETTER, 1)
            qs.set_cond(7, true)
            htmltext = "30426-02.html"
          end
        elsif has_quest_items?(player, PRIASS_LETTER)
          htmltext = "30426-04.html"
        end
      end
    end

    htmltext
  end
end
