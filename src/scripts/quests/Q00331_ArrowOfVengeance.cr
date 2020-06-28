class Scripts::Q00331_ArrowOfVengeance < Quest
  # NPCs
  private BELTON = 30125
  # Items
  private HARPY_FEATHER = 1452
  private MEDUSA_VENOM = 1453
  private WYRMS_TOOTH = 1454
  # Monster
  private MONSTERS = {
    20145 => 59, # Harpy
    20158 => 61, # Medusa
    20176 => 60  # Wyrm
  }
  # Misc
  private MIN_LVL = 32
  private HARPY_FEATHER_ADENA = 78
  private MEDUSA_VENOM_ADENA = 88
  private WYRMS_TOOTH_ADENA = 92
  private BONUS = 3100
  private BONUS_COUNT = 10

  def initialize
    super(331, self.class.simple_name, "Arrow for Vengeance")

    add_start_npc(BELTON)
    add_talk_id(BELTON)
    add_kill_id(MONSTERS.keys)
    register_quest_items(HARPY_FEATHER, MEDUSA_VENOM, WYRMS_TOOTH)
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    if st = get_quest_state(pc, false)
      case event
      when "30125-03.htm"
        st.start_quest
        html = event
      when "30125-06.html"
        st.exit_quest(true, true)
        html = event
      when "30125-07.html"
        html = event
      end

    end

    html
  end

  def on_talk(npc, pc)
    st = get_quest_state!(pc)

    case st.state
    when State::CREATED
      html = pc.level < MIN_LVL ? "30125-01.htm" : "30125-02.htm"
    when State::STARTED
      harpy_feathers = st.get_quest_items_count(HARPY_FEATHER)
      medusa_venoms = st.get_quest_items_count(MEDUSA_VENOM)
      wyrms_teeth = st.get_quest_items_count(WYRMS_TOOTH)
      if harpy_feathers + medusa_venoms + wyrms_teeth > 0
        adena = harpy_feathers * HARPY_FEATHER_ADENA
        adena += medusa_venoms * MEDUSA_VENOM_ADENA
        adena += wyrms_teeth * WYRMS_TOOTH_ADENA
        if harpy_feathers + medusa_venoms + wyrms_teeth >= BONUS_COUNT
          adena += BONUS
        end
        st.give_adena(adena, true)
        take_items(pc, -1, {HARPY_FEATHER, MEDUSA_VENOM, WYRMS_TOOTH})
        html = "30125-05.html"
      else
        html = "30125-04.html"
      end
    end


    html || get_no_quest_msg(pc)
  end

  def on_kill(npc, pc, is_pet)
    if st = get_quest_state(pc, false)
      if Rnd.rand(100) < MONSTERS[npc.id]
        case npc.id
        when 20145
          st.give_items(HARPY_FEATHER, 1)
        when 20158
          st.give_items(MEDUSA_VENOM, 1)
        when 20176
          st.give_items(WYRMS_TOOTH, 1)
        end

        st.play_sound(Sound::ITEMSOUND_QUEST_ITEMGET)
      end
    end

    super
  end
end
