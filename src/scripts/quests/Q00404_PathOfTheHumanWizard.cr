class Scripts::Q00404_PathOfTheHumanWizard < Quest
  # NPCs
	private PARINA = 30391
	private EARTH_SNAKE = 30409
	private WASTELAND_LIZARDMAN = 30410
	private FLAME_SALAMANDER = 30411
	private WIND_SYLPH = 30412
	private WATER_UNDINE = 30413
	# Items
	private MAP_OF_LUSTER = 1280
	private KEY_OF_FLAME = 1281
	private FLAME_EARING = 1282
	private BROKEN_BRONZE_MIRROR = 1283
	private WIND_FEATHER = 1284
	private WIND_BANGLE = 1285
	private RAMAS_DIARY = 1286
	private SPARKLE_PEBBLE = 1287
	private WATER_NECKLACE = 1288
	private RUSTY_COIN = 1289
	private RED_SOIL = 1290
	private EARTH_RING = 1291
	# Reward
	private BEAD_OF_SEASON = 1292
	# Monster
	private RED_BEAR = 20021
	private RATMAN_WARRIOR = 20359
	# Quest Monster
	private WATER_SEER = 27030
	# Misc
	private MIN_LEVEL = 18

  def initialize
    super(404, self.class.simple_name, "Path Of The Human Wizard")

    add_start_npc(PARINA)
		add_talk_id(
      PARINA, EARTH_SNAKE, WASTELAND_LIZARDMAN, FLAME_SALAMANDER, WIND_SYLPH,
      WATER_UNDINE
    )
		add_kill_id(RED_BEAR, RATMAN_WARRIOR, WATER_SEER)
		register_quest_items(
      MAP_OF_LUSTER, KEY_OF_FLAME, FLAME_EARING, BROKEN_BRONZE_MIRROR,
      WIND_FEATHER, WIND_BANGLE, RAMAS_DIARY, SPARKLE_PEBBLE, WATER_NECKLACE,
      RUSTY_COIN, RED_SOIL, EARTH_RING
    )
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    return unless qs = get_quest_state(pc, false)

    case event
    when "ACCEPT"
      if pc.class_id.mage?
        if pc.level >= MIN_LEVEL
          if has_quest_items?(pc, BEAD_OF_SEASON)
            "30391-03.htm"
          else
            qs.start_quest
            "30391-07.htm"
          end
        else
          "30391-02.htm"
        end
      elsif pc.class_id.wizard?
        "30391-02a.htm"
      else
        "30391-01.htm"
      end
    when "30410-02.html"
      event
    when "30410-03.html"
      give_items(pc, WIND_FEATHER, 1)
      qs.set_cond(6, true)
      event
    end
  end

  def on_kill(npc, pc, is_summon)
    qs = get_quest_state(pc, false)

    if qs && qs.started? && Util.in_range?(1500, npc, pc, true)
      case npc.id
      when RED_BEAR
        on_red_bear_killed(qs, pc)
      when RATMAN_WARRIOR
        on_ratman_warrior_killed(qs, pc)
      when WATER_SEER
        on_water_seer_killed(qs, pc)
      end
    end

    super
  end

  private def on_red_bear_killed(qs, pc)
    if has_quest_items?(pc, RUSTY_COIN)
      unless has_quest_items?(pc, RED_SOIL)
        if Rnd.rand(100) < 20
          give_items(pc, RED_SOIL, 1)
          qs.set_cond(12, true)
        end
      end
    end
  end

  private def on_ratman_warrior_killed(qs, pc)
    if has_quest_items?(pc, MAP_OF_LUSTER)
      unless has_quest_items?(pc, KEY_OF_FLAME)
        if Rnd.rand(100) < 80
          give_items(pc, KEY_OF_FLAME, 1)
          qs.set_cond(3, true)
        end
      end
    end
  end

  private def on_water_seer_killed(qs, pc)
    if has_quest_items?(pc, RAMAS_DIARY)
      if get_quest_items_count(pc, SPARKLE_PEBBLE) < 2
        if Rnd.rand(100) < 80
          give_items(pc, SPARKLE_PEBBLE, 1)
          if get_quest_items_count(pc, SPARKLE_PEBBLE) == 2
            qs.set_cond(9, true)
          else
            play_sound(pc, Sound::ITEMSOUND_QUEST_ITEMGET)
          end
        end
      end
    end
  end

  def on_talk(npc, pc)
    qs = get_quest_state!(pc)

    if qs.created? || qs.completed?
      if npc.id == PARINA
        html = "30391-04.htm"
      end
    elsif qs.started?
      case npc.id
      when PARINA
        html = on_talk_with_parina(qs, pc)
      when EARTH_SNAKE
        html = on_talk_with_earth_snake(qs, pc)
      when WASTELAND_LIZARDMAN
        html = on_talk_with_wasteland_lizardman(qs, pc)
      when FLAME_SALAMANDER
        html = on_talk_with_flame_salamander(qs, pc)
      when WIND_SYLPH
        html = on_talk_with_wind_sylph(qs, pc)
      when WATER_UNDINE
        html = on_talk_with_water_undine(qs, pc)
      end
    end

    html || get_no_quest_msg(pc)
  end

  private def on_talk_with_parina(qs, pc)
    if !has_quest_items?(pc, FLAME_EARING, WIND_BANGLE, WATER_NECKLACE, EARTH_RING)
      html = "30391-05.html"
    else
      give_adena(pc, 163800, true)
      take_items(pc, FLAME_EARING, 1)
      take_items(pc, WIND_BANGLE, 1)
      take_items(pc, WATER_NECKLACE, 1)
      take_items(pc, EARTH_RING, 1)
      unless has_quest_items?(pc, BEAD_OF_SEASON)
        give_items(pc, BEAD_OF_SEASON, 1)
      end

      if pc.level >= 20
        add_exp_and_sp(pc, 320534, 23152)
      elsif pc.level == 19
        add_exp_and_sp(pc, 456128, 29850)
      else
        add_exp_and_sp(pc, 591724, 36548)
      end

      qs.exit_quest(false, true)
      pc.send_packet(SocialAction.new(pc.l2id, 3))
      qs.save_global_quest_var("1ClassQuestFinished", "1")
      html = "30391-06.html"
    end
  end

  private def on_talk_with_earth_snake(qs, pc)
    if has_quest_items?(pc, WATER_NECKLACE) && !has_at_least_one_quest_item?(pc, RUSTY_COIN, EARTH_RING)
      unless has_quest_items?(pc, RUSTY_COIN)
        give_items(pc, RUSTY_COIN, 1)
      end

      qs.set_cond(11, true)
      html = "30409-01.html"
    elsif has_quest_items?(pc, RUSTY_COIN)
      if has_quest_items?(pc, RED_SOIL)
        take_items(pc, RUSTY_COIN, 1)
        take_items(pc, RED_SOIL, 1)
        unless has_quest_items?(pc, EARTH_RING)
          give_items(pc, EARTH_RING, 1)
        end

        qs.set_cond(13, true)
        html = "30409-04.html"
      else
        html = "30409-02.html"
      end
    elsif has_quest_items?(pc, EARTH_RING)
      html = "30409-04.html"
    end
  end

  private def on_talk_with_wasteland_lizardman(qs, pc)
    if has_quest_items?(pc, BROKEN_BRONZE_MIRROR)
      if has_quest_items?(pc, WIND_FEATHER)
        html = "30410-04.html"
      else
        html = "30410-01.html"
      end
    end
  end

  private def on_talk_with_flame_salamander(qs, pc)
    if !has_at_least_one_quest_item?(pc, MAP_OF_LUSTER, FLAME_EARING)
      unless has_quest_items?(pc, MAP_OF_LUSTER)
        give_items(pc, MAP_OF_LUSTER, 1)
      end
      qs.set_cond(2, true)
      html = "30411-01.html"
    elsif has_quest_items?(pc, MAP_OF_LUSTER)
      if !has_quest_items?(pc, KEY_OF_FLAME)
        html = "30411-02.html"
      else
        take_items(pc, MAP_OF_LUSTER, 1)
        take_items(pc, KEY_OF_FLAME, 1)
        unless has_quest_items?(pc, FLAME_EARING)
          give_items(pc, FLAME_EARING, 1)
        end
        qs.set_cond(4, true)
        html = "30411-03.html"
      end
    elsif has_quest_items?(pc, FLAME_EARING)
      html = "30411-04.html"
    end
  end

  private def on_talk_with_wind_sylph(qs, pc)
    if has_quest_items?(pc, FLAME_EARING) && !has_at_least_one_quest_item?(pc, BROKEN_BRONZE_MIRROR, WIND_BANGLE)
      unless has_quest_items?(pc, BROKEN_BRONZE_MIRROR)
        give_items(pc, BROKEN_BRONZE_MIRROR, 1)
      end
      qs.set_cond(5, true)
      html = "30412-01.html"
    elsif has_quest_items?(pc, BROKEN_BRONZE_MIRROR)
      if !has_quest_items?(pc, WIND_FEATHER)
        html = "30412-02.html"
      else
        take_items(pc, BROKEN_BRONZE_MIRROR, 1)
        take_items(pc, WIND_FEATHER, 1)
        unless has_quest_items?(pc, WIND_BANGLE)
          give_items(pc, WIND_BANGLE, 1)
        end
        qs.set_cond(7, true)
        html = "30412-03.html"
      end
    elsif has_quest_items?(pc, WIND_BANGLE)
      html = "30412-04.html"
    end
  end

  private def on_talk_with_water_undine(qs, pc)
    if has_quest_items?(pc, WIND_BANGLE) && !has_at_least_one_quest_item?(pc, RAMAS_DIARY, WATER_NECKLACE)
      unless has_quest_items?(pc, RAMAS_DIARY)
        give_items(pc, RAMAS_DIARY, 1)
      end
      qs.set_cond(8, true)
      html = "30413-01.html"
    elsif has_quest_items?(pc, RAMAS_DIARY)
      if get_quest_items_count(pc, SPARKLE_PEBBLE) < 2
        html = "30413-02.html"
      else
        take_items(pc, RAMAS_DIARY, 1)
        take_items(pc, SPARKLE_PEBBLE, -1)
        unless has_quest_items?(pc, WATER_NECKLACE)
          give_items(pc, WATER_NECKLACE, 1)
        end
        qs.set_cond(10, true)
        html = "30413-03.html"
      end
    elsif has_quest_items?(pc, WATER_NECKLACE)
      html = "30413-04.html"
    end
  end
end
