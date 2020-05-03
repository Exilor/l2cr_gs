module CharNameTable
  extend self
  extend Synchronizable
  extend Loggable

  private CHARS = Concurrent::Map(Int32, String).new
  private ACCESS_LEVELS = Concurrent::Map(Int32, Int32).new

  def load
    unless Config.cache_char_names
      return
    end

    timer = Timer.new
    count = 0
    sql = "SELECT charId, char_name, accesslevel FROM characters"
    GameDB.query_each(sql) do |rs|
      id = rs.read(Int32)
      name = rs.read(String)
      lvl = rs.read(Int32)
      CHARS[id] = name
      ACCESS_LEVELS[id] = lvl
      count += 1
    end
    info { "Loaded #{count} names in #{timer} s." }
  end

  def add_name(pc : L2PcInstance?)
    if pc
      add_name(pc.l2id, pc.name)
      ACCESS_LEVELS[pc.l2id] = pc.access_level.level
    end
  end

  def add_name(l2id : Int32, name : String?)
    if name && name != CHARS[l2id]?
      CHARS[l2id] = name
    end
  end

  def remove_name(l2id : Int32)
    CHARS.delete(l2id)
    ACCESS_LEVELS.delete(l2id)
  end

  def get_id_by_name(name : String?) : Int32
    unless name && !name.empty?
      return -1
    end

    CHARS.each do |key, value|
      if value.casecmp?(name)
        return key
      end
    end

    if Config.cache_char_names
      return -1
    end

    id = -1
    access_level = 0

    sql = "SELECT charId,accesslevel FROM characters WHERE char_name=?"
    begin
      GameDB.query_each(sql, name) do |rs|
        id = rs.read(Int32)
        access_level = rs.read(Int32)
      end
    rescue e
      error e
    end

    if id > 0
      CHARS[id] = name
      ACCESS_LEVELS[id] = access_level
      return id
    end

    -1
  end

  def get_name_by_id(id : Int32) : String?
    return unless id > 0

    if name = CHARS[id]?
      return name
    end

    if Config.cache_char_names
      return
    end

    begin
      sql = "SELECT char_name,accesslevel FROM characters WHERE charId=?"
      GameDB.query_each(sql, id) do |rs|
        name = rs.read(String)
        CHARS[id] = name
        ACCESS_LEVELS[id] = rs.read(Int32)
        return name
      end
    rescue e
      error e
    end

    nil
  end

  def get_access_level_by_id(id : Int32) : Int32
    if ret = ACCESS_LEVELS[id]?
      return ret
    end

    0
  end

  def name_exists?(name : String) : Bool
    sync do

      begin
        sql = "SELECT account_name FROM characters WHERE char_name=?"
        GameDB.query_each(sql, name) do |rs|
          # In theory, if there's iteration there's a match
          return true
        end
      rescue e
        error e
      end

      false
    end
  end

  def get_account_character_count(account : String) : Int32
    sql = "SELECT COUNT(char_name) FROM characters WHERE account_name=?"

    # GameDB.query_each(sql, account) do |rs|
    #   return rs.read(Int64).to_i32
    # end
    # 0

    ret = GameDB.scalar(sql, account)
    if ret.is_a?(Number)
      ret.to_i32
    else
      warn { "#{ret} is not a number, it's a #{ret.class}" }
      0
    end
  end
end
