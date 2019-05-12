class Scripts::Q00345_MethodToRaiseTheDead < Quest
  # NPCs
  private XENOVIA = 30912
  private DOROTHY = 30970
  private ORPHEUS = 30971
  private MEDIUM_JAR = 30973
  # Items
  private IMPERIAL_DIAMOND = 3456
  private VICTIMS_ARM_BONE = 4274
  private VICTIMS_THIGH_BONE = 4275
  private VICTIMS_SKULL = 4276
  private VICTIMS_RIB_BONE = 4277
  private VICTIMS_SPINE = 4278
  private USELESS_BONE_PIECES = 4280
  private POWDER_TO_SUMMON_DEAD_SOULS = 4281
  private BILL_OF_IASON_HEINE = 4407
  # Misc
  private MIN_LEVEL = 35
  # Monsters
  private CROKIAN = 20789
  private CROKIAN_WARRIOR = 20791

  def initialize
    super(345, self.class.simple_name, "Method to Raise the Dead")

    add_start_npc(DOROTHY)
    add_talk_id(DOROTHY, ORPHEUS, MEDIUM_JAR, XENOVIA)
    add_kill_id(CROKIAN, CROKIAN_WARRIOR)
    register_quest_items(
      VICTIMS_ARM_BONE, VICTIMS_THIGH_BONE, VICTIMS_SKULL, VICTIMS_RIB_BONE,
      VICTIMS_SPINE, USELESS_BONE_PIECES, POWDER_TO_SUMMON_DEAD_SOULS
    )
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    unless qs = get_quest_state(pc, false)
      return
    end

    case event
    when "30970-02.htm"
      qs.start_quest
      html = event
    when "30970-03.html"
      qs.memo_state = 1
      html = event
    when "30970-07.html"
      if has_quest_items?(pc, VICTIMS_ARM_BONE, VICTIMS_THIGH_BONE, VICTIMS_SKULL, VICTIMS_RIB_BONE, VICTIMS_SPINE)
        qs.memo_state = 2
        qs.set_cond(2, true)
        html = event
      end
    when "30971-02.html", "30912-05.html"
      html = event
    when "30971-03.html"
      useless_bone_pieces_count = get_quest_items_count(pc, USELESS_BONE_PIECES)

      if useless_bone_pieces_count > 0
        give_adena(pc, useless_bone_pieces_count * 104, true)
        take_items(pc, USELESS_BONE_PIECES, -1)
        html = event
      end
    when "30973-02.html"
      memo_state_ex = qs.get_memo_state_ex(1)

      if memo_state_ex == 1
        html = event
      elsif memo_state_ex == 2
        html = "30973-04.html"
      elsif memo_state_ex == 3
        html = "30973-06.html"
      end
    when "30973-03.html"
      if qs.memo_state?(7) && qs.get_memo_state_ex(1) == 1
        qs.memo_state = 8
        qs.set_cond(6, true)
        html = event
      end
    when "30973-05.html"
      if qs.memo_state?(7) && qs.get_memo_state_ex(1) == 2
        qs.memo_state = 8
        qs.set_cond(6, true)
        html = event
      end
    when "30973-07.html"
      if qs.memo_state?(7) && qs.get_memo_state_ex(1) == 3
        qs.memo_state = 8
        qs.set_cond(7, true)
        html = event
      end
    when "30912-02.html"
      if qs.memo_state?(2)
        html = event
      end
    when "30912-03.html"
      if qs.memo_state?(2)
        if pc.adena >= 1000
          give_items(pc, POWDER_TO_SUMMON_DEAD_SOULS, 1)
          take_items(pc, Inventory::ADENA_ID, 1000)
          qs.memo_state = 3
          qs.set_cond(3, true)
          html = event
        else
          html = "30912-04.html"
        end
      end
    end

    html
  end

  def on_kill(npc, killer, is_summon)
    qs = get_random_party_member_state(killer, 1, 3, npc)

    if qs.nil? || !Util.in_range?(1500, npc, killer, true)
      return
    end

    random = rand(100)
    if random <= 5
      if !has_quest_items?(qs.player, VICTIMS_ARM_BONE)
        give_items(qs.player, VICTIMS_ARM_BONE, 1)
      else
        give_items(qs.player, USELESS_BONE_PIECES, 1)
      end

      play_sound(qs.player, Sound::ITEMSOUND_QUEST_ITEMGET)
    elsif random <= 11
      if !has_quest_items?(qs.player, VICTIMS_THIGH_BONE)
        give_items(qs.player, VICTIMS_THIGH_BONE, 1)
      else
        give_items(qs.player, USELESS_BONE_PIECES, 1)
      end

      play_sound(qs.player, Sound::ITEMSOUND_QUEST_ITEMGET)
    elsif random <= 17
      if !has_quest_items?(qs.player, VICTIMS_SKULL)
        give_items(qs.player, VICTIMS_SKULL, 1)
      else
        give_items(qs.player, USELESS_BONE_PIECES, 1)
      end

      play_sound(qs.player, Sound::ITEMSOUND_QUEST_ITEMGET)
    elsif random <= 23
      if !has_quest_items?(qs.player, VICTIMS_RIB_BONE)
        give_items(qs.player, VICTIMS_RIB_BONE, 1)
      else
        give_items(qs.player, USELESS_BONE_PIECES, 1)
      end

      play_sound(qs.player, Sound::ITEMSOUND_QUEST_ITEMGET)
    elsif random <= 29
      if !has_quest_items?(qs.player, VICTIMS_SPINE)
        give_items(qs.player, VICTIMS_SPINE, 1)
      else
        give_items(qs.player, USELESS_BONE_PIECES, 1)
      end

      play_sound(qs.player, Sound::ITEMSOUND_QUEST_ITEMGET)
    elsif random <= 60
      give_items(qs.player, USELESS_BONE_PIECES, 1)
    end

    super
  end

  def on_talk(npc, pc)
    qs = get_quest_state!(pc)

    if qs.created?
      html = pc.level >= MIN_LEVEL ? "30970-01.htm" : "30970-04.htm"
    elsif qs.started?
      case npc.id
      when DOROTHY
        case qs.memo_state
        when 0
          html = "30970-03.html"
          qs.memo_state = 1
        when 1
          if has_quest_items?(pc, VICTIMS_ARM_BONE, VICTIMS_THIGH_BONE, VICTIMS_SKULL, VICTIMS_RIB_BONE, VICTIMS_SPINE)
            html = "30970-06.html"
          else
            html = "30970-05.html"
          end
        when 2
          html = "30970-08.html"
        when 3
          html = "30970-09.html"
        when 7
          html = "30970-10.html"
        when 8
          memo_state_ex = qs.get_memo_state_ex(1)
          useless_bone_pieces_count = get_quest_items_count(pc, USELESS_BONE_PIECES)

          if memo_state_ex == 1 || memo_state_ex == 2
            give_items(pc, BILL_OF_IASON_HEINE, 3)
            give_adena(pc, 5390i64 + (70 * useless_bone_pieces_count), true)
            html = "30970-11.html"
          elsif memo_state_ex == 3
            if rand(100) <= 92
              give_items(pc, BILL_OF_IASON_HEINE, 5)
            else
              give_items(pc, IMPERIAL_DIAMOND, 1)
            end

            give_adena(pc, 3040i64 + (70 * useless_bone_pieces_count), true)
            html = "30970-12.html"
          end

          qs.exit_quest(true, true)
        end
      when ORPHEUS
        if has_quest_items?(pc, USELESS_BONE_PIECES)
          html = "30971-01.html"
        end
      when MEDIUM_JAR
        case qs.memo_state
        when 3
          take_items(pc, -1, {POWDER_TO_SUMMON_DEAD_SOULS, VICTIMS_ARM_BONE, VICTIMS_THIGH_BONE, VICTIMS_SKULL, VICTIMS_RIB_BONE, VICTIMS_SPINE})
          qs.memo_state = 7

          random = rand(100)

          if random <= 39
            qs.set_memo_state_ex(1, 1)
          elsif random <= 79
            qs.set_memo_state_ex(1, 2)
          else
            qs.set_memo_state_ex(1, 3)
          end

          html = "30973-01.html"
        when 7
          memo_state_ex = qs.get_memo_state_ex(1)

          if memo_state_ex == 1
            html = "30973-08.html"
          elsif memo_state_ex == 2
            html = "30973-09.html"
          elsif memo_state_ex == 3
            html = "30973-10.html"
          end
        when 8
          html = "30973-11.html"
        end
      when XENOVIA
        if qs.memo_state?(2)
          html = "30912-01.html"
        elsif qs.memo_state?(7) || qs.memo_state?(8) || has_quest_items?(pc, POWDER_TO_SUMMON_DEAD_SOULS)
          html = "30912-06.html"
        end
      end
    end

    html || get_no_quest_msg(pc)
  end
end
