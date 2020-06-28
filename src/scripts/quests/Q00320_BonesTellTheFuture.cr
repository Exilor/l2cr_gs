class Scripts::Q00320_BonesTellTheFuture < Quest
  # NPC
  private TETRACH_KAITAR = 30359
  # Item
  private BONE_FRAGMENT = 809
  # Misc
  private MIN_LEVEL = 10
  private REQUIRED_BONE_COUNT = 10
  private DROP_CHANCE = 0.18
  # Monsters
  private MONSTERS = {
    20517, # Skeleton Hunter
    20518  # Skeleton Hunter Archer
  }

  def initialize
    super(320, self.class.simple_name, "Bones Tell The Future")

    add_start_npc(TETRACH_KAITAR)
    add_talk_id(TETRACH_KAITAR)
    add_kill_id(MONSTERS)
    register_quest_items(BONE_FRAGMENT)
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    st = get_quest_state(pc, false)
    if st && event == "30359-04.htm"
      st.start_quest
      event
    end
  end

  def on_kill(npc, killer, is_summon)
    qs = get_random_party_member_state(killer, 1, 3, npc)
    if qs && qs.give_item_randomly(npc, BONE_FRAGMENT, 1, REQUIRED_BONE_COUNT, DROP_CHANCE, true)
      qs.set_cond(2)
    end

    super
  end

  def on_talk(npc, pc)
    st = get_quest_state!(pc)

    case st.state
    when State::CREATED
      if pc.race.dark_elf?
        if pc.level >= MIN_LEVEL
          html = "30359-03.htm"
        else
          html = "30359-02.htm"
        end
      else
        html = "30359-00.htm"
      end
    when State::STARTED
      if st.get_quest_items_count(BONE_FRAGMENT) >= REQUIRED_BONE_COUNT
        html = "30359-06.html"
        st.give_adena(8470, true)
        st.exit_quest(true, true)
      else
        html = "30359-05.html"
      end
    end


    html || get_no_quest_msg(pc)
  end
end
