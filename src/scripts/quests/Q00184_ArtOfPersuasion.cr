class Quests::Q00184_ArtOfPersuasion < Quest
  # NPCs
  private MAESTRO_NIKOLA = 30621
  private RESEARCHER_LORAIN = 30673
  private DESTROYED_DEVICE = 32366
  private ALARM_OF_GIANT = 32367
  # Items
  private METALLOGRAPH = 10359
  private BROKEN_METAL_PIECES = 10360
  private NIKOLAS_MAP = 10361
  # Reward
  private LORAINES_CERTIFICATE = 10362
  # Misc
  private MIN_LEVEL = 40
  private MAX_LEVEL_FOR_EXP_SP = 46

  def initialize
    super(184, self.class.simple_name, "Art Of Persuasion")

    add_start_npc(MAESTRO_NIKOLA)
    add_talk_id(MAESTRO_NIKOLA, RESEARCHER_LORAIN, DESTROYED_DEVICE, ALARM_OF_GIANT)
    register_quest_items(METALLOGRAPH, BROKEN_METAL_PIECES, NIKOLAS_MAP)
  end

  def on_adv_event(event, npc, player)
    return unless player
    unless qs = get_quest_state(player, false)
      return
    end

    case event
    when "30621-06.htm"
      if qs.created?
        qs.start_quest
        qs.memo_state = 1
        give_items(player, NIKOLAS_MAP, 1)
        htmltext = event
      end
    when "30621-03.htm"
      if player.level >= MIN_LEVEL
        htmltext = event
      else
        htmltext = "30621-03a.htm"
      end
    when "30621-04.htm", "30621-05.htm"
      htmltext = event
    when "30673-02.html"
      if qs.memo_state?(1)
        htmltext = event
      end
    when "30673-03.html"
      if qs.memo_state?(1)
        take_items(player, NIKOLAS_MAP, -1)
        qs.memo_state = 2
        qs.set_cond(2, true)
        htmltext = event
      end
    when "30673-05.html"
      if qs.memo_state?(2)
        qs.memo_state = 3
        qs.set_cond(3, true)
        htmltext = event
      end
    when "30673-08.html"
      if qs.memo_state?(6)
        htmltext = event
      end
    when "30673-09.html"
      if qs.memo_state?(6)
        if has_quest_items?(player, METALLOGRAPH)
          give_items(player, LORAINES_CERTIFICATE, 1)
          qs.exit_quest(false, true)
          htmltext = event
        else
          htmltext = "30673-10.htm"
          qs.exit_quest(false, true)
        end
        if player.level < MAX_LEVEL_FOR_EXP_SP
          give_adena(player, 72527, true)
          add_exp_and_sp(player, 203717, 14032)
        else
          give_adena(player, 72527, true)
        end
      end
    when "32366-03.html"
      npc = npc.not_nil!
      if qs.memo_state?(3) && !npc.variables.get_bool("SPAWNED", false)
        npc.variables["SPAWNED"] = true
        npc.variables["PLAYER_ID"] = player.l2id
        alarm = add_spawn(ALARM_OF_GIANT, player.x + 80, player.y + 60, player.z, 16384, false, 0)
        alarm.variables["player0"] = player
        alarm.variables["npc0"] = npc
      end
    when "32366-06.html"
      if qs.memo_state?(4)
        give_items(player, METALLOGRAPH, 1)
        qs.memo_state = 6
        qs.set_cond(4, true)
        htmltext = event
      end
    when "32366-08.html"
      if qs.memo_state?(5)
        give_items(player, BROKEN_METAL_PIECES, 1)
        qs.memo_state = 6
        qs.set_cond(5, true)
        htmltext = event
      end
    end

    htmltext
  end

  def on_talk(npc, player)
    qs = get_quest_state!(player)
    memo_state = qs.memo_state

    if qs.created?
      if npc.id == MAESTRO_NIKOLA
        q184 = player.get_quest_state(Q00184_ArtOfPersuasion.simple_name)
        q185 = player.get_quest_state(Q00185_NikolasCooperation.simple_name)
        if player.quest_completed?(Q00183_RelicExploration.simple_name) && q184 && q185
          htmltext = player.level >= MIN_LEVEL ? "30621-01.htm" : "30621-02.html"
        end
      end
    elsif qs.started?
      case npc.id
      when MAESTRO_NIKOLA
        if memo_state == 1
          htmltext = "30621-07.html"
        end
      when RESEARCHER_LORAIN
        if memo_state == 1
          htmltext = "30673-01.html"
        elsif memo_state == 2
          htmltext = "30673-04.html"
        elsif memo_state >= 3 && memo_state <= 5
          htmltext = "30673-06.html"
        elsif memo_state == 6
          htmltext = "30673-07.html"
        end
      when DESTROYED_DEVICE
        if memo_state == 3
          if !npc.variables.get_bool("SPAWNED", false)
            htmltext = "32366-01.html"
          elsif npc.variables.get_i32("PLAYER_ID") == player.l2id
            htmltext = "32366-03.html"
          else
            htmltext = "32366-04.html"
          end
        elsif memo_state == 4
          htmltext = "32366-05.html"
        elsif memo_state == 5
          htmltext = "32366-07.html"
        end
      end
    elsif qs.completed?
      if npc.id == MAESTRO_NIKOLA
        htmltext = get_already_completed_msg(player)
      end
    end

    htmltext || get_no_quest_msg(player)
  end
end
