class Scripts::Q00688_DefeatTheElrokianRaiders < Quest
  # NPCs
  private ELROKI = 22214
  private DINN = 32105
  # Item
  private DINOSAUR_FANG_NECKLACE = 8785
  # Misc
  private MIN_LEVEL = 75
  private DROP_RATE = 448

  def initialize
    super(688, self.class.simple_name, "Defeat the Elrokian Raiders!")

    add_start_npc(DINN)
    add_talk_id(DINN)
    add_kill_id(ELROKI)
    register_quest_items(DINOSAUR_FANG_NECKLACE)
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    unless st = get_quest_state(pc, false)
      return
    end

    case event
    when "32105-02.htm", "32105-10.html"
      html = event
    when "32105-03.html"
      st.start_quest
      html = event
    when "32105-06.html"
      if st.has_quest_items?(DINOSAUR_FANG_NECKLACE)
        adena = 3000 * st.get_quest_items_count(DINOSAUR_FANG_NECKLACE)
        st.give_adena(adena, true)
        st.take_items(DINOSAUR_FANG_NECKLACE, -1)
        html = event
      end
    when "donation"
      if st.get_quest_items_count(DINOSAUR_FANG_NECKLACE) < 100
        html = "32105-07.html"
      else
        if Rnd.rand(1000) < 500
          st.give_adena(450000, true)
          html = "32105-08.html"
        else
          st.give_adena(150000, true)
          html = "32105-09.html"
        end
        st.take_items(DINOSAUR_FANG_NECKLACE, 100)
      end
    when "32105-11.html"
      if st.has_quest_items?(DINOSAUR_FANG_NECKLACE)
        adena = 3000 * st.get_quest_items_count(DINOSAUR_FANG_NECKLACE)
        st.give_adena(adena, true)
      end
      st.exit_quest(true, true)
      html = event
    end

    html
  end

  def on_kill(npc, pc, is_summon)
    unless member = get_random_party_member(pc, 1)
      return super
    end

    st = get_quest_state!(member, false)

    chance = DROP_RATE * Config.rate_quest_drop
    if Rnd.rand(1000) < chance
      st.reward_items(DINOSAUR_FANG_NECKLACE, 1)
      st.play_sound(Sound::ITEMSOUND_QUEST_ITEMGET)
    end

    super
  end

  def on_talk(npc, pc)
    st = get_quest_state!(pc)

    case st.state
    when State::CREATED
      html = pc.level >= MIN_LEVEL ? "32105-01.htm" : "32105-04.html"
    when State::STARTED
      if st.has_quest_items?(DINOSAUR_FANG_NECKLACE)
        html = "32105-05.html"
      else
        html = "32105-12.html"
      end
    end

    html || get_no_quest_msg(pc)
  end
end
