module BotReportTable
  extend self
  include Loggable
  extend Synchronizable
  extend XMLReader
  include Packets::Outgoing

  private COLUMN_BOT_ID = 1
  private COLUMN_REPORTER_ID = 2
  private COLUMN_REPORT_TIME = 3

  ATTACK_ACTION_BLOCK_ID = -1
  TRADE_ACTION_BLOCK_ID = -2
  PARTY_ACTION_BLOCK_ID = -3
  ACTION_BLOCK_ID = -4
  CHAT_BLOCK_ID = -5

  private SQL_LOAD_REPORTED_CHAR_DATA = "SELECT * FROM bot_reported_char_data"
  private SQL_INSERT_REPORTED_CHAR_DATA = "INSERT INTO bot_reported_char_data VALUES (?,?,?)"
  private SQL_CLEAR_REPORTED_CHAR_DATA = "DELETE FROM bot_reported_char_data"

  private IP_REGISTRY = {} of Int32 => Int64
  private CHAR_REGISTRY = {} of Int32 => ReporterCharData
  private CHAR_REGISTRY_LOCK = Mutex.new(:Reentrant)
  private REPORTS = Concurrent::Map(Int32, ReportedCharData).new
  private PUNISHMENTS = Concurrent::Map(Int32, PunishHolder).new

  def load
    if Config.botreport_enable
      begin
        path = Dir.current + "/config/botreport_punishments.xml"
        XMLReader.parse_file(path) do |doc|
          parse_document(doc)
        end
      rescue e
        error { "Could not load punishments from '#{path}'." }
      end

      load_reported_char_data
      schedule_reset_point_task
    end
  end

  private def load_reported_char_data
    last_reset_time = 0i64
    begin
      hour = Config.botreport_resetpoint_hour
      c = Calendar.new
      c.hour = hour[0].to_i
      c.minute = hour[1].to_i

      if Time.ms < c.ms
        c.day_of_year &-= 1
      end

      last_reset_time = c.ms
    rescue e
      error e
    end

    GameDB.each(SQL_LOAD_REPORTED_CHAR_DATA) do |rs|
      bot_id = rs.get_i32(COLUMN_BOT_ID)
      reporter = rs.get_i32(COLUMN_REPORTER_ID)
      date = rs.get_i64(COLUMN_REPORT_TIME)
      if tmp = REPORTS[bot_id]?
        tmp.add_reporter(reporter, date)
      else
        rcd = ReportedCharData.new
        rcd.add_reporter(reporter, date)
        REPORTS[rs.get_i32(COLUMN_BOT_ID)] = rcd
      end

      if date > last_reset_time
        if rcd = CHAR_REGISTRY[reporter]?
          rcd.points = rcd.points - 1
        else
          rcd = ReporterCharData.new
          rcd.points = 6
          CHAR_REGISTRY[reporter] = rcd
        end
      end
    end

    info { "Loaded #{REPORTS.size} bot reports." }
  rescue e
    error e
  end

  def save_reported_char_data
    GameDB.transaction do |tr|
      tr.exec(SQL_CLEAR_REPORTED_CHAR_DATA)
      REPORTS.each do |key, value|
        report_table = value.reporters
        report_table.each do |k, v|
          tr.exec(SQL_INSERT_REPORTED_CHAR_DATA, key, k, v)
        end
      end
    end
  rescue e
    error e
  end

  def report_bot(reporter : L2PcInstance) : Bool
    return false unless target = reporter.target

    bot = target.acting_player

    if bot.nil? || target.l2id == reporter.l2id
      return false
    end

    if bot.inside_peace_zone? || bot.inside_pvp_zone?
      reporter.send_packet(SystemMessageId::YOU_CANNOT_REPORT_CHARACTER_IN_PEACE_OR_BATTLE_ZONE)
      return false
    end

    if bot.in_olympiad_mode?
      reporter.send_packet(SystemMessageId::TARGET_NOT_REPORT_CANNOT_REPORT_PEACE_PVP_ZONE_OR_OLYMPIAD_OR_CLAN_WAR_ENEMY)
      return false
    end

    if (clan = bot.clan) && clan.at_war_with?(reporter.clan)
      reporter.send_packet(SystemMessageId::YOU_CANNOT_REPORT_CLAN_WAR_ENEMY)
      return false
    end

    if bot.exp == bot.stat.starting_exp
      reporter.send_packet(SystemMessageId::YOU_CANNOT_REPORT_CHAR_WHO_ACQUIRED_XP)
      return false
    end

    rcd = REPORTS[bot.l2id]?
    rcd_rep = CHAR_REGISTRY[reporter.l2id]?
    reporter_id = reporter.l2id

    sync do
      if REPORTS.has_key?(reporter_id)
        reporter.send_packet(SystemMessageId::YOU_HAVE_BEEN_REPORTED_AND_CANNOT_REPORT)
        return false
      end

      ip = hash_ip(reporter)
      unless time_has_passed?(IP_REGISTRY, ip)
        reporter.send_packet(SystemMessageId::CANNOT_REPORT_TARGET_ALREDY_REPORTED_BY_CLAN_ALLY_MEMBER_OR_SAME_IP)
        return false
      end

      if rcd
        if rcd.already_reported_by?(reporter_id)
          reporter.send_packet(SystemMessageId::YOU_CANNOT_REPORT_CHAR_AT_THIS_TIME_1)
          return false
        end

        if !Config.botreport_allow_reports_from_same_clan_members && rcd.reported_by_same_clan?(reporter.clan)
          reporter.send_packet(SystemMessageId::CANNOT_REPORT_TARGET_ALREDY_REPORTED_BY_CLAN_ALLY_MEMBER_OR_SAME_IP)
          return false
        end
      end

      if rcd_rep
        if rcd_rep.points == 0
          reporter.send_packet(SystemMessageId::YOU_HAVE_USED_ALL_POINTS_POINTS_ARE_RESET_AT_NOON)
          return false
        end

        reuse = Time.ms - rcd_rep.last_report_time
        if reuse < Config.botreport_report_delay
          sm = SystemMessage.you_can_report_in_s1_mins_you_have_s2_points_left
          sm.add_int(reuse // 60_000)
          sm.add_int(rcd_rep.points)
          reporter.send_packet(sm)
          return false
        end
      end

      cur_time = Time.ms

      unless rcd
        rcd = ReportedCharData.new
        REPORTS[bot.l2id] = rcd
      end
      rcd.add_reporter(reporter_id, cur_time)

      unless rcd_rep
        rcd_rep = ReporterCharData.new
      end
      rcd_rep.register_report(cur_time)

      IP_REGISTRY[ip] = cur_time
      CHAR_REGISTRY[reporter_id] = rcd_rep
    end

    sm = SystemMessage.c1_was_reported_as_bot
    sm.add_char_name(bot)
    reporter.send_packet(sm)

    sm = SystemMessage.you_have_used_report_point_on_c1_you_have_c2_points_left
    sm.add_char_name(bot)
    sm.add_int(rcd_rep.not_nil!.points)
    reporter.send_packet(sm)

    handle_report(bot, rcd.not_nil!)

    true
  end

  private def handle_report(bot : L2PcInstance, rcd : ReportedCharData)
    punish_bot(bot, PUNISHMENTS[rcd.report_count])

    PUNISHMENTS.each do |key, value|
      if key < 0 && key.abs <= rcd.report_count
        punish_bot(bot, value)
      end
    end
  end

  private def punish_bot(bot : L2PcInstance, ph : PunishHolder?)
    return unless ph
    ph.punish.apply_effects(bot, bot)
    if ph.system_message_id > -1
      if id = SystemMessageId.get?(ph.system_message_id)
        bot.send_packet(id)
      end
    end
  end

  def add_punishment(needed_reports : Int32, skill_id : Int32, skill_lvl : Int32, sys_msg : Int32)
    if sk = SkillData[skill_id, skill_lvl]?
      PUNISHMENTS[needed_reports] = PunishHolder.new(sk, sys_msg)
    else
      warn { "Could not add punishment for #{needed_reports} report(s): Skill #{skill_id}-#{skill_lvl} does not exist." }
    end
  end

  private def reset_points_and_schedule
    CHAR_REGISTRY_LOCK.synchronize do
      CHAR_REGISTRY.each_value do |rcd|
        rcd.points = 7
      end
    end

    schedule_reset_point_task
  end

  private def schedule_reset_point_task
    hour = Config.botreport_resetpoint_hour
    c = Calendar.new
    c.hour = hour[0].to_i
    c.minute = hour[1].to_i

    if Time.ms > c.ms
      c.day_of_year &+= 1
    end

    delay = c.ms - Time.ms

    ThreadPoolManager.schedule_general(->reset_points_and_schedule, delay)
  rescue e
    warn e
    ThreadPoolManager.schedule_general(->reset_points_and_schedule, 24 &* 3600 &* 1000)
  end

  private def hash_ip(pc) : Int32
    con = pc.client.not_nil!.connection.ip
    ip = con.split('.')

    ip[0].to_i | (ip[1].to_i << 8) | (ip[2].to_i << 16) | (ip[3].to_i << 24)
  end

  private def time_has_passed?(map : Hash(Int32, Int64), l2id : Int32) : Bool
    if tmp = map[l2id]?
      return Time.ms - tmp > Config.botreport_report_delay
    end

    true
  end

  private class ReporterCharData
    getter last_report_time = 7i64
    property points : Int8 = 0i8

    def register_report(time : Int64)
      @points -= 1
      @last_report_time = time
    end
  end

  private struct ReportedCharData
    getter reporters = {} of Int32 => Int64

    def report_count : Int32
      @reporters.size
    end

    def already_reported_by?(l2id : Int32)
      @reporters.has_key?(l2id)
    end

    def add_reporter(l2id : Int32, report_time : Int64)
      @reporters[l2id] = report_time
    end

    def reported_by_same_clan?(clan : L2Clan?)
      return false unless clan
      @reporters.local_each_key.any? { |reporter_id| clan.member?(reporter_id) }
    end
  end

  private def parse_document(doc)
    find_element(doc, "list") do |list|
      find_element(list, "punishment") do |pn|
        report_count = parse_int(pn, "neededReportCount", -1)
        skill_id = parse_int(pn, "skillId", -1)
        skill_level = parse_int(pn, "skillLevel", -1)
        sys_message = parse_int(pn, "sysMessageId", -1)

        add_punishment(report_count, skill_id, skill_level, sys_message)
      end
    end
  end

  private record PunishHolder, punish : Skill, system_message_id : Int32
end
