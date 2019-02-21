class Quests::Q00183_RelicExploration < Quest
  # NPCs
  private HEAD_BLACKSMITH_KUSTO = 30512
  private MAESTRO_NIKOLA = 30621
  private RESEARCHER_LORAIN = 30673
  # Misc
  private MIN_LEVEL = 40
  private MAX_LEVEL_FOR_EXP_SP = 46

  def initialize
    super(183, self.class.simple_name, "Relic Exploration")

    add_start_npc(HEAD_BLACKSMITH_KUSTO)
    add_talk_id(HEAD_BLACKSMITH_KUSTO, RESEARCHER_LORAIN, MAESTRO_NIKOLA)
  end

  def on_adv_event(event, npc, player)
    return unless player
    unless qs = get_quest_state(player, false)
      return
    end

    case event
    when "30512-04.htm"
      qs.start_quest
      qs.memo_state = 1
      htmltext = event
    when "30512-02.htm"
      htmltext = event
    when "30621-02.html"
      if qs.memo_state?(2)
        qs.give_adena(18100, true)
        if player.level < MAX_LEVEL_FOR_EXP_SP
          qs.add_exp_and_sp(60000, 3000)
        end
        qs.exit_quest(false, true)
        htmltext = event
      end
    when "30673-02.html", "30673-03.html"
      if qs.memo_state?(1)
        htmltext = event
      end
    when "30673-04.html"
      if qs.memo_state?(1)
        qs.memo_state = 2
        qs.set_cond(2, true)
        htmltext = event
      end
    when "Contract"
      qs184 = player.get_quest_state(Q00184_ArtOfPersuasion.simple_name)
      qs185 = player.get_quest_state(Q00185_NikolasCooperation.simple_name)
      quest = QuestManager.get_quest(Q00184_ArtOfPersuasion.simple_name)
      if quest && qs184.nil? && qs185.nil?
        if player.level >= MIN_LEVEL
          quest.notify_event("30621-03.htm", npc, player)
        else
          quest.notify_event("30621-03a.html", npc, player)
        end
      end
    when "Consideration"
      qs184 = player.get_quest_state(Q00184_ArtOfPersuasion.simple_name)
      qs185 = player.get_quest_state(Q00185_NikolasCooperation.simple_name)
      quest = QuestManager.get_quest(Q00185_NikolasCooperation.simple_name)
      if quest && qs184.nil? && qs185.nil?
        if player.level >= MIN_LEVEL
          quest.notify_event("30621-03.htm", npc, player)
        else
          quest.notify_event("30621-03a.html", npc, player)
        end
      end
    end

    htmltext
  end

  def on_talk(npc, player)
    qs = get_quest_state!(player)

    if qs.created?
      if npc.id == HEAD_BLACKSMITH_KUSTO
        htmltext = player.level >= MIN_LEVEL ? "30512-01.htm" : "30512-03.html"
      end
    elsif qs.started?
      case npc.id
      when HEAD_BLACKSMITH_KUSTO
        htmltext = "30512-05.html"
      when MAESTRO_NIKOLA
        if qs.memo_state?(2)
          htmltext = "30621-01.html"
        end
      when RESEARCHER_LORAIN
        if qs.memo_state?(1)
          htmltext = "30673-01.html"
        elsif qs.memo_state?(2)
          htmltext = "30673-05.html"
        end
      end
    elsif qs.completed?
      htmltext = get_already_completed_msg(player)
    end

    htmltext || get_no_quest_msg(player)
  end
end
