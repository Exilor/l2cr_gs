class Scripts::MC_Show < AbstractNpcAI
  private  MC = 32433
  private SINGERS = {
    32431, 32432
  }
  private CIRCUS = {
    32442, 32443, 32444, 32445, 32446
  }
  private INDIVIDUALS = {
    32439, 32440, 32441
  }
  private SHOW_STUFF = {
    32424, 32425, 32426, 32427, 32428
  }

  private MESSAGES = {
    NpcString::HOW_COME_PEOPLE_ARE_NOT_HERE_WE_ARE_ABOUT_TO_START_THE_SHOW_HMM,
    NpcString::UGH_I_HAVE_BUTTERFLIES_IN_MY_STOMACH_THE_SHOW_STARTS_SOON,
    NpcString::THANK_YOU_ALL_FOR_COMING_HERE_TONIGHT,
    NpcString::IT_IS_AN_HONOR_TO_HAVE_THE_SPECIAL_SHOW_TODAY,
    NpcString::FANTASY_ISLE_IS_FULLY_COMMITTED_TO_YOUR_HAPPINESS,
    NpcString::NOW_ID_LIKE_TO_INTRODUCE_THE_MOST_BEAUTIFUL_SINGER_IN_ADEN_PLEASE_WELCOMELEYLA_MIRA,
    NpcString::HERE_SHE_COMES,
    NpcString::THANK_YOU_VERY_MUCH_LEYLA,
    NpcString::NOW_WERE_IN_FOR_A_REAL_TREAT,
    NpcString::JUST_BACK_FROM_THEIR_WORLD_TOUR_PUT_YOUR_HANDS_TOGETHER_FOR_THE_FANTASY_ISLE_CIRCUS,
    NpcString::COME_ON_EVERYONE,
    NpcString::DID_YOU_LIKE_IT_THAT_WAS_SO_AMAZING,
    NpcString::NOW_WE_ALSO_INVITED_INDIVIDUALS_WITH_SPECIAL_TALENTS,
    NpcString::LETS_WELCOME_THE_FIRST_PERSON_HERE,
    NpcString::OH,
    NpcString::OKAY_NOW_HERE_COMES_THE_NEXT_PERSON_COME_ON_UP_PLEASE,
    NpcString::OH_IT_LOOKS_LIKE_SOMETHING_GREAT_IS_GOING_TO_HAPPEN_RIGHT,
    NpcString::OH_MY,
    NpcString::THATS_G_GREAT_NOW_HERE_COMES_THE_LAST_PERSON,
    NpcString::NOW_THIS_IS_THE_END_OF_TODAYS_SHOW,
    NpcString::HOW_WAS_IT_I_HOPE_YOU_ALL_ENJOYED_IT,
    NpcString::PLEASE_REMEMBER_THAT_FANTASY_ISLE_IS_ALWAYS_PLANNING_A_LOT_OF_GREAT_SHOWS_FOR_YOU,
    NpcString::WELL_I_WISH_I_COULD_CONTINUE_ALL_NIGHT_LONG_BUT_THIS_IS_IT_FOR_TODAY_THANK_YOU,
    NpcString::WE_LOVE_YOU
  }

  private record ShoutInfo, npc_string_id : NpcString, next_event : String,
    time : Int32

  private record WalkInfo, char_pos : Location, next_event : String,
    time : Int32

  private TALKS = {} of String => ShoutInfo
  private WALKS = {} of String => WalkInfo

  def initialize
    super(self.class.simple_name, "ai/fantasy_isle")

    @started = false

    add_spawn_id(32433, 32431, 32432, 32442, 32443, 32444, 32445, 32446, 32424, 32425, 32426, 32427, 32428)
    load
    schedule_timer
  end

  private def load
    # TODO put this stuff in Routes.xml
    TALKS["1"] = ShoutInfo.new(MESSAGES[1], "2", 1000)
    TALKS["2"] = ShoutInfo.new(MESSAGES[2], "3", 6000)
    TALKS["3"] = ShoutInfo.new(MESSAGES[3], "4", 4000)
    TALKS["4"] = ShoutInfo.new(MESSAGES[4], "5", 5000)
    TALKS["5"] = ShoutInfo.new(MESSAGES[5], "6", 3000)
    TALKS["8"] = ShoutInfo.new(MESSAGES[9], "9", 5000)
    TALKS["9"] = ShoutInfo.new(MESSAGES[10], "10", 5000)
    TALKS["12"] = ShoutInfo.new(MESSAGES[12], "13", 5000)
    TALKS["13"] = ShoutInfo.new(MESSAGES[13], "14", 5000)
    TALKS["15"] = ShoutInfo.new(MESSAGES[14], "16", 5000)
    TALKS["16"] = ShoutInfo.new(MESSAGES[15], "17", 5000)
    TALKS["18"] = ShoutInfo.new(MESSAGES[17], "19", 5000)
    TALKS["19"] = ShoutInfo.new(MESSAGES[18], "20", 5000)
    TALKS["21"] = ShoutInfo.new(MESSAGES[19], "22", 5000)
    TALKS["22"] = ShoutInfo.new(MESSAGES[20], "23", 400)
    TALKS["25"] = ShoutInfo.new(MESSAGES[21], "26", 5000)
    TALKS["26"] = ShoutInfo.new(MESSAGES[22], "27", 5400)

    WALKS["npc1_1"] = WalkInfo.new(Location.new(-56546, -56384, -2008, 0), "npc1_2", 1200)
    WALKS["npc1_2"] = WalkInfo.new(Location.new(-56597, -56384, -2008, 0), "npc1_3", 1200)
    WALKS["npc1_3"] = WalkInfo.new(Location.new(-56596, -56428, -2008, 0), "npc1_4", 1200)
    WALKS["npc1_4"] = WalkInfo.new(Location.new(-56593, -56474, -2008, 0), "npc1_5", 1000)
    WALKS["npc1_5"] = WalkInfo.new(Location.new(-56542, -56474, -2008, 0), "npc1_6", 1000)
    WALKS["npc1_6"] = WalkInfo.new(Location.new(-56493, -56473, -2008, 0), "npc1_7", 2000)
    WALKS["npc1_7"] = WalkInfo.new(Location.new(-56495, -56425, -2008, 0), "npc1_1", 4000)
    WALKS["npc2_1"] = WalkInfo.new(Location.new(-56550, -56291, -2008, 0), "npc2_2", 1200)
    WALKS["npc2_2"] = WalkInfo.new(Location.new(-56601, -56293, -2008, 0), "npc2_3", 1200)
    WALKS["npc2_3"] = WalkInfo.new(Location.new(-56603, -56247, -2008, 0), "npc2_4", 1200)
    WALKS["npc2_4"] = WalkInfo.new(Location.new(-56605, -56203, -2008, 0), "npc2_5", 1000)
    WALKS["npc2_5"] = WalkInfo.new(Location.new(-56553, -56202, -2008, 0), "npc2_6", 1100)
    WALKS["npc2_6"] = WalkInfo.new(Location.new(-56504, -56200, -2008, 0), "npc2_7", 2000)
    WALKS["npc2_7"] = WalkInfo.new(Location.new(-56503, -56243, -2008, 0), "npc2_1", 4000)
    WALKS["npc3_1"] = WalkInfo.new(Location.new(-56500, -56290, -2008, 0), "npc3_2", 1200)
    WALKS["npc3_2"] = WalkInfo.new(Location.new(-56551, -56313, -2008, 0), "npc3_3", 1200)
    WALKS["npc3_3"] = WalkInfo.new(Location.new(-56601, -56293, -2008, 0), "npc3_4", 1200)
    WALKS["npc3_4"] = WalkInfo.new(Location.new(-56651, -56294, -2008, 0), "npc3_5", 1200)
    WALKS["npc3_5"] = WalkInfo.new(Location.new(-56653, -56250, -2008, 0), "npc3_6", 1200)
    WALKS["npc3_6"] = WalkInfo.new(Location.new(-56654, -56204, -2008, 0), "npc3_7", 1200)
    WALKS["npc3_7"] = WalkInfo.new(Location.new(-56605, -56203, -2008, 0), "npc3_8", 1200)
    WALKS["npc3_8"] = WalkInfo.new(Location.new(-56554, -56202, -2008, 0), "npc3_9", 1200)
    WALKS["npc3_9"] = WalkInfo.new(Location.new(-56503, -56200, -2008, 0), "npc3_10", 1200)
    WALKS["npc3_10"] = WalkInfo.new(Location.new(-56502, -56244, -2008, 0), "npc3_1", 900)
    WALKS["npc4_1"] = WalkInfo.new(Location.new(-56495, -56381, -2008, 0), "npc4_2", 1200)
    WALKS["npc4_2"] = WalkInfo.new(Location.new(-56548, -56383, -2008, 0), "npc4_3", 1200)
    WALKS["npc4_3"] = WalkInfo.new(Location.new(-56597, -56383, -2008, 0), "npc4_4", 1200)
    WALKS["npc4_4"] = WalkInfo.new(Location.new(-56643, -56385, -2008, 0), "npc4_5", 1200)
    WALKS["npc4_5"] = WalkInfo.new(Location.new(-56639, -56436, -2008, 0), "npc4_6", 1200)
    WALKS["npc4_6"] = WalkInfo.new(Location.new(-56639, -56473, -2008, 0), "npc4_7", 1200)
    WALKS["npc4_7"] = WalkInfo.new(Location.new(-56589, -56473, -2008, 0), "npc4_8", 1200)
    WALKS["npc4_8"] = WalkInfo.new(Location.new(-56541, -56473, -2008, 0), "npc4_9", 1200)
    WALKS["npc4_9"] = WalkInfo.new(Location.new(-56496, -56473, -2008, 0), "npc4_10", 1200)
    WALKS["npc4_10"] = WalkInfo.new(Location.new(-56496, -56429, -2008, 0), "npc4_1", 900)
    WALKS["npc5_1"] = WalkInfo.new(Location.new(-56549, -56335, -2008, 0), "npc5_2", 1000)
    WALKS["npc5_2"] = WalkInfo.new(Location.new(-56599, -56337, -2008, 0), "npc5_3", 2000)
    WALKS["npc5_3"] = WalkInfo.new(Location.new(-56649, -56341, -2008, 0), "npc5_4", 26000)
    WALKS["npc5_4"] = WalkInfo.new(Location.new(-56600, -56341, -2008, 0), "npc5_5", 1000)
    WALKS["npc5_5"] = WalkInfo.new(Location.new(-56553, -56341, -2008, 0), "npc5_6", 1000)
    WALKS["npc5_6"] = WalkInfo.new(Location.new(-56508, -56331, -2008, 0), "npc5_2", 8000)
    WALKS["npc6_1"] = WalkInfo.new(Location.new(-56595, -56428, -2008, 0), "npc6_2", 1000)
    WALKS["npc6_2"] = WalkInfo.new(Location.new(-56596, -56383, -2008, 0), "npc6_3", 1000)
    WALKS["npc6_3"] = WalkInfo.new(Location.new(-56648, -56384, -2008, 0), "npc6_4", 1000)
    WALKS["npc6_4"] = WalkInfo.new(Location.new(-56645, -56429, -2008, 0), "npc6_5", 1000)
    WALKS["npc6_5"] = WalkInfo.new(Location.new(-56644, -56475, -2008, 0), "npc6_6", 1000)
    WALKS["npc6_6"] = WalkInfo.new(Location.new(-56595, -56473, -2008, 0), "npc6_7", 1000)
    WALKS["npc6_7"] = WalkInfo.new(Location.new(-56542, -56473, -2008, 0), "npc6_8", 1000)
    WALKS["npc6_8"] = WalkInfo.new(Location.new(-56492, -56472, -2008, 0), "npc6_9", 1200)
    WALKS["npc6_9"] = WalkInfo.new(Location.new(-56495, -56426, -2008, 0), "npc6_10", 2000)
    WALKS["npc6_10"] = WalkInfo.new(Location.new(-56540, -56426, -2008, 0), "npc6_1", 3000)
    WALKS["npc7_1"] = WalkInfo.new(Location.new(-56603, -56249, -2008, 0), "npc7_2", 1000)
    WALKS["npc7_2"] = WalkInfo.new(Location.new(-56601, -56294, -2008, 0), "npc7_3", 1000)
    WALKS["npc7_3"] = WalkInfo.new(Location.new(-56651, -56295, -2008, 0), "npc7_4", 1000)
    WALKS["npc7_4"] = WalkInfo.new(Location.new(-56653, -56248, -2008, 0), "npc7_5", 1000)
    WALKS["npc7_5"] = WalkInfo.new(Location.new(-56605, -56203, -2008, 0), "npc7_6", 1000)
    WALKS["npc7_6"] = WalkInfo.new(Location.new(-56554, -56202, -2008, 0), "npc7_7", 1000)
    WALKS["npc7_7"] = WalkInfo.new(Location.new(-56504, -56201, -2008, 0), "npc7_8", 1000)
    WALKS["npc7_8"] = WalkInfo.new(Location.new(-56502, -56247, -2008, 0), "npc7_9", 1200)
    WALKS["npc7_9"] = WalkInfo.new(Location.new(-56549, -56248, -2008, 0), "npc7_10", 2000)
    WALKS["npc7_10"] = WalkInfo.new(Location.new(-56549, -56248, -2008, 0), "npc7_1", 3000)
    WALKS["npc8_1"] = WalkInfo.new(Location.new(-56493, -56426, -2008, 0), "npc8_2", 1000)
    WALKS["npc8_2"] = WalkInfo.new(Location.new(-56497, -56381, -2008, 0), "npc8_3", 1200)
    WALKS["npc8_3"] = WalkInfo.new(Location.new(-56544, -56381, -2008, 0), "npc8_4", 1200)
    WALKS["npc8_4"] = WalkInfo.new(Location.new(-56596, -56383, -2008, 0), "npc8_5", 1200)
    WALKS["npc8_5"] = WalkInfo.new(Location.new(-56594, -56428, -2008, 0), "npc8_6", 900)
    WALKS["npc8_6"] = WalkInfo.new(Location.new(-56645, -56429, -2008, 0), "npc8_7", 1200)
    WALKS["npc8_7"] = WalkInfo.new(Location.new(-56647, -56384, -2008, 0), "npc8_8", 1200)
    WALKS["npc8_8"] = WalkInfo.new(Location.new(-56649, -56362, -2008, 0), "npc8_9", 9200)
    WALKS["npc8_9"] = WalkInfo.new(Location.new(-56654, -56429, -2008, 0), "npc8_10", 1200)
    WALKS["npc8_10"] = WalkInfo.new(Location.new(-56644, -56474, -2008, 0), "npc8_11", 900)
    WALKS["npc8_11"] = WalkInfo.new(Location.new(-56593, -56473, -2008, 0), "npc8_12", 1100)
    WALKS["npc8_12"] = WalkInfo.new(Location.new(-56543, -56472, -2008, 0), "npc8_13", 1200)
    WALKS["npc8_13"] = WalkInfo.new(Location.new(-56491, -56471, -2008, 0), "npc8_1", 1200)
    WALKS["npc9_1"] = WalkInfo.new(Location.new(-56505, -56246, -2008, 0), "npc9_2", 1000)
    WALKS["npc9_2"] = WalkInfo.new(Location.new(-56504, -56291, -2008, 0), "npc9_3", 1200)
    WALKS["npc9_3"] = WalkInfo.new(Location.new(-56550, -56291, -2008, 0), "npc9_4", 1200)
    WALKS["npc9_4"] = WalkInfo.new(Location.new(-56600, -56292, -2008, 0), "npc9_5", 1200)
    WALKS["npc9_5"] = WalkInfo.new(Location.new(-56603, -56248, -2008, 0), "npc9_6", 900)
    WALKS["npc9_6"] = WalkInfo.new(Location.new(-56653, -56249, -2008, 0), "npc9_7", 1200)
    WALKS["npc9_7"] = WalkInfo.new(Location.new(-56651, -56294, -2008, 0), "npc9_8", 1200)
    WALKS["npc9_8"] = WalkInfo.new(Location.new(-56650, -56316, -2008, 0), "npc9_9", 9200)
    WALKS["npc9_9"] = WalkInfo.new(Location.new(-56660, -56250, -2008, 0), "npc9_10", 1200)
    WALKS["npc9_10"] = WalkInfo.new(Location.new(-56656, -56205, -2008, 0), "npc9_11", 900)
    WALKS["npc9_11"] = WalkInfo.new(Location.new(-56606, -56204, -2008, 0), "npc9_12", 1100)
    WALKS["npc9_12"] = WalkInfo.new(Location.new(-56554, -56203, -2008, 0), "npc9_13", 1200)
    WALKS["npc9_13"] = WalkInfo.new(Location.new(-56506, -56203, -2008, 0), "npc9_1", 1200)
    WALKS["24"] = WalkInfo.new(Location.new(-56730, -56340, -2008, 0), "25", 1800)
    WALKS["27"] = WalkInfo.new(Location.new(-56702, -56340, -2008, 0), "29", 1800)
  end

  private def schedule_timer
    game_time = GameTimer.time
    hours = (game_time / 60) % 24
    minutes = game_time % 60
    hour_diff = 20 - hours
    if hour_diff < 0
      hour_diff = 24 - (hour_diff *= -1)
    end
    min_diff = 30 - minutes
    if min_diff < 0
      min_diff = 60 - (min_diff *= -1)
    end
    hour_diff *= 3600000
    min_diff *= 60000
    diff = hour_diff + min_diff

    debug { "Show starting at #{Time.local + diff.milliseconds}" }
    start_quest_timer("Start", 14400000, nil, nil, true)
  end

  private def auto_chat(npc, npc_string, type)
    npc.broadcast_packet(NpcSay.new(npc.l2id, type, npc.id, npc_string))
  end

  def on_spawn(npc)
    if @started
      case npc.id
      when 32433
        auto_chat(npc, MESSAGES[0], Say2::NPC_SHOUT)
        start_quest_timer("1", 30000, npc, nil)
      when 32431
        npc.set_intention(AI::MOVE_TO, Location.new(-56657, -56338, -2008, 33102))
        start_quest_timer("social1", 6000, npc, nil, true)
        start_quest_timer("7", 215000, npc, nil)
      when 32432
        start_quest_timer("social1", 6000, npc, nil, true)
        start_quest_timer("7", 215000, npc, nil)
      when 32442..32446
        start_quest_timer("11", 100000, npc, nil)
      when 32424..32428
        start_quest_timer("social1", 5500, npc, nil)
        start_quest_timer("social1", 12500, npc, nil)
        start_quest_timer("28", 19700, npc, nil)
      else
        # [automatically added else]
      end

    end

    super
  end

  def on_adv_event(event, npc, pc)
    if event.empty?
      warn { "Empty event for npc #{npc} and player #{pc}." }
      return
    end

    if event.casecmp?("Start")
      @started = true
      add_spawn(MC, -56698, -56430, -2008, 32768, false, 0)
    elsif npc && @started
      # TODO switch on event
      if event.casecmp?("6")
        auto_chat(npc, MESSAGES[6], Say2::NPC_SHOUT)
        npc.set_intention(AI::MOVE_TO, Location.new(-56511, -56647, -2008, 36863))
        npc.broadcast_packet(Music::NS22_F.packet)
        add_spawn(SINGERS[0], -56344, -56328, -2008, 32768, false, 224000)
        add_spawn(SINGERS[1], -56552, -56245, -2008, 36863, false, 224000)
        add_spawn(SINGERS[1], -56546, -56426, -2008, 28672, false, 224000)
        add_spawn(SINGERS[1], -56570, -56473, -2008, 28672, false, 224000)
        add_spawn(SINGERS[1], -56594, -56516, -2008, 28672, false, 224000)
        add_spawn(SINGERS[1], -56580, -56203, -2008, 36863, false, 224000)
        add_spawn(SINGERS[1], -56606, -56157, -2008, 36863, false, 224000)
        start_quest_timer("7", 215000, npc, nil)
      elsif event.casecmp?("7")
        case npc.id
        when 32433
          auto_chat(npc, MESSAGES[7], Say2::NPC_SHOUT)
          npc.set_intention(AI::MOVE_TO, Location.new(-56698, -56430, -2008, 32768))
          start_quest_timer("8", 12000, npc, nil)
        else
          cancel_quest_timer("social1", npc, nil)
          npc.set_intention(AI::MOVE_TO, Location.new(-56594, -56064, -2008, 32768))
        end
      elsif event.casecmp?("10")
        npc.set_intention(AI::MOVE_TO, Location.new(-56483, -56665, -2034, 32768))
        npc.broadcast_packet(Music::TP05_F.packet)
        start_quest_timer("npc1_1", 3000, add_spawn(CIRCUS[0], -56495, -56375, -2008, 32768, false, 101000), nil)
        start_quest_timer("npc2_1", 3000, add_spawn(CIRCUS[0], -56491, -56289, -2008, 32768, false, 101000), nil)
        start_quest_timer("npc3_1", 3000, add_spawn(CIRCUS[1], -56502, -56246, -2008, 32768, false, 101000), nil)
        start_quest_timer("npc4_1", 3000, add_spawn(CIRCUS[1], -56496, -56429, -2008, 32768, false, 101000), nil)
        start_quest_timer("npc5_1", 3500, add_spawn(CIRCUS[2], -56505, -56334, -2008, 32768, false, 101000), nil)
        start_quest_timer("npc6_1", 4000, add_spawn(CIRCUS[3], -56545, -56427, -2008, 32768, false, 101000), nil)
        start_quest_timer("npc7_1", 4000, add_spawn(CIRCUS[3], -56552, -56248, -2008, 32768, false, 101000), nil)
        start_quest_timer("npc8_1", 3000, add_spawn(CIRCUS[4], -56493, -56473, -2008, 32768, false, 101000), nil)
        start_quest_timer("npc9_1", 3000, add_spawn(CIRCUS[4], -56504, -56201, -2008, 32768, false, 101000), nil)
        start_quest_timer("11", 100000, npc, nil)
      elsif event.casecmp?("11")
        case npc.id
        when 32433
          auto_chat(npc, MESSAGES[11], Say2::NPC_SHOUT)
          npc.set_intention(AI::MOVE_TO, Location.new(-56698, -56430, -2008, 32768))
          start_quest_timer("12", 5000, npc, nil)
        else
          npc.set_intention(AI::MOVE_TO, Location.new(-56343, -56330, -2008, 32768))
        end
      elsif event.casecmp?("14")
        start_quest_timer("social1", 2000, add_spawn(INDIVIDUALS[0], -56700, -56385, -2008, 32768, false, 49000), nil)
        start_quest_timer("15", 7000, npc, nil)
      elsif event.casecmp?("17")
        auto_chat(npc, MESSAGES[16], Say2::NPC_SHOUT)
        start_quest_timer("social1", 2000, add_spawn(INDIVIDUALS[1], -56700, -56340, -2008, 32768, false, 32000), nil)
        start_quest_timer("18", 9000, npc, nil)
      elsif event.casecmp?("20")
        start_quest_timer("social1", 2000, add_spawn(INDIVIDUALS[2], -56703, -56296, -2008, 32768, false, 13000), nil)
        start_quest_timer("21", 8000, npc, nil)
      elsif event.casecmp?("23")
        npc.set_intention(AI::MOVE_TO, Location.new(-56702, -56340, -2008, 32768))
        start_quest_timer("24", 2800, npc, nil)
        add_spawn(SHOW_STUFF[0], -56672, -56406, -2000, 32768, false, 20900)
        add_spawn(SHOW_STUFF[1], -56648, -56368, -2000, 32768, false, 20900)
        add_spawn(SHOW_STUFF[2], -56608, -56338, -2000, 32768, false, 20900)
        add_spawn(SHOW_STUFF[3], -56652, -56307, -2000, 32768, false, 20900)
        add_spawn(SHOW_STUFF[4], -56672, -56272, -2000, 32768, false, 20900)
      elsif event.casecmp?("28")
        auto_chat(npc, MESSAGES[23], Say2::NPC_ALL)
        start_quest_timer("social1", 1, npc, nil)
      elsif event.casecmp?("29")
        npc.set_intention(AI::MOVE_TO, Location.new(-56730, -56340, -2008, 32768))
        start_quest_timer("clean_npc", 4100, npc, nil)
        start_quest_timer("timer_check", 60000, nil, nil, true)
      elsif event.casecmp?("social1")
        npc.broadcast_social_action(1)
      elsif event.casecmp?("clean_npc")
        @started = false
        npc.delete_me
      else
        if si = TALKS[event]?
          auto_chat(npc, si.npc_string_id, Say2::NPC_SHOUT)
          start_quest_timer(si.next_event, si.time, npc, nil)
        elsif wi = WALKS[event]?
          npc.set_intention(AI::MOVE_TO, wi.char_pos)
          start_quest_timer(wi.next_event, wi.time, npc, nil)
        end
      end
    end

    nil
  end
end
