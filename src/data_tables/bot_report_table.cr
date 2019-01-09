module BotReportTable
  extend self
  extend Loggable

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

  def load
    debug "TODO"
  end
end
