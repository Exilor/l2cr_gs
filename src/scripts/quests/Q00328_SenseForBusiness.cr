class Quests::Q00328_SenseForBusiness < Quest
  # NPCs
  private SARIEN = 30436
  private MONSTER_EYES = {
    20055 => {61, 62},
    20059 => {61, 62},
    20067 => {72, 74},
    20068 => {78, 79}
  }
  private MONSTER_BASILISKS = {
    20070 => 60,
    20072 => 63
  }
  # Items
  private MONSTER_EYE_CARCASS = 1347
  private MONSTER_EYE_LENS = 1366
  private BASILISK_GIZZARD = 1348
  # Misc
  private MONSTER_EYE_CARCASS_ADENA = 25
  private MONSTER_EYE_LENS_ADENA = 1000
  private BASILISK_GIZZARD_ADENA = 60
  private BONUS = 618
  private BONUS_COUNT = 10
  private MIN_LVL = 21

  def initialize
    super(328, self.class.simple_name, "Sense for Business")

    add_start_npc(SARIEN)
    add_talk_id(SARIEN)
    add_kill_id(MONSTER_EYES.keys)
    add_kill_id(MONSTER_BASILISKS.keys)
    register_quest_items(MONSTER_EYE_CARCASS, MONSTER_EYE_LENS, BASILISK_GIZZARD)
  end

  def on_adv_event(event, npc, player)
    return unless player
    if st = get_quest_state(player, false)
      case event
      when "30436-03.htm"
        st.start_quest
        html = event
      when "30436-06.html"
        st.exit_quest(true, true)
        html = event
      end
    end

    html
  end

  def on_talk(npc, player)
    st = get_quest_state!(player)

    case st.state
    when State::CREATED
      html = player.level < MIN_LVL ? "30436-01.htm" : "30436-02.htm"
    when State::STARTED
      carcass = st.get_quest_items_count(MONSTER_EYE_CARCASS)
      lens = st.get_quest_items_count(MONSTER_EYE_LENS)
      gizzards = st.get_quest_items_count(BASILISK_GIZZARD)
      if carcass + lens + gizzards > 0
        adena = (carcass * MONSTER_EYE_CARCASS_ADENA) + (lens * MONSTER_EYE_LENS_ADENA) + (gizzards * BASILISK_GIZZARD_ADENA) + ((carcass + lens + gizzards) >= BONUS_COUNT ? BONUS : 0)
        st.give_adena(adena, true)
        take_items(player, -1, {MONSTER_EYE_CARCASS, MONSTER_EYE_LENS, BASILISK_GIZZARD})
        html = "30436-05.html"
      else
        html = "30436-04.html"
      end
    end

    html || get_no_quest_msg(player)
  end

  def on_kill(npc, player, is_pet)
    st = get_quest_state(player, false)
    if st && st.started?
      chance = rand(100)
      if tmp = MONSTER_EYES[npc.id]?
        if chance < tmp[0]
          st.give_items(MONSTER_EYE_CARCASS, 1)
          st.play_sound(Sound::ITEMSOUND_QUEST_ITEMGET)
        elsif chance < tmp[1]
          st.give_items(MONSTER_EYE_LENS, 1)
          st.play_sound(Sound::ITEMSOUND_QUEST_ITEMGET)
        end
      elsif tmp = MONSTER_BASILISKS[npc.id]?
        if chance < tmp
          st.give_items(BASILISK_GIZZARD, 1)
          st.play_sound(Sound::ITEMSOUND_QUEST_ITEMGET)
        end
      end
    end

    super
  end
end
