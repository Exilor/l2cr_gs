class UIKeysSettings
  include Loggable

  getter keys = {} of Int32 => Array(ActionKey)
  getter categories = {} of Int32 => Array(Int32)
  getter? saved = true

  def initialize(pc_id : Int32)
    @pc_id = pc_id
    load_from_db
  end

  def store_all(categories : Hash(Int32, Array(Int32)), keys : Hash(Int32, Array(ActionKey)))
    @categories = categories
    @keys = keys
    @saved = false
  end

  def store_categories(categories : Hash(Int32, Array(Int32)))
    @categories = categories
    @saved = false
  end

  def store_keys(@keys : Hash(Int32, Array(ActionKey)))
    @saved = false
  end

  def load_from_db
    get_cats_from_db
    get_keys_from_db
  end

  def save_in_db
    return if @saved

    sql = String.build do |io|
      io << "REPLACE INTO character_ui_categories (`charId`, `catId`, `order`, `cmdId`) VALUES "
      @categories.each do |category, ary|
        order = 0
        ary.each_with_index do |key, order|
          io << '(' << @pc_id << ", " << category << ", " << order << ", "
          io << key
          if order &+ 1 == ary.size
            io << ')'
          else
            io << "),"
          end
        end
      end

      io << "; "
    end

    begin
      GameDB.exec(sql)
    rescue e
      error e
    end

    sql = String.build do |io|
      io << "REPLACE INTO character_ui_actions (`charId`, `cat`, `order`, `cmd`, `key`, `tgKey1`, `tgKey2`, `show`) VALUES"
      @keys.each_value do |key_list|
        key_list.each_with_index do |key, order|
          key.get_sql_save_string(@pc_id, order, io)
          if order &+ 1 != key_list.size
            io << ','
          end
        end
      end

      io << ';'
    end

    begin
      GameDB.exec(sql)
    rescue e
      error e
    end

    @saved = true
  end

  def get_cats_from_db
    unless @categories.empty?
      return
    end

    begin
      sql = "SELECT * FROM character_ui_categories WHERE `charId` = ? ORDER BY `catId`, `order`"
      GameDB.each(sql, @pc_id) do |rs|
        UIData.add_category(@categories, rs.get_i32(:"catId"), rs.get_i32(:"cmdId"))
      end
    rescue e
      error e
    end

    if @categories.empty?
      @categories = UIData.categories
    end
  end

  def get_keys_from_db
    unless @keys.empty?
      return
    end

    begin
      sql = "SELECT * FROM character_ui_actions WHERE `charId` = ? ORDER BY `cat`, `order`"
      GameDB.each(sql, @pc_id) do |rs|
        cat = rs.get_i32(:"cat")
        cmd = rs.get_i32(:"cmd")
        key = rs.get_i32(:"key")
        tgKey1 = rs.get_i32(:"tgKey1")
        tgKey2 = rs.get_i32(:"tgKey2")
        show = rs.get_i32(:"show")
        ak = ActionKey.new(cat, cmd, key, tgKey1, tgKey2, show)
        UIData.add_key(@keys, cat, ak)
      end
    rescue e
      error e
    end

    if @keys.empty?
      @keys = UIData.keys
    end
  end
end
