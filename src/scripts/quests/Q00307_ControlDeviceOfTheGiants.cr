class Scripts::Q00307_ControlDeviceOfTheGiants < Quest
  # NPC
  private DROPH = 32711
  # RB
  private GORGOLOS = 25681
  private LAST_TITAN_UTENUS = 25684
  private GIANT_MARPANAK = 25680
  private HEKATON_PRIME = 25687
  # Items
  private SUPPORT_ITEMS = 14850
  private CET_1_SHEET = 14851
  private CET_2_SHEET = 14852
  private CET_3_SHEET = 14853
  # Misc
  private RESPAWN_DELAY = 3600000 # 1 hour

  @hekaton : L2Npc?

  def initialize
    super(307, self.class.simple_name, "Control Device of the Giants")

    add_start_npc(DROPH)
    add_talk_id(DROPH)
    add_kill_id(GORGOLOS, LAST_TITAN_UTENUS, GIANT_MARPANAK, HEKATON_PRIME)
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    unless st = get_quest_state(pc, false)
      return
    end

    html = event
    case event
    when "32711-04.html"
      if pc.level >= 79
        st.start_quest
        if st.has_quest_items?(CET_1_SHEET, CET_2_SHEET, CET_3_SHEET)
          html = "32711-04a.html"
        else
          html = "32711-04.html"
        end
      end
    when "32711-05a.html"
      pc.send_packet(RadarControl.new(0, 2, 186214, 61591, -4152))
    when "32711-05b.html"
      pc.send_packet(RadarControl.new(0, 2, 187554, 60800, -4984))
    when "32711-05c.html"
      pc.send_packet(RadarControl.new(0, 2, 193432, 53922, -4368))
    when "spawn"
      hekaton = @hekaton

      if !has_quest_items?(pc, CET_1_SHEET, CET_2_SHEET, CET_3_SHEET)
        return get_no_quest_msg(pc)
      elsif hekaton && hekaton.alive?
        return "32711-09.html"
      end
      respawn = load_global_quest_var("Respawn")
      remain = respawn.empty? ? 0 : respawn.to_i64 - Time.ms
      if remain > 0
        return "32711-09a.html"
      end
      st.take_items(CET_1_SHEET, 1)
      st.take_items(CET_2_SHEET, 1)
      st.take_items(CET_3_SHEET, 1)
      @hekaton = add_spawn(HEKATON_PRIME, 191777, 56197, -7624, 0, false, 0)
      html = "32711-09.html"
    when "32711-03.htm", "32711-05.html", "32711-06.html"
      # do nothing
    else
      html = nil
    end

    html
  end

  def on_kill(npc, pc, is_summon)
    unless m = get_random_party_member(pc, 1)
      return super
    end
    st = get_quest_state!(m, false)

    case npc.id
    when GORGOLOS
      st.give_items(CET_1_SHEET, 1)
      st.play_sound(Sound::ITEMSOUND_QUEST_ITEMGET)
    when LAST_TITAN_UTENUS
      st.give_items(CET_2_SHEET, 1)
      st.play_sound(Sound::ITEMSOUND_QUEST_ITEMGET)
    when GIANT_MARPANAK
      st.give_items(CET_3_SHEET, 1)
      st.play_sound(Sound::ITEMSOUND_QUEST_ITEMGET)
    when HEKATON_PRIME
      if party = pc.party
        party.members.each do |pl|
          qs = get_quest_state(pl, false)
          if qs && qs.cond?(1)
            qs.set_cond(2, true)
          end
        end
        save_global_quest_var("Respawn", (Time.ms + RESPAWN_DELAY).to_s)
      end
    else
      # [automatically added else]
    end


    super
  end

  def on_talk(npc, pc)
    st = get_quest_state!(pc)

    case st.state
    when State::CREATED
      html = pc.level >= 79 ? "32711-01.htm" : "32711-02.htm"
    when State::STARTED
      hekaton = @hekaton
      if hekaton && hekaton.alive?
        html = "32711-09.html"
      elsif st.cond?(1)
        if has_quest_items?(pc, CET_1_SHEET, CET_2_SHEET, CET_3_SHEET)
          html = "32711-08.html"
        else
          html = "32711-07.html"
        end
      elsif st.cond?(2)
        st.give_items(SUPPORT_ITEMS, 1)
        st.exit_quest(true, true)
        html = "32711-10.html"
      end
    else
      # [automatically added else]
    end


    html || get_no_quest_msg(pc)
  end
end
