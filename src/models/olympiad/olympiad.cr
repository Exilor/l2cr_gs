class Olympiad < ListenersContainer
  include Synchronizable
  include Loggable

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

  private OLYMPIAD_DELETE_ALL = "TRUNCATE olympiad_nobles"
  private OLYMPIAD_MONTH_CLEAR = "TRUNCATE olympiad_nobles_eom"
  private OLYMPIAD_MONTH_CREATE = "INSERT INTO olympiad_nobles_eom SELECT charId, class_id, olympiad_points, competitions_done, competitions_won, competitions_lost, competitions_drawn FROM olympiad_nobles"
  private OLYMPIAD_HTML_PATH = "data/html/olympiad/"
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
  protected setter period = 0
  @next_weekly_change = 0i64
  @current_cycle = 0
  @comp_end = 0i64
  @comp_start : Calendar?
  @comp_period = false
  @comp_started = false
  @scheduled_comp_start : Runnable::DelayedTask?
  @scheduled_comp_end : Runnable::DelayedTask?
  @scheduled_olympiad_end : Runnable::DelayedTask?
  @scheduled_weekly_task : Runnable::DelayedTask?
  @scheduled_validation_task : Runnable::DelayedTask?
  @game_manager : Runnable::DelayedTask?
  @game_announcer : Runnable::DelayedTask?

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
        @current_cycle = rs.get_i32("current_cycle")
        @period = rs.get_i32("period")
        @olympiad_end = rs.get_i32("olympiad_end")
        @validation_end = rs.get_i32("validation_end")
        @next_weekly_change = rs.get_i32("next_weekly_change")
        loaded = true
      end
    rescue e
      error e
    end

    unless loaded
      warn "Failed to load data from database. Trying to load from file."
      cfg = StatsSet.new
      cfg.parse(Config::OLYMPIAD_CONFIG_FILE)
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
        @scheduled_validation_task = ThreadPoolManager.schedule_general(ValidationEndTask.new, millis_to_validation_end)
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
      info "Loading Olympiad system..."
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

      info "#{ms / 60000} minutes until period ends."

      if @period == 0
        ms = millis_to_week_change
        info "Next weekly change is in #{ms / 60000} minutes."
      end
    end

    info "Loaded #{NOBLES.size} nobles."
  end

  def load_nobles_rank
    NOBLES_RANK.clear
    tmp = {} of Int32 => Int32

    begin
      place = 1
      GameDB.each(GET_ALL_CLASSIFIED_NOBLESS) do |rs|
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
    @comp_start.hour = COMP_START
    @comp_start.minute = COMP_MIN
    @comp_end = @comp_start.ms + COMP_PERIOD

    @scheduled_olympiad_end.try &.cancel

    @scheduled_olympiad_end = ThreadPoolManager.schedule_general(OlympiadEndTask.new(HEROS_TO_BE), millis_to_olympiad_end)
    update_comp_status
  end

  private struct OlympiadEndTask
    include Runnable

    initializer heroes_to_be: Array(StatsSet)

    def run
    end
  end

  def self.instance
    @@instance ||= new
  end
end
