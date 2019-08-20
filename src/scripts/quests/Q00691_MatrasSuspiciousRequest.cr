class Scripts::Q00691_MatrasSuspiciousRequest < Quest
  # NPC
  private MATRAS = 32245
  # Items
  private RED_GEM = 10372
  private DYNASTY_SOUL_II = 10413
  # Reward
  private REWARD_CHANCES = {
    22363 => 890,
    22364 => 261,
    22365 => 560,
    22366 => 560,
    22367 => 190,
    22368 => 129,
    22369 => 210,
    22370 => 787,
    22371 => 257,
    22372 => 656
  }
  # Misc
  private MIN_LEVEL = 76

  def initialize
    super(691, self.class.simple_name, "Matras' Suspicious Request")

    add_start_npc(MATRAS)
    add_talk_id(MATRAS)
    add_kill_id(REWARD_CHANCES.keys)
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    unless st = get_quest_state(pc, false)
      return
    end

    case event
    when "32245-02.htm", "32245-11.html"
      html = event
    when "32245-04.htm"
      st.start_quest
      html = event
    when "take_reward"
      if st.started?
        gem_count = st.get_int("submitted_gems")
        if gem_count >= 744
          st.set("submitted_gems", (gem_count - 744).to_s)
          st.give_items(DYNASTY_SOUL_II, 1)
          html = "32245-09.html"
        else
          html = get_htm(pc, "32245-10.html")
          html = html.sub("%itemcount%", st.get("submitted_gems"))
        end
      end
    when "32245-08.html"
      if st.started?
        submitted_count = st.get_int("submitted_gems")
        brought_count = st.get_quest_items_count(RED_GEM).to_i32
        final_count = submitted_count + brought_count
        st.take_items(RED_GEM, brought_count)
        st.set("submitted_gems", final_count.to_s)
        html = get_htm(pc, "32245-08.html")
        html = html.sub("%itemcount%", final_count.to_s)
      end
    when "32245-12.html"
      if st.started?
        st.give_adena(st.get_int("submitted_gems") * 10000, true)
        st.exit_quest(true, true)
        html = event
      end
    end

    html
  end

  def on_kill(npc, pc, is_summon)
    unless pl = get_random_party_member(pc, 1)
      return super
    end

    st = get_quest_state!(pl, false)
    chance = (Config.rate_quest_drop * REWARD_CHANCES[npc.id]).to_i32
    num_items = Math.max((chance // 1000).to_i, 1)
    chance = chance % 1000
    if rand(1000) <= chance
      st.give_items(RED_GEM, num_items)
      st.play_sound(Sound::ITEMSOUND_QUEST_ITEMGET)
    end

    super
  end

  def on_talk(npc, pc)
    st = get_quest_state!(pc)

    case st.state
    when State::CREATED
      html = pc.level >= MIN_LEVEL ? "32245-01.htm" : "32245-03.html"
    when State::STARTED
      if st.has_quest_items?(RED_GEM)
        html = "32245-05.html"
      elsif st.get_int("submitted_gems") > 0
        html = get_htm(pc, "32245-07.html")
        html = html.sub("%itemcount%", st.get("submitted_gems"))
      else
        html = "32245-06.html"
      end
    end

    html || get_no_quest_msg(pc)
  end
end
