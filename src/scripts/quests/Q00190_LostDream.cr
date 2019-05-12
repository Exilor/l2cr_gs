class Scripts::Q00190_LostDream < Quest
  # NPCs
  private JURIS = 30113
  private HEAD_BLACKSMITH_KUSTO = 30512
  private MAESTRO_NIKOLA = 30621
  private RESEARCHER_LORAIN = 30673
  # Misc
  private MIN_LEVEL = 42
  private MAX_LEVEL_FOR_EXP_SP = 48

  def initialize
    super(190, self.class.simple_name, "Lost Dream")

    add_start_npc(HEAD_BLACKSMITH_KUSTO)
    add_talk_id(HEAD_BLACKSMITH_KUSTO, RESEARCHER_LORAIN, MAESTRO_NIKOLA, JURIS)
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    unless qs = get_quest_state(pc, false)
      return
    end

    html = nil
    case event
    when "30512-03.htm"
      if qs.created?
        qs.start_quest
        qs.memo_state = 1
        html = event
      end
    when "30512-06.html"
      if qs.memo_state?(2)
        qs.memo_state = 3
        qs.set_cond(3, true)
        html = event
      end
    when "30113-02.html"
      if qs.memo_state?(1)
        html = event
      end
    when "30113-03.html"
      if qs.memo_state?(1)
        qs.memo_state = 2
        qs.set_cond(2, true)
        html = event
      end
    end

    html
  end

  def on_talk(npc, pc)
    qs = get_quest_state!(pc)
    memo_state = qs.memo_state

    if qs.created?
      if npc.id == HEAD_BLACKSMITH_KUSTO
        if pc.quest_completed?(Q00187_NikolasHeart.simple_name)
          html = pc.level >= MIN_LEVEL ? "30512-01.htm" : "30512-02.htm"
        end
      end
    elsif qs.started?
      case npc.id
      when HEAD_BLACKSMITH_KUSTO
        if memo_state == 1
          html = "30512-04.html"
        elsif memo_state == 2
          html = "30512-05.html"
        elsif memo_state >= 3 && memo_state <= 4
          html = "30512-07.html"
        elsif memo_state == 5
          html = "30512-08.html"
          give_adena(pc, 109427, true)
          if pc.level < MAX_LEVEL_FOR_EXP_SP
            add_exp_and_sp(pc, 309467, 20614)
          end
          qs.exit_quest(false, true)
        end
      when JURIS
        if memo_state == 1
          html = "30113-01.html"
        elsif memo_state == 2
          html = "30113-04.html"
        end
      when MAESTRO_NIKOLA
        if memo_state == 4
          qs.memo_state = 5
          qs.set_cond(5, true)
          html = "30621-01.html"
        elsif memo_state == 5
          html = "30621-02.html"
        end
      when RESEARCHER_LORAIN
        if memo_state == 3
          qs.memo_state = 4
          qs.set_cond(4, true)
          html = "30673-01.html"
        elsif memo_state == 4
          html = "30673-02.html"
        end
      end
    elsif qs.completed?
      if npc.id == HEAD_BLACKSMITH_KUSTO
        html = get_already_completed_msg(pc)
      end
    end

    html || get_no_quest_msg(pc)
  end
end
