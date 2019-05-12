class Scripts::Q00617_GatherTheFlames < Quest
  # NPCs
  private HILDA = 31271
  private VULCAN = 31539
  private ROONEY = 32049
  # Item
  private TORCH = 7264
  # Reward
  private REWARD = {
    6881,
    6883,
    6885,
    6887,
    6891,
    6893,
    6895,
    6897,
    6899,
    7580
  }

  # Monsters
  private MOBS = {
    22634 => 639,
    22635 => 611,
    22636 => 649,
    22637 => 639,
    22638 => 639,
    22639 => 645,
    22640 => 559,
    22641 => 588,
    22642 => 537,
    22643 => 618,
    22644 => 633,
    22645 => 550,
    22646 => 593,
    22647 => 688,
    22648 => 632,
    22649 => 685
  }

  def initialize
    super(617, self.class.simple_name, "Gather the Flames")

    add_start_npc(HILDA, VULCAN)
    add_talk_id(ROONEY, HILDA, VULCAN)
    add_kill_id(MOBS.keys)
    register_quest_items(TORCH)
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    unless st = get_quest_state(pc, false)
      return get_no_quest_msg(pc)
    end

    html = event
    case event
    when "31539-03.htm", "31271-03.htm"
      st.start_quest
    when "32049-02.html", "31539-04.html", "31539-06.html"
      # do nothing
    when "31539-07.html"
      if st.get_quest_items_count(TORCH) < 1000 || !st.started?
        return get_no_quest_msg(pc)
      end
      st.give_items(REWARD.sample, 1)
      st.take_items(TORCH, 1000)
    when "31539-08.html"
      st.exit_quest(true, true)
    when "6883", "6885", "7580", "6891", "6893", "6895", "6897", "6899"
      if st.get_quest_items_count(TORCH) < 1200 || !st.started?
        return get_no_quest_msg(pc)
      end
      st.give_items(event.to_i, 1)
      st.take_items(TORCH, 1200)
      html = "32049-04.html"
    when "6887", "6881"
      if st.get_quest_items_count(TORCH) < 1200 || !st.started?
        return get_no_quest_msg(pc)
      end
      st.give_items(event.to_i, 1)
      st.take_items(TORCH, 1200)
      html = "32049-03.html"
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

    if rand(1000) < MOBS[npc.id]
      st.give_items(TORCH, 2)
    else
      st.give_items(TORCH, 1)
    end
    st.play_sound(Sound::ITEMSOUND_QUEST_ITEMGET)

    super
  end

  def on_talk(npc, pc)
    st = get_quest_state!(pc)
    case npc.id
    when ROONEY
      if st.started?
        if st.get_quest_items_count(TORCH) >= 1200
          html = "32049-02.html"
        else
          html = "32049-01.html"
        end
      end
    when VULCAN
      if st.created?
        if pc.level >= 74
          html = "31539-01.htm"
        else
          html = "31539-02.htm"
        end
      else
        if st.get_quest_items_count(TORCH) >= 1000
          html = "31539-04.html"
        else
          html = "31539-05.html"
        end
      end
    when HILDA
      if st.created?
        html = pc.level >= 74 ? "31271-01.htm" : "31271-02.htm"
      else
        html = "31271-04.html"
      end
    end

    html || get_no_quest_msg(pc)
  end
end
