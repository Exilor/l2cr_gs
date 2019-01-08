class Quests::Q00257_TheGuardIsBusy < Quest
  private class MobDrop < ItemHolder
    def initialize(@random : Int32, @chance : Int32, id : Int32, count : Int64)
      super(id, count)
    end

    def drop : Bool
      Rnd.rand(@random) < @chance
    end
  end

  # NPC
	private GILBERT = 30039
	# Misc
	private MIN_LVL = 6
	# Items
	private GLUDIO_LORDS_MARK = 1084
	private ORC_AMULET = 752
	private ORC_NECKLACE = 1085
	private WEREWOLF_FANG = 1086
  # Monsters
	private MONSTERS = {
    20006 => [
      MobDrop.new(10, 2, ORC_AMULET, 2), # Orc Archer
      MobDrop.new(10, 10, ORC_AMULET, 1) # Orc Archer
    ],
		20093 => [MobDrop.new(100, 85, ORC_NECKLACE, 1)],  # Orc Fighter
		20096 => [MobDrop.new(100, 95, ORC_NECKLACE, 1)],  # Orc Fighter Sub Leader
		20098 => [MobDrop.new(100, 100, ORC_NECKLACE, 1)], # Orc Fighter Leader
		20130 => [MobDrop.new(10, 7, ORC_AMULET, 1)],      # Orc
		20131 => [MobDrop.new(10, 9, ORC_AMULET, 1)],      # Orc Grunt
		20132 => [MobDrop.new(10, 7, WEREWOLF_FANG, 1)],   # Werewolf
		20342 => [MobDrop.new(0, 1, WEREWOLF_FANG, 1)],    # Werewolf Chieftain
		20343 => [MobDrop.new(100, 85, WEREWOLF_FANG, 1)]  # Werewolf Hunter
  }

  def initialize
    super(257, self.class.simple_name, "The Guard is Busy")

    add_start_npc(GILBERT)
		add_talk_id(GILBERT)
		add_kill_id(MONSTERS.keys)
		register_quest_items(
      ORC_AMULET,
      GLUDIO_LORDS_MARK,
      ORC_NECKLACE,
      WEREWOLF_FANG
    )
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    return unless st = get_quest_state(pc, false)

    case event
    when "30039-03.htm"
      st.start_quest
      st.give_items(GLUDIO_LORDS_MARK, 1)
      event
    when "30039-05.html"
      st.exit_quest(true, true)
      event
    when "30039-06.html"
      event
    end
  end

  def on_kill(npc, killer, is_summon)
    return super unless st = get_quest_state(killer, false)

    MONSTERS[npc.id]?.try &.each do |drop|
      if drop.drop
        st.give_items(drop)
        st.play_sound(Sound::ITEMSOUND_QUEST_ITEMGET)
        break
      end
    end

    super
  end

  def on_talk(npc, pc)
    htmltext = get_no_quest_msg(pc)
    st = get_quest_state!(pc)

    case st.state
    when State::CREATED
      htmltext = pc.level >= MIN_LVL ? "30039-02.htm" : "30039-01.html"
    when State::STARTED
      if has_at_least_one_quest_item?(pc, ORC_AMULET, ORC_NECKLACE, WEREWOLF_FANG)
        amulets = st.get_quest_items_count(ORC_AMULET)
        common = get_quest_items_count(pc, ORC_NECKLACE, WEREWOLF_FANG)
        amount = (amulets * 10) + (common * 20) + (amulets + common >= 10 ? 1000 : 0)
        st.give_adena(amount, true)
        take_items(pc, -1, {ORC_AMULET, ORC_NECKLACE, WEREWOLF_FANG})
        Q00281_HeadForTheHills.give_newbie_reward(pc)
        htmltext = "30039-07.html"
      else
        htmltext = "30039-04.html"
      end
    end

    htmltext
  end
end
