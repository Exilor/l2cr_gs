class Scripts::Q00609_MagicalPowerOfWaterPart1 < Quest
  # NPCs
  private WAHKAN = 31371
  private ASEFA = 31372
  private UDANS_BOX = 31561
  private UDANS_EYE = 31684
  # Monsters
  private VARKA_MOBS = {
    21350, # Varka Silenos Recruit
    21351, # Varka Silenos Footman
    21353, # Varka Silenos Scout
    21354, # Varka Silenos Hunter
    21355, # Varka Silenos Shaman
    21357, # Varka Silenos Priest
    21358, # Varka Silenos Warrior
    21360, # Varka Silenos Medium
    21361, # Varka Silenos Magus
    21362, # Varka Silenos Officer
    21364, # Varka Silenos Seer
    21365, # Varka Silenos Great Magus
    21366, # Varka Silenos General
    21368, # Varka Silenos Great Seer
    21369, # Varka's Commander
    21370, # Varka's Elite Guard
    21371, # Varka's Head Magus
    21372, # Varka's Head Guard
    21373, # Varka's Prophet
    21374, # Prophet's Guard
    21375  # Disciple of Prophet
  }
  # Items
  private KEY = 1661
  private STOLEN_GREEN_TOTEM = 7237
  private WISDOM_STONE = 7081
  private GREEN_TOTEM = 7238
  private KETRA_MARKS = {
    7211, # Mark of Ketra's Alliance - Level 1
    7212, # Mark of Ketra's Alliance - Level 2
    7213, # Mark of Ketra's Alliance - Level 3
    7214, # Mark of Ketra's Alliance - Level 4
    7215  # Mark of Ketra's Alliance - Level 5
  }
  # Skills
  private GOW = SkillHolder.new(4547) # Gaze of Watcher
  private DISPEL_GOW = SkillHolder.new(4548) # Quest - Dispel Watcher Gaze
  # Misc
  private MIN_LEVEL = 74

  def initialize
    super(609, self.class.simple_name, "Magical Power of Water - Part 1")

    add_start_npc(WAHKAN)
    add_talk_id(ASEFA, WAHKAN, UDANS_BOX)
    add_attack_id(VARKA_MOBS)
    register_quest_items(STOLEN_GREEN_TOTEM)
  end

  def on_adv_event(event, npc, pc)
    pc = pc.not_nil!
    unless st = get_quest_state(pc, false)
      return
    end

    case event
    when "31371-02.html"
      st.start_quest
      html = event
    when "open_box"
      if !st.has_quest_items?(KEY)
        html = "31561-02.html"
      elsif st.cond?(2)
        if st.set?("spawned")
          st.take_items(KEY, 1)
          html = "31561-04.html"
        else
          st.give_items(STOLEN_GREEN_TOTEM, 1)
          st.take_items(KEY, 1)
          st.set_cond(3, true)
          html = "31561-03.html"
        end
      end
    when "eye_despawn"
      npc = npc.not_nil!
      npc.broadcast_packet(NpcSay.new(npc, Say2::NPC_ALL, NpcString::UDAN_HAS_ALREADY_SEEN_YOUR_FACE))
      npc.delete_me
    else
      # [automatically added else]
    end


    html
  end

  def on_attack(npc, attacker, damage, is_summon)
    st = get_quest_state(attacker, false)
    if st && st.cond?(2) && !st.set?("spawned")
      st.set("spawned", "1")
      npc.target = attacker
      npc.do_cast(GOW)
      eye = add_spawn(UDANS_EYE, npc)
      eye.broadcast_packet(NpcSay.new(eye, Say2::NPC_ALL, NpcString::YOU_CANT_AVOID_THE_EYES_OF_UDAN))
      start_quest_timer("eye_despawn", 10000, eye, attacker)
    end

    super
  end

  def on_talk(npc, pc)
    st = get_quest_state!(pc)
    case npc.id
    when WAHKAN
      case st.state
      when State::CREATED
        if pc.level >= MIN_LEVEL
          if has_at_least_one_quest_item?(pc, KETRA_MARKS)
            html = "31371-01.htm"
          else
            html = "31371-00a.html"
          end
        else
          html = "31371-00b.html"
        end
      when State::STARTED
        if st.cond?(1)
          html = "31371-03.html"
        end
      else
        # [automatically added else]
      end

    when ASEFA
      if st.started?
        case st.cond
        when 1
          html = "31372-01.html"
          st.set_cond(2, true)
        when 2
          if st.set?("spawned")
            st.unset("spawned")
            npc.target = pc
            npc.do_cast(DISPEL_GOW)
            html = "31372-03.html"
          else
            html = "31372-02.html"
          end
        when 3
          st.give_items(GREEN_TOTEM, 1)
          st.give_items(WISDOM_STONE, 1)
          st.exit_quest(true, true)
          html = "31372-04.html"
        else
          # [automatically added else]
        end

      end
    when UDANS_BOX
      if st.cond?(2)
        html = "31561-01.html"
      end
    else
      # [automatically added else]
    end


    html || get_no_quest_msg(pc)
  end
end
