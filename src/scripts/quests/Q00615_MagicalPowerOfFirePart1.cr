class Scripts::Q00615_MagicalPowerOfFirePart1 < Quest
  # NPCs
  private NARAN = 31378
  private UDAN = 31379
  private ASEFA_BOX = 31559
  private ASEFA_EYE = 31684
  # Monsters
  private KETRA_MOBS = {
    21324, # Ketra Orc Footman
    21325, # Ketra's War Hound
    21327, # Ketra Orc Raider
    21328, # Ketra Orc Scout
    21329, # Ketra Orc Shaman
    21331, # Ketra Orc Warrior
    21332, # Ketra Orc Lieutenant
    21334, # Ketra Orc Medium
    21335, # Ketra Orc Elite Soldier
    21336, # Ketra Orc White Captain
    21338, # Ketra Orc Seer
    21339, # Ketra Orc General
    21340, # Ketra Orc Battalion Commander
    21342, # Ketra Orc Grand Seer
    21343, # Ketra Commander
    21344, # Ketra Elite Guard
    21345, # Ketra's Head Shaman
    21346, # Ketra's Head Guard
    21347, # Ketra Prophet
    21348, # Prophet's Guard
    21349  # Prophet's Aide
  }
  # Items
  private KEY = 1661
  private STOLEN_RED_TOTEM = 7242
  private WISDOM_STONE = 7081
  private RED_TOTEM = 7243
  private VARKA_MARKS = {
    7221, # Mark of Varka's Alliance - Level 1
    7222, # Mark of Varka's Alliance - Level 2
    7223, # Mark of Varka's Alliance - Level 3
    7224, # Mark of Varka's Alliance - Level 4
    7225  # Mark of Varka's Alliance - Level 5
  }
  # Skills
  private GOW = SkillHolder.new(4547) # Gaze of Watcher
  private DISPEL_GOW = SkillHolder.new(4548) # Quest - Dispel Watcher Gaze
  # Misc
  private MIN_LEVEL = 74

  def initialize
    super(615, self.class.simple_name, "Magical Power of Fire - Part 1")

    add_start_npc(NARAN)
    add_talk_id(UDAN, NARAN, ASEFA_BOX)
    add_attack_id(KETRA_MOBS)
    register_quest_items(STOLEN_RED_TOTEM)
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    unless st = get_quest_state(pc, false)
      return
    end

    case event
    when "31378-02.html"
      st.start_quest
      html = event
    when "open_box"
      if !st.has_quest_items?(KEY)
        html = "31559-02.html"
      elsif st.cond?(2)
        if st.set?("spawned")
          st.take_items(KEY, 1)
          html = "31559-04.html"
        else
          st.give_items(STOLEN_RED_TOTEM, 1)
          st.take_items(KEY, 1)
          st.set_cond(3, true)
          html = "31559-03.html"
        end
      end
    when "eye_despawn"
      npc = npc.not_nil!
      npc.broadcast_packet(NpcSay.new(npc, Say2::NPC_ALL, NpcString::ASEFA_HAS_ALREADY_SEEN_YOUR_FACE))
      npc.delete_me
    end

    html
  end

  def on_attack(npc, attacker, damage, is_summon)
    st = get_quest_state(attacker, false)
    if st && st.cond?(2) && !st.set?("spawned")
      st.set("spawned", "1")
      npc.target = attacker
      npc.do_cast(GOW)
      eye = add_spawn(ASEFA_EYE, npc)
      eye.broadcast_packet(NpcSay.new(eye, Say2::NPC_ALL, NpcString::YOU_CANT_AVOID_THE_EYES_OF_ASEFA))
      start_quest_timer("eye_despawn", 10000, eye, attacker)
    end

    super
  end

  def on_talk(npc, pc)
    st = get_quest_state!(pc)
    case npc.id
    when NARAN
      case st.state
      when State::CREATED
        if pc.level >= MIN_LEVEL
          if has_at_least_one_quest_item?(pc, VARKA_MARKS)
            html = "31378-01.htm"
          else
            html = "31378-00a.html"
          end
        else
          html = "31378-00b.html"
        end
      when State::STARTED
        if st.cond?(1)
          html = "31378-03.html"
        end
      end
    when UDAN
      if st.started?
        case st.cond
        when 1
          html = "31379-01.html"
          st.set_cond(2, true)
        when 2
          if st.set?("spawned")
            st.unset("spawned")
            npc.target = pc
            npc.do_cast(DISPEL_GOW.skill)
            html = "31379-03.html"
          else
            html = "31379-02.html"
          end
        when 3
          st.give_items(RED_TOTEM, 1)
          st.give_items(WISDOM_STONE, 1)
          st.exit_quest(true, true)
          html = "31379-04.html"
        end
      end
    when ASEFA_BOX
      if st.cond?(2)
        html = "31559-01.html"
      end
    end

    html || get_no_quest_msg(pc)
  end
end
