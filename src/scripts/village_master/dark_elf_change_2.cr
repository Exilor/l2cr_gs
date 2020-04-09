class Scripts::DarkElfChange2 < AbstractNpcAI
  # NPCs
  private NPCS = {
    30195, # Brecson
    30474, # Angus
    30699, # Medown
    30862, # Oltran
    30910, # Xairakin
    31285, # Samael
    31324, # Andromeda
    31334, # Tifaren
    31974  # Drizzit
  }

  # Classes
  private SHILLIEN_KNIGHT = 33
  private BLADEDANCER = 34
  private ABYSS_WALKER = 36
  private PHANTOM_RANGER = 37
  private SPELLHOWLER = 40
  private PHANTOM_SUMMONER = 41
  private SHILLIEN_ELDER = 43
  # Items
  private MARK_OF_CHALLENGER = 2627
  private MARK_OF_DUTY = 2633
  private MARK_OF_SEEKER = 2673
  private MARK_OF_SCHOLAR = 2674
  private MARK_OF_PILGRIM = 2721
  private MARK_OF_DUELIST = 2762
  private MARK_OF_SEARCHER = 2809
  private MARK_OF_REFORMER = 2821
  private MARK_OF_MAGUS = 2840
  private MARK_OF_FATE = 3172
  private MARK_OF_SAGITTARIUS = 3293
  private MARK_OF_WITCHCRAFT = 3307
  private MARK_OF_SUMMONER = 3336
  # Reward
  private SHADOW_ITEM_EXCHANGE_COUPON_C_GRADE = 8870
  # Misc
  private MIN_LEVEL = 40

  def initialize
    super(self.class.simple_name, "village_master")

    add_start_npc(NPCS)
    add_talk_id(NPCS)
  end

  def on_adv_event(event, npc, pc)
    return unless npc && pc

    case event
    when /\A30195-(?:0[2-9]|1[0-9]|2[0-6]).htm\z/
    # when "30195-02.htm", "30195-03.htm", "30195-04.htm", "30195-05.htm",
    #      "30195-06.htm", "30195-07.htm", "30195-08.htm", "30195-09.htm",
    #      "30195-10.htm", "30195-11.htm", "30195-12.htm", "30195-13.htm",
    #      "30195-14.htm", "30195-15.htm", "30195-16.htm", "30195-17.htm",
    #      "30195-18.htm", "30195-19.htm", "30195-20.htm", "30195-21.htm",
    #      "30195-22.htm", "30195-23.htm", "30195-24.htm", "30195-25.htm",
    #      "30195-26.htm"
      event
    when "33", "34", "36", "37", "40", "41", "43"
      class_change_requested(pc, event.to_i)
    else
      # [automatically added else]
    end

  end

  private def class_change_requested(pc, class_id)
    if pc.in_category?(CategoryType::THIRD_CLASS_GROUP)
      html = "30195-29.htm"
    elsif class_id == SHILLIEN_KNIGHT && pc.class_id.palus_knight?
      if pc.level < MIN_LEVEL
        if has_quest_items?(pc, MARK_OF_DUTY, MARK_OF_FATE, MARK_OF_WITCHCRAFT)
          html = "30195-30.htm"
        else
          html = "30195-31.htm"
        end
      elsif has_quest_items?(pc, MARK_OF_DUTY, MARK_OF_FATE, MARK_OF_WITCHCRAFT)
        take_items(pc, -1, {MARK_OF_DUTY, MARK_OF_FATE, MARK_OF_WITCHCRAFT})
        pc.class_id = SHILLIEN_KNIGHT
        pc.base_class = SHILLIEN_KNIGHT
        # SystemMessage and cast skill is done by class_id=
        pc.broadcast_user_info
        give_items(pc, SHADOW_ITEM_EXCHANGE_COUPON_C_GRADE, 15)
        html = "30195-32.htm"
      else
        html = "30195-33.htm"
      end
    elsif class_id == BLADEDANCER && pc.class_id.palus_knight?
      if pc.level < MIN_LEVEL
        if has_quest_items?(pc, MARK_OF_CHALLENGER, MARK_OF_FATE, MARK_OF_DUELIST)
          html = "30195-34.htm"
        else
          html = "30195-35.htm"
        end
      elsif has_quest_items?(pc, MARK_OF_CHALLENGER, MARK_OF_FATE, MARK_OF_DUELIST)
        take_items(pc, -1, {MARK_OF_CHALLENGER, MARK_OF_FATE, MARK_OF_DUELIST})
        pc.class_id = BLADEDANCER
        pc.base_class = BLADEDANCER
        # SystemMessage and cast skill is done by class_id=
        pc.broadcast_user_info
        give_items(pc, SHADOW_ITEM_EXCHANGE_COUPON_C_GRADE, 15)
        html = "30195-36.htm"
      else
        html = "30195-37.htm"
      end
    elsif class_id == ABYSS_WALKER && pc.class_id.assassin?
      if pc.level < MIN_LEVEL
        if has_quest_items?(pc, MARK_OF_SEEKER, MARK_OF_FATE, MARK_OF_SEARCHER)
          html = "30195-38.htm"
        else
          html = "30195-39.htm"
        end
      elsif has_quest_items?(pc, MARK_OF_SEEKER, MARK_OF_FATE, MARK_OF_SEARCHER)
        take_items(pc, -1, {MARK_OF_SEEKER, MARK_OF_FATE, MARK_OF_SEARCHER})
        pc.class_id = ABYSS_WALKER
        pc.base_class = ABYSS_WALKER
        # SystemMessage and cast skill is done by class_id=
        pc.broadcast_user_info
        give_items(pc, SHADOW_ITEM_EXCHANGE_COUPON_C_GRADE, 15)
        html = "30195-40.htm"
      else
        html = "30195-41.htm"
      end
    elsif class_id == PHANTOM_RANGER && pc.class_id.assassin?
      if pc.level < MIN_LEVEL
        if has_quest_items?(pc, MARK_OF_SEEKER, MARK_OF_FATE, MARK_OF_SAGITTARIUS)
          html = "30195-42.htm"
        else
          html = "30195-43.htm"
        end
      elsif has_quest_items?(pc, MARK_OF_SEEKER, MARK_OF_FATE, MARK_OF_SAGITTARIUS)
        take_items(pc, -1, {MARK_OF_SEEKER, MARK_OF_FATE, MARK_OF_SAGITTARIUS})
        pc.class_id = PHANTOM_RANGER
        pc.base_class = PHANTOM_RANGER
        # SystemMessage and cast skill is done by class_id=
        pc.broadcast_user_info
        give_items(pc, SHADOW_ITEM_EXCHANGE_COUPON_C_GRADE, 15)
        html = "30195-44.htm"
      else
        html = "30195-45.htm"
      end
    elsif class_id == SPELLHOWLER && pc.class_id.dark_wizard?
      if pc.level < MIN_LEVEL
        if has_quest_items?(pc, MARK_OF_SCHOLAR, MARK_OF_FATE, MARK_OF_MAGUS)
          html = "30195-46.htm"
        else
          html = "30195-47.htm"
        end
      elsif has_quest_items?(pc, MARK_OF_SCHOLAR, MARK_OF_FATE, MARK_OF_MAGUS)
        take_items(pc, -1, {MARK_OF_SCHOLAR, MARK_OF_FATE, MARK_OF_MAGUS})
        pc.class_id = SPELLHOWLER
        pc.base_class = SPELLHOWLER
        # SystemMessage and cast skill is done by class_id=
        pc.broadcast_user_info
        give_items(pc, SHADOW_ITEM_EXCHANGE_COUPON_C_GRADE, 15)
        html = "30195-48.htm"
      else
        html = "30195-49.htm"
      end
    elsif class_id == PHANTOM_SUMMONER && pc.class_id.dark_wizard?
      if pc.level < MIN_LEVEL
        if has_quest_items?(pc, MARK_OF_SCHOLAR, MARK_OF_FATE, MARK_OF_SUMMONER)
          html = "30195-50.htm"
        else
          html = "30195-51.htm"
        end
      elsif has_quest_items?(pc, MARK_OF_SCHOLAR, MARK_OF_FATE, MARK_OF_SUMMONER)
        take_items(pc, -1, {MARK_OF_SCHOLAR, MARK_OF_FATE, MARK_OF_SUMMONER})
        pc.class_id = PHANTOM_SUMMONER
        pc.base_class = PHANTOM_SUMMONER
        # SystemMessage and cast skill is done by class_id=
        pc.broadcast_user_info
        give_items(pc, SHADOW_ITEM_EXCHANGE_COUPON_C_GRADE, 15)
        html = "30195-52.htm"
      else
        html = "30195-53.htm"
      end
    elsif class_id == SHILLIEN_ELDER && pc.class_id.shillien_oracle?
      if pc.level < MIN_LEVEL
        if has_quest_items?(pc, MARK_OF_PILGRIM, MARK_OF_FATE, MARK_OF_REFORMER)
          html = "30195-54.htm"
        else
          html = "30195-55.htm"
        end
      elsif has_quest_items?(pc, MARK_OF_PILGRIM, MARK_OF_FATE, MARK_OF_REFORMER)
        take_items(pc, -1, {MARK_OF_PILGRIM, MARK_OF_FATE, MARK_OF_REFORMER})
        pc.class_id = SHILLIEN_ELDER
        pc.base_class = SHILLIEN_ELDER
        # SystemMessage and cast skill is done by class_id=
        pc.broadcast_user_info
        give_items(pc, SHADOW_ITEM_EXCHANGE_COUPON_C_GRADE, 15)
        html = "30195-56.htm"
      else
        html = "30195-57.htm"
      end
    end

    html
  end

  def on_talk(npc, pc)
    if pc.in_category?(CategoryType::FOURTH_CLASS_GROUP) && (pc.in_category?(CategoryType::DELF_MALL_CLASS) || pc.in_category?(CategoryType::DELF_FALL_CLASS))
      "30195-01.htm"
    elsif pc.in_category?(CategoryType::DELF_MALL_CLASS) || pc.in_category?(CategoryType::DELF_FALL_CLASS)
      class_id = pc.class_id
      if class_id.palus_knight? || class_id.shillien_knight? || class_id.bladedancer?
        "30195-02.htm"
      elsif class_id.assassin? || class_id.abyss_walker? || class_id.phantom_ranger?
        "30195-09.htm"
      elsif class_id.dark_wizard? || class_id.spellhowler? || class_id.phantom_summoner?
        "30195-16.htm"
      elsif class_id.shillien_oracle? || class_id.shillien_elder?
        "30195-23.htm"
      else
        "30195-27.htm"
      end
    else
      "30195-28.htm"
    end
  end
end
