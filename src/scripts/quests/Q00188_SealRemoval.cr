class Scripts::Q00188_SealRemoval < Quest
  # NPCs
  private MAESTRO_NIKOLA = 30621
  private RESEARCHER_LORAIN = 30673
  private DOROTHY_LOCKSMITH = 30970
  # Items
  private LORAINES_CERTIFICATE = 10362
  private BROKEN_METAL_PIECES = 10369
  # Misc
  private MIN_LEVEL = 41
  private MAX_LEVEL_FOR_EXP_SP = 47

  def initialize
    super(188, self.class.simple_name, "Seal Removal")

    add_start_npc(RESEARCHER_LORAIN)
    add_talk_id(RESEARCHER_LORAIN, MAESTRO_NIKOLA, DOROTHY_LOCKSMITH)
    register_quest_items(BROKEN_METAL_PIECES)
  end

  def on_adv_event(event, npc, pc)
    return unless pc && (qs = get_quest_state(pc, false))

    case event
    when "30673-03.htm"
      if qs.created?
        qs.start_quest
        qs.memo_state = 1
        give_items(pc, BROKEN_METAL_PIECES, 1)
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
    when "30621-04.html"
      if qs.memo_state?(2)
        html = event
      end
    when "30970-02.html"
      if qs.memo_state?(2)
        html = event
      end
    when "30970-03.html"
      if qs.memo_state?(2)
        give_adena(pc, 98_583, true)
        if pc.level < MAX_LEVEL_FOR_EXP_SP
          add_exp_and_sp(pc, 285_935, 18_711)
        end
        qs.exit_quest(false, true)
        html = event
      end
    end

    html
  end

  def on_talk(npc, pc)
    qs = get_quest_state!(pc)

    if qs.created?
      if npc.id == RESEARCHER_LORAIN
        unless has_quest_items?(pc, LORAINES_CERTIFICATE)
          q186 = pc.get_quest_state(Q00186_ContractExecution.simple_name)
          q187 = pc.get_quest_state(Q00187_NikolasHeart.simple_name)
          if pc.quest_completed?(Q00184_ArtOfPersuasion.simple_name) || (pc.quest_completed?(Q00185_NikolasCooperation.simple_name) && q186.nil? && q187.nil?)
            html = pc.level >= MIN_LEVEL ? "30673-01.htm" : "30673-02.htm"
          end
        end
      end
    elsif qs.started?
      case npc.id
      when RESEARCHER_LORAIN
        html = "30673-04.html"
      when MAESTRO_NIKOLA
        if qs.memo_state?(1)
          html = "30621-01.html"
        elsif qs.memo_state?(2)
          html = "30621-05.html"
        end
      when DOROTHY_LOCKSMITH
        if qs.memo_state?(2)
          html = "30970-01.html"
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
