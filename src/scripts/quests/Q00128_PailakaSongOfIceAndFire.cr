class Scripts::Q00128_PailakaSongOfIceAndFire < Quest
  # NPCs
  private ADLER1 = 32497
  private ADLER2 = 32510
  private SINAI = 32500
  private INSPECTOR = 32507
  private HILLAS = 18610
  private PAPION = 18609
  private KINSUS = 18608
  private GARGOS = 18607
  private ADIANTUM = 18620
  # Items
  private SWORD = 13034
  private ENH_SWORD1 = 13035
  private ENH_SWORD2 = 13036
  private BOOK1 = 13130
  private BOOK2 = 13131
  private BOOK3 = 13132
  private BOOK4 = 13133
  private BOOK5 = 13134
  private BOOK6 = 13135
  private BOOK7 = 13136
  private WATER_ESSENCE = 13038
  private FIRE_ESSENCE = 13039
  private SHIELD_POTION = 13032
  private HEAL_POTION = 13033
  private FIRE_ENHANCER = 13040
  private WATER_ENHANCER = 13041
  private REWARDS = {
    13294, # Pailaka Ring
    13293, # Pailaka Earring
    736    # Scroll of Escape
  }
  # Skills
  private VITALITY_REPLENISHING = SkillHolder.new(5774)
  # Misc
  private MIN_LEVEL = 36
  private MAX_LEVEL = 42
  private EXIT_TIME = 5

  def initialize
    super(128, self.class.simple_name, "Pailaka - Song of Ice and Fire")

    add_start_npc(ADLER1)
    add_talk_id(ADLER1, ADLER2, SINAI, INSPECTOR)
    add_kill_id(HILLAS, PAPION, KINSUS, GARGOS, ADIANTUM)
    register_quest_items(
      SWORD, ENH_SWORD1, ENH_SWORD2, BOOK1, BOOK2, BOOK3, BOOK4, BOOK5, BOOK6,
      BOOK7, WATER_ESSENCE, FIRE_ESSENCE, SHIELD_POTION, HEAL_POTION,
      FIRE_ENHANCER, WATER_ENHANCER
    )
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    unless st = get_quest_state(pc, false)
      return get_no_quest_msg(pc)
    end

    case event
    when "32500-02.htm", "32500-03.htm", "32500-04.htm", "32500-05.htm",
         "32497-02.htm", "32507-07.htm", "32497-04.htm"
      html = event
    when "32497-03.htm"
      unless st.started?
        st.start_quest
        html = event
      end
    when "32500-06.htm"
      if st.cond?(1)
        st.set_cond(2, true)
        give_items(pc, SWORD, 1)
        give_items(pc, BOOK1, 1)
        html = event
      end
    when "32507-04.htm"
      if st.cond?(3)
        st.set_cond(4, true)
        take_items(pc, SWORD, -1)
        take_items(pc, WATER_ESSENCE, -1)
        take_items(pc, BOOK2, -1)
        give_items(pc, BOOK3, 1)
        give_items(pc, ENH_SWORD1, 1)
        html = event
      end
    when "32507-08.htm"
      if st.cond?(6)
        st.set_cond(7, true)
        take_items(pc, ENH_SWORD1, -1)
        take_items(pc, BOOK5, -1)
        take_items(pc, FIRE_ESSENCE, -1)
        give_items(pc, ENH_SWORD2, 1)
        give_items(pc, BOOK6, 1)
        html = event
      end
    when "32510-02.htm"
      npc = npc.not_nil!
      st.exit_quest(false, true)

      unless inst = InstanceManager.get_instance(npc.instance_id)
        raise "Instance with id #{npc.instance_id} not found."
      end
      inst.duration = EXIT_TIME * 60000
      inst.empty_destroy_time = 0

      if inst.includes?(pc.l2id)
        npc.target = pc
        npc.do_cast(VITALITY_REPLENISHING)
        add_exp_and_sp(pc, 810000, 50000)
        REWARDS.each do |id|
          give_items(pc, id, 1)
        end
      end
      html = event
    end


    html
  end

  def on_talk(npc, pc)
    st = get_quest_state!(pc)
    case npc.id
    when ADLER1
      case st.state
      when State::CREATED
        if pc.level < MIN_LEVEL
          html = "32497-05.htm"
        elsif pc.level > MAX_LEVEL
          html = "32497-06.htm"
        else
          html = "32497-01.htm"
        end
      when State::STARTED
        if st.cond > 1
          html = "32497-00.htm"
        else
          html = "32497-03.htm"
        end
      when State::COMPLETED
        html = "32497-07.htm"
      else
        html = "32497-01.htm"
      end
    when SINAI
      if st.cond > 1
        html = "32500-00.htm"
      else
        html = "32500-01.htm"
      end
    when INSPECTOR
      case st.cond
      when 1
        html = "32507-01.htm"
      when 2
        html = "32507-02.htm"
      when 3
        html = "32507-03.htm"
      when 4, 5
        html = "32507-05.htm"
      when 6
        html = "32507-06.htm"
      else
        html = "32507-09.htm"
      end
    when ADLER2
      if st.completed?
        html = "32510-00.htm"
      elsif st.cond?(9)
        html = "32510-01.htm"
      end
    end


    html || get_no_quest_msg(pc)
  end

  def on_kill(npc, pc, is_summon)
    st = get_quest_state(pc, false)
    if st && st.started?
      case npc.id
      when HILLAS
        if st.cond?(2)
          st.set_cond(3)
          play_sound(pc, Sound::ITEMSOUND_QUEST_ITEMGET)
          take_items(pc, BOOK1, -1)
          give_items(pc, BOOK2, 1)
          give_items(pc, WATER_ESSENCE, 1)
        end
        add_spawn(PAPION, -53903, 181484, -4555, 30456, false, 0, false, npc.instance_id)
      when PAPION
        if st.cond?(4)
          st.set_cond(5)
          take_items(pc, BOOK3, -1)
          give_items(pc, BOOK4, 1)
          play_sound(pc, Sound::ITEMSOUND_QUEST_ITEMGET)
        end
        add_spawn(KINSUS, -61415, 181418, -4818, 63852, false, 0, false, npc.instance_id)
      when KINSUS
        if st.cond?(5)
          st.set_cond(6)
          play_sound(pc, Sound::ITEMSOUND_QUEST_ITEMGET)
          take_items(pc, BOOK4, -1)
          give_items(pc, BOOK5, 1)
          give_items(pc, FIRE_ESSENCE, 1)
        end
        add_spawn(GARGOS, -61354, 183624, -4821, 63613, false, 0, false, npc.instance_id)
      when GARGOS
        if st.cond?(7)
          st.set_cond(8)
          play_sound(pc, Sound::ITEMSOUND_QUEST_ITEMGET)
          take_items(pc, BOOK6, -1)
          give_items(pc, BOOK7, 1)
        end
        add_spawn(ADIANTUM, -53297, 185027, -4617, 1512, false, 0, false, npc.instance_id)
      when ADIANTUM
        if st.cond?(8)
          st.set_cond(9)
          play_sound(pc, Sound::ITEMSOUND_QUEST_MIDDLE)
          take_items(pc, BOOK7, -1)
          add_spawn(ADLER2, -53297, 185027, -4617, 33486, false, 0, false, npc.instance_id)
        end
      end

    end

    super
  end
end
