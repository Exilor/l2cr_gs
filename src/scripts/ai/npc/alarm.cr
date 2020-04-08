class Scripts::Alarm < AbstractNpcAI
  # NPC
  private ALARM = 32367
  # Misc
  private ART_OF_PERSUASION_ID = 184
  private NIKOLAS_COOPERATION_ID = 185

  def initialize
    super(self.class.simple_name, "ai/npc")

    add_start_npc(ALARM)
    add_talk_id(ALARM)
    add_first_talk_id(ALARM)
    add_spawn_id(ALARM)
  end

  def on_adv_event(event, npc, player)
    return unless npc

    player0 = npc.variables.get_object("player0", L2PcInstance?)
    npc0 = npc.variables.get_object("npc0", L2Npc?)

    case event
    when "SELF_DESTRUCT_IN_60"
      start_quest_timer("SELF_DESTRUCT_IN_30", 30000, npc, nil)
      broadcast_npc_say(npc, Say2::NPC_ALL, NpcString::THE_ALARM_WILL_SELF_DESTRUCT_IN_60_SECONDS_ENTER_PASSCODE_TO_OVERRIDE)
    when "SELF_DESTRUCT_IN_30"
      start_quest_timer("SELF_DESTRUCT_IN_10", 20000, npc, nil)
      broadcast_npc_say(npc, Say2::NPC_ALL, NpcString::THE_ALARM_WILL_SELF_DESTRUCT_IN_30_SECONDS_ENTER_PASSCODE_TO_OVERRIDE)
    when "SELF_DESTRUCT_IN_10"
      start_quest_timer("RECORDER_CRUSHED", 10000, npc, nil)
      broadcast_npc_say(npc, Say2::NPC_ALL, NpcString::THE_ALARM_WILL_SELF_DESTRUCT_IN_10_SECONDS_ENTER_PASSCODE_TO_OVERRIDE)
    when "RECORDER_CRUSHED"
      if npc0
        if npc0.variables.get_bool("SPAWNED")
          npc0.variables["SPAWNED"] = false
          if player0
            broadcast_npc_say(npc, Say2::NPC_ALL, NpcString::RECORDER_CRUSHED)
            if verify_memo_state(player0, ART_OF_PERSUASION_ID, -1)
              set_memo_state(player0, ART_OF_PERSUASION_ID, 5)
            elsif verify_memo_state(player0, NIKOLAS_COOPERATION_ID, -1)
              set_memo_state(player0, NIKOLAS_COOPERATION_ID, 5)
            end
          end
        end
      end
      npc.delete_me
    when "32367-184_04.html", "32367-184_06.html", "32367-184_08.html"
      html = event
    when "2"
      player = player.not_nil!
      if player0 == player
        if verify_memo_state(player, ART_OF_PERSUASION_ID, 3)
          html = "32367-184_02.html"
        elsif verify_memo_state(player, NIKOLAS_COOPERATION_ID, 3)
          html = "32367-185_02.html"
        end
      end
    when "3"
      player = player.not_nil!
      if verify_memo_state(player, ART_OF_PERSUASION_ID, 3)
        set_memo_state_ex(player, ART_OF_PERSUASION_ID, 1, 1)
        html = "32367-184_04.html"
      elsif verify_memo_state(player, NIKOLAS_COOPERATION_ID, 3)
        set_memo_state_ex(player, NIKOLAS_COOPERATION_ID, 1, 1)
        html = "32367-185_04.html"
      end
    when "4"
      player = player.not_nil!
      if verify_memo_state(player, ART_OF_PERSUASION_ID, 3)
        set_memo_state_ex(player, ART_OF_PERSUASION_ID, 1, get_memo_state_ex(player, ART_OF_PERSUASION_ID, 1) + 1)
        html = "32367-184_06.html"
      elsif verify_memo_state(player, NIKOLAS_COOPERATION_ID, 3)
        set_memo_state_ex(player, NIKOLAS_COOPERATION_ID, 1, get_memo_state_ex(player, NIKOLAS_COOPERATION_ID, 1) + 1)
        html = "32367-185_06.html"
      end
    when "5"
      player = player.not_nil!
      if verify_memo_state(player, ART_OF_PERSUASION_ID, 3)
        set_memo_state_ex(player, ART_OF_PERSUASION_ID, 1, get_memo_state_ex(player, ART_OF_PERSUASION_ID, 1) + 1)
        html = "32367-184_08.html"
      elsif verify_memo_state(player, NIKOLAS_COOPERATION_ID, 3)
        set_memo_state_ex(player, NIKOLAS_COOPERATION_ID, 1, get_memo_state_ex(player, NIKOLAS_COOPERATION_ID, 1) + 1)
        html = "32367-185_08.html"
      end
    when "6"
      player = player.not_nil!
      if verify_memo_state(player, ART_OF_PERSUASION_ID, 3)
        i0 = get_memo_state_ex(player, ART_OF_PERSUASION_ID, 1)
        if i0 >= 3
          if npc0 && npc0.variables.get_bool("SPAWNED")
            npc0.variables["SPAWNED"] = false
          end
          npc.delete_me
          set_memo_state(player, ART_OF_PERSUASION_ID, 4)
          html = "32367-184_09.html"
        else
          set_memo_state_ex(player, ART_OF_PERSUASION_ID, 1, 0)
          html = "32367-184_10.html"
        end
      elsif verify_memo_state(player, NIKOLAS_COOPERATION_ID, 3)
        i0 = get_memo_state_ex(player, NIKOLAS_COOPERATION_ID, 1)
        if i0 >= 3
          if npc0 && npc0.variables.get_bool("SPAWNED")
            npc0.variables["SPAWNED"] = false
          end

          npc.delete_me
          set_memo_state(player, NIKOLAS_COOPERATION_ID, 4)
          html = "32367-185_09.html"
        else
          set_memo_state_ex(player, NIKOLAS_COOPERATION_ID, 1, 0)
          html = "32367-185_10.html"
        end
      end
    else
      # automatically added
    end


    html
  end

  def on_first_talk(npc, talker)
    html = get_no_quest_msg(talker)
    if verify_memo_state(talker, ART_OF_PERSUASION_ID, 3) || verify_memo_state(talker, NIKOLAS_COOPERATION_ID, 3)
      player = npc.variables.get_object("player0", L2PcInstance?)
      if player == talker
        html = "32367-01.html"
      else
        html = "32367-02.html"
      end
    end

    html
  end

  def on_spawn(npc)
    start_quest_timer("SELF_DESTRUCT_IN_60", 60000, npc, nil)
    broadcast_npc_say(npc, Say2::NPC_ALL, NpcString::INTRUDER_ALERT_THE_ALARM_WILL_SELF_DESTRUCT_IN_2_MINUTES)
    if player = npc.variables.get_object("player0", L2PcInstance?)
      play_sound(player, Sound::ITEMSOUND_SIREN)
    end

    super
  end

  private def verify_memo_state(player, quest_id, memo_state) : Bool
    case quest_id
    when ART_OF_PERSUASION_ID
      qs = player.get_quest_state("Q00184_ArtOfPersuasion")
    when NIKOLAS_COOPERATION_ID
      qs = player.get_quest_state("Q00185_NikolasCooperation")
    else
      # automatically added
    end


    !!qs && (memo_state < 0 || qs.memo_state?(memo_state))
  end

  private def set_memo_state(player, quest_id, memo_state)
    case quest_id
    when ART_OF_PERSUASION_ID
      qs = player.get_quest_state("Q00184_ArtOfPersuasion")
    when NIKOLAS_COOPERATION_ID
      qs = player.get_quest_state("Q00185_NikolasCooperation")
    else
      # automatically added
    end


    if qs
      qs.memo_state = memo_state
    end
  end

  def get_memo_state_ex(player, quest_id, slot)
    case quest_id
    when ART_OF_PERSUASION_ID
      qs = player.get_quest_state("Q00184_ArtOfPersuasion")
    when NIKOLAS_COOPERATION_ID
      qs = player.get_quest_state("Q00185_NikolasCooperation")
    else
      # automatically added
    end


    qs ? qs.get_memo_state_ex(slot) : -1
  end

  private def set_memo_state_ex(player, quest_id, slot, memo_state_ex)
    case quest_id
    when ART_OF_PERSUASION_ID
      qs = player.get_quest_state("Q00184_ArtOfPersuasion")
    when NIKOLAS_COOPERATION_ID
      qs = player.get_quest_state("Q00185_NikolasCooperation")
    else
      # automatically added
    end


    if qs
      qs.set_memo_state_ex(slot, memo_state_ex)
    end
  end
end