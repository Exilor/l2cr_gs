class Scripts::Q00312_TakeAdvantageOfTheCrisis < Quest
  # NPC
  private FILAUR = 30535
  # Monsters
  private MOBS = {
    22678 => 291, # Grave Robber Summoner (Lunatic)
    22679 => 596, # Grave Robber Magician (Lunatic)
    22680 => 610, # Grave Robber Worker (Lunatic)
    22681 => 626, # Grave Robber Warrior (Lunatic)
    22682 => 692, # Grave Robber Warrior of Light (Lunatic)
    22683 => 650, # Servitor of Darkness
    22684 => 310, # Servitor of Darkness
    22685 => 626, # Servitor of Darkness
    22686 => 626, # Servitor of Darkness
    22687 => 308, # Phantoms of the Mine
    22688 => 416, # Evil Spirits of the Mine
    22689 => 212, # Mine Bug
    22690 => 748  # Earthworm's Descendant
  }
  # Item
  private MINERAL_FRAGMENT = 14875
  # Misc
  private MIN_LEVEL = 80

  def initialize
    super(312, self.class.simple_name, "Take Advantage of the Crisis!")

    add_start_npc(FILAUR)
    add_talk_id(FILAUR)
    add_kill_id(MOBS.keys)
    register_quest_items(MINERAL_FRAGMENT)
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    unless st = get_quest_state(pc, false)
      return
    end

    html = event
    case event
    when "30535-02.html", "30535-03.html", "30535-04.html", "30535-05.htm",
         "30535-09.html", "30535-10.html"
    when "30535-06.htm"
      st.start_quest
    when "30535-11.html"
      st.exit_quest(true, true)
    else
      html = nil
    end

    html
  end

  def on_kill(npc, pc, is_summon)
    member = get_random_party_member(pc, 1)
    if member && Rnd.rand(1000) < MOBS[npc.id]
      st = get_quest_state!(member, false)
      st.give_items(MINERAL_FRAGMENT, 1)
      st.play_sound(Sound::ITEMSOUND_QUEST_ITEMGET)
    end

    super
  end

  def on_talk(npc, pc)
    st = get_quest_state!(pc)

    case st.state
    when State::CREATED
      html = pc.level >= MIN_LEVEL ? "30535-01.htm" : "30535-00.htm"
    when State::STARTED
      if st.has_quest_items?(MINERAL_FRAGMENT)
        html = "30535-08.html"
      else
        html = "30535-07.html"
      end
    else
      # automatically added
    end


    html || get_no_quest_msg(pc)
  end
end