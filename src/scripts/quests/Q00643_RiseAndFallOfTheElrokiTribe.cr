class Scripts::Q00643_RiseAndFallOfTheElrokiTribe < Quest
  # NPCs
  private SINGSING = 32106
  private KARAKAWEI = 32117
  # Item
  private BONES_OF_A_PLAINS_DINOSAUR = 8776
  # Misc
  private MIN_LEVEL = 75
  private CHANCE_MOBS1 = 116
  private CHANCE_MOBS2 = 360
  private CHANCE_DEINO = 558

  # Rewards
  private PIECE = {
    8712, # Sirra's Blade Edge
    8713, # Sword of Ipos Blade
    8714, # Barakiel's Axe Piece
    8715, # Behemoth's Tuning Fork Piece
    8716, # Naga Storm Piece
    8717, # Tiphon's Spear Edge
    8718, # Shyeed's Bow Shaft
    8719, # Sobekk's Hurricane Edge
    8720, # Themis' Tongue Piece
    8721, # Cabrio's Hand Head
    8722  # Daimon Crystal Fragment
  }
  # Mobs
  private MOBS1 = {
    22200, # Ornithomimus
    22201, # Ornithomimus
    22202, # Ornithomimus
    22204, # Deinonychus
    22205, # Deinonychus
    22208, # Pachycephalosaurus
    22209, # Pachycephalosaurus
    22210, # Pachycephalosaurus
    22211, # Wild Strider
    22212, # Wild Strider
    22213, # Wild Strider
    22219, # Ornithomimus
    22220, # Deinonychus
    22221, # Pachycephalosaurus
    22222, # Wild Strider
    22224, # Ornithomimus
    22225, # Deinonychus
    22226, # Pachycephalosaurus
    22227  # Wild Strider
  }

  private MOBS2 = {
    22742, # Ornithomimus
    22743, # Deinonychus
    22744, # Ornithomimus
    22745  # Deinonychus
  }

  private DEINONYCHUS = 22203

  @@first_talk = true

  def initialize
    super(643, self.class.simple_name, "Rise and Fall of the Elroki Tribe")

    add_start_npc(SINGSING)
    add_talk_id(SINGSING, KARAKAWEI)
    add_kill_id(MOBS1)
    add_kill_id(MOBS2)
    add_kill_id(DEINONYCHUS)
    register_quest_items(BONES_OF_A_PLAINS_DINOSAUR)
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    unless st = get_quest_state(pc, false)
      return
    end

    html = nil
    case event
    when "32106-02.htm", "32106-04.htm", "32106-05.html", "32106-10.html",
         "32106-13.html", "32117-02.html", "32117-06.html", "32117-07.html"
      html = event
    when "quest_accept"
      if pc.level >= MIN_LEVEL
        st.start_quest
        html = "32106-03.html"
      else
        html = "32106-07.html"
      end
    when "32106-09.html"
      st.give_adena(1374 * st.get_quest_items_count(BONES_OF_A_PLAINS_DINOSAUR), true)
      st.take_items(BONES_OF_A_PLAINS_DINOSAUR, -1)
      html = event
    when "exit"
      if !st.has_quest_items?(BONES_OF_A_PLAINS_DINOSAUR)
        html = "32106-11.html"
      else
        st.give_adena(1374 * st.get_quest_items_count(BONES_OF_A_PLAINS_DINOSAUR), true)
        html = "32106-12.html"
      end
      st.exit_quest(true, true)
    when "exchange"
      if st.get_quest_items_count(BONES_OF_A_PLAINS_DINOSAUR) < 300
        html = "32117-04.html"
      else
        st.reward_items(PIECE.sample, 5)
        st.take_items(BONES_OF_A_PLAINS_DINOSAUR, 300)
        st.play_sound(Sound::ITEMSOUND_QUEST_MIDDLE)
        html = "32117-05.html"
      end
    end

    html
  end

  def on_kill(npc, pc, is_summon)
    unless member = get_random_party_member(pc, 1)
      return super
    end

    st = get_quest_state!(member, false)
    npc_id = npc.id

    if MOBS1.includes?(npc_id)
      chance = CHANCE_MOBS1 * Config.rate_quest_drop
      if rand(1000) < chance
        st.reward_items(BONES_OF_A_PLAINS_DINOSAUR, 2)
      else
        st.reward_items(BONES_OF_A_PLAINS_DINOSAUR, 1)
      end
      st.play_sound(Sound::ITEMSOUND_QUEST_ITEMGET)
    end

    if MOBS2.includes?(npc_id)
      chance = CHANCE_MOBS2 * Config.rate_quest_drop
      if rand(1000) < chance
        st.reward_items(BONES_OF_A_PLAINS_DINOSAUR, 1)
        st.play_sound(Sound::ITEMSOUND_QUEST_ITEMGET)
      end
    end

    if npc_id == DEINONYCHUS
      chance = CHANCE_DEINO * Config.rate_quest_drop
      if rand(1000) < chance
        st.reward_items(BONES_OF_A_PLAINS_DINOSAUR, 1)
        st.play_sound(Sound::ITEMSOUND_QUEST_ITEMGET)
      end
    end

    super
  end

  def on_talk(npc, pc)
    st = get_quest_state!(pc)

    case st.state
    when State::CREATED
      html = pc.level >= MIN_LEVEL ? "32106-01.htm" : "32106-06.html"
    when State::STARTED
      if npc.id == SINGSING
        if st.has_quest_items?(BONES_OF_A_PLAINS_DINOSAUR)
          html = "32106-08.html"
        else
          html = "32106-14.html"
        end
      elsif npc.id == KARAKAWEI
        if @@first_talk
          @@first_talk = false
          html = "32117-01.html"
        else
          html = "32117-03.html"
        end
      end
    end

    html || get_no_quest_msg(pc)
  end
end
