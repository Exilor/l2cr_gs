class Scripts::Q00419_GetAPet < Quest
  # NPCs
  private GUARD_METTY = 30072
  private ACCESSORY_MERCHANT_ELLIE = 30091
  private GATEKEEPER_BELLA = 30256
  private PET_MENAGER_MARTIN = 30731
  # Items
  private ANIMAL_LOVERS_LIST = 3417
  private ANIMAL_SLAYERS_1ST_LIST = 3418
  private ANIMAL_SLAYERS_2ND_LIST = 3419
  private ANIMAL_SLAYERS_3RD_LIST = 3420
  private ANIMAL_SLAYERS_4TH_LIST = 3421
  private ANIMAL_SLAYERS_5TH_LIST = 3422
  private BLOODY_FANG = 3423
  private BLOODY_CLAW = 3424
  private BLOODY_NAIL = 3425
  private BLOODY_KASHA_FANG = 3426
  private BLOODY_TARANTULA_NAIL = 3427
  private ANIMAL_SLAYERS_LIST = 10164
  private BLOODY_RED_CLAW = 10165
  # Reward
  private WOLF_COLLAR = 2375
  # Monster
  private LESSER_DARK_HORROR = 20025
  private PROWLER = 20034
  private GIANT_SPIDER = 20103
  private DARK_HORROR = 20105
  private TALON_SPIDER = 20106
  private BLADE_SPIDER = 20108
  private HOOK_SPIDER = 20308
  private HUNTER_TARANTULA = 20403
  private CRIMSON_SPIDER = 20460
  private PINCER_SPIDER = 20466
  private KASHA_SPIDER = 20474
  private KASHA_FANG_SPIDER = 20476
  private KASHA_BLADE_SPIDER = 20478
  private PLUNDER_TARANTULA = 20508
  private CRIMSON_SPIDER2 = 22244
  # Misc
  private MIN_LEVEL = 15
  # Links
  private LINKS = {
    1110001 => "<a action=\"bypass -h Quest Q00419_GetAPet 30731-14.html\">Can be used for item transportation.</a><br>",
    1110002 => "<a action=\"bypass -h Quest Q00419_GetAPet 30731-14.html\">Can help during hunting by assisting in attacks.</a><br>",
    1110003 => "<a action=\"bypass -h Quest Q00419_GetAPet QUESTIONS\">Can be sent to the village to buy items.</a><br>",
    1110004 => "<a action=\"bypass -h Quest Q00419_GetAPet 30731-14.html\">Can be traded or sold to a new owner for adena.</a><br>",
    1110005 => "<a action=\"bypass -h Quest Q00419_GetAPet 30731-14.html\">None of the above.</a><br>",
    1110006 => "<a action=\"bypass -h Quest Q00419_GetAPet QUESTIONS\">When taking down a monster, always have a pet's company.</a><br>",
    1110007 => "<a action=\"bypass -h Quest Q00419_GetAPet 30731-14.html\">Tell your pet to pick up items.</a><br>",
    1110008 => "<a action=\"bypass -h Quest Q00419_GetAPet 30731-14.html\">Tell your pet to attack monsters first.</a><br>",
    1110009 => "<a action=\"bypass -h Quest Q00419_GetAPet 30731-14.html\">Let your pet do what it wants.</a><br>",
    1110010 => "<a action=\"bypass -h Quest Q00419_GetAPet 30731-14.html\">None of the above.</a><br>",
    1110011 => "<a action=\"bypass -h Quest Q00419_GetAPet 30731-14.html\">10 hours</a><br>",
    1110012 => "<a action=\"bypass -h Quest Q00419_GetAPet 30731-14.html\">15 hours</a><br>",
    1110013 => "<a action=\"bypass -h Quest Q00419_GetAPet QUESTIONS\">It won't disappear.</a><br>",
    1110014 => "<a action=\"bypass -h Quest Q00419_GetAPet 30731-14.html\">25 hours</a><br>",
    1110015 => "<a action=\"bypass -h Quest Q00419_GetAPet 30731-14.html\">None of the above.</a><br>",
    1110016 => "<a action=\"bypass -h Quest Q00419_GetAPet QUESTIONS\">Dire Wolf</a><br>",
    1110017 => "<a action=\"bypass -h Quest Q00419_GetAPet 30731-14.html\">Air Wolf</a><br>",
    1110018 => "<a action=\"bypass -h Quest Q00419_GetAPet 30731-14.html\">Turek Wolf</a><br>",
    1110019 => "<a action=\"bypass -h Quest Q00419_GetAPet 30731-14.html\">Kasha Wolf</a><br>",
    1110020 => "<a action=\"bypass -h Quest Q00419_GetAPet 30731-14.html\">None of the above.</a><br>",
    1110021 => "<a action=\"bypass -h Quest Q00419_GetAPet QUESTIONS\">It's tail is always pointing straight down.</a><br>",
    1110022 => "<a action=\"bypass -h Quest Q00419_GetAPet 30731-14.html\">It's tail is always curled up.</a><br>",
    1110023 => "<a action=\"bypass -h Quest Q00419_GetAPet 30731-14.html\">It's tail is always wagging back and forth.</a><br>",
    1110024 => "<a action=\"bypass -h Quest Q00419_GetAPet 30731-14.html\">What are you talking about?! A wolf doesn't have a tail.</a><br>",
    1110025 => "<a action=\"bypass -h Quest Q00419_GetAPet 30731-14.html\">None of the above.</a><br>",
    1110026 => "<a action=\"bypass -h Quest Q00419_GetAPet 30731-14.html\">Raccoon</a><br>",
    1110027 => "<a action=\"bypass -h Quest Q00419_GetAPet 30731-14.html\">Jackal</a><br>",
    1110028 => "<a action=\"bypass -h Quest Q00419_GetAPet 30731-14.html\">Fox</a><br>",
    1110029 => "<a action=\"bypass -h Quest Q00419_GetAPet 30731-14.html\">Shepherd Dog</a><br>",
    1110030 => "<a action=\"bypass -h Quest Q00419_GetAPet QUESTIONS\">None of the above.</a><br>",
    1110031 => "<a action=\"bypass -h Quest Q00419_GetAPet 30731-14.html\">1.4 km</a><br>",
    1110032 => "<a action=\"bypass -h Quest Q00419_GetAPet QUESTIONS\">2.4 km</a><br>",
    1110033 => "<a action=\"bypass -h Quest Q00419_GetAPet 30731-14.html\">3.4 km</a><br>",
    1110034 => "<a action=\"bypass -h Quest Q00419_GetAPet 30731-14.html\">4.4 km</a><br>",
    1110035 => "<a action=\"bypass -h Quest Q00419_GetAPet 30731-14.html\">None of the above.</a><br>",
    1110036 => "<a action=\"bypass -h Quest Q00419_GetAPet QUESTIONS\">Male</a><br>",
    1110037 => "<a action=\"bypass -h Quest Q00419_GetAPet 30731-14.html\">Female</a><br>",
    1110038 => "<a action=\"bypass -h Quest Q00419_GetAPet 30731-14.html\">A baby that was born last year</a><br>",
    1110039 => "<a action=\"bypass -h Quest Q00419_GetAPet 30731-14.html\">A baby that was born two years ago</a><br>",
    1110040 => "<a action=\"bypass -h Quest Q00419_GetAPet 30731-14.html\">None of the above.</a><br>",
    1110041 => "<a action=\"bypass -h Quest Q00419_GetAPet 30731-14.html\">Goat</a><br>",
    1110042 => "<a action=\"bypass -h Quest Q00419_GetAPet 30731-14.html\">Meat of a dead animal</a><br>",
    1110043 => "<a action=\"bypass -h Quest Q00419_GetAPet 30731-14.html\">Berries</a><br>",
    1110044 => "<a action=\"bypass -h Quest Q00419_GetAPet 30731-14.html\">Wild Bird</a><br>",
    1110045 => "<a action=\"bypass -h Quest Q00419_GetAPet QUESTIONS\">None of the above.</a><br>",
    1110046 => "<a action=\"bypass -h Quest Q00419_GetAPet 30731-14.html\">Breeding season is January-February.</a><br>",
    1110047 => "<a action=\"bypass -h Quest Q00419_GetAPet QUESTIONS\">Pregnancy is nine months.</a><br>",
    1110048 => "<a action=\"bypass -h Quest Q00419_GetAPet 30731-14.html\">Babies are born in April-June.</a><br>",
    1110049 => "<a action=\"bypass -h Quest Q00419_GetAPet 30731-14.html\">Has up to ten offspring at one time.</a><br>",
    1110050 => "<a action=\"bypass -h Quest Q00419_GetAPet 30731-14.html\">None of the above.</a><br>",
    1110051 => "<a action=\"bypass -h Quest Q00419_GetAPet 30731-14.html\">3-6 years</a><br>",
    1110052 => "<a action=\"bypass -h Quest Q00419_GetAPet 30731-14.html\">6-9 years</a><br>",
    1110053 => "<a action=\"bypass -h Quest Q00419_GetAPet 30731-14.html\">9-12 years</a><br>",
    1110054 => "<a action=\"bypass -h Quest Q00419_GetAPet QUESTIONS\">12-15 years</a><br>",
    1110055 => "<a action=\"bypass -h Quest Q00419_GetAPet 30731-14.html\">None of the above.</a><br>",
    1110056 => "<a action=\"bypass -h Quest Q00419_GetAPet 30731-14.html\">Wolves gather and move in groups of 7-13 animals.</a><br>",
    1110057 => "<a action=\"bypass -h Quest Q00419_GetAPet 30731-14.html\">Wolves can eat a whole calf in one sitting.</a><br>",
    1110058 => "<a action=\"bypass -h Quest Q00419_GetAPet 30731-14.html\">If they have water, wolves can live for 5-6 days without eating anything.</a><br>",
    1110059 => "<a action=\"bypass -h Quest Q00419_GetAPet QUESTIONS\">A pregnant wolf makes its home in a wide open place to have its babies.</a><br>",
    1110060 => "<a action=\"bypass -h Quest Q00419_GetAPet 30731-14.html\">None of the above.</a><br>",
    1110061 => "<a action=\"bypass -h Quest Q00419_GetAPet QUESTIONS\">A grown wolf is still not as heavy as a fully-grown male adult human.</a><br>",
    1110062 => "<a action=\"bypass -h Quest Q00419_GetAPet 30731-14.html\">A wolf changes into a werewolf during a full-moon.</a><br>",
    1110063 => "<a action=\"bypass -h Quest Q00419_GetAPet 30731-14.html\">The color of a wolf's fur is the same as the place where it lives.</a><br>",
    1110064 => "<a action=\"bypass -h Quest Q00419_GetAPet 30731-14.html\">A wolf enjoys eating Dwarves.</a><br>",
    1110065 => "<a action=\"bypass -h Quest Q00419_GetAPet 30731-14.html\">None of the above.</a><br>",
    1110066 => "<a action=\"bypass -h Quest Q00419_GetAPet 30731-14.html\">Talking Island - Wolf</a><br>",
    1110067 => "<a action=\"bypass -h Quest Q00419_GetAPet 30731-14.html\">Dark Forest - Ashen Wolf</a><br>",
    1110068 => "<a action=\"bypass -h Quest Q00419_GetAPet 30731-14.html\">Elven Forest - Gray Wolf</a><br>",
    1110069 => "<a action=\"bypass -h Quest Q00419_GetAPet QUESTIONS\">Orc - Black Wolf</a><br>",
    1110070 => "<a action=\"bypass -h Quest Q00419_GetAPet 30731-14.html\">None of the above.</a><br>"
  }

  def initialize
    super(419, self.class.simple_name, "Get A Pet")

    add_start_npc(PET_MENAGER_MARTIN)
    add_talk_id(
      PET_MENAGER_MARTIN, GUARD_METTY, ACCESSORY_MERCHANT_ELLIE,
      GATEKEEPER_BELLA
    )
    add_kill_id(
      LESSER_DARK_HORROR, PROWLER, GIANT_SPIDER, DARK_HORROR, TALON_SPIDER,
      BLADE_SPIDER, HOOK_SPIDER, HUNTER_TARANTULA, CRIMSON_SPIDER,
      PINCER_SPIDER, KASHA_SPIDER, KASHA_FANG_SPIDER, KASHA_BLADE_SPIDER,
      PLUNDER_TARANTULA, CRIMSON_SPIDER2
    )
    register_quest_items(
      ANIMAL_LOVERS_LIST, ANIMAL_SLAYERS_1ST_LIST, ANIMAL_SLAYERS_2ND_LIST,
      ANIMAL_SLAYERS_3RD_LIST, ANIMAL_SLAYERS_4TH_LIST,
      ANIMAL_SLAYERS_5TH_LIST, BLOODY_FANG, BLOODY_CLAW, BLOODY_NAIL,
      BLOODY_KASHA_FANG, BLOODY_TARANTULA_NAIL, ANIMAL_SLAYERS_LIST,
      BLOODY_RED_CLAW
    )
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    return unless qs = get_quest_state(pc, false)

    case event
    when "ACCEPT"
      if qs.created?
        qs.start_quest
        case pc.race
        when Race::HUMAN
          give_items(pc, ANIMAL_SLAYERS_1ST_LIST, 1)
          html = "30731-04.htm"
        when Race::ELF
          give_items(pc, ANIMAL_SLAYERS_2ND_LIST, 1)
          html = "30731-05.htm"
        when Race::DARK_ELF
          give_items(pc, ANIMAL_SLAYERS_3RD_LIST, 1)
          html = "30731-06.htm"
        when Race::ORC
          give_items(pc, ANIMAL_SLAYERS_4TH_LIST, 1)
          html = "30731-07.htm"
        when Race::DWARF
          give_items(pc, ANIMAL_SLAYERS_5TH_LIST, 1)
          html = "30731-08.htm"
        when Race::KAMAEL
          give_items(pc, ANIMAL_SLAYERS_LIST, 1)
          html = "30731-08a.htm"
        end

      end
    when "30731-03.htm", "30072-02.html", "30091-02.html", "30256-02.html", "30256-03.html"
      html = event
    when "30731-12.html"
      case pc.race
      when Race::HUMAN
        take_give_quest_items(pc, ANIMAL_SLAYERS_1ST_LIST, BLOODY_FANG)
      when Race::ELF
        take_give_quest_items(pc, ANIMAL_SLAYERS_2ND_LIST, BLOODY_CLAW)
      when Race::DARK_ELF
        take_give_quest_items(pc, ANIMAL_SLAYERS_3RD_LIST, BLOODY_NAIL)
      when Race::ORC
        take_give_quest_items(pc, ANIMAL_SLAYERS_4TH_LIST, BLOODY_KASHA_FANG)
      when Race::DWARF
        take_give_quest_items(pc, ANIMAL_SLAYERS_5TH_LIST, BLOODY_TARANTULA_NAIL)
      when Race::KAMAEL
        take_give_quest_items(pc, ANIMAL_SLAYERS_LIST, BLOODY_RED_CLAW)
      end

      qs.memo_state = 0
      html = event
    when "QUESTIONS"
      if qs.memo_state & 15 == 10 && has_quest_items?(pc, ANIMAL_LOVERS_LIST)
        take_items(pc, ANIMAL_LOVERS_LIST, -1)
        give_items(pc, WOLF_COLLAR, 1)
        qs.exit_quest(true, true)
        html = "30731-15.html"
      else
        link_id = 0
        find_response = false
        until find_response
          random_link_offset = Rnd.rand(14) &+ 4
          i7 = 1
          i = 1
          while i <= random_link_offset
            i7 &*= 2
            i &+= 1
          end
          if i7 & qs.memo_state == 0 && random_link_offset < 18
            find_response = true
            qs.memo_state = (qs.memo_state &+ 1) | i7
            link_id = 1110000 &+ (5 * (random_link_offset &- 4))
            html = "30731-#{20 &+ (random_link_offset &- 4)}.htm"
          end
        end

        link_count = 1
        reply_offset1 = reply_offset2 = reply_offset3 = reply_offset4 = i8 = 0
        while link_count < 5
          random_reply_offset = Rnd.rand(4) &+ 1
          i7 = 1
          i = 1
          while i <= random_reply_offset
            i7 &*= 2
            i &+= 1
          end
          if i7 & i8 == 0 && random_reply_offset < 5
            case link_count
            when 1
              reply_offset1 = random_reply_offset
            when 2
              reply_offset2 = random_reply_offset
            when 3
              reply_offset3 = random_reply_offset
            when 4
              reply_offset4 = random_reply_offset
            end

            link_count &+= 1
            i8 |= i7
          end
        end
        html = get_htm(pc, html.not_nil!)
        html = html.sub("<?reply1?>", LINKS[link_id + reply_offset1])
        html = html.sub("<?reply2?>", LINKS[link_id + reply_offset2])
        html = html.sub("<?reply3?>", LINKS[link_id + reply_offset3])
        html = html.sub("<?reply4?>", LINKS[link_id + reply_offset4])
        html = html.sub("<?reply5?>", LINKS[link_id + 5])
      end
    when "30731-14.html"
      qs.memo_state = 0
      html = event
    end

    html
  end

  private def take_give_quest_items(pc, item_list, item)
    if has_quest_items?(pc, item_list)
      if get_quest_items_count(pc, item) >= 50
        take_items(pc, item_list, -1)
        take_items(pc, item, -1)
        give_items(pc, ANIMAL_LOVERS_LIST, 1)
      end
    end
  end

  def on_kill(npc, killer, is_summon)
    qs = get_quest_state(killer, false)

    if qs && qs.started? && Util.in_range?(1500, npc, killer, true)
      case npc.id
      when LESSER_DARK_HORROR
        try_reward(killer, ANIMAL_SLAYERS_3RD_LIST, BLOODY_NAIL, 60)
      when PROWLER
        try_reward(killer, ANIMAL_SLAYERS_3RD_LIST, BLOODY_NAIL, 100)
      when GIANT_SPIDER
        try_reward(killer, ANIMAL_SLAYERS_1ST_LIST, BLOODY_FANG, 60)
      when DARK_HORROR
        try_reward(killer, ANIMAL_SLAYERS_3RD_LIST, BLOODY_NAIL, 75)
      when TALON_SPIDER
        try_reward(killer, ANIMAL_SLAYERS_1ST_LIST, BLOODY_FANG, 75)
      when BLADE_SPIDER
        try_reward(killer, ANIMAL_SLAYERS_1ST_LIST, BLOODY_FANG, 100)
      when HOOK_SPIDER
        try_reward(killer, ANIMAL_SLAYERS_2ND_LIST, BLOODY_CLAW, 75)
      when HUNTER_TARANTULA
        try_reward(killer, ANIMAL_SLAYERS_5TH_LIST, BLOODY_TARANTULA_NAIL, 75)
      when CRIMSON_SPIDER
        try_reward(killer, ANIMAL_SLAYERS_2ND_LIST, BLOODY_CLAW, 60)
      when PINCER_SPIDER
        try_reward(killer, ANIMAL_SLAYERS_2ND_LIST, BLOODY_CLAW, 100)
      when KASHA_SPIDER
        try_reward(killer, ANIMAL_SLAYERS_4TH_LIST, BLOODY_KASHA_FANG, 60)
      when KASHA_FANG_SPIDER
        try_reward(killer, ANIMAL_SLAYERS_4TH_LIST, BLOODY_KASHA_FANG, 75)
      when KASHA_BLADE_SPIDER
        try_reward(killer, ANIMAL_SLAYERS_4TH_LIST, BLOODY_KASHA_FANG, 100)
      when PLUNDER_TARANTULA
        try_reward(killer, ANIMAL_SLAYERS_5TH_LIST, BLOODY_TARANTULA_NAIL, 100)
      when CRIMSON_SPIDER2
        try_reward(killer, ANIMAL_SLAYERS_1ST_LIST, BLOODY_RED_CLAW, 75)
      end
    end

    super
  end

  private def try_reward(killer, item_list, item, random)
    return unless has_quest_items?(killer, item_list)
    return unless Rnd.rand(100) < random
    return unless get_quest_items_count(killer, item) < 50
    give_items(killer, item, 1)
    if get_quest_items_count(killer, item) >= 50
      play_sound(killer, Sound::ITEMSOUND_QUEST_MIDDLE)
    else
      play_sound(killer, Sound::ITEMSOUND_QUEST_ITEMGET)
    end
  end

  def on_talk(npc, pc)
    qs = get_quest_state!(pc)
    html = nil

    if qs.created?
      if npc.id == PET_MENAGER_MARTIN
        if pc.level < MIN_LEVEL
          html = "30731-01.htm"
        else
          html = "30731-02.htm"
        end
      end
    elsif qs.started?
      case npc.id
      when PET_MENAGER_MARTIN
        if has_quest_items?(pc, ANIMAL_SLAYERS_LIST)
          html = validate_quest_items(html, pc, BLOODY_RED_CLAW)
        elsif has_quest_items?(pc, ANIMAL_SLAYERS_1ST_LIST)
          html = validate_quest_items(html, pc, BLOODY_FANG)
        elsif has_quest_items?(pc, ANIMAL_SLAYERS_2ND_LIST)
          html = validate_quest_items(html, pc, BLOODY_CLAW)
        elsif has_quest_items?(pc, ANIMAL_SLAYERS_3RD_LIST)
          html = validate_quest_items(html, pc, BLOODY_NAIL)
        elsif has_quest_items?(pc, ANIMAL_SLAYERS_4TH_LIST)
          html = validate_quest_items(html, pc, BLOODY_KASHA_FANG)
        elsif has_quest_items?(pc, ANIMAL_SLAYERS_5TH_LIST)
          html = validate_quest_items(html, pc, BLOODY_TARANTULA_NAIL)
        elsif has_quest_items?(pc, ANIMAL_LOVERS_LIST)
          if qs.memo_state != 14 && qs.memo_state != 1879048192
            html = "30731-16.html"
          else
            qs.memo_state = 1879048192
            html = "30731-13.html"
          end
        end
      when GUARD_METTY
        if has_quest_items?(pc, ANIMAL_LOVERS_LIST)
          qs.memo_state |= 4
          html = "30072-01.html"
        end
      when ACCESSORY_MERCHANT_ELLIE
        if has_quest_items?(pc, ANIMAL_LOVERS_LIST)
          qs.memo_state |= 8
          html = "30091-01.html"
        end
      when GATEKEEPER_BELLA
        if has_quest_items?(pc, ANIMAL_LOVERS_LIST)
          qs.memo_state |= 2
          html = "30256-01.html"
        end
      end
    end

    html || get_no_quest_msg(pc)
  end

  private def validate_quest_items(original_text, pc, item)
    html = original_text

    if get_quest_items_count(pc, item) < 50
      if has_quest_items?(pc, item)
        html = "30731-10.html"
      else
        html = "30731-09.html"
      end
    else
      html = "30731-11.html"
    end

    html
  end
end
