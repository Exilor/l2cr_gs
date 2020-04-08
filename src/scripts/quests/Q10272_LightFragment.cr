class Scripts::Q10272_LightFragment < Quest
  private ORBYU = 32560
  private ARTIUS = 32559
  private GINBY = 32566
  private LELRIKIA = 32567
  private LEKON = 32557
  private MOBS = {
    22536, # Royal Guard Captain
    22537, # Dragon Steed Troop Grand Magician
    22538, # Dragon Steed Troop Commander
    22539, # Dragon Steed Troops No 1 Battalion Commander
    22540, # White Dragon Leader
    22541, # Dragon Steed Troop Infantry
    22542, # Dragon Steed Troop Magic Leader
    22543, # Dragon Steed Troop Magician
    22544, # Dragon Steed Troop Magic Soldier
    22547, # Dragon Steed Troop Healer
    22550, # Savage Warrior
    22551, # Priest of Darkness
    22552, # Mutation Drake
    22596  # White Dragon Leader
  }
  private FRAGMENT_POWDER = 13853
  private LIGHT_FRAGMENT_POWDER = 13854
  private LIGHT_FRAGMENT = 13855
  private DROP_CHANCE = 60

  def initialize
    super(10272, self.class.simple_name, "Light Fragment")

    add_start_npc(ORBYU)
    add_talk_id(ORBYU, ARTIUS, GINBY, LELRIKIA, LEKON)
    add_kill_id(MOBS)
    register_quest_items(FRAGMENT_POWDER, LIGHT_FRAGMENT_POWDER)
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    unless st = get_quest_state(pc, false)
      return get_no_quest_msg(pc)
    end

    case event
    when "32560-06.html"
      st.start_quest
    when "32559-03.html"
      st.set_cond(2, true)
    when "32559-07.html"
      st.set_cond(3, true)
    when "pay"
      if st.get_quest_items_count(Inventory::ADENA_ID) >= 10000
        st.take_items(Inventory::ADENA_ID, 10000)
        event = "32566-05.html"
      else
        event = "32566-04a.html"
      end
    when "32567-04.html"
      st.set_cond(4, true)
    when "32559-12.html"
      st.set_cond(5, true)
    when "32557-03.html"
      if st.get_quest_items_count(LIGHT_FRAGMENT_POWDER) >= 100
        st.take_items(LIGHT_FRAGMENT_POWDER, 100)
        st.set("wait", "1")
      else
        event = "32557-04.html"
      end
    else
      # automatically added
    end


    event
  end

  def on_kill(npc, pc, is_summon)
    st = get_quest_state(pc, false)
    if st && st.cond?(5)
      count = st.get_quest_items_count(FRAGMENT_POWDER)
      if count < 100
        chance = (Config.rate_quest_drop * DROP_CHANCE).to_i
        num_items = chance // 100
        chance = chance % 100
        if Rnd.rand(100) < chance
          num_items += 1
        end
        if num_items > 0
          if count + num_items > 100
            num_items = 100 - count.to_i
          end
          if num_items > 0
            st.give_items(FRAGMENT_POWDER, num_items)
            st.play_sound(Sound::ITEMSOUND_QUEST_ITEMGET)
          end
        end
      end
    end

    nil
  end

  def on_talk(npc, pc)
    st = get_quest_state!(pc)

    case npc.id
    when ORBYU
      case st.state
      when State::CREATED
        if pc.level < 75
          html = "32560-03.html"
        else
          if pc.quest_completed?(Q10271_TheEnvelopingDarkness.simple_name)
            html = "32560-01.htm"
          else
            html = "32560-02.html"
          end
        end
      when State::STARTED
        html = "32560-06.html"
      when State::COMPLETED
        html = "32560-04.html"
      else
        # automatically added
      end

    when ARTIUS
      if st.completed?
        html = "32559-19.html"
      else
        case st.cond
        when 1
          html = "32559-01.html"
        when 2
          html = "32559-04.html"
        when 3
          html = "32559-08.html"
        when 4
          html = "32559-10.html"
        when 5
          if st.get_quest_items_count(FRAGMENT_POWDER) >= 100
            html = "32559-15.html"
            st.set_cond(6, true)
          else
            if st.has_quest_items?(FRAGMENT_POWDER)
              html = "32559-14.html"
            else
              html = "32559-13.html"
            end
          end
        when 6
          if st.get_quest_items_count(LIGHT_FRAGMENT_POWDER) < 100
            html = "32559-16.html"
          else
            html = "32559-17.html"
            st.set_cond(7, true)
          end
        when 7
          # TODO Nothing here?
        when 8
          html = "32559-18.html"
          st.give_adena(556980, true)
          st.add_exp_and_sp(1009016, 91363)
          st.exit_quest(false, true)
        else
          # automatically added
        end

      end
    when GINBY
      case st.cond
      when 1, 2
        html = "32566-02.html"
      when 3
        html = "32566-01.html"
      when 4
        html = "32566-09.html"
      when 5
        html = "32566-10.html"
      when 6
        html = "32566-10.html"
      else
        # automatically added
      end

    when LELRIKIA
      case st.cond
      when 3
        html = "32567-01.html"
      when 4
        html = "32567-05.html"
      else
        # automatically added
      end

    when LEKON
      case st.cond
      when 7
        if st.get_int("wait") == 1
          html = "32557-05.html"
          st.unset("wait")
          st.set_cond(8, true)
          st.give_items(LIGHT_FRAGMENT, 1)
        else
          html = "32557-01.html"
        end
      when 8
        html = "32557-06.html"
      else
        # automatically added
      end

    else
      # automatically added
    end


    html || get_no_quest_msg(pc)
  end
end