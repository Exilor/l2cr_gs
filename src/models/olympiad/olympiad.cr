require "./olympiad_game_manager"
require "./olympiad_announcer"

class Olympiad < ListenersContainer
  include Singleton

  private alias SystemMessage = Packets::Outgoing::SystemMessage

  private NOBLES = {} of Int32 => StatsSet
  private HEROS_TO_BE = [] of StatsSet
  private NOBLES_RANK = {} of Int32 => Int32

  private HERO_IDS = {
    88,
    89,
    90,
    91,
    92,
    93,
    94,
    95,
    96,
    97,
    98,
    99,
    100,
    101,
    102,
    103,
    104,
    105,
    106,
    107,
    108,
    109,
    110,
    111,
    112,
    113,
    114,
    115,
    116,
    117,
    118,
    131,
    132,
    133,
    134
  }

  OLYMPIAD_HTML_PATH = "data/html/olympiad/"
  private OLYMPIAD_DELETE_ALL = "TRUNCATE olympiad_nobles"
  private OLYMPIAD_MONTH_CLEAR = "TRUNCATE olympiad_nobles_eom"
  private OLYMPIAD_MONTH_CREATE = "INSERT INTO olympiad_nobles_eom SELECT charId, class_id, olympiad_points, competitions_done, competitions_won, competitions_lost, competitions_drawn FROM olympiad_nobles"
  private OLYMPIAD_LOAD_DATA = "SELECT current_cycle, period, olympiad_end, validation_end, next_weekly_change FROM olympiad_data WHERE id = 0"
  private OLYMPIAD_SAVE_DATA = "INSERT INTO olympiad_data (id, current_cycle, period, olympiad_end, validation_end, next_weekly_change) VALUES (0,?,?,?,?,?) ON DUPLICATE KEY UPDATE current_cycle=?, period=?, olympiad_end=?, validation_end=?, next_weekly_change=?"
  private OLYMPIAD_LOAD_NOBLES = "SELECT olympiad_nobles.charId, olympiad_nobles.class_id, characters.char_name, olympiad_nobles.olympiad_points, olympiad_nobles.competitions_done, olympiad_nobles.competitions_won, olympiad_nobles.competitions_lost, olympiad_nobles.competitions_drawn, olympiad_nobles.competitions_done_week, olympiad_nobles.competitions_done_week_classed, olympiad_nobles.competitions_done_week_non_classed, olympiad_nobles.competitions_done_week_team FROM olympiad_nobles, characters WHERE characters.charId = olympiad_nobles.charId"
  private OLYMPIAD_SAVE_NOBLES = "INSERT INTO olympiad_nobles (`charId`,`class_id`,`olympiad_points`,`competitions_done`,`competitions_won`,`competitions_lost`,`competitions_drawn`, `competitions_done_week`, `competitions_done_week_classed`, `competitions_done_week_non_classed`, `competitions_done_week_team`) VALUES (?,?,?,?,?,?,?,?,?,?,?)"
  private OLYMPIAD_UPDATE_NOBLES = "UPDATE olympiad_nobles SET olympiad_points = ?, competitions_done = ?, competitions_won = ?, competitions_lost = ?, competitions_drawn = ?, competitions_done_week = ?, competitions_done_week_classed = ?, competitions_done_week_non_classed = ?, competitions_done_week_team = ? WHERE charId = ?"

  CHAR_ID = "charId"
  CLASS_ID = "class_id"
  CHAR_NAME = "char_name"
  POINTS = "olympiad_points"
  COMP_DONE = "competitions_done"
  COMP_WON = "competitions_won"
  COMP_LOST = "competitions_lost"
  COMP_DRAWN = "competitions_drawn"
  COMP_DONE_WEEK = "competitions_done_week"
  COMP_DONE_WEEK_CLASSED = "competitions_done_week_classed"
  COMP_DONE_WEEK_NON_CLASSED = "competitions_done_week_non_classed"
  COMP_DONE_WEEK_TEAM = "competitions_done_week_team"

  @olympiad_end = 0i64
  @validation_end = 0i64
  @next_weekly_change = 0i64
  @comp_end = 0i64
  @comp_start = Calendar.new
  @comp_started = false
  @scheduled_comp_start : TaskScheduler::DelayedTask?
  @scheduled_comp_end : TaskScheduler::DelayedTask?
  @scheduled_olympiad_end : TaskScheduler::DelayedTask?
  @scheduled_weekly_task : TaskScheduler::PeriodicTask?
  @scheduled_validation_task : TaskScheduler::DelayedTask?
  @game_manager : TaskScheduler::PeriodicTask?
  @game_announcer : TaskScheduler::PeriodicTask?

  getter current_cycle = 0
  getter period = 0
  getter? in_comp_period = false
  protected setter period : Int32

  class_getter(default_points) { Config.alt_oly_start_points }
  class_getter(weekly_points) { Config.alt_oly_weekly_points }

  private def initialize
    @OLYMPIAD_GET_HEROS = "SELECT olympiad_nobles.charId, characters.char_name FROM olympiad_nobles, characters WHERE characters.charId = olympiad_nobles.charId AND olympiad_nobles.class_id = ? AND olympiad_nobles.competitions_done >= #{Config.alt_oly_min_matches} AND olympiad_nobles.competitions_won > 0 ORDER BY olympiad_nobles.olympiad_points DESC, olympiad_nobles.competitions_done DESC, olympiad_nobles.competitions_won DESC"
    @GET_ALL_CLASSIFIED_NOBLESS = "SELECT charId from olympiad_nobles_eom WHERE competitions_done >= #{Config.alt_oly_min_matches} ORDER BY olympiad_points DESC, competitions_done DESC, competitions_won DESC"
    @GET_EACH_CLASS_LEADER = "SELECT characters.char_name from olympiad_nobles_eom, characters WHERE characters.charId = olympiad_nobles_eom.charId AND olympiad_nobles_eom.class_id = ? AND olympiad_nobles_eom.competitions_done >= #{Config.alt_oly_min_matches} ORDER BY olympiad_nobles_eom.olympiad_points DESC, olympiad_nobles_eom.competitions_done DESC, olympiad_nobles_eom.competitions_won DESC LIMIT 10"
    @GET_EACH_CLASS_LEADER_CURRENT = "SELECT characters.char_name from olympiad_nobles, characters WHERE characters.charId = olympiad_nobles.charId AND olympiad_nobles.class_id = ? AND olympiad_nobles.competitions_done >= #{Config.alt_oly_min_matches} ORDER BY olympiad_nobles.olympiad_points DESC, olympiad_nobles.competitions_done DESC, olympiad_nobles.competitions_won DESC LIMIT 10"
    @GET_EACH_CLASS_LEADER_SOULHOUND = "SELECT characters.char_name from olympiad_nobles_eom, characters WHERE characters.charId = olympiad_nobles_eom.charId AND (olympiad_nobles_eom.class_id = ? OR olympiad_nobles_eom.class_id = 133) AND olympiad_nobles_eom.competitions_done >= #{Config.alt_oly_min_matches} ORDER BY olympiad_nobles_eom.olympiad_points DESC, olympiad_nobles_eom.competitions_done DESC, olympiad_nobles_eom.competitions_won DESC LIMIT 10"
    @GET_EACH_CLASS_LEADER_CURRENT_SOULHOUND = "SELECT characters.char_name from olympiad_nobles, characters WHERE characters.charId = olympiad_nobles.charId AND (olympiad_nobles.class_id = ? OR olympiad_nobles.class_id = 133) AND olympiad_nobles.competitions_done >= #{Config.alt_oly_min_matches} ORDER BY olympiad_nobles.olympiad_points DESC, olympiad_nobles.competitions_done DESC, olympiad_nobles.competitions_won DESC LIMIT 10"
    @COMP_START = Config.alt_oly_start_time # 6PM
    @COMP_MIN = Config.alt_oly_min # 00 mins
    @COMP_PERIOD = Config.alt_oly_cperiod # 6 hours
    @WEEKLY_PERIOD = Config.alt_oly_wperiod # 1 week
    @VALIDATION_PERIOD = Config.alt_oly_vperiod # 24 hours
    @DEFAULT_POINTS = Config.alt_oly_start_points
    @WEEKLY_POINTS = Config.alt_oly_weekly_points

    load

    AntiFeedManager.register_event(AntiFeedManager::OLYMPIAD_ID)

    if @period == 0
      init
    end
  end

  private def load
    NOBLES.clear
    loaded = false

    begin
      GameDB.each(OLYMPIAD_LOAD_DATA) do |rs|
        @current_cycle = rs.get_i32(:"current_cycle")
        @period = rs.get_i32(:"period")
        @olympiad_end = rs.get_i64(:"olympiad_end")
        @validation_end = rs.get_i64(:"validation_end")
        @next_weekly_change = rs.get_i64(:"next_weekly_change")
        loaded = true
      end
    rescue e
      error e
    end

    unless loaded
      warn "Failed to load data from database. Trying to load from file."
      cfg = PropertiesReader.new
      cfg.parse(Dir.current + Config::OLYMPIAD_CONFIG_FILE)
      # error check

      @current_cycle = cfg.get_i32("CurrentCycle", 1)
      @period = cfg.get_i32("Period", 0)
      @olympiad_end = cfg.get_i64("OlympiadEnd", 0)
      @validation_end = cfg.get_i64("ValidationEnd", 0)
      @next_weekly_change = cfg.get_i64("NextWeeklyChange", 0)
    end

    case @period
    when 0
      if @olympiad_end == 0 || @olympiad_end < Time.ms
        set_new_olympiad_end
      else
        schedule_weekly_change
      end
    when 1
      if @validation_end > Time.ms
        load_nobles_rank
        @scheduled_validation_task = ThreadPoolManager.schedule_general(->validation_end_task, millis_to_validation_end)
      else
        @current_cycle += 1
        @period = 0
        delete_nobles
        set_new_olympiad_end
      end
    else
      raise "Wrong period #{@period}."
    end

    begin
      GameDB.each(OLYMPIAD_LOAD_NOBLES) do |rs|
        data = StatsSet {
          CLASS_ID => rs.get_i32(CLASS_ID),
          CHAR_NAME => rs.get_string(CHAR_NAME),
          POINTS => rs.get_i32(POINTS),
          COMP_DONE => rs.get_i32(COMP_DONE),
          COMP_WON => rs.get_i32(COMP_WON),
          COMP_LOST => rs.get_i32(COMP_LOST),
          COMP_DRAWN => rs.get_i32(COMP_DRAWN),
          COMP_DONE_WEEK => rs.get_i32(COMP_DONE_WEEK),
          COMP_DONE_WEEK_CLASSED => rs.get_i32(COMP_DONE_WEEK_CLASSED),
          COMP_DONE_WEEK_NON_CLASSED => rs.get_i32(COMP_DONE_WEEK_NON_CLASSED),
          COMP_DONE_WEEK_TEAM => rs.get_i32(COMP_DONE_WEEK_TEAM),
          "to_save" => false
        }
        add_noble_stats(rs.get_i32(CHAR_ID), data)
      end
    rescue e
      error e
    end

    sync do
      debug "Loading Olympiad system..."
      if @period == 0
        info "Currently in Olympiad period."
      else
        info "Currently in Validation period."
      end

      if @period == 0
        ms = millis_to_olympiad_end
      else
        ms = millis_to_validation_end
      end

      info { "#{ms // 60000} minutes until period ends." }

      if @period == 0
        ms = millis_to_week_change
        info { "Next weekly change is in #{ms // 60000} minutes." }
      end
    end

    info { "Loaded #{NOBLES.size} nobles." }
  end

  def load_nobles_rank
    NOBLES_RANK.clear
    tmp = {} of Int32 => Int32

    begin
      place = 1
      GameDB.each(@GET_ALL_CLASSIFIED_NOBLESS) do |rs|
        tmp[rs.get_i32(CHAR_ID)] = place
        place += 1
      end
    rescue e
      error e
    end

    rank1 = (tmp.size * 0.01).round.to_i
    rank2 = (tmp.size * 0.10).round.to_i
    rank3 = (tmp.size * 0.25).round.to_i
    rank4 = (tmp.size * 0.50).round.to_i

    if rank1 == 0
      rank1 = 1
      rank2 += 1
      rank3 += 1
      rank4 += 1
    end

    tmp.each do |key, val|
      if val <= rank1
        NOBLES_RANK[key] = 1
      elsif key <= rank2
        NOBLES_RANK[key] = 2
      elsif key <= rank3
        NOBLES_RANK[key] = 3
      elsif key <= rank4
        NOBLES_RANK[key] = 4
      else
        NOBLES_RANK[key] = 5
      end
    end
  end

  private def init
    if @period == 1
      return
    end

    @comp_start = Calendar.new
    @comp_start.hour = @COMP_START
    @comp_start.minute = @COMP_MIN
    @comp_end = @comp_start.ms + @COMP_PERIOD

    @scheduled_olympiad_end.try &.cancel

    # task = OlympiadEndTask.new(HEROS_TO_BE)
    task = ->olympiad_end_task
    delay = millis_to_olympiad_end
    @scheduled_olympiad_end = ThreadPoolManager.schedule_general(task, delay)

    update_comp_status
  end

  private def olympiad_end_task
    sm = SystemMessage.olympiad_period_s1_has_ended
    sm.add_int(Olympiad.instance.current_cycle)

    Broadcast.to_all_online_players(sm)
    Broadcast.to_all_online_players("Olympiad Validation Period has begun")

    if task = @scheduled_weekly_task
      task.cancel
    end

    save_noble_data

    @period = 1
    sort_heros_to_be
    Hero.reset_data
    Hero.compute_new_heroes(HEROS_TO_BE)

    save_olympiad_status
    update_monthly_data

    @validation_end = Time.ms + @VALIDATION_PERIOD

    load_nobles_rank
    task = ->validation_end_task
    delay = millis_to_validation_end
    @scheduled_validation_task = ThreadPoolManager.schedule_general(task, delay)
  end

  private def validation_end_task
    Broadcast.to_all_online_players("Olympiad Validation Period has ended")
    @period = 0
    @current_cycle += 1
    delete_nobles
    set_new_olympiad_end
    init
  end

  def self.noble_count : Int32
    NOBLES.size
  end

  def self.get_noble_stats(l2id) : StatsSet?
    NOBLES[l2id]?
  end

  private def update_comp_status
    sync do
      ms_to_start = millis_to_comp_begin

      num_secs = ms_to_start.fdiv(1000) % 60
      countdown = (ms_to_start.fdiv(1000) - num_secs) / 60
      num_mins = (countdown % 60).floor.to_i
      countdown = (countdown - num_mins) / 60
      num_hours = (countdown % 24).to_i
      num_days = ((countdown - num_hours) / 24).floor.to_i

      info { "Competition Period starts in #{num_days} days, #{num_hours} hours and #{num_mins} minutes." }
      info { "Event starts/started at #{@comp_start.time}" }

      scheduled_comp_task = -> do
        if olympiad_end?
          return
        end

        @in_comp_period = true

        sm = SystemMessage.the_olympiad_game_has_started
        Broadcast.to_all_online_players(sm)
        info "Olympiad Game Started."

        @game_manager = ThreadPoolManager.schedule_general_at_fixed_rate(OlympiadGameManager, 30000, 30000)
        if Config.alt_oly_announce_games
          @game_announcer = ThreadPoolManager.schedule_general_at_fixed_rate(OlympiadAnnouncer.new, 30000, 500)
        end

        reg_end = millis_to_comp_end - 600_000
        if reg_end > 0
          broadcast_task = -> do
            sm = SystemMessage.olympiad_registration_period_ended
            Broadcast.to_all_online_players(sm)
          end
          ThreadPoolManager.schedule_general(broadcast_task, reg_end)

          scheduled_comp_end = -> do
            if olympiad_end?
              return
            end

            @in_comp_period = false
            sm = SystemMessage.the_olympiad_game_has_ended
            Broadcast.to_all_online_players(sm)
            info "Olympiad Game ended"

            while OlympiadGameManager.battle_started?
              sleep(1.minute)
            end

            if task = @game_manager
              task.cancel
              @game_manager = nil
            end

            if task = @game_announcer
              task.cancel
              @game_manager = nil
            end

            save_olympiad_status

            init
          end

          @scheduled_comp_end = ThreadPoolManager.schedule_general(scheduled_comp_end, millis_to_comp_end)
        end
      end

      @scheduled_comp_task = ThreadPoolManager.schedule_general(scheduled_comp_task, millis_to_comp_begin)
    end
  end

  private def millis_to_olympiad_end : Int64
    @olympiad_end - Time.ms
  end

  def manual_select_heroes
    if task = @scheduled_olympiad_end
      task.cancel
    end

    task = ->olympiad_end_task
    @scheduled_olympiad_end = ThreadPoolManager.schedule_general(task, 0)
  end

  private def millis_to_validation_end : Int64
    time = Time.ms
    if @validation_end > time
      return @validation_end - time
    end

    10i64
  end

  def olympiad_end? : Bool
    @period != 0
  end

  private def set_new_olympiad_end
    sm = SystemMessage.olympiad_period_s1_has_started
    sm.add_int(@current_cycle)

    Broadcast.to_all_online_players(sm)

    cal = Calendar.new
    cal.add(:MONTH, 1)
    cal.day = 1
    cal.hour = 12
    cal.minute = 0
    cal.second = 0
    @olympiad_end = Time.ms

    @next_weekly_change = Time.ms + @WEEKLY_PERIOD
    schedule_weekly_change
  end

  def millis_to_comp_begin : Int64
    time = Time.ms

    if @comp_start.ms < time && @comp_end > time
      return 10i64
    end

    if @comp_start.ms > time
      return @comp_start.ms - time
    end

    set_new_comp_begin
  end

  private def set_new_comp_begin : Int64
    @comp_start = Calendar.new
    @comp_start.hour = @COMP_START
    @comp_start.minute = @COMP_MIN
    @comp_start.add(:DAY, 1)
    @comp_end = @comp_start.ms + @COMP_PERIOD

    info { "New schedule: #{@comp_start.time}." }

    @comp_start.ms - Time.ms
  end

  def millis_to_comp_end : Int64
    @comp_end - Time.ms
  end

  def millis_to_week_change : Int64
    time = Time.ms

    if @next_weekly_change > time
      return @next_weekly_change - time
    end

    10i64
  end

  private def schedule_weekly_change
    task = -> do
      add_weekly_points
      info "Added weekly points to nobles."
      reset_weekly_matches
      info "Reset weekly matches to nobles."

      @next_weekly_change = Time.ms + @WEEKLY_PERIOD
    end

    delay = millis_to_week_change
    @scheduled_weekly_task = ThreadPoolManager.schedule_general_at_fixed_rate(task, delay, @WEEKLY_PERIOD)
  end

  private def add_weekly_points
    sync do
      if @period == 1
        return
      end

      NOBLES.each_value do |info|
        points = info.get_i32(POINTS)
        points += @WEEKLY_POINTS
        info[POINTS] = points
      end
    end
  end

  private def reset_weekly_matches
    sync do
      if @period == 1
        return
      end

      NOBLES.each_value do |info|
        info[COMP_DONE_WEEK] = 0
        info[COMP_DONE_WEEK_CLASSED] = 0
        info[COMP_DONE_WEEK_NON_CLASSED] = 0
        info[COMP_DONE_WEEK_TEAM] = 0
      end
    end
  end

  def player_in_stadium?(pc : L2PcInstance) : Bool
    !!ZoneManager.get_olympiad_stadium(pc)
  end

  private def save_noble_data
    sync do
      if NOBLES.empty?
        return
      end

      begin
        NOBLES.each do |char_id, info|
          class_id = info.get_i32(CLASS_ID)
          points = info.get_i32(POINTS)
          comp_done = info.get_i32(COMP_DONE)
          comp_won = info.get_i32(COMP_WON)
          comp_lost = info.get_i32(COMP_LOST)
          comp_drawn = info.get_i32(COMP_DRAWN)
          comp_done_week = info.get_i32(COMP_DONE_WEEK)
          comp_done_week_classed = info.get_i32(COMP_DONE_WEEK_CLASSED)
          comp_done_week_non_classed = info.get_i32(COMP_DONE_WEEK_NON_CLASSED)
          comp_done_week_team = info.get_i32(COMP_DONE_WEEK_TEAM)
          to_save = info.get_bool("to_save")

          if to_save
            GameDB.exec(
              OLYMPIAD_SAVE_NOBLES,
              char_id,
              class_id,
              points,
              comp_done,
              comp_won,
              comp_lost,
              comp_drawn,
              comp_done_week,
              comp_done_week_classed,
              comp_done_week_non_classed,
              comp_done_week_team
            )
            info["to_save"] = false
          else
            GameDB.exec(
              OLYMPIAD_UPDATE_NOBLES,
              points,
              comp_done,
              comp_won,
              comp_lost,
              comp_drawn,
              comp_done_week,
              comp_done_week_classed,
              comp_done_week_non_classed,
              comp_done_week_team,
              char_id
            )
          end
        end
      rescue e
        error e
      end
    end
  end

  def save_olympiad_status
    save_noble_data

    begin
      GameDB.exec(
        OLYMPIAD_SAVE_DATA,
        @current_cycle,
        @period,
        @olympiad_end,
        @validation_end,
        @next_weekly_change,
        @current_cycle,
        @period,
        @olympiad_end,
        @validation_end,
        @next_weekly_change
      )
    rescue e
      error e
    end
  end

  private def update_monthly_data
    GameDB.exec(OLYMPIAD_MONTH_CLEAR)
    GameDB.exec(OLYMPIAD_MONTH_CREATE)
  rescue e
    error e
  end

  private def sort_heros_to_be
    if @period != 1
      return
    end

    # logging

    soul_hounds = [] of StatsSet

    HERO_IDS.each do |element|
      GameDB.each(@OLYMPIAD_GET_HEROS, element) do |rs|
        hero = StatsSet.new
        hero[CLASS_ID] = element
        hero[CHAR_ID] = rs.get_i32(CHAR_ID)
        hero[CHAR_NAME] = rs.get_i32(CHAR_NAME)

        if element == 132 || element == 133 # male and female soulhounds
          hero = NOBLES[hero.get_i32(CHAR_ID)]
          hero[CHAR_ID] = rs.get_i32(CHAR_ID)
          soul_hounds << hero
        else
          # logging
          HEROS_TO_BE << hero
        end
      end
    end

    case soul_hounds.size
    when 0
      # do nothing
    when 1
      hero = StatsSet.new
      winner = soul_hounds[0]
      hero[CLASS_ID] = winner.get_i32(CLASS_ID)
      hero[CHAR_ID] = winner.get_i32(CHAR_ID)
      hero[CHAR_NAME] = winner.get_string(CHAR_NAME)

      # logging

      HEROS_TO_BE << hero
    when 2
      hero = StatsSet.new
      hero1, hero2 = soul_hounds
      hero_1_points = hero1.get_i32(POINTS)
      hero_2_points = hero2.get_i32(POINTS)
      hero_1_comps = hero1.get_i32(COMP_DONE)
      hero_2_comps = hero2.get_i32(COMP_DONE)
      hero_1_wins = hero1.get_i32(COMP_WON)
      hero_2_wins = hero2.get_i32(COMP_WON)

      if hero_1_points > hero_2_points
        winner = hero1
      elsif hero_2_points > hero_1_points
        winner = hero2
      else
        if hero_1_comps > hero_2_comps
          winner = hero1
        elsif hero_2_comps > hero_1_comps
          winner = hero2
        else
          if hero_1_wins > hero_2_wins
            winner = hero1
          else
            winner = hero2
          end
        end
      end

      hero[CLASS_ID] = winner.get_i32(CLASS_ID)
      hero[CHAR_ID] = winner.get_i32(CHAR_ID)
      hero[CHAR_NAME] = winner.get_string(CHAR_NAME)

      # logging

      HEROS_TO_BE << hero
    end


  rescue e
    error e
  end

  def get_class_leader_board(class_id : Int32) : Array(String)
    names = [] of String
    if Config.alt_oly_show_monthly_winners
      if class_id == 134
        sql = @GET_EACH_CLASS_LEADER_SOULHOUND
      else
        sql = @GET_EACH_CLASS_LEADER
      end
    else
      if class_id == 132
        sql = @GET_EACH_CLASS_LEADER_CURRENT_SOULHOUND
      else
        sql = @GET_EACH_CLASS_LEADER_CURRENT
      end
    end

    begin
      GameDB.each(sql, class_id) do |rs|
        name = rs.get_string(CHAR_NAME)
        names << name
      end
    rescue e
      error "Couldn't load olympiad leaders from DB."
      error e
    end

    names
  end

  def get_noblesse_passes(pc : L2PcInstance, clear : Bool) : Int32
    if @period != 1 || NOBLES_RANK.empty?
      return 0
    end

    l2id = pc.l2id

    unless rank = NOBLES_RANK[l2id]?
      return 0
    end

    unless noble = NOBLES[l2id]?
      return 0
    end

    if noble.get_i32(POINTS) == 0
      return 0
    end

    if pc.hero? || Hero.unclaimed_hero?(l2id)
      points = Config.alt_oly_hero_points
    else
      points = 0
    end

    case rank
    when 1
      points += Config.alt_oly_rank1_points
    when 2
      points += Config.alt_oly_rank2_points
    when 3
      points += Config.alt_oly_rank3_points
    when 4
      points += Config.alt_oly_rank4_points
    else
      points += Config.alt_oly_rank5_points
    end

    if clear
      noble[POINTS] = 0
    end

    points * Config.alt_oly_gp_per_point
  end

  def get_noble_points(l2id : Int32) : Int32
    if tmp = NOBLES[l2id]?
      return tmp.get_i32(POINTS)
    end

    0
  end

  def get_last_noble_olympiad_points(l2id : Int32) : Int32
    ret = 0

    begin
      sql = "SELECT olympiad_points FROM olympiad_nobles_eom WHERE charId = ?"
      GameDB.query_each(sql, l2id) do |rs|
        ret = rs.read(Int32)
      end
    rescue e
      error e
    end

    ret
  end

  def get_competition_done(l2id : Int32) : Int32
    if tmp = NOBLES[l2id]?
      return tmp.get_i32(COMP_DONE)
    end

    0
  end

  def get_competition_won(l2id : Int32) : Int32
    if tmp = NOBLES[l2id]?
      return tmp.get_i32(COMP_WON)
    end

    0
  end

  def get_competition_lost(l2id : Int32) : Int32
    if tmp = NOBLES[l2id]?
      return tmp.get_i32(COMP_LOST)
    end

    0
  end

  def get_competition_done_week(l2id : Int32) : Int32
    if tmp = NOBLES[l2id]?
      return tmp.get_i32(COMP_DONE_WEEK)
    end

    0
  end

  def get_competition_done_week_classed(l2id : Int32) : Int32
    if tmp = NOBLES[l2id]?
      return tmp.get_i32(COMP_DONE_WEEK_CLASSED)
    end

    0
  end

  def get_competition_done_week_non_classed(l2id : Int32) : Int32
    if tmp = NOBLES[l2id]?
      return tmp.get_i32(COMP_DONE_WEEK_NON_CLASSED)
    end

    0
  end

  def get_competition_done_week_team(l2id : Int32) : Int32
    if tmp = NOBLES[l2id]?
      return tmp.get_i32(COMP_DONE_WEEK_TEAM)
    end

    0
  end

  def get_remaining_weekly_matches(l2id : Int32) : Int32
    Math.max(Config.alt_oly_max_weekly_matches - get_competition_done_week(l2id), 0)
  end

  def get_remaining_weekly_matches_classed(l2id : Int32) : Int32
    Math.max(Config.alt_oly_max_weekly_matches_classed - get_competition_done_week_classed(l2id), 0)
  end

  def get_remaining_weekly_matches_non_classed(l2id : Int32) : Int32
    Math.max(Config.alt_oly_max_weekly_matches_non_classed - get_competition_done_week_non_classed(l2id), 0)
  end

  def get_remaining_weekly_matches_team(l2id : Int32) : Int32
    Math.max(Config.alt_oly_max_weekly_matches_team - get_competition_done_week_team(l2id), 0)
  end

  private def delete_nobles
    begin
      GameDB.exec(OLYMPIAD_DELETE_ALL)
    rescue e
      error "Couldn't delete nobles from DB."
      error e
    end

    NOBLES.clear
  end

  def add_noble_stats(l2id : Int32, data : StatsSet)
    NOBLES[l2id] = data
  end

  def self.add_noble_stats(*args)
    instance.add_noble_stats(*args)
  end

  def self.in_comp_period? : Bool
    instance.in_comp_period?
  end
end
