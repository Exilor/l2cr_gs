require "./models/calendar"
require "./models/auto_spawn_handler"

module SevenSigns
  extend self
  extend Loggable
  include Packets::Outgoing

  SEVEN_SIGNS_HTML_PATH = "data/html/seven_signs/"

  CABAL_NULL = 0
  CABAL_DUSK = 1
  CABAL_DAWN = 2

  SEAL_NULL = 0
  SEAL_AVARICE = 1
  SEAL_GNOSIS = 2
  SEAL_STRIFE = 3

  PERIOD_COMP_RECRUITING = 0
  PERIOD_COMPETITION = 1
  PERIOD_COMP_RESULTS = 2
  PERIOD_SEAL_VALIDATION = 3

  PERIOD_START_HOUR = 18
  PERIOD_START_MINS = 0
  PERIOD_START_DAY = Calendar::MONDAY

  # The quest event and seal validation periods last for approximately one week
  # with a 15 minutes "interval" period sandwiched between them.
  PERIOD_MINOR_LENGTH = 900000
  PERIOD_MAJOR_LENGTH = 604800000 - PERIOD_MINOR_LENGTH

  RECORD_SEVEN_SIGNS_ID = 5707
  RECORD_SEVEN_SIGNS_COST = 500i64

  # NPC Related Constants
  ORATOR_NPC_ID = 31094
  PREACHER_NPC_ID = 31093
  MAMMON_MERCHANT_ID = 31113
  MAMMON_BLACKSMITH_ID = 31126
  MAMMON_MARKETEER_ID = 31092
  LILITH_NPC_ID = 25283
  ANAKIM_NPC_ID = 25286
  CREST_OF_DAWN_ID = 31170
  CREST_OF_DUSK_ID = 31171
  # Seal Stone Related Constants
  SEAL_STONE_BLUE_ID = 6360
  SEAL_STONE_GREEN_ID = 6361
  SEAL_STONE_RED_ID = 6362

  SEAL_STONE_IDS = {
    SEAL_STONE_BLUE_ID,
    SEAL_STONE_GREEN_ID,
    SEAL_STONE_RED_ID
  }

  SEAL_STONE_BLUE_VALUE = 3
  SEAL_STONE_GREEN_VALUE = 5
  SEAL_STONE_RED_VALUE = 10

  BLUE_CONTRIB_POINTS = 3
  GREEN_CONTRIB_POINTS = 5
  RED_CONTRIB_POINTS = 10

  private LOAD_DATA = "SELECT charId, cabal, seal, red_stones, green_stones, blue_stones, ancient_adena_amount, contribution_score FROM seven_signs"
  private LOAD_STATUS = "SELECT * FROM seven_signs_status WHERE id=0"
  private INSERT_PLAYER = "INSERT INTO seven_signs (charId, cabal, seal) VALUES (?,?,?)"
  private UPDATE_PLAYER = "UPDATE seven_signs SET cabal=?, seal=?, red_stones=?, green_stones=?, blue_stones=?, ancient_adena_amount=?, contribution_score=? WHERE charId=?"
  private UPDATE_STATUS = "UPDATE seven_signs_status SET current_cycle=?, active_period=?, previous_winner=?, dawn_stone_score=?, dawn_festival_score=?, dusk_stone_score=?, dusk_festival_score=?, " \
    "avarice_owner=?, gnosis_owner=?, strife_owner=?, avarice_dawn_score=?, gnosis_dawn_score=?, strife_dawn_score=?, avarice_dusk_score=?, gnosis_dusk_score=?, strife_dusk_score=?, festival_cycle=?, accumulated_bonus0=?, accumulated_bonus1=?, accumulated_bonus2=?," \
    "accumulated_bonus3=?, accumulated_bonus4=?, date=? WHERE id=0"

  private SIGNS_PLAYER_DATA = {} of Int32 => StatsSet
  private SIGNS_SEAL_OWNERS = {} of Int32 => Int32
  private SIGNS_DUSK_SEAL_TOTALS = {} of Int32 => Int32
  private SIGNS_DAWN_SEAL_TOTALS = {} of Int32 => Int32

  @@last_save = Calendar.new
  @@next_period_change = Calendar.new
  @@active_period = 0
  @@dawn_stone_score = 0.0
  @@dusk_stone_score = 0.0
  @@dawn_festival_score = 0
  @@dusk_festival_score = 0
  @@comp_winner = 0
  @@previous_winner = 0

  class_getter current_cycle = 0

  def load
    restore_seven_signs_data

    info "Currently in the #{current_period_name} period."

    initialize_seals

    if seal_validation_period?
      if cabal_highest_score == CABAL_NULL
        info "The competition ended with a tie last week."
      else
        info "The #{get_cabal_name(cabal_highest_score)} were victorious last week."
      end
    elsif cabal_highest_score == CABAL_NULL
      info "The competition, if the current trend continues, will end in a tie this week."
    else
      info "The #{get_cabal_name(cabal_highest_score)} are in the lead this week."
    end

    milli_to_change = 0

    if next_period_change_in_past?
      info "Next period change occurred while the server was offline. Changing periods now."
    else
      set_calendar_for_next_period_change
      milli_to_change = milli_to_period_change
    end

    sspc = ->seven_signs_period_change
    ThreadPoolManager.schedule_general(sspc, milli_to_change)

    num_secs   = (milli_to_change / 1000) % 60
    count_down = ((milli_to_change / 1000.0) - num_secs) / 60
    num_mins   = (count_down % 60).floor.to_i
    count_down = (count_down - num_mins) / 60
    num_hours  = (count_down % 24).floor.to_i
    num_days   = ((count_down - num_hours) / 24).floor.to_i

    info "Next period begins in #{num_days} days, #{num_hours} hours and #{num_mins} mins."
  end

  def current_period
    @@active_period
  end

  private def next_period_change_in_past?
    last_period_change = Calendar.new
    case current_period
    when PERIOD_SEAL_VALIDATION, PERIOD_COMPETITION
      last_period_change.day_of_week = PERIOD_START_DAY
      last_period_change.hour = PERIOD_START_HOUR
      last_period_change.minute = PERIOD_START_MINS
      last_period_change.second = 0
      if Calendar.new < last_period_change
        last_period_change.add(-7.days)
      end
    when PERIOD_COMP_RECRUITING, PERIOD_COMP_RESULTS
      last_period_change.ms = @@last_save.ms + PERIOD_MINOR_LENGTH
    end

    @@last_save.ms > 7 && @@last_save < last_period_change
  end

  def spawn_seven_signs_npc
    merchant_spawn = AutoSpawnHandler.get_auto_spawn_instance(MAMMON_MERCHANT_ID, false)
    blacksmith_spawn = AutoSpawnHandler.get_auto_spawn_instance(MAMMON_BLACKSMITH_ID, false)
    lilith_spawn = AutoSpawnHandler.get_auto_spawn_instance(LILITH_NPC_ID, false)
    anakim_spawn = AutoSpawnHandler.get_auto_spawn_instance(ANAKIM_NPC_ID, false)
    crest_of_dawn_spawns = AutoSpawnHandler.get_auto_spawn_instances(CREST_OF_DAWN_ID)
    crest_of_dusk_spawns = AutoSpawnHandler.get_auto_spawn_instances(CREST_OF_DUSK_ID)
    orator_spawns = AutoSpawnHandler.get_auto_spawn_instances(ORATOR_NPC_ID)
    preacher_spawns = AutoSpawnHandler.get_auto_spawn_instances(PREACHER_NPC_ID)
    marketeer_spawns = AutoSpawnHandler.get_auto_spawn_instances(MAMMON_MARKETEER_ID)

    if seal_validation_period? || comp_results_period?
      marketeer_spawns.each do |spawn_inst|
        AutoSpawnHandler.set_spawn_active(spawn_inst, true)
      end

      if get_seal_owner(SEAL_GNOSIS) == cabal_highest_score && get_seal_owner(SEAL_GNOSIS) != CABAL_NULL
        unless Config.announce_mammon_spawn
          blacksmith_spawn.broadcast = false
        end

        unless AutoSpawnHandler.get_auto_spawn_instance(blacksmith_spawn.l2id, true).spawn_active?
          AutoSpawnHandler.set_spawn_active(blacksmith_spawn, true)
        end

        orator_spawns.each do |spawn_inst|
          unless AutoSpawnHandler.get_auto_spawn_instance(spawn_inst.l2id, true).spawn_active?
            AutoSpawnHandler.set_spawn_active(spawn_inst, true)
          end
        end

        preacher_spawns.each do |spawn_inst|
          unless AutoSpawnHandler.get_auto_spawn_instance(spawn_inst.l2id, true).spawn_active?
            AutoSpawnHandler.set_spawn_active(spawn_inst, true)
          end
        end
      else
        AutoSpawnHandler.set_spawn_active(blacksmith_spawn, false)

        orator_spawns.each do |spawn_inst|
          AutoSpawnHandler.set_spawn_active(spawn_inst, false)
        end

        preacher_spawns.each do |spawn_inst|
          AutoSpawnHandler.set_spawn_active(spawn_inst, false)
        end
      end

      if (get_seal_owner(SEAL_AVARICE) == cabal_highest_score) && (get_seal_owner(SEAL_AVARICE) != CABAL_NULL)
        unless Config.announce_mammon_spawn
          merchant_spawn.broadcast = false
        end

        unless AutoSpawnHandler.get_auto_spawn_instance(merchant_spawn.l2id, true).spawn_active?
          AutoSpawnHandler.set_spawn_active(merchant_spawn, true)
        end

        case (cabal_highest_score)
        when CABAL_DAWN
          unless AutoSpawnHandler.get_auto_spawn_instance(lilith_spawn.l2id, true).spawn_active?
            AutoSpawnHandler.set_spawn_active(lilith_spawn, true)
          end

          AutoSpawnHandler.set_spawn_active(anakim_spawn, false)

          crest_of_dawn_spawns.each do |dawn_crest|
            unless AutoSpawnHandler.get_auto_spawn_instance(dawn_crest.l2id, true).spawn_active?
              AutoSpawnHandler.set_spawn_active(dawn_crest, true)
            end
          end

          crest_of_dusk_spawns.each do |dusk_crest|
            AutoSpawnHandler.set_spawn_active(dusk_crest, false)
          end

        when CABAL_DUSK
          unless AutoSpawnHandler.get_auto_spawn_instance(anakim_spawn.l2id, true).spawn_active?
            AutoSpawnHandler.set_spawn_active(anakim_spawn, true)
          end

          AutoSpawnHandler.set_spawn_active(lilith_spawn, false)

          crest_of_dusk_spawns.each do |dusk_crest|
            unless AutoSpawnHandler.get_auto_spawn_instance(dusk_crest.l2id, true).spawn_active?
              AutoSpawnHandler.set_spawn_active(dusk_crest, true)
            end
          end

          crest_of_dawn_spawns.each do |dawn_crest|
            AutoSpawnHandler.set_spawn_active(dawn_crest, false)
          end
        end
      else
        AutoSpawnHandler.set_spawn_active(merchant_spawn, false)
        AutoSpawnHandler.set_spawn_active(lilith_spawn, false)
        AutoSpawnHandler.set_spawn_active(anakim_spawn, false)
        crest_of_dawn_spawns.each do |dawn_crest|
          AutoSpawnHandler.set_spawn_active(dawn_crest, false)
        end
        crest_of_dusk_spawns.each do |dusk_crest|
          AutoSpawnHandler.set_spawn_active(dusk_crest, false)
        end
      end
    else
      AutoSpawnHandler.set_spawn_active(merchant_spawn, false)
      AutoSpawnHandler.set_spawn_active(blacksmith_spawn, false)
      AutoSpawnHandler.set_spawn_active(lilith_spawn, false)
      AutoSpawnHandler.set_spawn_active(anakim_spawn, false)
      crest_of_dawn_spawns.each do |dawn_crest|
        AutoSpawnHandler.set_spawn_active(dawn_crest, false)
      end
      crest_of_dusk_spawns.each do |dusk_crest|
        AutoSpawnHandler.set_spawn_active(dusk_crest, false)
      end
      orator_spawns.each do |spawn_inst|
        AutoSpawnHandler.set_spawn_active(spawn_inst, false)
      end

      preacher_spawns.each do |spawn_inst|
        AutoSpawnHandler.set_spawn_active(spawn_inst, false)
      end

      marketeer_spawns.each do |spawn_inst|
        AutoSpawnHandler.set_spawn_active(spawn_inst, false)
      end
    end
  end

  def calc_contribution_score(blue : Int64, green : Int64, red : Int64) : Int64
    ret =  blue  * BLUE_CONTRIB_POINTS
    ret += green * GREEN_CONTRIB_POINTS
    ret + (red   * RED_CONTRIB_POINTS)
  end

  def calc_ancient_adena_reward(blue : Int64, green : Int64, red : Int64) : Int64
    ret =  blue  * SEAL_STONE_BLUE_VALUE
    ret += green * SEAL_STONE_GREEN_VALUE
    ret + (red   * SEAL_STONE_RED_VALUE)
  end

  def get_cabal_short_name(num : Int) : String
    case num
    when CABAL_DAWN; "dawn"
    when CABAL_DUSK; "dusk"
    else "No Cabal"
    end
  end

  def get_cabal_name(num : Int) : String
    case num
    when CABAL_DAWN; "Lords of Dawn"
    when CABAL_DUSK; "Revolutionaries of Dusk"
    else "No Cabal"
    end
  end

  def get_seal_name(seal : Int, shorten : Bool) : String
    case seal
    when SEAL_AVARICE; shorten ? "Avarice" : "Seal of Avarice"
    when SEAL_GNOSIS;  shorten ? "Gnosis"  : "Seal of Gnosis"
    when SEAL_STRIFE;  shorten ? "Strife"  : "Seal of Strife"
    else shorten ? "" : "Seal of"
    end
  end

  private def days_to_period_change : Int64
    days = @@next_period_change.day_of_week - PERIOD_START_DAY
    days < 0 ? 0i64 - days : 7i64 - days
  end

  def milli_to_period_change : Int64
    @@next_period_change.ms - Time.ms
  end

  def set_calendar_for_next_period_change
    case current_period
    when PERIOD_SEAL_VALIDATION, PERIOD_COMPETITION
      days_to_change = days_to_period_change
      # debug "days to change: #{days_to_change}"
      if days_to_change == 7
        if @@next_period_change.hour < PERIOD_START_HOUR
          days_to_change = 0
        elsif @@next_period_change.hour == PERIOD_START_DAY
          if @@next_period_change.minute < PERIOD_START_MINS
            days_to_change = 0
          end
        end
      end

      if days_to_change > 0
        @@next_period_change.add(days_to_change.days)
      end

      @@next_period_change.hour = PERIOD_START_HOUR
      @@next_period_change.minute = PERIOD_START_MINS
    when PERIOD_COMP_RECRUITING, PERIOD_COMP_RESULTS
      @@next_period_change.add(PERIOD_MINOR_LENGTH.milliseconds) # 15 mins
    end

    # debug "active period: #{@@active_period}"

    info "Next period change set to #{@@next_period_change.time}."
  end

  def current_period_name : String? # i think the last when should be an else
    case @@active_period
    when PERIOD_COMP_RECRUITING; "Quest Event Initialization"
    when PERIOD_COMPETITION; "Competition (Quest Event)"
    when PERIOD_COMP_RESULTS; "Quest Event Results"
    when PERIOD_SEAL_VALIDATION; "Seal Validation"
    end
  end

  def competition_period? : Bool
    @@active_period == PERIOD_COMPETITION
  end

  def seal_validation_period? : Bool
    @@active_period == PERIOD_SEAL_VALIDATION
  end

  def comp_results_period? : Bool
    @@active_period == PERIOD_COMP_RESULTS
  end

  def date_in_seal_valid_period?(date : Calendar) : Bool
    next_period_change = milli_to_period_change
    next_quest_start = 0
    next_valid_start = 0
    till_date = date.ms - Time.ms
    while ((2 * PERIOD_MAJOR_LENGTH) + (2 * PERIOD_MINOR_LENGTH)) < till_date
      till_date -= (2 * PERIOD_MAJOR_LENGTH) + (2 * PERIOD_MINOR_LENGTH)
    end
    while till_date < 0
      till_date += (2 * PERIOD_MAJOR_LENGTH) + (2 * PERIOD_MINOR_LENGTH)
    end

    case current_period
    when PERIOD_COMP_RECRUITING
      next_valid_start = next_period_change + PERIOD_MAJOR_LENGTH
      next_quest_start = next_valid_start + PERIOD_MAJOR_LENGTH + PERIOD_MINOR_LENGTH
    when PERIOD_COMPETITION
      next_valid_start = next_period_change
      next_quest_start = next_period_change + PERIOD_MAJOR_LENGTH + PERIOD_MINOR_LENGTH
    when PERIOD_COMP_RESULTS
      next_quest_start = next_period_change + PERIOD_MAJOR_LENGTH
      next_valid_start = next_quest_start + PERIOD_MAJOR_LENGTH + PERIOD_MINOR_LENGTH
    when PERIOD_SEAL_VALIDATION
      next_quest_start = next_period_change
      next_valid_start = next_period_change + PERIOD_MAJOR_LENGTH + PERIOD_MINOR_LENGTH
    end

    !(
      ((next_quest_start < till_date) && (till_date < next_valid_start)) ||
      ((next_valid_start < next_quest_start) &&
      ((till_date < next_valid_start) || (next_quest_start < till_date)))
    )
  end

  def get_current_score(cabal : Int) : Int32
    total = @@dawn_stone_score.to_f64 + @@dusk_stone_score
    case cabal
    when CABAL_DAWN
      ((@@dawn_stone_score.to_f32 / (total.to_f32 == 0 ? 1 : total)) * 500).round + @@dawn_festival_score
    when CABAL_DUSK
      ((@@dusk_stone_score.to_f32 / (total.to_f32 == 0 ? 1 : total)) * 500).round + @@dusk_festival_score
    else 0
    end
    .to_i32
  end

  def get_current_stone_score(cabal : Int) : Float64
    case cabal
    when CABAL_DAWN
      @@dawn_stone_score
    when CABAL_DUSK
      @@dusk_stone_score
    else
      0.0
    end
  end

  def get_current_festival_score(cabal : Int) : Int32
    case cabal
    when CABAL_DAWN
      @@dawn_festival_score
    when CABAL_DUSK
      @@dusk_festival_score
    else
      0
    end
  end

  def cabal_highest_score : Int32
    if get_current_score(CABAL_DUSK) == get_current_score(CABAL_DAWN)
      CABAL_NULL
    elsif get_current_score(CABAL_DUSK) > get_current_score(CABAL_DAWN)
      CABAL_DUSK
    else
      CABAL_DAWN
    end
  end

  def get_seal_owner(seal : Int) : Int32
    SIGNS_SEAL_OWNERS[seal]
  end

  def get_seal_proportion(seal : Int, cabal : Int) : Int32
    case cabal
    when CABAL_NULL; 0
    when CABAL_DUSK; SIGNS_DUSK_SEAL_TOTALS[seal]
    else SIGNS_DAWN_SEAL_TOTALS[seal]
    end
  end

  def get_total_members(cabal : Int) : Int32
    members = 0
    name = get_cabal_short_name(cabal)
    SIGNS_PLAYER_DATA.each_value do |data|
      if data.get_string("cabal") == name
        members += 1
      end
    end

    members
  end

  def get_player_stone_contrib(l2id : Int) : Int32
    return 0 unless data = SIGNS_PLAYER_DATA[l2id]?
    data.get_i32("red_stones") +
    data.get_i32("green_stones") +
    data.get_i32("blue_stones")
  end

  def get_player_contrib_score(l2id : Int) : Int32
    SIGNS_PLAYER_DATA[l2id]?.try &.get_i32("contribution_score") || 0
  end

  def get_player_adena_collect(l2id : Int) : Int32
    SIGNS_PLAYER_DATA[l2id]?.try &.get_i32("ancient_adena_amount") || 0
  end

  def get_player_seal(l2id : Int) : Int32
    SIGNS_PLAYER_DATA[l2id]?.try &.get_i32("seal") || SEAL_NULL
  end

  def get_player_cabal(l2id : Int) : Int32
    return CABAL_NULL unless data = SIGNS_PLAYER_DATA[l2id]?

    cabal = data.get_string("cabal")
    if cabal.casecmp?("dawn")
      CABAL_DAWN
    elsif cabal.casecmp?("dusk")
      CABAL_DUSK
    else
      CABAL_NULL
    end
  end

  def restore_seven_signs_data
    GameDB.each(LOAD_DATA) do |rs|
      char_id = rs.get_i32("charId")
      dat = StatsSet.new
      dat["charId"] = char_id
      dat["cabal"] = rs.get_string("cabal")
      dat["seal"] = rs.get_i32("seal")
      dat["red_stones"] = rs.get_i32("red_stones")
      dat["green_stones"] = rs.get_i32("green_stones")
      dat["blue_stones"] = rs.get_i32("blue_stones")
      dat["ancient_adena_amount"] = rs.get_f64("ancient_adena_amount")
      dat["contribution_score"] = rs.get_f64("contribution_score")
      SIGNS_PLAYER_DATA[char_id] = dat
    end

    GameDB.each(LOAD_STATUS) do |rs|
      @@current_cycle = rs.get_i32("current_cycle")
      @@active_period = rs.get_i32("active_period")
      @@previous_winner = rs.get_i32("previous_winner")
      @@dawn_stone_score = rs.get_f64("dawn_stone_score")
      @@dawn_festival_score = rs.get_i32("dawn_festival_score")
      @@dusk_stone_score = rs.get_f64("dusk_stone_score")
      @@dusk_festival_score = rs.get_i32("dusk_festival_score")
      SIGNS_SEAL_OWNERS[SEAL_AVARICE] = rs.get_i32("avarice_owner")
      SIGNS_SEAL_OWNERS[SEAL_GNOSIS] = rs.get_i32("gnosis_owner")
      SIGNS_SEAL_OWNERS[SEAL_STRIFE] = rs.get_i32("strife_owner")
      SIGNS_DAWN_SEAL_TOTALS[SEAL_AVARICE] = rs.get_i32("avarice_dawn_score")
      SIGNS_DAWN_SEAL_TOTALS[SEAL_GNOSIS] = rs.get_i32("gnosis_dawn_score")
      SIGNS_DAWN_SEAL_TOTALS[SEAL_STRIFE] = rs.get_i32("strife_dawn_score")
      SIGNS_DUSK_SEAL_TOTALS[SEAL_AVARICE] = rs.get_i32("avarice_dusk_score")
      SIGNS_DUSK_SEAL_TOTALS[SEAL_GNOSIS] = rs.get_i32("gnosis_dusk_score")
      SIGNS_DUSK_SEAL_TOTALS[SEAL_STRIFE] = rs.get_i32("strife_dusk_score")
      @@last_save.ms = rs.get_i64("date")
    end
  rescue e
    error e
  end

  def save_seven_signs_data
    SIGNS_PLAYER_DATA.each_value do |dat|
      GameDB.exec(
        UPDATE_PLAYER,
        dat.get_string("cabal"),
        dat.get_i32("seal"),
        dat.get_i32("red_stones"),
        dat.get_i32("green_stones"),
        dat.get_i32("blue_stones"),
        dat.get_f64("ancient_adena_amount"),
        dat.get_f64("contribution_score"),
        dat.get_i32("charId")
      )
    end
  rescue e
    error e
  end

  def save_seven_signs_data(l2id : Int)
    return unless dat = SIGNS_PLAYER_DATA[l2id]?
    # p dat
    GameDB.exec(
      UPDATE_PLAYER,
      dat.get_string("cabal"),
      dat.get_i32("seal"),
      dat.get_i32("red_stones"),
      dat.get_i32("green_stones"),
      dat.get_i32("blue_stones"),
      dat.get_f64("ancient_adena_amount"),
      dat.get_f64("contribution_score"),
      dat.get_i32("charId")
    )
  rescue e
    error e
  end

  def save_seven_signs_status
    @@last_save = Calendar.new
    GameDB.exec(
      UPDATE_STATUS,
      @@current_cycle,
      @@active_period,
      @@previous_winner,
      @@dawn_stone_score,
      @@dawn_festival_score,
      @@dusk_stone_score,
      @@dusk_festival_score,
      SIGNS_SEAL_OWNERS[SEAL_AVARICE],
      SIGNS_SEAL_OWNERS[SEAL_GNOSIS],
      SIGNS_SEAL_OWNERS[SEAL_STRIFE],
      SIGNS_DAWN_SEAL_TOTALS[SEAL_AVARICE],
      SIGNS_DAWN_SEAL_TOTALS[SEAL_GNOSIS],
      SIGNS_DAWN_SEAL_TOTALS[SEAL_STRIFE],
      SIGNS_DUSK_SEAL_TOTALS[SEAL_AVARICE],
      SIGNS_DUSK_SEAL_TOTALS[SEAL_GNOSIS],
      SIGNS_DUSK_SEAL_TOTALS[SEAL_STRIFE],
      SevenSignsFestival.current_festival_cycle,
      SevenSignsFestival.get_accumulated_bonus(0),
      SevenSignsFestival.get_accumulated_bonus(1),
      SevenSignsFestival.get_accumulated_bonus(2),
      SevenSignsFestival.get_accumulated_bonus(3),
      SevenSignsFestival.get_accumulated_bonus(4),
      @@last_save.ms
    )
  rescue e
    error e
  end

  def reset_player_data
    SIGNS_PLAYER_DATA.each_value do |data|
      data["cabal"] = ""
      data["seal"] = SEAL_NULL
      data["contribution_score"] = 0
    end
  end

  def set_player_info(id : Int32, cabal : Int32, seal : Int32) : Int32
    if data = SIGNS_PLAYER_DATA[id]?
      data["cabal"] = get_cabal_short_name(cabal)
      data["seal"] = seal
    else
      data = StatsSet.new
      data["charId"] = id
      data["cabal"] = get_cabal_short_name(cabal)
      data["seal"] = seal
      data["red_stones"] = 0
      data["green_stones"] = 0
      data["blue_stones"] = 0
      data["ancient_adena_amount"] = 0
      data["contribution_score"] = 0
      SIGNS_PLAYER_DATA[id] = data

      begin
        GameDB.exec(
          INSERT_PLAYER,
          id,
          get_cabal_short_name(cabal),
          seal
        )
      rescue e
        error e
      end
    end

    if data["cabal"] == "dawn"
      SIGNS_DAWN_SEAL_TOTALS[seal] += 1
    else
      SIGNS_DUSK_SEAL_TOTALS[seal] += 1
    end

    unless Config.alt_sevensigns_lazy_update
      save_seven_signs_status
    end

    cabal
  end

  def get_ancient_adena_reward(id : Int, remove : Bool) : Int32
    data = SIGNS_PLAYER_DATA[id]
    amount = data.get_i32("ancient_adena_amount")

    data["red_stones"] = 0
    data["green_stones"] = 0
    data["blue_stones"] = 0
    data["ancient_adena_amount"] = 0

    if remove
      SIGNS_PLAYER_DATA[id] = data
      unless Config.alt_sevensigns_lazy_update
        save_seven_signs_data(id)
        save_seven_signs_status
      end
    end

    amount
  end

  def add_player_stone_contrib(id : Int32, blue : Int64, green : Int64, red : Int64) : Int64
    data = SIGNS_PLAYER_DATA[id]
    contrib_score = calc_contribution_score(blue, green, red)
    total_ancient_adena = data.get_i64("ancient_adena_amount") + calc_ancient_adena_reward(blue, green, red)
    total_contrib_score = data.get_i64("contribution_score") + contrib_score
    if total_contrib_score > Config.alt_maximum_player_contrib
      return -1i64
    end

    data["red_stones"] = data.get_i32("red_stones") + red
    data["green_stones"] = data.get_i32("green_stones") + green
    data["blue_stones"] = data.get_i32("blue_stones") + blue
    data["ancient_adena_amount"] = total_ancient_adena
    data["contribution_score"] = total_contrib_score

    case get_player_cabal(id)
    when CABAL_DAWN
      @@dawn_stone_score += contrib_score
    when CABAL_DUSK
      @@dusk_stone_score += contrib_score
    end

    unless Config.alt_sevensigns_lazy_update
      save_seven_signs_data(id)
      save_seven_signs_status
    end

    contrib_score
  end

  def add_festival_score(cabal : Int, amount : Int)
    if cabal == CABAL_DUSK
      @@dusk_festival_score += amount
      if @@dawn_festival_score >= amount
        @@dawn_festival_score -= amount
      end
    else
      @@dawn_festival_score += amount
      if @@dusk_festival_score >= amount
        @@dusk_festival_score -= amount
      end
    end
  end

  def send_current_period_msg(pc : L2PcInstance)
    case current_period
    when PERIOD_COMP_RECRUITING
      pc.send_packet(SystemMessageId::PREPARATIONS_PERIOD_BEGUN)
    when PERIOD_COMPETITION
      pc.send_packet(SystemMessageId::COMPETITION_PERIOD_BEGUN)
    when PERIOD_COMP_RESULTS
      pc.send_packet(SystemMessageId::RESULTS_PERIOD_BEGUN)
    when PERIOD_SEAL_VALIDATION
      pc.send_packet(SystemMessageId::VALIDATION_PERIOD_BEGUN)
    end
  end

  def initialize_seals
    SIGNS_SEAL_OWNERS.each do |key, value|
      if value != CABAL_NULL
        if seal_validation_period?
          info "The #{get_cabal_name(value)} have won the #{get_seal_name(key, false)}."
        else
          info "The #{get_seal_name(key, false)} is currently owned by #{get_cabal_name(value)}."
        end
      else
        info "The #{get_seal_name(key, false)} remains unclaimed."
      end
    end
  end

  def reset_seals
    SIGNS_DAWN_SEAL_TOTALS[SEAL_AVARICE] = 0
    SIGNS_DAWN_SEAL_TOTALS[SEAL_GNOSIS]  = 0
    SIGNS_DAWN_SEAL_TOTALS[SEAL_STRIFE]  = 0
    SIGNS_DUSK_SEAL_TOTALS[SEAL_AVARICE] = 0
    SIGNS_DUSK_SEAL_TOTALS[SEAL_GNOSIS]  = 0
    SIGNS_DUSK_SEAL_TOTALS[SEAL_STRIFE]  = 0
  end

  def calc_new_seal_owners
    SIGNS_DAWN_SEAL_TOTALS.each_key do |seal|
      prev_seal_owner = SIGNS_SEAL_OWNERS[seal]
      new_seal_owner = CABAL_NULL
      dawn_proportion = get_seal_proportion(seal, CABAL_DAWN)
      total_dawn_members = Math.max(get_total_members(CABAL_DAWN), 1)
      dawn_percent = (dawn_proportion.fdiv(total_dawn_members) * 100).round.to_i
      dusk_proportion = get_seal_proportion(seal, CABAL_DUSK)
      total_dusk_members = Math.max(get_total_members(CABAL_DUSK), 1)
      dusk_percent = (dusk_proportion.fdiv(total_dusk_members) * 100).round.to_i

      case prev_seal_owner
      when CABAL_NULL
        case cabal_highest_score
        when CABAL_NULL
          new_seal_owner = CABAL_NULL
        when CABAL_DAWN
          if dawn_percent >= 35
            new_seal_owner = CABAL_DAWN
          else
            new_seal_owner = CABAL_NULL
          end
        when CABAL_DUSK
          if dusk_percent >= 35
            new_seal_owner = CABAL_DUSK
          else
            new_seal_owner = CABAL_NULL
          end
        end
      when CABAL_DAWN
        case cabal_highest_score
        when CABAL_NULL
          if dawn_percent >= 10
            new_seal_owner = CABAL_DAWN
          else
            new_seal_owner = CABAL_NULL
          end
        when CABAL_DAWN
          if dawn_percent >= 10
            new_seal_owner = CABAL_DAWN
          else
            new_seal_owner = CABAL_NULL
          end
        when CABAL_DUSK
          if dusk_percent >= 35
            new_seal_owner = CABAL_DUSK
          elsif dawn_percent >= 10
            new_seal_owner = CABAL_DAWN
          else
            new_seal_owner = CABAL_NULL
          end
        end
      when CABAL_DUSK
        case cabal_highest_score
        when CABAL_NULL
          if dusk_percent >= 10
            new_seal_owner = CABAL_DUSK
          else
            new_seal_owner = CABAL_NULL
          end
        when CABAL_DAWN
          if dawn_percent >= 35
            new_seal_owner = CABAL_DAWN
          elsif dusk_percent >= 10
            new_seal_owner = CABAL_DUSK
          else
            new_seal_owner = CABAL_NULL
          end
        when CABAL_DUSK
          if dusk_percent >= 10
            new_seal_owner = CABAL_DUSK
          else
            new_seal_owner = CABAL_NULL
          end
        end
      end

      SIGNS_SEAL_OWNERS[seal] = new_seal_owner

      case seal
      when SEAL_AVARICE
        if new_seal_owner == CABAL_DAWN
          send_message_to_all(SystemMessageId::DAWN_OBTAINED_AVARICE)
        elsif new_seal_owner == CABAL_DUSK
          send_message_to_all(SystemMessageId::DUSK_OBTAINED_AVARICE)
        end
      when SEAL_GNOSIS
        if new_seal_owner == CABAL_DAWN
          send_message_to_all(SystemMessageId::DAWN_OBTAINED_GNOSIS)
        elsif new_seal_owner == CABAL_DUSK
          send_message_to_all(SystemMessageId::DUSK_OBTAINED_GNOSIS)
        end
      when SEAL_STRIFE
        if new_seal_owner == CABAL_DAWN
          send_message_to_all(SystemMessageId::DAWN_OBTAINED_STRIFE)
        elsif new_seal_owner == CABAL_DUSK
          send_message_to_all(SystemMessageId::DUSK_OBTAINED_STRIFE)
        end

        CastleManager.validate_taxes(new_seal_owner)
      end
    end
  end

  def tele_losing_cabal_from_dungeons(winner : String)
    L2World.players.each do |pc|
      data = SIGNS_PLAYER_DATA[pc.l2id]?

      if seal_validation_period? || comp_results_period?
        if !pc.gm? && pc.in_7s_dungeon? && (data.nil? || data.get_string("cabal") == winner)
          pc.tele_to_location(TeleportWhereType::TOWN)
          pc.in_7s_dungeon = false
          pc.send_message("You have been teleported to the nearest town due to the beginning of the Seal Validation period.")
        end
      else
        if !pc.gm? && pc.in_7s_dungeon? && (data.nil? || data.get_string("cabal").empty?)
          pc.tele_to_location(TeleportWhereType::TOWN)
          pc.in_7s_dungeon = false
          pc.send_message("You have been teleported to the nearest town because you have not signed for any cabal.")
        end
      end
    end
  end

  def check_is_dawn_posting_ticket(item_id : Int) : Bool
    (item_id > 6114 && item_id < 6175) || (item_id > 6801 && item_id < 6812) ||
    (item_id > 7997 && item_id < 8008) || (item_id > 7940 && item_id < 7951) ||
    (item_id > 6294 && item_id < 6307) || (item_id > 6831 && item_id < 6834) ||
    (item_id > 8027 && item_id < 8030) || (item_id > 7970 && item_id < 7973)
  end

  def check_is_rookie_posting_ticket(item_id : Int) : Bool
    (item_id > 6174) && (item_id < 6295) ||
    (item_id > 6811) && (item_id < 6832) ||
    (item_id > 7950) && (item_id < 7971) ||
    (item_id > 8007) && (item_id < 8028)
  end

  def give_cp_mult(strife_owner : Int)
    skill1 = CommonSkill::THE_VICTOR_OF_WAR.skill
    skill2 = CommonSkill::THE_VANQUISHED_OF_WAR.skill

    L2World.players.each do |pc|
      cabal = get_player_cabal(pc.l2id)
      if cabal != CABAL_NULL
        if cabal == strife_owner
          pc.add_skill(skill1)
        else
          pc.add_skill(skill2)
        end
      end
    end
  end

  def remove_cp_mult
    skill1 = CommonSkill::THE_VICTOR_OF_WAR.skill
    skill2 = CommonSkill::THE_VANQUISHED_OF_WAR.skill

    L2World.players.each do |pc|
      pc.remove_skill(skill1)
      pc.remove_skill(skill2)
    end
  end

  def check_summon_conditions(pc : L2PcInstance?) : Bool
    return true unless pc

    if seal_validation_period?
      if get_seal_owner(SEAL_STRIFE) == CABAL_DAWN
        if get_player_cabal(pc.l2id) == CABAL_DUSK
          pc.send_packet(SystemMessageId::SEAL_OF_STRIFE_FORBIDS_SUMMONING)
          return true
        end
      end
    end

    false
  end

  private def seven_signs_period_change
    period_ended = current_period
    @@active_period += 1
    case period_ended
    when PERIOD_COMP_RECRUITING
      SevenSignsFestival.start_festival_manager
      send_message_to_all(SystemMessageId::QUEST_EVENT_PERIOD_BEGUN)
    when PERIOD_COMPETITION
      send_message_to_all(SystemMessageId::QUEST_EVENT_PERIOD_ENDED)
      winner = cabal_highest_score
      SevenSignsFestival.festival_manager_schedule.cancel
      SevenSignsFestival.reward_highest_ranked
      calc_new_seal_owners
      case winner
      when CABAL_DAWN
        send_message_to_all(SystemMessageId::DAWN_WON)
      when CABAL_DUSK
        send_message_to_all(SystemMessageId::DUSK_WON)
      end

      @@previous_winner = winner

      CastleManager.castles.each do |castle|
        castle.ticket_buy_count = 0
      end
    when PERIOD_COMP_RESULTS
      initialize_seals
      give_cp_mult(get_seal_owner(SEAL_STRIFE))
      send_message_to_all(SystemMessageId::SEAL_VALIDATION_PERIOD_BEGUN)
      info "The #{get_cabal_name(@@previous_winner)} have won the competition with #{get_current_score(@@previous_winner)} points."
    when PERIOD_SEAL_VALIDATION
      @@active_period = PERIOD_COMP_RECRUITING
      send_message_to_all(SystemMessageId::SEAL_VALIDATION_PERIOD_ENDED)
      remove_cp_mult
      reset_player_data
      reset_seals
      @@current_cycle += 1
      SevenSignsFestival.reset_festival_data(false)
      @@dawn_stone_score = 0.0
      @@dusk_stone_score = 0.0
      @@dawn_festival_score = 0
      @@dusk_festival_score = 0
    end

    save_seven_signs_data
    save_seven_signs_status

    tele_losing_cabal_from_dungeons(get_cabal_short_name(cabal_highest_score))

    ss = SSQInfo.new
    Broadcast.to_all_online_players(ss)

    spawn_seven_signs_npc

    info "The #{current_period_name} has begun."

    set_calendar_for_next_period_change

    sspc = ->seven_signs_period_change
    ThreadPoolManager.schedule_general(sspc, milli_to_period_change)
  end

  private def send_message_to_all(sm_id : SystemMessageId)
    Broadcast.to_all_online_players(SystemMessage[sm_id])
  end
end

require "./seven_signs_festival"
