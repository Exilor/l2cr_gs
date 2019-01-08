class Quests::Q00226_TestOfTheHealer < Quest
  # NPCs
  private MASTER_SORIUS = 30327
  private ALLANA = 30424
  private PERRIN = 30428
  private PRIEST_BANDELLOS = 30473
  private FATHER_GUPU = 30658
  private ORPHAN_GIRL = 30659
  private WINDY_SHAORING = 30660
  private MYSTERIOUS_DARK_ELF = 30661
  private PIPER_LONGBOW = 30662
  private SLEIN_SHINING_BLADE = 30663
  private CAIN_FLYING_KNIFE = 30664
  private SAINT_KRISTINA = 30665
  private DAURIN_HAMMERCRUSH = 30674
  # Items
  private ADENA = 57
  private REPORT_OF_PERRIN = 2810
  private CRISTINAS_LETTER = 2811
  private PICTURE_OF_WINDY = 2812
  private GOLDEN_STATUE = 2813
  private WINDYS_PEBBLES = 2814
  private ORDER_OF_SORIUS = 2815
  private SECRET_LETTER1 = 2816
  private SECRET_LETTER2 = 2817
  private SECRET_LETTER3 = 2818
  private SECRET_LETTER4 = 2819
  # Reward
  private MARK_OF_HEALER = 2820
  private DIMENSIONAL_DIAMOND = 7562
  # Quest Monster
  private LERO_LIZARDMAN_AGENT = 27122
  private LERO_LIZARDMAN_LEADER = 27123
  private LERO_LIZARDMAN_ASSASSIN = 27124
  private LERO_LIZARDMAN_SNIPER = 27125
  private LERO_LIZARDMAN_WIZARD = 27126
  private LERO_LIZARDMAN_LORD = 27127
  private TATOMA = 27134
  # Misc
  private MIN_LEVEL = 39

  def initialize
    super(226, self.class.simple_name, "Test Of The Healer")

    add_start_npc(PRIEST_BANDELLOS)
    add_talk_id(PRIEST_BANDELLOS, MASTER_SORIUS, ALLANA, PERRIN, FATHER_GUPU, ORPHAN_GIRL, WINDY_SHAORING, MYSTERIOUS_DARK_ELF, PIPER_LONGBOW, SLEIN_SHINING_BLADE, CAIN_FLYING_KNIFE, SAINT_KRISTINA, DAURIN_HAMMERCRUSH)
    add_kill_id(LERO_LIZARDMAN_AGENT, LERO_LIZARDMAN_LEADER, LERO_LIZARDMAN_ASSASSIN, LERO_LIZARDMAN_SNIPER, LERO_LIZARDMAN_WIZARD, LERO_LIZARDMAN_LORD, TATOMA)
    register_quest_items(REPORT_OF_PERRIN, CRISTINAS_LETTER, PICTURE_OF_WINDY, GOLDEN_STATUE, WINDYS_PEBBLES, ORDER_OF_SORIUS, SECRET_LETTER1, SECRET_LETTER2, SECRET_LETTER3, SECRET_LETTER4)
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
        give_items(player, REPORT_OF_PERRIN, 1)
        if player.variables.get_i32("2ND_CLASS_DIAMOND_REWARD", 0) == 0
          if player.class_id.cleric?
            give_items(player, DIMENSIONAL_DIAMOND, 60)
          elsif player.class_id.knight?
            give_items(player, DIMENSIONAL_DIAMOND, 104)
          elsif player.class_id.oracle?
            give_items(player, DIMENSIONAL_DIAMOND, 45)
          else
            give_items(player, DIMENSIONAL_DIAMOND, 72)
          end
          player.variables["2ND_CLASS_DIAMOND_REWARD"] = 1
          htmltext = "30473-04a.htm"
        else
          htmltext = "30473-04.htm"
        end
      end
    when "30473-08.html"
      if qs.memo_state?(10) && has_quest_items?(player, GOLDEN_STATUE)
        htmltext = event
      end
    when "30473-09.html"
      if qs.memo_state?(10) && has_quest_items?(player, GOLDEN_STATUE)
        give_adena(player, 233490, true)
        give_items(player, MARK_OF_HEALER, 1)
        add_exp_and_sp(player, 738283, 50662)
        qs.exit_quest(false, true)
        player.send_packet(SocialAction.new(player.l2id, 3))
        htmltext = event
      end
    when "30428-02.html"
      if qs.memo_state?(1) && has_quest_items?(player, REPORT_OF_PERRIN)
        npc = npc.not_nil!
        qs.set_cond(2, true)
        if npc.summoned_npc_count < 1
          add_attack_desire(add_spawn(npc, TATOMA, npc, true, 200000), player)
        end
      end
      htmltext = event
    when "30658-02.html"
      if qs.memo_state?(4) && !has_at_least_one_quest_item?(player, PICTURE_OF_WINDY, WINDYS_PEBBLES, GOLDEN_STATUE)
        if get_quest_items_count(player, ADENA) >= 100000
          take_items(player, ADENA, 100000)
          give_items(player, PICTURE_OF_WINDY, 1)
          qs.set_cond(7, true)
          htmltext = event
        else
          htmltext = "30658-05.html"
        end
      end
    when "30658-03.html"
      if qs.memo_state?(4) && !has_at_least_one_quest_item?(player, PICTURE_OF_WINDY, WINDYS_PEBBLES, GOLDEN_STATUE)
        qs.memo_state = 5
        htmltext = event
      end
    when "30658-07.html"
      htmltext = event
    when "30660-02.html"
      if has_quest_items?(player, PICTURE_OF_WINDY)
        htmltext = event
      end
    when "30660-03.html"
      if has_quest_items?(player, PICTURE_OF_WINDY)
        npc = npc.not_nil!
        take_items(player, PICTURE_OF_WINDY, 1)
        give_items(player, WINDYS_PEBBLES, 1)
        qs.set_cond(8, true)
        npc.delete_me
        htmltext = event
      end
    when "30665-02.html"
      if get_quest_items_count(player, SECRET_LETTER1) + get_quest_items_count(player, SECRET_LETTER2) + get_quest_items_count(player, SECRET_LETTER3) + get_quest_items_count(player, SECRET_LETTER4) == 4
        give_items(player, CRISTINAS_LETTER, 1)
        take_items(player, SECRET_LETTER1, 1)
        take_items(player, SECRET_LETTER2, 1)
        take_items(player, SECRET_LETTER3, 1)
        take_items(player, SECRET_LETTER4, 1)
        qs.memo_state = 9
        qs.set_cond(22, true)
        htmltext = event
      end
    when "30674-02.html"
      if qs.memo_state?(6)
        npc = npc.not_nil!
        qs.set_cond(11)
        take_items(player, ORDER_OF_SORIUS, 1)
        add_spawn(npc, LERO_LIZARDMAN_AGENT, npc, true, 200000)
        add_spawn(npc, LERO_LIZARDMAN_AGENT, npc, true, 200000)
        add_spawn(npc, LERO_LIZARDMAN_LEADER, npc, true, 200000)
        play_sound(player, Sound::ITEMSOUND_QUEST_BEFORE_BATTLE)
        htmltext = event
      end
    end

    htmltext
  end

  def on_kill(npc, killer, is_summon)
    qs = get_quest_state(killer, false)
    if qs && qs.started? && Util.in_range?(1500, npc, killer, true)
      case npc.id
      when LERO_LIZARDMAN_LEADER
        if qs.memo_state?(6) && !has_quest_items?(killer, SECRET_LETTER1)
          give_items(killer, SECRET_LETTER1, 1)
          qs.set_cond(12, true)
        end
      when LERO_LIZARDMAN_ASSASSIN
        if qs.memo_state?(8) && has_quest_items?(killer, SECRET_LETTER1) && !has_quest_items?(killer, SECRET_LETTER2)
          give_items(killer, SECRET_LETTER2, 1)
          qs.set_cond(15, true)
        end
      when LERO_LIZARDMAN_SNIPER
        if qs.memo_state?(8) && has_quest_items?(killer, SECRET_LETTER1) && !has_quest_items?(killer, SECRET_LETTER3)
          give_items(killer, SECRET_LETTER3, 1)
          qs.set_cond(17, true)
        end
      when LERO_LIZARDMAN_LORD
        if qs.memo_state?(8) && has_quest_items?(killer, SECRET_LETTER1) && !has_quest_items?(killer, SECRET_LETTER4)
          give_items(killer, SECRET_LETTER4, 1)
          qs.set_cond(19, true)
        end
      when TATOMA
        if qs.memo_state?(1)
          qs.memo_state = 2
          qs.set_cond(3, true)
          play_sound(killer, Sound::ITEMSOUND_QUEST_MIDDLE)
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
      if npc.id == PRIEST_BANDELLOS
        if player.in_category?(CategoryType::WHITE_MAGIC_GROUP)
          if player.level >= MIN_LEVEL
            htmltext = "30473-03.htm"
          else
            htmltext = "30473-01.html"
          end
        else
          htmltext = "30473-02.html"
        end
      end
    elsif qs.started?
      case npc.id
      when PRIEST_BANDELLOS
        if (memo_state >= 1) && (memo_state < 10)
          htmltext = "30473-05.html"
        elsif memo_state == 10
          if has_quest_items?(player, GOLDEN_STATUE)
            htmltext = "30473-07.html"
          else
            give_adena(player, 266980, true)
            give_items(player, MARK_OF_HEALER, 1)
            add_exp_and_sp(player, 1476566, 101324)
            qs.exit_quest(false, true)
            player.send_packet(SocialAction.new(player.l2id, 3))
            htmltext = "30473-06.html"
          end
        end
      when MASTER_SORIUS
        if memo_state == 5
          give_items(player, ORDER_OF_SORIUS, 1)
          qs.memo_state = 6
          qs.set_cond(10, true)
          htmltext = "30327-01.html"
        elsif (memo_state >= 6) && (memo_state < 9)
          htmltext = "30327-02.html"
        elsif memo_state == 9
          if has_quest_items?(player, CRISTINAS_LETTER)
            take_items(player, CRISTINAS_LETTER, 1)
            qs.memo_state = 10
            qs.set_cond(23, true)
            htmltext = "30327-03.html"
          end
        elsif memo_state >= 10
          htmltext = "30327-04.html"
        end
      when ALLANA
        if memo_state == 3
          qs.memo_state = 4
          qs.set_cond(5, true)
          htmltext = "30424-01.html"
        elsif memo_state == 4
          qs.memo_state = 4
          htmltext = "30424-02.html"
        end
      when PERRIN
        if memo_state == 1
          if has_quest_items?(player, REPORT_OF_PERRIN)
            htmltext = "30428-01.html"
          end
        elsif memo_state == 2
          take_items(player, REPORT_OF_PERRIN, 1)
          qs.memo_state = 3
          qs.set_cond(4, true)
          htmltext = "30428-03.html"
        elsif memo_state == 3
          htmltext = "30428-04.html"
        end
      when FATHER_GUPU
        if memo_state == 4
          if !has_at_least_one_quest_item?(player, PICTURE_OF_WINDY, WINDYS_PEBBLES, GOLDEN_STATUE)
            qs.set_cond(6, true)
            htmltext = "30658-01.html"
          elsif has_quest_items?(player, PICTURE_OF_WINDY)
            htmltext = "30658-04.html"
          elsif has_quest_items?(player, WINDYS_PEBBLES)
            give_items(player, GOLDEN_STATUE, 1)
            take_items(player, WINDYS_PEBBLES, 1)
            qs.memo_state = 5
            htmltext = "30658-06.html"
          end
        elsif memo_state == 5
          qs.set_cond(9, true)
          htmltext = "30658-07.html"
        end
      when ORPHAN_GIRL
        case Rnd.rand(5)
        when 0
          htmltext = "30659-01.html"
        when 1
          htmltext = "30659-02.html"
        when 2
          htmltext = "30659-03.html"
        when 3
          htmltext = "30659-04.html"
        when 4
          htmltext = "30659-05.html"
        end
      when WINDY_SHAORING
        if has_quest_items?(player, PICTURE_OF_WINDY)
          htmltext = "30660-01.html"
        elsif has_quest_items?(player, WINDYS_PEBBLES)
          htmltext = "30660-04.html"
        end
      when MYSTERIOUS_DARK_ELF
        if memo_state == 8
          if has_quest_items?(player, SECRET_LETTER1) && !has_quest_items?(player, SECRET_LETTER2)
            if npc.summoned_npc_count < 36
              add_spawn(npc, LERO_LIZARDMAN_ASSASSIN, npc, true, 200000)
              add_spawn(npc, LERO_LIZARDMAN_ASSASSIN, npc, true, 200000)
              add_spawn(npc, LERO_LIZARDMAN_ASSASSIN, npc, true, 200000)
              play_sound(player, Sound::ITEMSOUND_QUEST_BEFORE_BATTLE)
            end
            qs.set_cond(14)
            npc.delete_me
            htmltext = "30661-01.html"
          elsif has_quest_items?(player, SECRET_LETTER1, SECRET_LETTER2) && !has_quest_items?(player, SECRET_LETTER3)
            if npc.summoned_npc_count < 36
              add_spawn(npc, LERO_LIZARDMAN_SNIPER, npc, true, 200000)
              add_spawn(npc, LERO_LIZARDMAN_SNIPER, npc, true, 200000)
              add_spawn(npc, LERO_LIZARDMAN_SNIPER, npc, true, 200000)
              play_sound(player, Sound::ITEMSOUND_QUEST_BEFORE_BATTLE)
            end
            qs.set_cond(16)
            npc.delete_me
            htmltext = "30661-02.html"
          elsif has_quest_items?(player, SECRET_LETTER1, SECRET_LETTER2, SECRET_LETTER3) && !has_quest_items?(player, SECRET_LETTER4)
            if npc.summoned_npc_count < 36
              add_spawn(npc, LERO_LIZARDMAN_WIZARD, npc, true, 200000)
              add_spawn(npc, LERO_LIZARDMAN_WIZARD, npc, true, 200000)
              add_spawn(npc, LERO_LIZARDMAN_LORD, npc, true, 200000)
              play_sound(player, Sound::ITEMSOUND_QUEST_BEFORE_BATTLE)
            end
            qs.set_cond(18)
            npc.delete_me
            htmltext = "30661-03.html"
          elsif get_quest_items_count(player, SECRET_LETTER1) + get_quest_items_count(player, SECRET_LETTER2) + get_quest_items_count(player, SECRET_LETTER3) + get_quest_items_count(player, SECRET_LETTER4) == 4
            qs.set_cond(20, true)
            htmltext = "30661-04.html"
          end
        end
      when PIPER_LONGBOW
        if memo_state == 8
          if has_quest_items?(player, SECRET_LETTER1) && !has_quest_items?(player, SECRET_LETTER2)
            htmltext = "30662-01.html"
          elsif has_quest_items?(player, SECRET_LETTER2) && !has_quest_items?(player, SECRET_LETTER3, SECRET_LETTER4)
            htmltext = "30662-02.html"
          elsif has_quest_items?(player, SECRET_LETTER2, SECRET_LETTER3, SECRET_LETTER4)
            qs.set_cond(21, true)
            htmltext = "30662-03.html"
          end
        end
      when SLEIN_SHINING_BLADE
        if memo_state == 8
          if has_quest_items?(player, SECRET_LETTER1) && !has_quest_items?(player, SECRET_LETTER2)
            htmltext = "30663-01.html"
          elsif has_quest_items?(player, SECRET_LETTER2) && !has_quest_items?(player, SECRET_LETTER3, SECRET_LETTER4)
            htmltext = "30663-02.html"
          elsif has_quest_items?(player, SECRET_LETTER2, SECRET_LETTER3, SECRET_LETTER4)
            qs.set_cond(21, true)
            htmltext = "30663-03.html"
          end
        end
      when CAIN_FLYING_KNIFE
        if memo_state == 8
          if has_quest_items?(player, SECRET_LETTER1) && !has_quest_items?(player, SECRET_LETTER4)
            htmltext = "30664-01.html"
          elsif has_quest_items?(player, SECRET_LETTER2) && !has_quest_items?(player, SECRET_LETTER3, SECRET_LETTER4)
            htmltext = "30664-02.html"
          elsif has_quest_items?(player, SECRET_LETTER2, SECRET_LETTER3, SECRET_LETTER4)
            qs.set_cond(21, true)
            htmltext = "30664-03.html"
          end
        end
      when SAINT_KRISTINA
        if get_quest_items_count(player, SECRET_LETTER1) + get_quest_items_count(player, SECRET_LETTER2) + get_quest_items_count(player, SECRET_LETTER3) + get_quest_items_count(player, SECRET_LETTER4) == 4
          htmltext = "30665-01.html"
        elsif memo_state < 9
          if get_quest_items_count(player, SECRET_LETTER1) + get_quest_items_count(player, SECRET_LETTER2) + get_quest_items_count(player, SECRET_LETTER3) + get_quest_items_count(player, SECRET_LETTER4) < 4
            htmltext = "30665-03.html"
          end
        elsif memo_state >= 9
          htmltext = "30665-04.html"
        end
      when DAURIN_HAMMERCRUSH
        if memo_state == 6
          if has_quest_items?(player, ORDER_OF_SORIUS)
            htmltext = "30674-01.html"
          elsif !has_at_least_one_quest_item?(player, SECRET_LETTER1, ORDER_OF_SORIUS)
            if npc.summoned_npc_count < 4
              add_spawn(npc, LERO_LIZARDMAN_AGENT, npc, true, 200000)
              add_spawn(npc, LERO_LIZARDMAN_LEADER, npc, true, 200000)
            end
            htmltext = "30674-02a.html"
          elsif has_quest_items?(player, SECRET_LETTER1)
            qs.memo_state = 8
            qs.set_cond(13, true)
            htmltext = "30674-03.html"
          end
        elsif memo_state >= 8
          htmltext = "30674-04.html"
        end
      end
    elsif qs.completed?
      if npc.id == PRIEST_BANDELLOS
        htmltext = get_already_completed_msg(player)
      end
    end

    htmltext
  end
end
