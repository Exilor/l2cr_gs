class Scripts::Q00189_ContractCompletion < Quest
  # NPCs
  private SHEGFIELD = 30068
  private HEAD_BLACKSMITH_KUSTO = 30512
  private RESEARCHER_LORAIN = 30673
  private BLUEPRINT_SELLER_LUKA = 31437
  # Items
  private SCROLL_OF_DECODING = 10370
  # Misc
  private MIN_LEVEL = 42
  private MAX_LEVEL_FOR_EXP_SP = 48

  def initialize
    super(189, self.class.simple_name, "Contract Completion")

    add_start_npc(BLUEPRINT_SELLER_LUKA)
    add_talk_id(
      BLUEPRINT_SELLER_LUKA, HEAD_BLACKSMITH_KUSTO, RESEARCHER_LORAIN, SHEGFIELD
    )
    register_quest_items(SCROLL_OF_DECODING)
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    unless qs = get_quest_state(pc, false)
      return
    end

    case event
    when "31437-03.htm"
      if qs.created?
        qs.start_quest
        qs.memo_state = 1
        give_items(pc, SCROLL_OF_DECODING, 1)
        html = event
      end
    when "30512-02.html"
      if qs.memo_state?(4)
        give_adena(pc, 121527, true)
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
        take_items(pc, SCROLL_OF_DECODING, -1)
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
    end


    html
  end

  def on_talk(npc, pc)
    qs = get_quest_state!(pc)

    if qs.created?
      if npc.id == BLUEPRINT_SELLER_LUKA
        if pc.quest_completed?(Q00186_ContractExecution.simple_name)
          html = pc.level >= MIN_LEVEL ? "31437-01.htm" : "31437-02.htm"
        end
      end
    elsif qs.started?
      case npc.id
      when BLUEPRINT_SELLER_LUKA
        if qs.memo_state >= 1
          html = "31437-04.html"
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

      when SHEGFIELD
        case qs.cond
        when 2
          html = "30068-01.html"
        when 3
          html = "30068-04.html"
        end

      end

    elsif qs.completed?
      if npc.id == BLUEPRINT_SELLER_LUKA
        html = get_already_completed_msg(pc)
      end
    end

    html || get_no_quest_msg(pc)
  end
end
