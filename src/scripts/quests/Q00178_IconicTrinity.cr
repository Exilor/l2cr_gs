class Scripts::Q00178_IconicTrinity < Quest
  # NPCs
  private HIERARCH_KEKROPUS = 32138
  private ICON_OF_THE_PAST = 32255
  private ICON_OF_THE_PRESENT = 32256
  private ICON_OF_THE_FUTURE = 32257
  # Reward
  private SCROLL_ENCHANT_ARMOR_D_GRADE = 956
  # Misc
  private MIN_LEVEL = 17
  private TWENTY_LEVEL = 20

  def initialize
    super(178, self.class.simple_name, "Iconic Trinity")

    add_start_npc(HIERARCH_KEKROPUS)
    add_talk_id(
      HIERARCH_KEKROPUS, ICON_OF_THE_PAST, ICON_OF_THE_PRESENT,
      ICON_OF_THE_FUTURE
    )
  end

  def on_adv_event(event, npc, pc)
    return unless pc && (qs = get_quest_state(pc, false))

    case event
    when "32138-05.htm"
      if qs.created?
        qs.start_quest
        qs.memo_state = 1
        html = event
      end
    when "32255-11.html", "32256-11.html", "32256-12.html", "32256-13.html"
      html = get_htm(pc, event)
      html = html.gsub("%name1%", pc.name)
    when "32138-14.html"
      if qs.memo_state?(10) && pc.level <= TWENTY_LEVEL && (pc.class_id.male_soldier? || pc.class_id.female_soldier?)
        give_items(pc, SCROLL_ENCHANT_ARMOR_D_GRADE, 1)
        add_exp_and_sp(pc, 20123, 976)
        qs.exit_quest(false, true)
        html = event
      end
    when "32138-17.html"
      if qs.memo_state?(10) && pc.level > TWENTY_LEVEL && (!pc.class_id.male_soldier? || !pc.class_id.female_soldier?)
        give_items(pc, SCROLL_ENCHANT_ARMOR_D_GRADE, 1)
        qs.exit_quest(false, true)
        html = event
      end
    when "32255-02.html"
      if qs.memo_state?(1)
        qs.memo_state = 2
        html = event
      end
    when "32255-03.html"
      if qs.memo_state?(2)
        qs.set_memo_state_ex(1, 0)
        html = event
      end
    when "PASS1_1"
      if qs.memo_state?(2)
        i0 = qs.get_memo_state_ex(1)
        qs.set_memo_state_ex(1, i0 &+ 1)
        html = "32255-04.html"
      end
    when "PASS1_2"
      if qs.memo_state?(2)
        i0 = qs.get_memo_state_ex(1)
        qs.set_memo_state_ex(1, i0 &+ 10)
        html = "32255-05.html"
      end
    when "PASS1_3"
      if qs.memo_state?(2)
        i0 = qs.get_memo_state_ex(1)
        qs.set_memo_state_ex(1, i0 &+ 100)
        html = "32255-06.html"
      end
    when "PASS1_4"
      if qs.memo_state?(2)
        if qs.get_memo_state_ex(1) == 111
          qs.memo_state = 3
          qs.set_memo_state_ex(1, 0)
          html = "32255-07.html"
        elsif qs.get_memo_state_ex(1) != 111
          html = "32255-08.html"
        end
      end
    when "32255-13.html"
      if qs.memo_state?(3)
        qs.memo_state = 4
        qs.set_cond(2, true)
        html = get_htm(pc, event)
        html = html.gsub("%name1%", pc.name)
      end
    when "32256-02.html"
      if qs.memo_state?(4)
        qs.memo_state = 5
        html = event
      end
    when "32256-03.html"
      if qs.memo_state?(5)
        qs.set_memo_state_ex(1, 0)
        html = event
      end
    when "PASS2_1"
      if qs.memo_state?(5)
        i0 = qs.get_memo_state_ex(1)
        qs.set_memo_state_ex(1, i0 &+ 1)
        html = "32256-04.html"
      end
    when "PASS2_2"
      if qs.memo_state?(5)
        i0 = qs.get_memo_state_ex(1)
        qs.set_memo_state_ex(1, i0 &+ 10)
        html = "32256-05.html"
      end
    when "PASS2_3"
      if qs.memo_state?(5)
        i0 = qs.get_memo_state_ex(1)
        qs.set_memo_state_ex(1, i0 &+ 100)
        html = "32256-06.html"
      end
    when "PASS2_4"
      if qs.memo_state?(5)
        if qs.get_memo_state_ex(1) == 111
          qs.memo_state = 6
          qs.set_memo_state_ex(1, 0)
          html = "32256-07.html"
        elsif qs.get_memo_state_ex(1) != 111
          html = "32256-08.html"
        end
      end
    when "32256-14.html"
      if qs.memo_state?(6)
        qs.memo_state = 7
        qs.set_cond(3, true)
        html = get_htm(pc, event)
        html = html.gsub("%name1%", pc.name)
      end
    when "32257-02.html"
      if qs.memo_state?(7)
        qs.memo_state = 8
        html = event
      end
    when "32257-03.html"
      if qs.memo_state?(8)
        qs.set_memo_state_ex(1, 0)
        html = event
      end
    when "PASS3_1"
      if qs.memo_state?(8)
        i0 = qs.get_memo_state_ex(1)
        qs.set_memo_state_ex(1, i0 &+ 1)
        html = "32257-04.html"
      end
    when "PASS3_2"
      if qs.memo_state?(8)
        i0 = qs.get_memo_state_ex(1)
        qs.set_memo_state_ex(1, i0 &+ 10)
        html = "32257-05.html"
      end
    when "PASS3_3"
      if qs.memo_state?(8)
        i0 = qs.get_memo_state_ex(1)
        qs.set_memo_state_ex(1, i0 &+ 100)
        html = "32257-06.html"
      end
    when "PASS3_4"
      if qs.memo_state?(8)
        i0 = qs.get_memo_state_ex(1)
        qs.set_memo_state_ex(1, i0 &+ 1000)
        html = "32257-07.html"
      end
    when "PASS3_5"
      if qs.memo_state?(8)
        if qs.get_memo_state_ex(1) == 1111
          qs.memo_state = 9
          qs.set_memo_state_ex(1, 0)
          html = "32257-08.html"
        elsif qs.get_memo_state_ex(1) != 1111
          html = "32257-09.html"
        end
      end
    when "32257-12.html"
      if qs.memo_state?(9)
        qs.memo_state = 10
        qs.set_cond(4, true)
        html = get_htm(pc, event)
        html = html.gsub("%name1%", pc.name)
      end
    when "32138-13.html", "32138-16.html", "32255-04.html", "32255-05.html",
         "32255-06.html", "32255-07.html", "32255-08.html", "32255-09.html",
         "32255-10.html", "32255-12.html", "32256-04.html", "32256-05.html",
         "32256-06.html", "32256-07.html", "32256-08.html", "32256-09.html",
         "32256-10.html", "32257-04.html", "32257-05.html", "32257-06.html",
         "32257-07.html", "32257-08.html", "32257-09.html", "32257-10.html",
         "32257-11.html"
      html = event
    end

    html
  end

  def on_talk(npc, pc)
    qs = get_quest_state!(pc)

    if qs.created?
      if npc.id == HIERARCH_KEKROPUS
        if !pc.race.kamael?
          html = "32138-03.htm"
        elsif pc.level >= MIN_LEVEL
          html = "32138-01.htm"
        else
          html = "32138-02.htm"
        end
      end
    elsif qs.started?
      case npc.id
      when HIERARCH_KEKROPUS
        case qs.memo_state
        when 1, 2
          html = "32138-06.html"
        when 3
          html = "32138-07.html"
        when 4, 5
          html = "32138-08.html"
        when 6
          html = "32138-09.html"
        when 7, 8
          html = "32138-10.html"
        when 9
          html = "32138-11.html"
        when 10
          if (pc.level <= TWENTY_LEVEL && pc.class_id.male_soldier?) || pc.class_id.female_soldier?
            html = "32138-12.html"
          else
            html = "32138-15.html"
          end
        end
      when ICON_OF_THE_PAST
        case qs.memo_state
        when 1
          html = "32255-01.html"
        when 2
          qs.set_memo_state_ex(1, 0)
          html = "32255-03.html"
        when 3
          html = "32255-09.html"
        when 4, 5
          html = "32255-14.html"
        end
      when ICON_OF_THE_PRESENT
        case qs.memo_state
        when 4
          html = "32256-01.html"
        when 5
          qs.set_memo_state_ex(1, 0)
          html = "32256-03.html"
        when 6
          html = "32256-09.html"
        when 7, 8
          html = "32256-15.html"
        end
      when ICON_OF_THE_FUTURE
        case qs.memo_state
        when 7
          html = "32257-01.html"
        when 8
          qs.set_memo_state_ex(1, 0)
          html = "32257-03.html"
        when 9
          html = "32257-10.html"
        when 10
          html = "32257-13.html"
        end
      end
    elsif qs.completed?
      if npc.id == HIERARCH_KEKROPUS
        html = get_already_completed_msg(pc)
      end
    end

    html || get_no_quest_msg(pc)
  end
end
