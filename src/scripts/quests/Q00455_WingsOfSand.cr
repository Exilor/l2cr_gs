class Scripts::Q00455_WingsOfSand < Quest
  # NPCs
  private SEPARATED_SOULS = {
    32864,
    32865,
    32866,
    32867,
    32868,
    32869,
    32870,
    32891
  }
  # Monsters
  private EMERALD_HORN = 25718
  private DUST_RIDER = 25719
  private BLEEDING_FLY = 25720
  private BLACK_DAGGER_WING = 25721
  private SHADOW_SUMMONER = 25722
  private SPIKE_SLASHER = 25723
  private MUSCLE_BOMBER = 25724
  # Item
  private LARGE_BABY_DRAGON = 17250
  private ARMOR_PARTS = {
    15660, 15661, 15662, 15663, 15664, 15665, 15666, 15667, 15668, 15669, 15670,
    15671, 15672, 15673, 15674, 15675, 15691
  }
  # Misc
  private MIN_LEVEL = 80
  private CHANCE = 350

  def initialize
    super(455, self.class.simple_name, "Wings of Sand")

    add_start_npc(SEPARATED_SOULS)
    add_talk_id(SEPARATED_SOULS)
    add_kill_id(
      EMERALD_HORN, DUST_RIDER, BLEEDING_FLY, BLACK_DAGGER_WING,
      SHADOW_SUMMONER, SPIKE_SLASHER, MUSCLE_BOMBER
    )
    register_quest_items(LARGE_BABY_DRAGON)
  end

  def action_for_each_player(pc, npc, is_summon)
    st = get_quest_state(pc, false)
    if st && Util.in_range?(1500, npc, pc, false) && Rnd.rand(1000) < CHANCE
      st.give_items(LARGE_BABY_DRAGON, 1)
      st.play_sound(Sound::ITEMSOUND_QUEST_ITEMGET)
      if st.get_quest_items_count(LARGE_BABY_DRAGON) == 1
        st.set_cond(2, true)
      elsif st.get_quest_items_count(LARGE_BABY_DRAGON) == 2
        st.set_cond(3, true)
      end
    end
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    unless st = get_quest_state(pc, false)
      return
    end

    if pc.level >= MIN_LEVEL
      case event
      when "32864-02.htm", "32864-03.htm", "32864-04.htm"
        html = event
      when "32864-05.htm"
        st.start_quest
        html = event
      end

    end

    html
  end

  def on_kill(npc, killer, is_summon)
    execute_for_each_player(killer, npc, is_summon, true, false)
    super
  end

  def on_talk(npc, pc)
    st = get_quest_state!(pc)

    case st.state
    when State::CREATED
      if pc.level >= MIN_LEVEL
        html = "32864-01.htm"
      end
    when State::STARTED
      case st.cond
      when 1
        html = "32864-06.html"
      when 2
        give_items(st)
        html = "32864-07.html"
      when 3
        give_items(st)
        html = "32864-07.html"
      end

    when State::COMPLETED
      if !st.now_available?
        html = "32864-08.html"
      else
        st.state = State::CREATED
        if pc.level >= MIN_LEVEL
          html = "32864-01.htm"
        end
      end
    end


    html || get_no_quest_msg(pc)
  end

  private def give_items(st)
    1.upto(st.cond - 1) do
      chance = Rnd.rand(1000)
      parts = Rnd.rand(1..2)
      if chance < 50
        st.give_items(Rnd.rand(15815..15825), 1) # Weapon Recipes
      elsif chance < 100
        st.give_items(Rnd.rand(15792..15808), parts) # Armor Recipes
      elsif chance < 150
        st.give_items(Rnd.rand(15809..15811), parts) # Jewelry Recipes
      elsif chance < 250
        st.give_items(ARMOR_PARTS.sample(random: Rnd), parts) # Armor Parts
      elsif chance < 500
        st.give_items(Rnd.rand(15634..15644), parts) # Weapon Parts
      elsif chance < 750
        st.give_items(Rnd.rand(15769..15771), parts) # Jewelry Parts
      elsif chance < 900
        st.give_items(Rnd.rand(9552..9557), 1) # Crystals
      elsif chance < 970
        st.give_items(6578, 1) # Blessed Scroll: Enchant Armor (S-Grade)
      else
        st.give_items(6577, 1) # Blessed Scroll: Enchant Weapon (S-Grade)
      end
    end

    st.exit_quest(QuestType::DAILY, true)
  end
end
