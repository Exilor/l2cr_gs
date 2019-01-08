class Quests::Q00178_IconicTrinity < Quest
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
    add_talk_id(HIERARCH_KEKROPUS, ICON_OF_THE_PAST, ICON_OF_THE_PRESENT, ICON_OF_THE_FUTURE)
  end

  def on_adv_event(event, npc, player)
    return unless player
    return unless qs = get_quest_state(player, false)

    case event
    when "32138-05.htm"
      if qs.created?
        qs.start_quest
        qs.memo_state = 1
        htmltext = event
      end
    when "32255-11.html", "32256-11.html", "32256-12.html", "32256-13.html"
      htmltext = get_htm(event)
      htmltext = htmltext.gsub("%name1%", player.name)
    when "32138-14.html"
      if qs.memo_state?(10) && player.level <= TWENTY_LEVEL && (player.class_id.male_soldier? || player.class_id.female_soldier?)
        give_items(player, SCROLL_ENCHANT_ARMOR_D_GRADE, 1)
        add_exp_and_sp(player, 20123, 976)
        qs.exit_quest(false, true)
        htmltext = event
      end
    when "32138-17.html"
      if qs.memo_state?(10) && player.level > TWENTY_LEVEL && (!player.class_id.male_soldier? || !player.class_id.female_soldier?)
        give_items(player, SCROLL_ENCHANT_ARMOR_D_GRADE, 1)
        qs.exit_quest(false, true)
        htmltext = event
      end
    when "32255-02.html"
      if qs.memo_state?(1)
        qs.memo_state = 2
        htmltext = event
      end
    when "32255-03.html"
      if qs.memo_state?(2)
        qs.set_memo_state_ex(1, 0)
        htmltext = event
      end
    when "PASS1_1"
      if qs.memo_state?(2)
        i0 = qs.get_memo_state_ex(1)
        qs.set_memo_state_ex(1, i0 + 1)
        htmltext = "32255-04.html"
      end
    when "PASS1_2"
      if qs.memo_state?(2)
        i0 = qs.get_memo_state_ex(1)
        qs.set_memo_state_ex(1, i0 + 10)
        htmltext = "32255-05.html"
      end
    when "PASS1_3"
      if qs.memo_state?(2)
        i0 = qs.get_memo_state_ex(1)
        qs.set_memo_state_ex(1, i0 + 100)
        htmltext = "32255-06.html"
      end
    when "PASS1_4"
      if qs.memo_state?(2)
        if qs.get_memo_state_ex(1) == 111
          qs.memo_state = 3
          qs.set_memo_state_ex(1, 0)
          htmltext = "32255-07.html"
        elsif qs.get_memo_state_ex(1) != 111
          htmltext = "32255-08.html"
        end
      end
    when "32255-13.html"
      if qs.memo_state?(3)
        qs.memo_state = 4
        qs.set_cond(2, true)
        htmltext = get_htm(event)
        htmltext = htmltext.gsub("%name1%", player.name)
      end
    when "32256-02.html"
      if qs.memo_state?(4)
        qs.memo_state = 5
        htmltext = event
      end
    when "32256-03.html"
      if qs.memo_state?(5)
        qs.set_memo_state_ex(1, 0)
        htmltext = event
      end
    when "PASS2_1"
      if qs.memo_state?(5)
        i0 = qs.get_memo_state_ex(1)
        qs.set_memo_state_ex(1, i0 + 1)
        htmltext = "32256-04.html"
      end
    when "PASS2_2"
      if qs.memo_state?(5)
        i0 = qs.get_memo_state_ex(1)
        qs.set_memo_state_ex(1, i0 + 10)
        htmltext = "32256-05.html"
      end
    when "PASS2_3"
      if qs.memo_state?(5)
        i0 = qs.get_memo_state_ex(1)
        qs.set_memo_state_ex(1, i0 + 100)
        htmltext = "32256-06.html"
      end
    when "PASS2_4"
      if qs.memo_state?(5)
        if qs.get_memo_state_ex(1) == 111
          qs.memo_state = 6
          qs.set_memo_state_ex(1, 0)
          htmltext = "32256-07.html"
        elsif qs.get_memo_state_ex(1) != 111
          htmltext = "32256-08.html"
        end
      end
    when "32256-14.html"
      if qs.memo_state?(6)
        qs.memo_state = 7
        qs.set_cond(3, true)
        htmltext = get_htm(event)
        htmltext = htmltext.gsub("%name1%", player.name)
      end
    when "32257-02.html"
      if qs.memo_state?(7)
        qs.memo_state = 8
        htmltext = event
      end
    when "32257-03.html"
      if qs.memo_state?(8)
        qs.set_memo_state_ex(1, 0)
        htmltext = event
      end
    when "PASS3_1"
      if qs.memo_state?(8)
        i0 = qs.get_memo_state_ex(1)
        qs.set_memo_state_ex(1, i0 + 1)
        htmltext = "32257-04.html"
      end
    when "PASS3_2"
      if qs.memo_state?(8)
        i0 = qs.get_memo_state_ex(1)
        qs.set_memo_state_ex(1, i0 + 10)
        htmltext = "32257-05.html"
      end
    when "PASS3_3"
      if qs.memo_state?(8)
        i0 = qs.get_memo_state_ex(1)
        qs.set_memo_state_ex(1, i0 + 100)
        htmltext = "32257-06.html"
      end
    when "PASS3_4"
      if qs.memo_state?(8)
        i0 = qs.get_memo_state_ex(1)
        qs.set_memo_state_ex(1, i0 + 1000)
        htmltext = "32257-07.html"
      end
    when "PASS3_5"
      if qs.memo_state?(8)
        if qs.get_memo_state_ex(1) == 1111
          qs.memo_state = 9
          qs.set_memo_state_ex(1, 0)
          htmltext = "32257-08.html"
        elsif qs.get_memo_state_ex(1) != 1111
          htmltext = "32257-09.html"
        end
      end
    when "32257-12.html"
      if qs.memo_state?(9)
        qs.memo_state = 10
        qs.set_cond(4, true)
        htmltext = get_htm(event)
        htmltext = htmltext.gsub("%name1%", player.name)
      end
    when "32138-13.html", "32138-16.html", "32255-04.html", "32255-05.html",
         "32255-06.html", "32255-07.html", "32255-08.html", "32255-09.html",
         "32255-10.html", "32255-12.html", "32256-04.html", "32256-05.html",
         "32256-06.html", "32256-07.html", "32256-08.html", "32256-09.html",
         "32256-10.html", "32257-04.html", "32257-05.html", "32257-06.html",
         "32257-07.html", "32257-08.html", "32257-09.html", "32257-10.html",
         "32257-11.html"
      htmltext = event
    end

    htmltext
  end

  def on_talk(npc, player)
    qs = get_quest_state!(player)
    htmltext = get_no_quest_msg(player)
    if qs.created?
      if npc.id == HIERARCH_KEKROPUS
        if !player.race.kamael?
          htmltext = "32138-03.htm"
        elsif player.level >= MIN_LEVEL
          htmltext = "32138-01.htm"
        else
          htmltext = "32138-02.htm"
        end
      end
    elsif qs.started?
      case npc.id
      when HIERARCH_KEKROPUS
        case qs.memo_state
        when 1
        when 2
          htmltext = "32138-06.html"
        when 3
          htmltext = "32138-07.html"
        when 4
        when 5
          htmltext = "32138-08.html"
        when 6
          htmltext = "32138-09.html"
        when 7, 8
          htmltext = "32138-10.html"
        when 9
          htmltext = "32138-11.html"
        when 10
          if (player.level <= TWENTY_LEVEL && player.class_id.male_soldier?) || player.class_id.female_soldier?
            htmltext = "32138-12.html"
          else
            htmltext = "32138-15.html"
          end
        end
      when ICON_OF_THE_PAST
        case qs.memo_state
        when 1
          htmltext = "32255-01.html"
        when 2
          qs.set_memo_state_ex(1, 0)
          htmltext = "32255-03.html"
        when 3
          htmltext = "32255-09.html"
        when 4, 5
          htmltext = "32255-14.html"
        end
      when ICON_OF_THE_PRESENT
        case qs.memo_state
        when 4
          htmltext = "32256-01.html"
        when 5
          qs.set_memo_state_ex(1, 0)
          htmltext = "32256-03.html"
        when 6
          htmltext = "32256-09.html"
        when 7, 8
          htmltext = "32256-15.html"
        end
      when ICON_OF_THE_FUTURE
        case qs.memo_state
        when 7
          htmltext = "32257-01.html"
        when 8
          qs.set_memo_state_ex(1, 0)
          htmltext = "32257-03.html"
        when 9
          htmltext = "32257-10.html"
        when 10
          htmltext = "32257-13.html"
        end
      end
    elsif qs.completed?
      if npc.id == HIERARCH_KEKROPUS
        htmltext = get_already_completed_msg(player)
      end
    end

    htmltext
  end
end
