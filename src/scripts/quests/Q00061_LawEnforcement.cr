class Scripts::Q00061_LawEnforcement < Quest
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

  def on_adv_event(event, npc, pc)
    return unless pc
    unless qs = get_quest_state(pc, false)
      return
    end

    case event
    when "32222-02.htm"
      html = event
    when "32222-03.htm"
      qs.memo_state = 1
      qs.start_quest
      html = event
    when "32138-01.html", "32138-02.html"
      if qs.memo_state?(1)
        html = event
      end
    when "32138-03.html"
      if qs.memo_state?(1)
        qs.memo_state = 2
        html = event
      end
    when "32138-04.html", "32138-05.html", "32138-06.html", "32138-07.html"
      if qs.memo_state?(2) || qs.memo_state?(3)
        html = event
      end
    when "32138-08.html"
      if qs.memo_state?(2) || qs.memo_state?(3)
        qs.memo_state = 4
        qs.set_cond(2, true)
        html = event
      end
    when "32138-09.html"
      if qs.memo_state?(1)
        qs.memo_state = 3
        html = event
      end
    when "32469-02.html"
      if qs.memo_state?(4)
        qs.memo_state = 5
        html = event
      end
    when "32469-03.html", "32469-04.html", "32469-05.html", "32469-06.html",
         "32469-07.html"
      if qs.memo_state?(5)
        html = event
      end
    when "32469-08.html", "32469-09.html"
      if qs.memo_state?(5)
        pc.class_id = 136
        # SystemMessage and cast skill is done by class_id=
        pc.broadcast_user_info
        give_adena(pc, 26000, true)
        qs.exit_quest(false, true)
        html = event
      end
    else
      # [automatically added else]
    end

    html
  end

  def on_talk(npc, pc)
    qs = get_quest_state!(pc)

    if qs.completed? && npc.id == LIANE
      html = get_already_completed_msg(pc)
    elsif qs.created?
      if pc.level >= MIN_LEVEL
        if pc.class_id.inspector?
          html = get_htm(pc, "32222-01.htm")
          return html.sub("%name%", pc.name)
        end
        html = "32222-04.htm"
      else
        html = "32222-05.htm"
      end
    elsif qs.started?
      case npc.id
      when LIANE
        if qs.memo_state?(1)
          html = "32222-06.html"
        end
      when KEKROPUS
        case qs.memo_state
        when 1
          html = "32138-01.html"
        when 2
          html = "32138-03.html"
        when 3
          html = "32138-10.html"
        when 4
          html = "32138-10.html"
        else
          # [automatically added else]
        end
      when EINDBURGH
        if qs.memo_state?(4)
          html = get_htm(pc, "32469-01.html")
          return html.sub("%name%", pc.name)
        elsif qs.memo_state?(5)
          html = "32469-02.html"
        end
      else
        # [automatically added else]
      end
    end

    html || get_no_quest_msg(pc)
  end
end
