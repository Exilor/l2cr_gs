class Scripts::Q00215_TrialOfThePilgrim < Quest
  # NPCs
  private PRIEST_PETRON = 30036
  private PRIEST_PRIMOS = 30117
  private ANDELLIA = 30362
  private GAURI_TWINKLEROCK = 30550
  private SEER_TANAPI = 30571
  private ELDER_CASIAN = 30612
  private HERMIT_SANTIAGO = 30648
  private ANCESTOR_MARTANKUS = 30649
  private PRIEST_OF_THE_EARTH_GERALD = 30650
  private WANDERER_DORF = 30651
  private URUHA = 30652
  # Items
  private ADENA = 57
  private BOOK_OF_SAGE = 2722
  private VOUCHER_OF_TRIAL = 2723
  private SPIRIT_OF_FLAME = 2724
  private ESSENCE_OF_FLAME = 2725
  private BOOK_OF_GERALD = 2726
  private GREY_BADGE = 2727
  private PICTURE_OF_NAHIR = 2728
  private HAIR_OF_NAHIR = 2729
  private STATUE_OF_EINHASAD = 2730
  private BOOK_OF_DARKNESS = 2731
  private DEBRIS_OF_WILLOW = 2732
  private TAG_OF_RUMOR = 2733
  # Reward
  private MARK_OF_PILGRIM = 2721
  private DIMENSIONAL_DIAMOND = 7562
  # Quest Monster
  private LAVA_SALAMANDER = 27116
  private NAHIR = 27117
  private BLACK_WILLOW = 27118
  # Misc
  private MIN_LVL = 35

  def initialize
    super(215, self.class.simple_name, "Trial Of The Pilgrim")

    add_start_npc(HERMIT_SANTIAGO)
    add_talk_id(
      HERMIT_SANTIAGO, PRIEST_PETRON, PRIEST_PRIMOS, ANDELLIA,
      GAURI_TWINKLEROCK, SEER_TANAPI, ELDER_CASIAN, ANCESTOR_MARTANKUS,
      PRIEST_OF_THE_EARTH_GERALD, WANDERER_DORF, URUHA
    )
    add_kill_id(LAVA_SALAMANDER, NAHIR, BLACK_WILLOW)
    register_quest_items(
      BOOK_OF_SAGE, VOUCHER_OF_TRIAL, SPIRIT_OF_FLAME, ESSENCE_OF_FLAME,
      BOOK_OF_GERALD, GREY_BADGE, PICTURE_OF_NAHIR, HAIR_OF_NAHIR,
      STATUE_OF_EINHASAD, BOOK_OF_DARKNESS, DEBRIS_OF_WILLOW, TAG_OF_RUMOR
    )
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    return unless qs = get_quest_state(pc, false)

    case event
    when "ACCEPT"
      if qs.created?
        qs.start_quest
        qs.memo_state = 1
        give_items(pc, VOUCHER_OF_TRIAL, 1)
        play_sound(pc, Sound::ITEMSOUND_QUEST_MIDDLE)
        if pc.variables.get_i32("2ND_CLASS_DIAMOND_REWARD", 0) == 0
          give_items(pc, DIMENSIONAL_DIAMOND, 49)
          pc.variables["2ND_CLASS_DIAMOND_REWARD"] = 1
          html = "30648-04a.htm"
        else
          html = "30648-04.htm"
        end
      end
    when "30648-05.html", "30648-06.html", "30648-07.html", "30648-08.html"
      html = event
    when "30362-05.html"
      if qs.memo_state?(15) && has_quest_items?(pc, BOOK_OF_DARKNESS)
        take_items(pc, BOOK_OF_DARKNESS, 1)
        qs.memo_state = 16
        qs.set_cond(16, true)
        html = event
      end
    when "30362-04.html"
      if qs.memo_state?(15) && has_quest_items?(pc, BOOK_OF_DARKNESS)
        qs.memo_state = 16
        qs.set_cond(16, true)
        html = event
      end
    when "30649-04.html"
      if qs.memo_state?(4) && has_quest_items?(pc, ESSENCE_OF_FLAME)
        give_items(pc, SPIRIT_OF_FLAME, 1)
        take_items(pc, ESSENCE_OF_FLAME, 1)
        qs.memo_state = 5
        qs.set_cond(5, true)
        html = event
      end
    when "30650-02.html"
      if qs.memo_state?(6) && has_quest_items?(pc, TAG_OF_RUMOR)
        if get_quest_items_count(pc, ADENA) >= 100000
          give_items(pc, BOOK_OF_GERALD, 1)
          take_items(pc, ADENA, 100000)
          qs.memo_state = 7
          html = event
        else
          html = "30650-03.html"
        end
      end
    when "30650-03.html"
      if qs.memo_state?(6) && has_quest_items?(pc, TAG_OF_RUMOR)
        html = event
      end
    when "30652-02.html"
      if qs.memo_state?(14) && has_quest_items?(pc, DEBRIS_OF_WILLOW)
        give_items(pc, BOOK_OF_DARKNESS, 1)
        take_items(pc, DEBRIS_OF_WILLOW, 1)
        qs.memo_state = 15
        qs.set_cond(15, true)
        html = event
      end
    end


    return html
  end

  def on_kill(npc, killer, is_summon)
    qs = get_quest_state(killer, false)

    if qs && qs.started? && Util.in_range?(1500, npc, killer, true)
      case npc.id
      when LAVA_SALAMANDER
        if qs.memo_state?(3) && !has_quest_items?(killer, ESSENCE_OF_FLAME)
          qs.memo_state = 4
          qs.set_cond(4, true)
          give_items(killer, ESSENCE_OF_FLAME, 1)
        end
      when NAHIR
        if qs.memo_state?(10) && !has_quest_items?(killer, HAIR_OF_NAHIR)
          qs.memo_state = 11
          qs.set_cond(11, true)
          give_items(killer, HAIR_OF_NAHIR, 1)
        end
      when BLACK_WILLOW
        if qs.memo_state?(13) && !has_quest_items?(killer, DEBRIS_OF_WILLOW)
          qs.memo_state = 14
          qs.set_cond(14, true)
          give_items(killer, DEBRIS_OF_WILLOW, 1)
        end
      end

    end

    super
  end

  def on_talk(npc, pc)
    qs = get_quest_state!(pc)
    memo_state = qs.memo_state

    if qs.created?
      if npc.id == HERMIT_SANTIAGO
        if !pc.in_category?(CategoryType::HEAL_GROUP)
          html = "30648-02.html"
        elsif pc.level < MIN_LVL
          html = "30648-01.html"
        else
          html = "30648-03.htm"
        end
      end
    elsif qs.started?
      case npc.id
      when HERMIT_SANTIAGO
        if memo_state >= 1
          if !has_quest_items?(pc, BOOK_OF_SAGE)
            html = "30648-09.html"
          else
            give_adena(pc, 229298, true)
            give_items(pc, MARK_OF_PILGRIM, 1)
            add_exp_and_sp(pc, 1258250, 81606)
            qs.exit_quest(false, true)
            pc.send_packet(SocialAction.new(pc.l2id, 3))
            html = "30648-10.html"
          end
        end
      when PRIEST_PETRON
        if memo_state == 9
          give_items(pc, PICTURE_OF_NAHIR, 1)
          qs.memo_state = 10
          qs.set_cond(10, true)
          html = "30036-01.html"
        elsif memo_state == 10
          html = "30036-02.html"
        elsif memo_state == 11
          take_items(pc, PICTURE_OF_NAHIR, 1)
          take_items(pc, HAIR_OF_NAHIR, 1)
          give_items(pc, STATUE_OF_EINHASAD, 1)
          qs.memo_state = 12
          qs.set_cond(12, true)
          html = "30036-03.html"
        elsif memo_state == 12
          if has_quest_items?(pc, STATUE_OF_EINHASAD)
            html = "30036-04.html"
          end
        end
      when PRIEST_PRIMOS
        if memo_state == 8
          qs.memo_state = 9
          qs.set_cond(9, true)
          html = "30117-01.html"
        elsif memo_state == 9
          qs.memo_state = 9
          qs.set_cond(9, true)
          html = "30117-02.html"
        end
      when ANDELLIA
        if memo_state == 12
          if pc.level >= 0
            qs.memo_state = 13
            qs.set_cond(13, true)
            html = "30362-01.html"
          else
            html = "30362-01a.html"
          end
        elsif memo_state == 13
          html = "30362-02.html"
        elsif memo_state == 14
          html = "30362-02a.html"
        elsif memo_state == 15
          if has_quest_items?(pc, BOOK_OF_DARKNESS)
            html = "30362-03.html"
          else
            html = "30362-07.html"
          end
        elsif memo_state == 16
          html = "30362-06.html"
        end
      when GAURI_TWINKLEROCK
        if memo_state == 5
          if has_quest_items?(pc, SPIRIT_OF_FLAME)
            take_items(pc, SPIRIT_OF_FLAME, 1)
            give_items(pc, TAG_OF_RUMOR, 1)
            qs.memo_state = 6
            qs.set_cond(7, true)
            html = "30550-01.html"
          end
        elsif memo_state == 6
          html = "30550-02.html"
        end
      when SEER_TANAPI
        if memo_state == 1
          if has_quest_items?(pc, VOUCHER_OF_TRIAL)
            take_items(pc, VOUCHER_OF_TRIAL, 1)
            qs.memo_state = 2
            qs.set_cond(2, true)
            html = "30571-01.html"
          end
        elsif memo_state == 2
          html = "30571-02.html"
        elsif memo_state == 5
          if has_quest_items?(pc, SPIRIT_OF_FLAME)
            qs.set_cond(6, true)
            html = "30571-03.html"
          end
        end
      when ELDER_CASIAN
        if memo_state == 16
          qs.memo_state = 17
          if !has_quest_items?(pc, BOOK_OF_SAGE)
            give_items(pc, BOOK_OF_SAGE, 1)
          end
          take_items(pc, GREY_BADGE, 1)
          take_items(pc, SPIRIT_OF_FLAME, 1)
          take_items(pc, STATUE_OF_EINHASAD, 1)
          if has_quest_items?(pc, BOOK_OF_DARKNESS)
            add_exp_and_sp(pc, 5000, 500)
            take_items(pc, BOOK_OF_DARKNESS, 1)
          end
          html = "30612-01.html"
        elsif memo_state == 17
          qs.set_cond(17, true)
          html = "30612-02.html"
        end
      when ANCESTOR_MARTANKUS
        if memo_state == 2
          qs.memo_state = 3
          qs.set_cond(3, true)
          html = "30649-01.html"
        elsif memo_state == 3
          html = "30649-02.html"
        elsif memo_state == 4
          if has_quest_items?(pc, ESSENCE_OF_FLAME)
            html = "30649-03.html"
          end
        end
      when PRIEST_OF_THE_EARTH_GERALD
        if memo_state == 6
          if has_quest_items?(pc, TAG_OF_RUMOR)
            html = "30650-01.html"
          end
        elsif has_quest_items?(pc, GREY_BADGE, BOOK_OF_GERALD)
          give_adena(pc, 100000, true)
          take_items(pc, BOOK_OF_GERALD, 1)
          html = "30650-04.html"
        end
      when WANDERER_DORF
        if memo_state == 6
          if has_quest_items?(pc, TAG_OF_RUMOR)
            give_items(pc, GREY_BADGE, 1)
            take_items(pc, TAG_OF_RUMOR, 1)
            qs.memo_state = 8
            html = "30651-01.html"
          end
        elsif memo_state == 7
          if has_quest_items?(pc, TAG_OF_RUMOR)
            give_items(pc, GREY_BADGE, 1)
            take_items(pc, TAG_OF_RUMOR, 1)
            qs.memo_state = 8
            html = "30651-02.html"
          end
        elsif memo_state == 8
          qs.set_cond(8, true)
          html = "30651-03.html"
        end
      when URUHA
        if memo_state == 14
          if has_quest_items?(pc, DEBRIS_OF_WILLOW)
            html = "30652-01.html"
          end
        elsif memo_state == 15
          if has_quest_items?(pc, BOOK_OF_DARKNESS)
            html = "30652-03.html"
          end
        end
      end

    elsif qs.completed?
      if npc.id == HERMIT_SANTIAGO
        html = get_already_completed_msg(pc)
      end
    end

    html || get_no_quest_msg(pc)
  end
end
