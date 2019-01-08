# At some point between talking with Innocentin and Tifaren, the quest can only
# progress if the player manually deletes the cross of einhasad from his
# inventory.
class Quests::Q00022_TragedyInVonHellmannForest < Quest
  # NPCs
  private INNOCENTIN = 31328
  private TIFAREN = 31334
  private WELL = 31527
  private GHOST_OF_PRIEST = 31528
  private GHOST_OF_ADVENTURER = 31529
  # Mobs
  private MOBS = {
    21553, # Trampled Man
    21554, # Trampled Man
    21555, # Slaughter Executioner
    21556, # Slaughter Executioner
    21561  # Sacrificed Man
  }
  private SOUL_OF_WELL = 27217
  # Items
  private CROSS_OF_EINHASAD = 7141
  private LOST_SKULL_OF_ELF = 7142
  private LETTER_OF_INNOCENTIN = 7143
  private JEWEL_OF_ADVENTURER_1 = 7144
  private JEWEL_OF_ADVENTURER_2 = 7145
  private SEALED_REPORT_BOX = 7146
  private REPORT_BOX = 7147
  # Misc
  private MIN_LVL = 63
  private PRIEST_LOC = Location.new(38354, -49777, -1128)
  private SOUL_WELL_LOC = Location.new(34706, -54590, -2054)

  @soul_well : L2Npc?
  @tifaren_owner = 0

  def initialize
    super(22, self.class.simple_name, "Tragedy in Von Hellmann Forest")

    add_kill_id(MOBS)
    add_kill_id(SOUL_OF_WELL)
    add_attack_id(SOUL_OF_WELL)
    add_start_npc(TIFAREN)
    add_talk_id(INNOCENTIN, TIFAREN, WELL, GHOST_OF_PRIEST, GHOST_OF_ADVENTURER)
    register_quest_items(LOST_SKULL_OF_ELF, CROSS_OF_EINHASAD, REPORT_BOX, JEWEL_OF_ADVENTURER_1, JEWEL_OF_ADVENTURER_2, SEALED_REPORT_BOX)
  end

  def on_adv_event(event, npc, player)
    debug "#on_adv_event(event: #{event}, npc: #{npc}, player: #{player})"
    return unless player
    return unless qs = get_quest_state(player, false)
    htmltext = nil

    case event
    when "31529-02.html", "31529-04.html", "31529-05.html", "31529-06.html",
         "31529-07.html", "31529-09.html", "31529-13.html", "31529-13a.html",
         "31528-02.html", "31528-05.html", "31528-06.html", "31528-07.html",
         "31328-13.html", "31328-06.html", "31328-05.html", "31328-02.html",
         "31328-07.html", "31328-08.html", "31328-14.html", "31328-15.html",
         "31328-16.html", "31328-17.html", "31328-18.html", "31334-12.html"
      htmltext = event
    when "31334-02.htm"
      if qs.created?
        q21 = player.get_quest_state(Q00021_HiddenTruth.simple_name)
        if player.level >= MIN_LVL && q21 && q21.completed?
          htmltext = event
        else
          htmltext = "31334-03.html"
        end
      end
    when "31334-04.html"
      if qs.created?
        qs.start_quest
        htmltext = event
      end
    when "31334-06.html"
      if qs.cond?(3) && has_quest_items?(player, CROSS_OF_EINHASAD)
        htmltext = event
      else
        qs.set_cond(2, true)
        htmltext = "31334-07.html"
      end
    when "31334-08.html"
      if qs.cond?(3)
        qs.set_cond(4, true)
        htmltext = event
      end
    when "31334-13.html"
      cond = qs.cond
      if 5 <= cond <= 7 && has_quest_items?(player, CROSS_OF_EINHASAD)
        if @tifaren_owner == 0
          @tifaren_owner = player.l2id
          ghost2 = add_spawn(GHOST_OF_PRIEST, PRIEST_LOC, true, 0)
          ghost2.script_value = player.l2id
          qs.start_quest_timer("DESPAWN_GHOST2", 1000 * 120, ghost2)
          ghost2.broadcast_packet(NpcSay.new(ghost2.l2id, Say2::NPC_ALL, ghost2.id, NpcString::DID_YOU_CALL_ME_S1).add_string_parameter(player.name))
          if (cond == 5 || cond == 6) && has_quest_items?(player, LOST_SKULL_OF_ELF)
            take_items(player, LOST_SKULL_OF_ELF, -1)
            qs.set_cond(7, true)
          end
          htmltext = event
        else
          qs.set_cond(6, true)
          htmltext = "31334-14.html"
        end
      end
    when "31528-04.html"
      npc = npc.not_nil!
      if npc.script_value == player.l2id
        play_sound(player, Sound::AMBSOUND_HORROR_03)
        htmltext = event
      end
    when "31528-08.html"
      npc = npc.not_nil!
      qt = get_quest_timer("DESPAWN_GHOST2", npc, player)
      if qt && npc.script_value == player.l2id
        qt.cancel_and_remove
        npc.script_value = 0
        qs.start_quest_timer("DESPAWN_GHOST2", 1000 * 3, npc)
        qs.set_cond(8)
        htmltext = event
      end
    when "DESPAWN_GHOST2"
      npc = npc.not_nil!
      @tifaren_owner = 0
      if npc.script_value != 0
        npc.broadcast_packet(NpcSay.new(npc.l2id, Say2::NPC_ALL, npc.id, NpcString::IM_CONFUSED_MAYBE_ITS_TIME_TO_GO_BACK))
      end
      npc.delete_me
    when "31328-03.html"
      if qs.cond?(8)
        take_items(player, CROSS_OF_EINHASAD, -1)
        htmltext = event
      end
    when "31328-09.html"
      if qs.cond?(8)
        give_items(player, LETTER_OF_INNOCENTIN, 1)
        qs.set_cond(9, true)
        htmltext = event
      end
    when "31328-11.html"
      if qs.cond?(14) && has_quest_items?(player, REPORT_BOX)
        take_items(player, REPORT_BOX, -1)
        qs.set_cond(15, true)
        htmltext = event
      end
    when "31328-19.html"
      if qs.cond?(15)
        qs.set_cond(16, true)
        htmltext = event
      end
    when "31527-02.html"
      if qs.cond?(10) && (@soul_well.nil?)
        @soul_well = add_spawn(SOUL_OF_WELL, SOUL_WELL_LOC, true, 0)
        qs.start_quest_timer("activateSoulOfWell", 90_000, @soul_well)
        qs.start_quest_timer("despawnSoulOfWell", 120_000, @soul_well)
        @soul_well.not_nil!.set_intention(AI::ATTACK, player)
        play_sound(player, Sound::SKILLSOUND_ANTARAS_FEAR)
        htmltext = event
      else
        htmltext = "31527-03.html"
      end
    when "activateSoulOfWell"
      npc = npc.not_nil!
      # this enables onAttack ELSE IF block which allows the player to proceed the quest
      npc.script_value = 1
    when "despawnSoulOfWell"
      npc = npc.not_nil!
      # if the player fails to proceed the quest in 2 minutes, the soul is unspawned
      if npc.alive?
        @soul_well = nil
      end
      npc.delete_me
    when "31529-03.html"
      if qs.cond?(9) && has_quest_items?(player, LETTER_OF_INNOCENTIN)
        qs.memo_state = 8
        htmltext = event
      end
    when "31529-08.html"
      if qs.memo_state?(8)
        qs.memo_state = 9
        htmltext = event
      end
    when "31529-11.html"
      if qs.memo_state?(9)
        give_items(player, JEWEL_OF_ADVENTURER_1, 1)
        qs.set_cond(10, true)
        qs.memo_state = 10
        htmltext = event
      end
    end

    htmltext
  end

  def on_attack(npc, attacker, damage, is_summon)
    qs = get_quest_state(attacker, false)

    if qs && qs.cond?(10) && has_quest_items?(attacker, JEWEL_OF_ADVENTURER_1)
      if qs.memo_state?(10)
        qs.memo_state = 11
      elsif npc.script_value?(1)
        take_items(attacker, JEWEL_OF_ADVENTURER_1, -1)
        give_items(attacker, JEWEL_OF_ADVENTURER_2, 1)
        qs.set_cond(11, true)
      end
    end

    super
  end

  def on_kill(npc, killer, is_summon)
    if Util.in_range?(1500, killer, npc, true)
      if npc.id == SOUL_OF_WELL
        @soul_well = nil
      else
        qs = get_quest_state(killer, false)
        if qs && qs.cond?(4) && has_quest_items?(killer, CROSS_OF_EINHASAD) && !has_quest_items?(killer, LOST_SKULL_OF_ELF) && (rand(100) < 10)
          give_items(killer, LOST_SKULL_OF_ELF, 1)
          qs.set_cond(5, true)
        end
      end
    end

    super
  end

  def on_talk(npc, talker)
    debug "#on_talk(npc: #{npc}, talker: #{talker})"
    qs = get_quest_state!(talker)
    debug "cond: #{qs.cond}, memo_state: #{qs.memo_state}"
    htmltext = get_no_quest_msg(talker)
    case npc.id
    when TIFAREN
      case qs.cond
      when 0
        if qs.created?
          htmltext = "31334-01.htm"
        elsif qs.completed?
          htmltext = get_already_completed_msg(talker)
        end
      when 1, 3
        htmltext = "31334-05.html"
      when 4, 5
        if has_quest_items?(talker, CROSS_OF_EINHASAD)
          if !has_quest_items?(talker, LOST_SKULL_OF_ELF)
            htmltext = "31334-09.html"
          elsif @tifaren_owner == 0
            htmltext = "31334-10.html"
          else
            htmltext = "31334-11.html"
          end
        end
      when 6, 7
        if has_quest_items?(talker, CROSS_OF_EINHASAD)
          if @tifaren_owner == 0
            htmltext = "31334-17.html"
          elsif @tifaren_owner == talker.l2id
            htmltext = "31334-15.html"
          else
            htmltext = "31334-16.html"
            qs.set_cond(6, true)
          end
        end
      when 8
        if has_quest_items?(talker, CROSS_OF_EINHASAD)
          htmltext = "31334-18.html"
        end
      end
    when GHOST_OF_PRIEST
      play_sound(talker, Sound::AMBSOUND_HORROR_15)
      if npc.script_value == talker.l2id
        htmltext = "31528-01.html"
      else
        htmltext = "31528-03.html"
      end
    when INNOCENTIN
      case qs.cond
      when 2
        unless has_quest_items?(talker, CROSS_OF_EINHASAD)
          give_items(talker, CROSS_OF_EINHASAD, 1)
          qs.set_cond(3, true)
          htmltext = "31328-01.html"
        end
      when 3
        if has_quest_items?(talker, CROSS_OF_EINHASAD)
          htmltext = "31328-01b.html"
        end
      when 8
        if has_quest_items?(talker, CROSS_OF_EINHASAD)
          htmltext = "31328-02.html"
        else
          htmltext = "31328-04.html"
        end
      when 9
        htmltext = "31328-09a.html"
      when 14
        if has_quest_items?(talker, REPORT_BOX)
          htmltext = "31328-10.html"
        end
      when 15
        htmltext = "31328-12.html"
      when 16
        add_exp_and_sp(talker, 345966, 31578)
        qs.exit_quest(false, true)
        if talker.level >= MIN_LVL
          htmltext = "31328-20.html"
        else
          htmltext = "31328-21.html"
        end
      end
    when WELL
      case qs.cond
      when 10
        if has_quest_items?(talker, JEWEL_OF_ADVENTURER_1)
          htmltext = "31527-01.html"
          play_sound(talker, Sound::AMBSOUND_HORROR_01)
        end
      when 12
        if has_quest_items?(talker, JEWEL_OF_ADVENTURER_2) && !has_quest_items?(talker, SEALED_REPORT_BOX)
          give_items(talker, SEALED_REPORT_BOX, 1)
          qs.set_cond(13, true)
          htmltext = "31527-04.html"
        end
      when 13..16
        htmltext = "31527-05.html"
      end
    when GHOST_OF_ADVENTURER
      case qs.cond
      when 9
        if has_quest_items?(talker, LETTER_OF_INNOCENTIN)
          case qs.memo_state
          # L2J says it's "when 0" but that doesn't take into account the fact
          # that QuestState#memo_state now returns -1 instead of 0 if there's
          # no set memo state.
          when -1
            htmltext = "31529-01.html"
          when 8
            htmltext = "31529-03a.html"
          when 9
            htmltext = "31529-10.html"
          end
        end
      when 10
        if has_quest_items?(talker, JEWEL_OF_ADVENTURER_1)
          id = qs.memo_state
          if id == 10
            htmltext = "31529-12.html"
          elsif id == 11
            htmltext = "31529-14.html"
          end
        end
      when 11
        if has_quest_items?(talker, JEWEL_OF_ADVENTURER_2) && !has_quest_items?(talker, SEALED_REPORT_BOX)
          htmltext = "31529-15.html"
          qs.set_cond(12, true)
        end
      when 13
        if has_quest_items?(talker, JEWEL_OF_ADVENTURER_2) && has_quest_items?(talker, SEALED_REPORT_BOX)
          give_items(talker, REPORT_BOX, 1)
          take_items(talker, SEALED_REPORT_BOX, -1)
          take_items(talker, JEWEL_OF_ADVENTURER_2, -1)
          qs.set_cond(14, true)
          htmltext = "31529-16.html"
        end
      when 14
        if has_quest_items?(talker, REPORT_BOX)
          htmltext = "31529-17.html"
        end
      end
    end

    htmltext
  end
end
