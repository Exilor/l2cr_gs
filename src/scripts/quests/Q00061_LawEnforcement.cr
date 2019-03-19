class Quests::Q00061_LawEnforcement < Quest
  # NPCs
  private LIANE = 32222
  private KEKROPUS = 32138
  private EINDBURGH = 32469
  # Misc
  private MIN_LEVEL = 76

  def initialize
    super(61, self.class.simple_name, "Law Enforcement")

    add_start_npc(LIANE)
    add_talk_id(LIANE, KEKROPUS, EINDBURGH)
  end

  def on_adv_event(event, npc, player)
    return unless player
    unless qs = get_quest_state(player, false)
      return
    end

    case event
    when "32222-02.htm"
      htmltext = event
    when "32222-03.htm"
      qs.memo_state = 1
      qs.start_quest
      htmltext = event
    when "32138-01.html", "32138-02.html"
      if qs.memo_state?(1)
        htmltext = event
      end
    when "32138-03.html"
      if qs.memo_state?(1)
        qs.memo_state = 2
        htmltext = event
      end
    when "32138-04.html", "32138-05.html", "32138-06.html", "32138-07.html"
      if qs.memo_state?(2) || qs.memo_state?(3)
        htmltext = event
      end
    when "32138-08.html"
      if qs.memo_state?(2) || qs.memo_state?(3)
        qs.memo_state = 4
        qs.set_cond(2, true)
        htmltext = event
      end
    when "32138-09.html"
      if qs.memo_state?(1)
        qs.memo_state = 3
        htmltext = event
      end
    when "32469-02.html"
      if qs.memo_state?(4)
        qs.memo_state = 5
        htmltext = event
      end
    when "32469-03.html", "32469-04.html", "32469-05.html", "32469-06.html",
         "32469-07.html"
      if qs.memo_state?(5)
        htmltext = event
      end
    when "32469-08.html", "32469-09.html"
      if qs.memo_state?(5)
        player.class_id = 136
        # SystemMessage and cast skill is done by class_id=
        player.broadcast_user_info
        give_adena(player, 26000, true)
        qs.exit_quest(false, true)
        htmltext = event
      end
    end

    htmltext
  end

  def on_talk(npc, player)
    qs = get_quest_state!(player)

    if qs.completed? && npc.id == LIANE
      htmltext = get_already_completed_msg(player)
    elsif qs.created?
      if player.level >= MIN_LEVEL
        if player.class_id.inspector?
          html = get_htm(player, "32222-01.htm")
          return html.sub("%name%", player.name)
        end
        htmltext = "32222-04.htm"
      else
        htmltext = "32222-05.htm"
      end
    elsif qs.started?
      case npc.id
      when LIANE
        if qs.memo_state?(1)
          htmltext = "32222-06.html"
        end
      when KEKROPUS
        case qs.memo_state
        when 1
          htmltext = "32138-01.html"
        when 2
          htmltext = "32138-03.html"
        when 3
          htmltext = "32138-10.html"
        when 4
          htmltext = "32138-10.html"
        end
      when EINDBURGH
        if qs.memo_state?(4)
          html = get_htm(player, "32469-01.html")
          return html.sub("%name%", player.name)
        elsif qs.memo_state?(5)
          htmltext = "32469-02.html"
        end
      end
    end

    htmltext || get_no_quest_msg(player)
  end
end
