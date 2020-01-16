class Scripts::Q00129_PailakaDevilsLegacy < Quest
  # NPCs
  private KAMS = 18629 # Kams (Panuka)
  private ALKASO = 18631 # Alkaso (Panuka)
  private LEMATAN = 18633 # Lematan
  private SURVIVOR = 32498 # Devil's Isle Survivor
  private SUPPORTER = 32501 # Devil's Isle Supporter
  private ADVENTURER1 = 32508 # Dwarf Adventurer
  private ADVENTURER2 = 32511 # Dwarf Adventurer
  # Items
  private SWORD = 13042 # Ancient Legacy Sword
  private ENH_SWORD1 = 13043 # Enhanced Ancient Legacy Sword
  private ENH_SWORD2 = 13044 # Complete Ancient Legacy Sword
  private SCROLL_1 = 13046 # Pailaka Weapon Upgrade Stage 1
  private SCROLL_2 = 13047 # Pailaka Weapon Upgrade Stage 2
  private SHIELD = 13032 # Pailaka Instant Shield
  private HEALING_POTION = 13033 # Quick Healing Potion
  private ANTIDOTE_POTION = 13048 # Pailaka Antidote
  private DIVINE_POTION = 13049 # Divine Soul
  private DEFENCE_POTION = 13059 # Long-Range Defense Increasing Potion
  private PAILAKA_KEY = 13150 # Pailaka All-Purpose Key
  private BRACELET = 13295 # Pailaka Bracelet
  private ESCAPE = 736 # Scroll of Escape
  # Skills
  private VITALITY_REPLENISHING = SkillHolder.new(5774, 2) # Pailaka Reward Vitality Replenishing
  # Misc
  private MIN_LEVEL = 61
  private MAX_LEVEL = 67
  private EXIT_TIME = 5

  def initialize
    super(129, self.class.simple_name, "Pailaka - Devil's Legacy")

    add_start_npc(SURVIVOR)
    add_first_talk_id(SURVIVOR, SUPPORTER, ADVENTURER1, ADVENTURER2)
    add_talk_id(SURVIVOR, SUPPORTER, ADVENTURER1, ADVENTURER2)
    add_kill_id(KAMS, ALKASO, LEMATAN)
    register_quest_items(SWORD, ENH_SWORD1, ENH_SWORD2, SCROLL_1, SCROLL_2, SHIELD, HEALING_POTION, ANTIDOTE_POTION, DIVINE_POTION, DEFENCE_POTION, PAILAKA_KEY)
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    unless qs = get_quest_state(pc, false)
      return get_no_quest_msg(pc)
    end

    case event
    when "32498-02.htm", "32498-03.htm", "32498-04.htm"
      html = event
    when "32498-05.htm"
      unless qs.started?
        html = event
        qs.start_quest
      end
    when "32501-02.htm", "32501-04.htm"
      html = event
    when "32501-03.htm"
      if qs.cond?(2)
        give_items(pc, SWORD, 1)
        qs.set_cond(3, true)
        html = event
      end
    end

    html
  end

  def on_first_talk(npc, pc)
    qs = get_quest_state(pc, false)
    if npc.id != ADVENTURER2 || (qs.nil? || !qs.completed?)
      return "#{npc.id}.htm"
    end

    "32511-03.htm"
  end

  def on_talk(npc, pc)
    qs = get_quest_state!(pc)

    case npc.id
    when SURVIVOR
      case qs.state
      when State::CREATED
        if pc.level < MIN_LEVEL
          html = "32498-11.htm"
        elsif pc.level > MAX_LEVEL
          html = "32498-12.htm"
        else
          html = "32498-01.htm"
        end
      when State::STARTED
        if qs.cond > 1
          html = "32498-08.htm"
        else
          html = "32498-06.htm"
        end
      when State::COMPLETED
        html = "32498-10.htm"
      else
        html = "32498-01.htm"
      end
    when SUPPORTER
      if qs.cond > 2
        html = "32501-04.htm"
      else
        html = "32501-01.htm"
      end
    when ADVENTURER1
      if pc.has_summon?
        html = "32508-07.htm"
      elsif has_quest_items?(pc, SWORD)
        if has_quest_items?(pc, SCROLL_1)
          take_items(pc, SWORD, -1)
          take_items(pc, SCROLL_1, -1)
          give_items(pc, ENH_SWORD1, 1)
          html = "32508-03.htm"
        else
          html = "32508-02.htm"
        end
      elsif has_quest_items?(pc, ENH_SWORD1)
        if has_quest_items?(pc, SCROLL_2)
          take_items(pc, ENH_SWORD1, -1)
          take_items(pc, SCROLL_2, -1)
          give_items(pc, ENH_SWORD2, 1)
          html = "32508-05.htm"
        end
        html = "32508-04.htm"
      elsif has_quest_items?(pc, ENH_SWORD2)
        html = "32508-06.htm"
      else
        html = "32508-00.htm"
      end
    when ADVENTURER2
      if pc.has_summon?
        html = "32511-02.htm"
      else
        inst = InstanceManager.get_instance(npc.instance_id).not_nil!
        qs.exit_quest(false, true)
        inst.duration = EXIT_TIME * 60000
        inst.empty_destroy_time = 0
        if inst.includes?(pc.l2id)
          npc.target = pc
          npc.do_cast(VITALITY_REPLENISHING)
          add_exp_and_sp(pc, 10800000, 950000)
          reward_items(pc, BRACELET, 1)
          reward_items(pc, ESCAPE, 1)
        # else
          # custom: else commented out. From the contents of the html it seems
          # it has to be this way.
          html = "32511-01.htm"
        end
      end
    end

    html || get_no_quest_msg(pc)
  end

  def on_kill(npc, pc, is_summon)
    qs = get_quest_state(pc, false)

    if qs && qs.started?
      case npc.id
      when KAMS
        if has_quest_items?(pc, SWORD)
          give_items(pc, SCROLL_1, 1)
          play_sound(pc, Sound::ITEMSOUND_QUEST_ITEMGET)
        end
      when ALKASO
        if has_quest_items?(pc, ENH_SWORD1)
          give_items(pc, SCROLL_2, 1)
          play_sound(pc, Sound::ITEMSOUND_QUEST_ITEMGET)
        end
      when LEMATAN
        if qs.cond?(3)
          qs.set_cond(4, true)
        end
      end
    end

    super
  end
end
