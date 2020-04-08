class Scripts::Q00327_RecoverTheFarmland < Quest
  # NPCs
  private IRIS = 30034
  private ASHA = 30313
  private NESTLE = 30314
  private LEIKAN = 30382
  private PIOTUR = 30597
  private TUREK_ORK_WARLORD = 20495
  private TUREK_ORK_ARCHER = 20496
  private TUREK_ORK_SKIRMISHER = 20497
  private TUREK_ORK_SUPPLIER = 20498
  private TUREK_ORK_FOOTMAN = 20499
  private TUREK_ORK_SENTINEL = 20500
  private TUREK_ORK_SHAMAN = 20501

  # Items
  private TUREK_DOG_TAG = 1846
  private TUREK_MEDALLION = 1847
  private LEIKANS_LETTER = 5012
  private CLAY_URN_FRAGMENT = 1848
  private BRASS_TRINKET_PIECE = 1849
  private BRONZE_MIRROR_PIECE = 1850
  private JADE_NECKLACE_BEAD = 1851
  private ANCIENT_CLAY_URN = 1852
  private ANCIENT_BRASS_TIARA = 1853
  private ANCIENT_BRONZE_MIRROR = 1854
  private ANCIENT_JADE_NECKLACE = 1855
  private QUICK_STEP_POTION = 734
  private SWIFT_ATTACK_POTION = 735
  private SCROLL_OF_ESCAPE = 736
  private SCROLL_OF_RESURRECTION = 737
  private HEALING_POTION = 1061
  private SOULSHOT_D = 1463
  private SPIRITSHOT_D = 2510

  # Misc
  private MIN_LVL = 25
  private FRAGMENTS_REWARD_DATA = {
    "30034-03.html" => ItemHolder.new(CLAY_URN_FRAGMENT, 307),
    "30034-04.html" => ItemHolder.new(BRASS_TRINKET_PIECE, 368),
    "30034-05.html" => ItemHolder.new(BRONZE_MIRROR_PIECE, 368),
    "30034-06.html" => ItemHolder.new(JADE_NECKLACE_BEAD, 430)
  }
  private FRAGMENTS_DROP_PROB = {
    TUREK_ORK_ARCHER => 21,
    TUREK_ORK_FOOTMAN => 19,
    TUREK_ORK_SENTINEL => 18,
    TUREK_ORK_SHAMAN => 22,
    TUREK_ORK_SKIRMISHER => 21,
    TUREK_ORK_SUPPLIER => 20,
    TUREK_ORK_WARLORD => 26
  }
  private FULL_REWARD_DATA = {
    ItemHolder.new(ANCIENT_CLAY_URN, 2766),
    ItemHolder.new(ANCIENT_BRASS_TIARA, 3227),
    ItemHolder.new(ANCIENT_BRONZE_MIRROR, 3227),
    ItemHolder.new(ANCIENT_JADE_NECKLACE, 3919)
  }

  def initialize
    super(327, self.class.simple_name, "Recover the Farmland")

    add_start_npc(LEIKAN, PIOTUR)
    add_talk_id(LEIKAN, PIOTUR, IRIS, ASHA, NESTLE)
    add_kill_id(
      TUREK_ORK_WARLORD, TUREK_ORK_ARCHER, TUREK_ORK_SKIRMISHER,
      TUREK_ORK_SUPPLIER, TUREK_ORK_FOOTMAN, TUREK_ORK_SENTINEL,
      TUREK_ORK_SHAMAN
    )
    register_quest_items(TUREK_DOG_TAG, TUREK_MEDALLION, LEIKANS_LETTER)
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    unless st = get_quest_state(pc, false)
      return
    end

    case event
    when "30034-01.html", "30313-01.html", "30314-02.html", "30314-08.html",
         "30314-09.html", "30382-05a.html", "30382-05b.html", "30597-03.html",
         "30597-07.html"
      html = event
    when "30382-03.htm"
      st.start_quest
      give_items(pc, LEIKANS_LETTER, 1)
      st.set_cond(2)
      html = event
    when "30597-03.htm"
      st.start_quest
      html = event
    when "30597-06.html"
      st.exit_quest(true, true)
      html = event
    when "30034-03.html", "30034-04.html", "30034-05.html", "30034-06.html"
      item = FRAGMENTS_REWARD_DATA[event]
      if !has_quest_items?(pc, item.id)
        html = "30034-02.html"
      else
        add_exp_and_sp(pc, get_quest_items_count(pc, item.id) * item.count, 0)
        take_items(pc, item.id, -1)
        play_sound(pc, Sound::ITEMSOUND_QUEST_ITEMGET)
        html = event
      end
    when "30034-07.html"
      rewarded = false
      FULL_REWARD_DATA.each do |it|
        if has_quest_items?(pc, it.id)
          add_exp_and_sp(pc, get_quest_items_count(pc, it.id) * it.count, 0)
          take_items(pc, it.id, -1)
          play_sound(pc, Sound::ITEMSOUND_QUEST_ITEMGET)
          rewarded = true
        end
      end
      html = rewarded ? event : "30034-02.html"
    when "30313-03.html"
      if get_quest_items_count(pc, CLAY_URN_FRAGMENT) < 5
        html = "30313-02.html"
      else
        take_items(pc, CLAY_URN_FRAGMENT, 5)
        if Rnd.rand(6) < 5
          give_items(pc, ANCIENT_CLAY_URN, 1)
          html = event
        else
          html = "30313-10.html"
        end
      end
    when "30313-05.html"
      if get_quest_items_count(pc, BRASS_TRINKET_PIECE) < 5
        html = "30313-04.html"
      else
        take_items(pc, BRASS_TRINKET_PIECE, 5)
        if Rnd.rand(7) < 6
          give_items(pc, ANCIENT_BRASS_TIARA, 1)
          html = event
        else
          html = "30313-10.html"
        end
      end
    when "30313-07.html"
      if get_quest_items_count(pc, BRONZE_MIRROR_PIECE) < 5
        html = "30313-06.html"
      else
        take_items(pc, BRONZE_MIRROR_PIECE, 5)
        if Rnd.rand(7) < 6
          give_items(pc, ANCIENT_BRONZE_MIRROR, 1)
          html = event
        else
          html = "30313-10.html"
        end
      end
    when "30313-09.html"
      if get_quest_items_count(pc, JADE_NECKLACE_BEAD) < 5
        html = "30313-08.html"
      else
        take_items(pc, JADE_NECKLACE_BEAD, 5)
        if Rnd.rand(8) < 7
          give_items(pc, ANCIENT_JADE_NECKLACE, 1)
          html = event
        else
          html = "30313-10.html"
        end
      end
    when "30314-03.html"
      if !has_quest_items?(pc, ANCIENT_CLAY_URN)
        html = "30314-07.html"
      else
        reward_items(pc, SOULSHOT_D, Rnd.rand(70..110))
        take_items(pc, ANCIENT_CLAY_URN, 1)
        html = event
      end
    when "30314-04.html"
      if !has_quest_items?(pc, ANCIENT_BRASS_TIARA)
        html = "30314-07.html"
      else
        rnd = Rnd.rand(100)
        if rnd < 40
          reward_items(pc, HEALING_POTION, 1)
        elsif rnd < 84
          reward_items(pc, QUICK_STEP_POTION, 1)
        else
          reward_items(pc, SWIFT_ATTACK_POTION, 1)
        end
        take_items(pc, ANCIENT_BRASS_TIARA, 1)
        html = event
      end
    when "30314-05.html"
      if !has_quest_items?(pc, ANCIENT_BRONZE_MIRROR)
        html = "30314-07.html"
      else
        reward_items(pc, Rnd.rand(100) < 59 ? SCROLL_OF_ESCAPE : SCROLL_OF_RESURRECTION, 1)
        take_items(pc, ANCIENT_BRONZE_MIRROR, 1)
        html = event
      end
    when "30314-06.html"
      if !has_quest_items?(pc, ANCIENT_JADE_NECKLACE)
        html = "30314-07.html"
      else
        reward_items(pc, SPIRITSHOT_D, Rnd.rand(50..90))
        take_items(pc, ANCIENT_JADE_NECKLACE, 1)
        html = event
      end
    else
      # automatically added
    end


    html
  end

  def on_kill(npc, killer, is_summon)
    if st = get_quest_state(killer, false)
      if npc.id == TUREK_ORK_SHAMAN || npc.id == TUREK_ORK_WARLORD
        give_items(killer, TUREK_MEDALLION, 1)
      else
        give_items(killer, TUREK_DOG_TAG, 1)
      end

      if Rnd.rand(100) < FRAGMENTS_DROP_PROB[npc.id]
        give_items(killer, Rnd.rand(CLAY_URN_FRAGMENT..JADE_NECKLACE_BEAD), 1)
      end
    end

    super
  end

  def on_talk(npc, pc)
    st = get_quest_state!(pc)

    case npc.id
    when LEIKAN
      if st.created?
        html = pc.level >= MIN_LVL ? "30382-02.htm" : "30382-01.htm"
      elsif st.started?
        if has_quest_items?(pc, LEIKANS_LETTER)
          html = "30382-04.html"
        else
          html = "30382-05.html"
          st.set_cond(5, true)
        end
      end
    when PIOTUR
      if st.created?
        html = pc.level >= MIN_LVL ? "30597-02.htm" : "30597-01.htm"
      elsif st.started?
        if has_quest_items?(pc, LEIKANS_LETTER)
          html = "30597-03a.htm"
          take_items(pc, LEIKANS_LETTER, -1)
          st.set_cond(3, true)
        else
          if !has_quest_items?(pc, TUREK_DOG_TAG) && !has_quest_items?(pc, TUREK_MEDALLION)
            html = "30597-04.html"
          else
            html = "30597-05.html"
            dog_tags = get_quest_items_count(pc, TUREK_DOG_TAG)
            medallions = get_quest_items_count(pc, TUREK_MEDALLION)
            count = (dog_tags * 40) + (medallions * 50) + (dog_tags + medallions >= 10 ? 619 : 0)
            give_adena(pc, count, true)
            take_items(pc, TUREK_DOG_TAG, -1)
            take_items(pc, TUREK_MEDALLION, -1)
            st.set_cond(4, true)
          end
        end
      end
    when IRIS
      if st.started?
        html = "30034-01.html"
      end
    when ASHA
      if st.started?
        html = "30313-01.html"
      end
    when NESTLE
      if st.started?
        html = "30314-01.html"
      end
    else
      # automatically added
    end


    html || get_no_quest_msg(pc)
  end
end