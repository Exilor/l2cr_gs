class Scripts::Q00701_ProofOfExistence < Quest
  # NPC
  private ARTIUS = 32559
  # Items
  private DEADMANS_REMAINS = 13875
  private BANSHEE_QUEENS_EYE = 13876
  # Monsters
  private ENIRA = 25625
  private MOBS = {
    22606 => 518, # Floating Skull
    22607 => 858, # Floating Skull
    22608 => 482, # Floating Zombie
    22609 => 466, # Floating Zombie
    25629 => 735, # Floating Skull (Enira's Evil Spirit)
    25630 => 391  # Floating Zombie (Enira's Evil Spirit)
  }
  # Misc
  private MIN_LEVEL = 78

  def initialize
    super(701, self.class.simple_name, "Proof of Existence")

    add_start_npc(ARTIUS)
    add_talk_id(ARTIUS)
    add_kill_id(MOBS.keys)
    add_kill_id(ENIRA)
    register_quest_items(DEADMANS_REMAINS, BANSHEE_QUEENS_EYE)
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    unless st = get_quest_state(pc, false)
      return
    end

    html = event
    case event
    when "32559-03.htm", "32559-08.html"
      # do nothing
    when "32559-04.htm"
      st.start_quest
    when "32559-09.html"
      st.exit_quest(true, true)
    else
      html = nil
    end

    html
  end

  def on_kill(npc, pc, is_summon)
    unless member = get_random_party_member(pc, 1)
      return super
    end
    st = get_quest_state!(member, false)
    if npc.id == ENIRA
      chance = Rnd.rand(1000)
      if chance < 708
        count = Rnd.rand(2) + 1
      elsif chance < 978
        count = Rnd.rand(3) + 3
      elsif chance < 994
        count = Rnd.rand(4) + 6
      elsif chance < 998
        count = Rnd.rand(4) + 10
      else
        count = Rnd.rand(5) + 14
      end
      st.give_items(BANSHEE_QUEENS_EYE, count)
      st.play_sound(Sound::ITEMSOUND_QUEST_ITEMGET)
    elsif Rnd.rand(1000) < MOBS[npc.id]
      st.give_items(DEADMANS_REMAINS, 1)
      st.play_sound(Sound::ITEMSOUND_QUEST_ITEMGET)
    end

    super
  end

  def on_talk(npc, pc)
    st = get_quest_state!(pc)

    case st.state
    when State::CREATED
      if pc.level >= MIN_LEVEL && pc.quest_completed?(Q10273_GoodDayToFly.simple_name)
        html = "32559-01.htm"
      else
        html = "32559-02.htm"
      end
    when State::STARTED
      if st.has_quest_items?(BANSHEE_QUEENS_EYE)
        adena = st.get_quest_items_count(DEADMANS_REMAINS) * 2500
        adena += st.get_quest_items_count(BANSHEE_QUEENS_EYE) * 50000
        st.give_adena(adena + 23835, true)
        st.take_items(BANSHEE_QUEENS_EYE, -1)
        st.take_items(DEADMANS_REMAINS, -1)
        html = "32559-07.html"
      elsif st.has_quest_items?(DEADMANS_REMAINS)
        st.give_adena(st.get_quest_items_count(DEADMANS_REMAINS) * 2500, true)
        st.take_items(DEADMANS_REMAINS, -1)
        html = "32559-06.html"
      else
        html = "32559-05.html"
      end
    else
      # [automatically added else]
    end


    html || get_no_quest_msg(pc)
  end
end
