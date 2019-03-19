class Quests::Q00457_LostAndFound < Quest
  # NPCs
  private GUMIEL = 32759
  private ESCORT_CHECKER = 32764
  private SOLINA_CLAN = {
    22789, # Guide Solina
    22790, # Seeker Solina
    22791, # Savior Solina
    22793  # Ascetic Solina
  }
  # Misc
  private PACKAGED_BOOK = 15716
  private CHANCE_SPAWN = 1 # 1%
  private MIN_LVL = 82

  @escort_checkers = Set(L2Spawn).new

  def initialize
    super(457, self.class.simple_name, "Lost and Found")

    add_start_npc(GUMIEL)
    add_spawn_id(ESCORT_CHECKER)
    add_first_talk_id(GUMIEL)
    add_talk_id(GUMIEL)
    add_kill_id(SOLINA_CLAN)
  end

  def on_adv_event(event, npc, player)
    player = player.not_nil!
    npc = npc.not_nil!

    unless st = get_quest_state(player, false)
      return get_no_quest_msg(player)
    end

    case event
    when "32759-06.html"
      npc.script_value = 0
      st.start_quest
      npc.target = player
      npc.set_walking
      npc.set_intention(AI::FOLLOW, player)
      start_quest_timer("CHECK", 1000, npc, player, true)
      start_quest_timer("TIME_LIMIT", 600000, npc, player)
      start_quest_timer("TALK_TIME", 120000, npc, player)
      start_quest_timer("TALK_TIME2", 30000, npc, player)
    when "TALK_TIME"
      broadcast_npc_say(npc, player, NpcString::AH_I_THINK_I_REMEMBER_THIS_PLACE, false)
    when "TALK_TIME2"
      broadcast_npc_say(npc, player, NpcString::WHAT_WERE_YOU_DOING_HERE, false)
      start_quest_timer("TALK_TIME3", 10 * 1000, npc, player)
    when "TALK_TIME3"
      broadcast_npc_say(npc, player, NpcString::I_GUESS_YOURE_THE_SILENT_TYPE_THEN_ARE_YOU_LOOKING_FOR_TREASURE_LIKE_ME, false)
    when "TIME_LIMIT"
      start_quest_timer("STOP", 2000, npc, player)
      st.exit_quest(QuestType::DAILY)
    when "CHECK"
      distance = npc.calculate_distance(player, true, false)
      if distance > 1000
        if distance > 5000
          start_quest_timer("STOP", 2000, npc, player)
          st.exit_quest(QuestType::DAILY)
        elsif npc.script_value?(0)
          broadcast_npc_say(npc, player, NpcString::HEY_DONT_GO_SO_FAST, true)
          npc.script_value = 1
        elsif npc.script_value?(1)
          broadcast_npc_say(npc, player, NpcString::ITS_HARD_TO_FOLLOW, true)
          npc.script_value = 2
        elsif npc.script_value?(2)
          start_quest_timer("STOP", 2000, npc, player)
          st.exit_quest(QuestType::DAILY)
        end
      end
      @escort_checkers.each do |sp|
        escort = sp.last_spawn
        if escort && npc.inside_radius?(escort, 1000, false, false)
          start_quest_timer("STOP", 1000, npc, player)
          start_quest_timer("BYE", 3000, npc, player)
          cancel_quest_timer("CHECK", npc, player)
          npc.broadcast_packet(CreatureSay.new(npc.l2id, Say2::NPC_ALL, npc.name, NpcString::AH_FRESH_AIR))
          broadcast_npc_say(npc, player, NpcString::AH_FRESH_AIR, false)
          st.give_items(PACKAGED_BOOK, 1)
          st.exit_quest(QuestType::DAILY, true)
        end
      end
    when "STOP"
      npc.target = nil
      npc.ai.stop_follow
      npc.intention = AI::IDLE
      cancel_quest_timer("CHECK", npc, player)
      cancel_quest_timer("TIME_LIMIT", npc, player)
      cancel_quest_timer("TALK_TIME", npc, player)
      cancel_quest_timer("TALK_TIME2", npc, player)
    when "BYE"
      npc.delete_me
    else
      html = event
    end

    html
  end

  def on_first_talk(npc, player)
    if npc.target
      return npc.target == player ? "32759-08.html" : "32759-01a.html"
    end

    "32759.html"
  end

  def on_kill(npc, player, is_summon)
    st = get_quest_state!(player)

    if rand(100) < CHANCE_SPAWN && st.now_available? && player.level >= MIN_LVL
      add_spawn(GUMIEL, npc)
    end

    super
  end

  def on_talk(npc, player)
    st = get_quest_state!(player)
    case st.state
    when State::CREATED
      html = player.level >= MIN_LVL ? "32759-01.htm" : "32759-03.html"
    when State::COMPLETED
      if st.now_available?
        st.state = State::CREATED
        html = player.level >= MIN_LVL ? "32759-01.htm" : "32759-03.html"
      else
        html = "32759-02.html"
      end
    end

    html || get_no_quest_msg(player)
  end

  def on_spawn(npc)
    @escort_checkers = SpawnTable.get_spawns(ESCORT_CHECKER)
    super
  end

  def broadcast_npc_say(npc, player, str_id, whisper)
    if whisper
      player.send_packet(NpcSay.new(npc.l2id, Say2::TELL, npc.id, str_id))
    else
      # L2J uses sendPacket instead.
      npc.broadcast_packet(NpcSay.new(npc.l2id, Say2::ALL, npc.id, str_id))
    end
  end
end
