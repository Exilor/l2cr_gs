class Scripts::Q00135_TempleExecutor < Quest
  # NPCs
  private SHEGFIELD = 30068
  private PANO = 30078
  private ALEX = 30291
  private SONIN = 31773
  # Items
  private STOLEN_CARGO = 10328
  private HATE_CRYSTAL = 10329
  private OLD_TREASURE_MAP = 10330
  private SONINS_CREDENTIALS = 10331
  private PANOS_CREDENTIALS = 10332
  private ALEXS_CREDENTIALS = 10333
  private BADGE_TEMPLE_EXECUTOR = 10334
  # Monsters
  private MOBS = {
    20781 => 439, # Delu Lizardman Shaman
    21104 => 439, # Delu Lizardman Supplier
    21105 => 504, # Delu Lizardman Special Agent
    21106 => 423, # Cursed Seer
    21107 => 902  # Delu Lizardman Commander
  }
  # Misc
  private MIN_LEVEL = 35
  private ITEM_COUNT = 10
  private MAX_REWARD_LEVEL = 41

  def initialize
    super(135, self.class.simple_name, "Temple Executor")

    add_start_npc(SHEGFIELD)
    add_talk_id(SHEGFIELD, ALEX, SONIN, PANO)
    add_kill_id(MOBS.keys)
    register_quest_items(
      STOLEN_CARGO, HATE_CRYSTAL, OLD_TREASURE_MAP, SONINS_CREDENTIALS,
      PANOS_CREDENTIALS, ALEXS_CREDENTIALS
    )
  end

  def on_adv_event(event, npc, pc)
    return unless pc && (st = get_quest_state(pc, false))

    html = event
    case event
    when "30291-02a.html", "30291-04.html", "30291-05.html", "30291-06.html",
         "30068-08.html", "30068-09.html", "30068-10.html"
    when "30068-03.htm"
      st.start_quest
    when "30068-04.html"
      st.set_cond(2, true)
    when "30291-07.html"
      st.unset("talk")
      st.set_cond(3, true)
    when "30068-11.html"
      st.give_items(BADGE_TEMPLE_EXECUTOR, 1)
      st.give_adena(16_924, true)
      if pc.level < MAX_REWARD_LEVEL
        st.add_exp_and_sp(30_000, 2000)
      end
      st.exit_quest(false, true)
    else
      html = nil
    end

    html
  end

  def on_kill(npc, pc, is_summon)
    unless member = get_random_party_member(pc, 3)
      return super
    end

    st = get_quest_state(member, false).not_nil!

    if Rnd.rand(1000) < MOBS[npc.id]
      if st.get_quest_items_count(STOLEN_CARGO) < ITEM_COUNT
        st.give_items(STOLEN_CARGO, 1)
      elsif st.get_quest_items_count(HATE_CRYSTAL) < ITEM_COUNT
        st.give_items(HATE_CRYSTAL, 1)
      else
        st.give_items(OLD_TREASURE_MAP, 1)
      end

      if st.get_quest_items_count(STOLEN_CARGO) >= ITEM_COUNT
        if st.get_quest_items_count(HATE_CRYSTAL) >= ITEM_COUNT
          if st.get_quest_items_count(OLD_TREASURE_MAP) >= ITEM_COUNT
            st.set_cond(4, true)
          end
        end
      end
    end

    super
  end

  def on_talk(npc, pc)
    st = get_quest_state!(pc)

    case npc.id
    when SHEGFIELD
      case st.state
      when State::CREATED
        html = pc.level >= MIN_LEVEL ? "30068-01.htm" : "30068-02.htm"
      when State::STARTED
        case st.cond
        when 1
          st.set_cond(2, true)
          html = "30068-04.html"
        when 2, 3
          html = "30068-05.html"
        when 4
          html = "30068-06.html"
        when 5
          if st.set?("talk")
            html = "30068-08.html"
          elsif st.has_quest_items?(PANOS_CREDENTIALS, SONINS_CREDENTIALS, ALEXS_CREDENTIALS)
            st.take_items(SONINS_CREDENTIALS, -1)
            st.take_items(PANOS_CREDENTIALS, -1)
            st.take_items(ALEXS_CREDENTIALS, -1)
            st.set("talk", "1")
            html = "30068-07.html"
          else
            html = "30068-06.html"
          end
        end
      when State::COMPLETED
        html = get_already_completed_msg(pc)
      end
    when ALEX
      if st.started?
        case st.cond
        when 1
          html = "30291-01.html"
        when 2
          if st.set?("talk")
            html = "30291-03.html"
          else
            st.set("talk", "1")
            html = "30291-02.html"
          end
        when 3
          html = "30291-08.html"; # 4
        when 4
          if st.has_quest_items?(PANOS_CREDENTIALS, SONINS_CREDENTIALS)
            if st.get_quest_items_count(OLD_TREASURE_MAP) < ITEM_COUNT
              return get_no_quest_msg(pc)
            end
            st.set_cond(5, true)
            st.take_items(OLD_TREASURE_MAP, -1)
            st.give_items(ALEXS_CREDENTIALS, 1)
            html = "30291-10.html"
          else
            html = "30291-09.html"
          end
        when 5
          html = "30291-11.html"
        end
      end
    when PANO
      if st.started?
        case st.cond
        when 1
          html = "30078-01.html"
        when 2
          html = "30078-02.html"
        when 3
          html = "30078-03.html"
        when 4
          unless st.set?("Pano")
            if st.get_quest_items_count(HATE_CRYSTAL) < ITEM_COUNT
              return get_no_quest_msg(pc)
            end
            st.take_items(HATE_CRYSTAL, -1)
            st.give_items(PANOS_CREDENTIALS, 1)
            st.set("Pano", "1")
            html = "30078-04.html"
          end
        when 5
          html = "30078-05.html"
        end
      end
    when SONIN
      if st.started?
        case st.cond
        when 1
          html = "31773-01.html"
        when 2
          html = "31773-02.html"
        when 3
          html = "31773-03.html"
        when 4
          unless st.set?("Sonin")
            if st.get_quest_items_count(STOLEN_CARGO) < ITEM_COUNT
              return get_no_quest_msg(pc)
            end
            st.take_items(STOLEN_CARGO, -1)
            st.give_items(SONINS_CREDENTIALS, 1)
            st.set("Sonin", "1")
            html = "31773-04.html"
          end
        when 5
          html = "31773-05.html"
        end
      end
    end

    html || get_no_quest_msg(pc)
  end
end
