class Scripts::Q10275_ContainingTheAttributePower < Quest
  # NPCs
  private HOLLY = 30839
  private WEBER = 31307
  private YIN = 32325
  private YANG = 32326
  private WATER = 27380
  private AIR = 27381
  # Items
  private YINSWORD = 13845
  private YANGSWORD = 13881
  private SOULPIECE_WATER = 13861
  private SOULPIECE_AIR = 13862
  # Skills
  private BLESSING_OF_FIRE = SkillHolder.new(2635, 1)
  private BLESSING_OF_EARTH = SkillHolder.new(2636, 1)

  def initialize
    super(10275, self.class.simple_name, "Containing the Attribute Power")

    add_start_npc(HOLLY, WEBER)
    add_talk_id(HOLLY, WEBER, YIN, YANG)
    add_kill_id(AIR, WATER)
    register_quest_items(YINSWORD, YANGSWORD, SOULPIECE_WATER, SOULPIECE_AIR)
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    html = event
    unless st = get_quest_state(pc, false)
      return html
    end

    case event
    when "30839-02.html", "31307-02.html"
      st.start_quest
    when "30839-05.html"
      st.set_cond(2, true)
    when "31307-05.html"
      st.set_cond(7, true)
    when "32325-03.html"
      st.set_cond(3, true)
      st.give_items(YINSWORD, 1, AttributeType::FIRE.id.to_i32, 10)
    when "32326-03.html"
      st.set_cond(8, true)
      st.give_items(YANGSWORD, 1, AttributeType::EARTH.id.to_i32, 10)
    when "32325-06.html"
      if st.has_quest_items?(YINSWORD)
        st.take_items(YINSWORD, 1)
        html = "32325-07.html"
      end
      st.give_items(YINSWORD, 1, AttributeType::FIRE.id.to_i32, 10)
    when "32326-06.html"
      if st.has_quest_items?(YANGSWORD)
        st.take_items(YANGSWORD, 1)
        html = "32326-07.html"
      end
      st.give_items(YANGSWORD, 1, AttributeType::EARTH.id.to_i32, 10)
    when "32325-09.html"
      st.set_cond(5, true)
      BLESSING_OF_FIRE.skill.apply_effects(pc, pc)
      st.give_items(YINSWORD, 1, AttributeType::FIRE.id.to_i32, 10)
    when "32326-09.html"
      st.set_cond(10, true)
      BLESSING_OF_EARTH.skill.apply_effects(pc, pc)
      st.give_items(YANGSWORD, 1, AttributeType::EARTH.id.to_i32, 10)
    end

    if event.num?
      html = "#{npc.not_nil!.id}-1#{event}.html"
      st.give_items(10520 + event.to_i, 2)
      st.add_exp_and_sp(202160, 20375)
      st.exit_quest(false, true)
    end

    html
  end

  def on_kill(npc, pc, is_summon)
    unless st = get_quest_state(pc, false)
      return
    end

    case npc.id
    when AIR
      if st.cond?(8) || st.cond?(10)
        if st.get_item_equipped(Inventory::RHAND) == YANGSWORD
          if st.get_quest_items_count(SOULPIECE_AIR) < 6 && Rnd.rand(100) < 30
            st.give_items(SOULPIECE_AIR, 1)
            if st.get_quest_items_count(SOULPIECE_AIR) >= 6
              st.set_cond(st.cond + 1, true)
            else
              st.play_sound(Sound::ITEMSOUND_QUEST_ITEMGET)
            end
          end
        end
      end
    when WATER
      if st.cond >= 3 || st.cond <= 5
        if st.get_item_equipped(Inventory::RHAND) == YINSWORD
          if st.get_quest_items_count(SOULPIECE_WATER) < 6 && Rnd.rand(100) < 30
            st.give_items(SOULPIECE_WATER, 1)
            if st.get_quest_items_count(SOULPIECE_WATER) >= 6
              st.set_cond(st.cond + 1, true)
            else
              st.play_sound(Sound::ITEMSOUND_QUEST_ITEMGET)
            end
          end
        end
      end
    end

    nil
  end

  def on_talk(npc, pc)
    st = get_quest_state!(pc)

    case npc.id
    when HOLLY
      case st.state
      when State::CREATED
        html = pc.level > 75 ? "30839-01.htm" : "30839-00.html"
      when State::STARTED
        case st.cond
        when 1
          html = "30839-03.html"
        when 2
          html = "30839-05.html"
        end
      when State::COMPLETED
        html = "30839-0a.html"
      end
    when WEBER
      case st.state
      when State::CREATED
        html = pc.level > 75 ? "31307-01.htm" : "31307-00.html"
      when State::STARTED
        case st.cond
        when 1
          html = "31307-03.html"
        when 7
          html = "31307-05.html"
        end
      when State::COMPLETED
        html = "31307-0a.html"
      end
    when YIN
      if st.started?
        case st.cond
        when 2
          html = "32325-01.html"
        when 3, 5
          html = "32325-04.html"
        when 4
          html = "32325-08.html"
          st.take_items(YINSWORD, 1)
          st.take_items(SOULPIECE_WATER, -1)
        when 6
          html = "32325-10.html"
        end
      end
    when YANG
      if st.started?
        case st.cond
        when 7
          html = "32326-01.html"
        when 8, 10
          html = "32326-04.html"
        when 9
          html = "32326-08.html"
          st.take_items(YANGSWORD, 1)
          st.take_items(SOULPIECE_AIR, -1)
        when 11
          html = "32326-10.html"
        end
      end
    end

    html || get_no_quest_msg(pc)
  end
end
