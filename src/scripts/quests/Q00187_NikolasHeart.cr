class Scripts::Q00187_NikolasHeart < Quest
  # NPCs
  private HEAD_BLACKSMITH_KUSTO = 30512
  private MAESTRO_NIKOLA = 30621
  private RESEARCHER_LORAIN = 30673
  # Items
  private LORAINES_CERTIFICATE = 10362
  private METALLOGRAPH = 10368
  # Misc
  private MIN_LEVEL = 41
  private MAX_LEVEL_FOR_EXP_SP = 47

  def initialize
    super(187, self.class.simple_name, "Nikola's Heart")

    add_start_npc(RESEARCHER_LORAIN)
    add_talk_id(HEAD_BLACKSMITH_KUSTO, RESEARCHER_LORAIN, MAESTRO_NIKOLA)
    register_quest_items(METALLOGRAPH)
  end

  def on_adv_event(event, npc, pc)
    return unless pc && (qs = get_quest_state(pc, false))

    case event
    when "30673-03.htm"
      if qs.created?
        qs.start_quest
        qs.memo_state = 1
        give_items(pc, METALLOGRAPH, 1)
        take_items(pc, LORAINES_CERTIFICATE, -1)
        html = event
      end
    when "30512-02.html"
      if qs.memo_state?(2)
        html = event
      end
    when "30512-03.html"
      if qs.memo_state?(2)
        give_adena(pc, 93_383, true)
        if pc.level < MAX_LEVEL_FOR_EXP_SP
          add_exp_and_sp(pc, 285_935, 18_711)
        end
        qs.exit_quest(false, true)
        html = event
      end
    when "30621-02.html"
      if qs.memo_state?(1)
        html = event
      end
    when "30621-03.html"
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
      if npc.id == RESEARCHER_LORAIN
        if pc.quest_completed?(Q00185_NikolasCooperation.simple_name)
          if has_quest_items?(pc, LORAINES_CERTIFICATE)
            html = pc.level >= MIN_LEVEL ? "30673-01.htm" : "30673-02.htm"
          end
        end
      end
    elsif qs.started?
      case npc.id
      when RESEARCHER_LORAIN
        if memo_state >= 1
          html = "30673-04.html"
        end
      when HEAD_BLACKSMITH_KUSTO
        if memo_state == 2
          html = "30512-01.html"
        end
      when MAESTRO_NIKOLA
        if memo_state == 1
          html = "30621-01.html"
        elsif memo_state == 2
          html = "30621-04.html"
        end
      end
    elsif qs.completed?
      if npc.id == RESEARCHER_LORAIN
        html = get_already_completed_msg(pc)
      end
    end

    html || get_no_quest_msg(pc)
  end
end
