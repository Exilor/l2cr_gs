class Scripts::Q00191_VainConclusion < Quest
  # NPCs
  private SHEGFIELD = 30068
  private HEAD_BLACKSMITH_KUSTO = 30512
  private RESEARCHER_LORAIN = 30673
  private DOROTHY_LOCKSMITH = 30970
  # Items
  private REPAIRED_METALLOGRAPH = 10371
  # Misc
  private MIN_LEVEL = 42
  private MAX_LEVEL_FOR_EXP_SP = 48

  def initialize
    super(191, self.class.simple_name, "Vain Conclusion")

    add_start_npc(DOROTHY_LOCKSMITH)
    add_talk_id(
      DOROTHY_LOCKSMITH, HEAD_BLACKSMITH_KUSTO, RESEARCHER_LORAIN, SHEGFIELD
    )
    register_quest_items(REPAIRED_METALLOGRAPH)
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    unless qs = get_quest_state(pc, false)
      return
    end

    case event
    when "30970-03.htm"
      html = event
    when "30970-04.htm"
      if qs.created?
        qs.start_quest
        qs.memo_state = 1
        give_items(pc, REPAIRED_METALLOGRAPH, 1)
        html = event
      end
    when "30068-02.html"
      if qs.memo_state?(2)
        html = event
      end
    when "30068-03.html"
      if qs.memo_state?(2)
        qs.memo_state = 3
        qs.set_cond(3, true)
        html = event
      end
    when "30512-02.html"
      if qs.memo_state?(4)
        give_adena(pc, 117327, true)
        if pc.level < MAX_LEVEL_FOR_EXP_SP
          add_exp_and_sp(pc, 309467, 20614)
        end
        qs.exit_quest(false, true)
        html = event
      end
    when "30673-02.html"
      if qs.memo_state?(1)
        qs.memo_state = 2
        qs.set_cond(2, true)
        take_items(pc, REPAIRED_METALLOGRAPH, -1)
        html = event
      end
    end


    html
  end

  def on_talk(npc, pc)
    qs = get_quest_state!(pc)

    if qs.created?
      if npc.id == DOROTHY_LOCKSMITH
        if pc.quest_completed?(Q00188_SealRemoval.simple_name)
          html = pc.level >= MIN_LEVEL ? "30970-01.htm" : "30970-02.htm"
        end
      end
    elsif qs.started?
      case npc.id
      when DOROTHY_LOCKSMITH
        if qs.memo_state >= 1
          html = "30970-05.html"
        end
      when SHEGFIELD
        case qs.cond
        when 2
          html = "30068-01.html"
        when 3
          html = "30068-04.html"
        end

      when HEAD_BLACKSMITH_KUSTO
        if qs.memo_state?(4)
          html = "30512-01.html"
        end
      when RESEARCHER_LORAIN
        case qs.cond
        when 1
          html = "30673-01.html"
        when 2
          html = "30673-03.html"
        when 3
          qs.memo_state = 4
          qs.set_cond(4, true)
          html = "30673-04.html"
        when 4
          html = "30673-05.html"
        end

      end

    elsif qs.completed?
      if npc.id == DOROTHY_LOCKSMITH
        html = get_already_completed_msg(pc)
      end
    end

    html || get_no_quest_msg(pc)
  end
end
