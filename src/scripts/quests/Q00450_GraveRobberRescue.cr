class Quests::Q00450_GraveRobberRescue < Quest
  # NPCs
  private KANEMIKA = 32650
  private WARRIOR = 32651
  # Monster
  private WARRIOR_MON = 22741
  # Item
  private EVIDENCE_OF_MIGRATION = 14876
  # Misc
  private MIN_LEVEL = 80

  def initialize
    super(450, self.class.simple_name, "Grave Robber Rescue")

    add_start_npc(KANEMIKA)
    add_talk_id(KANEMIKA, WARRIOR)
    register_quest_items(EVIDENCE_OF_MIGRATION)
  end

  def on_adv_event(event, npc, player)
    return unless player
    unless st = get_quest_state(player, false)
      return
    end

    html = event
    case event
    when "32650-04.htm", "32650-05.htm", "32650-06.html"
      # do nothing
    when "32650-07.htm"
      st.start_quest
    when "despawn"
      npc = npc.not_nil!
      npc.busy = false
      npc.delete_me
      html = nil
    else
      html = nil
    end

    html
  end

  def on_talk(npc, player)
    st = get_quest_state!(player)
    if npc.id == KANEMIKA
      case st.state
      when State::COMPLETED
        unless st.now_available?
          html = "32650-03.html"
        end
        st.state = State::CREATED
      when State::CREATED
        html = player.level >= MIN_LEVEL ? "32650-01.htm" : "32650-02.htm"
      when State::STARTED
        if st.cond?(1)
          if st.has_quest_items?(EVIDENCE_OF_MIGRATION)
            html = "32650-09.html"
          else
            html = "32650-08.html"
          end
        else
          st.give_adena(65000, true) # Glory days reward: 6 886 980 exp, 8 116 410 sp, 371 400 Adena
          st.exit_quest(QuestType::DAILY, true)
          html = "32650-10.html"
        end
      end
    elsif st.cond?(1)
      if npc.busy?
        return
      end

      if rand(100) < 66
        st.give_items(EVIDENCE_OF_MIGRATION, 1)
        st.play_sound(Sound::ITEMSOUND_QUEST_ITEMGET)
        npc.set_intention(AI::MOVE_TO, Location.new(npc.x + 100, npc.y + 100, npc.z, 0))
        npc.busy = true

        start_quest_timer("despawn", 3000, npc, player)

        if st.get_quest_items_count(EVIDENCE_OF_MIGRATION) == 10
          st.set_cond(2, true)
        end
        html = "32651-01.html"
      else
        if rand(100) < 50
          npc.broadcast_packet(NpcSay.new(npc.l2id, Say2::NPC_ALL, npc.id, NpcString::GRUNT_OH))
        else
          npc.broadcast_packet(NpcSay.new(npc.l2id, Say2::NPC_ALL, npc.id, NpcString::GRUNT_WHATS_WRONG_WITH_ME))
        end
        npc.delete_me
        html = nil

        mob = add_spawn(WARRIOR_MON, *npc.xyz, npc.heading, true, 600000).as(L2Attackable)
        mob.set_running
        mob.add_damage_hate(player, 0, 999i64)
        mob.set_intention(AI::ATTACK, player)
        show_on_screen_msg(player, NpcString::THE_GRAVE_ROBBER_WARRIOR_HAS_BEEN_FILLED_WITH_DARK_ENERGY_AND_IS_ATTACKING_YOU, 5, 5000)
      end
    end

    html || get_no_quest_msg(player)
  end
end
