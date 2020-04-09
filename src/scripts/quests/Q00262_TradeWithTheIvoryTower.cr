class Scripts::Q00262_TradeWithTheIvoryTower < Quest
  # NPCs
  private VOLLODOS = 30137
  # Items
  private SPORE_SAC = 707
  # Misc
  private MIN_LEVEL = 8
  private REQUIRED_ITEM_COUNT = 10
  # Monsters
  private MOBS_SAC = {
    20007 => 3, # Green Fungus
    20400 => 4  # Blood Fungus
  }

  def initialize
    super(262, self.class.simple_name, "Trade With The Ivory Tower")

    add_start_npc(VOLLODOS)
    add_talk_id(VOLLODOS)
    add_kill_id(MOBS_SAC.keys)
    register_quest_items(SPORE_SAC)
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    st = get_quest_state(pc, false)
    if st && event.casecmp?("30137-03.htm")
      st.start_quest
      event
    end
  end

  def on_kill(npc, pc, is_summon)
    party_member = get_random_party_member(pc, 1)
    unless party_member
      return super
    end

    st = get_quest_state(party_member, false).not_nil!
    chance = MOBS_SAC[npc.id] * Config.rate_quest_drop
    if Rnd.rand(10) < chance
      st.reward_items(SPORE_SAC, 1)
      if st.get_quest_items_count(SPORE_SAC) >= REQUIRED_ITEM_COUNT
        st.set_cond(2, true)
      else
        st.play_sound(Sound::ITEMSOUND_QUEST_ITEMGET)
      end
    end

    super
  end

  def on_talk(npc, pc)
    st = get_quest_state!(pc)

    case st.state
    when State::CREATED
      html = pc.level >= MIN_LEVEL ? "30137-02.htm" : "30137-01.htm"
    when State::STARTED
      case st.cond
      when 1
        if st.get_quest_items_count(SPORE_SAC) < REQUIRED_ITEM_COUNT
          html = "30137-04.html"
        end
      when 2
        if st.get_quest_items_count(SPORE_SAC) >= REQUIRED_ITEM_COUNT
          html = "30137-05.html"
          st.give_adena(3000, true)
          st.exit_quest(true, true)
        end
      else
        # [automatically added else]
      end

    else
      # [automatically added else]
    end


    html || get_no_quest_msg(pc)
  end
end
