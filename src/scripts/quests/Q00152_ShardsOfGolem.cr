class Quests::Q00152_ShardsOfGolem < Quest
  # NPCs
  private HARRYS = 30035
  private ALTRAN = 30283
  # Monster
  private STONE_GOLEM = 20016
  # Items
  private WOODEN_BREASTPLATE = 23
  private HARRYS_1ST_RECIEPT = 1008
  private HARRYS_2ND_RECIEPT = 1009
  private GOLEM_SHARD = 1010
  private TOOL_BOX = 1011
  # Misc
  private MIN_LVL = 10

  def initialize
    super(152, self.class.simple_name, "Shards of Golem")

    add_start_npc(HARRYS)
    add_talk_id(HARRYS, ALTRAN)
    add_kill_id(STONE_GOLEM)
    register_quest_items(HARRYS_1ST_RECIEPT, HARRYS_2ND_RECIEPT, GOLEM_SHARD, TOOL_BOX)
  end

  def on_adv_event(event, npc, player)
    return unless player
    st = get_quest_state(player, false)

    if st
      case event
      when "30035-03.htm"
        st.start_quest
        st.give_items(HARRYS_1ST_RECIEPT, 1)
        htmltext = event
      when "30283-02.html"
        if st.cond?(1) && st.has_quest_items?(HARRYS_1ST_RECIEPT)
          st.take_items(HARRYS_1ST_RECIEPT, -1)
          st.give_items(HARRYS_2ND_RECIEPT, 1)
          st.set_cond(2, true)
          htmltext = event
        end
      end
    end

    htmltext
  end

  def on_kill(npc, killer, is_summon)
    st = get_quest_state(killer, false)
    if st && st.cond?(2) && Rnd.rand(100) < 30 && st.get_quest_items_count(GOLEM_SHARD) < 5
      st.give_items(GOLEM_SHARD, 1)
      if st.get_quest_items_count(GOLEM_SHARD) >= 5
        st.set_cond(3, true)
      else
        st.play_sound(Sound::ITEMSOUND_QUEST_ITEMGET)
      end
    end
    super
  end

  def on_talk(npc, player)
    st = get_quest_state(player, true)
    htmltext = get_no_quest_msg(player)
    if st
      case npc.id
      when HARRYS
        case st.state
        when State::CREATED
          htmltext = player.level >= MIN_LVL ? "30035-02.htm" : "30035-01.htm"
        when State::STARTED
          case st.cond
          when 1
            if st.has_quest_items?(HARRYS_1ST_RECIEPT)
              htmltext = "30035-04a.html"
            end
          when 2, 3
            if st.has_quest_items?(HARRYS_2ND_RECIEPT)
              htmltext = "30035-04.html"
            end
          when 4
            if st.has_quest_items?(HARRYS_2ND_RECIEPT, TOOL_BOX)
              st.give_items(WOODEN_BREASTPLATE, 1)
              st.add_exp_and_sp(5000, 0)
              st.exit_quest(false, true)
              htmltext = "30035-05.html"
            end
          end
        when State::COMPLETED
            htmltext = get_already_completed_msg(player)
        end
      when ALTRAN
        case st.cond
        when 1
          if st.has_quest_items?(HARRYS_1ST_RECIEPT)
            htmltext = "30283-01.html"
          end
        when 2
          if st.has_quest_items?(HARRYS_2ND_RECIEPT) && st.get_quest_items_count(GOLEM_SHARD) < 5
            htmltext = "30283-03.html"
          end
        when 3
          if st.has_quest_items?(HARRYS_2ND_RECIEPT) && st.get_quest_items_count(GOLEM_SHARD) >= 5
            st.take_items(GOLEM_SHARD, -1)
            st.give_items(TOOL_BOX, 1)
            st.set_cond(4, true)
            htmltext = "30283-04.html"
          end
        when 4
          if st.has_quest_items?(HARRYS_2ND_RECIEPT, TOOL_BOX)
            htmltext = "30283-05.html"
          end
        end
      end
    end

    htmltext
  end
end
