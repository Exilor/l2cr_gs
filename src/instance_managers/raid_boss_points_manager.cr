module RaidBossPointsManager
  extend self
  extend Loggable

  private LIST = Hash(Int32, Hash(Int32, Int32)).new

  def load
    sql = "SELECT `charId`,`boss_id`,`points` FROM `character_raid_points`"
    GameDB.each(sql) do |rs|
      char_id = rs.get_i32("charId")
      boss_id = rs.get_i32("boss_id")
      points = rs.get_i32("points")
      values = LIST[char_id] ||= {} of Int32 => Int32
      values[boss_id] = points
    end

    info { "Loaded #{LIST.size} character raid points." }
  rescue e
    error e
  end

  def update_points_in_db(pc : L2PcInstance, raid_id : Int32, points : Int32)
    sql = "REPLACE INTO character_raid_points (`charId`,`boss_id`,`points`) VALUES (?,?,?)"
    GameDB.exec(sql, pc.l2id, raid_id, points)
  rescue e
    error e
  end

  def add_points(pc : L2PcInstance, boss_id : Int32, points : Int32)
    hash = LIST[pc.l2id] ||= {} of Int32 => Int32
    hash[boss_id] ||= 0
    hash[boss_id] += points
    update_points_in_db(pc, boss_id, hash[boss_id])
  end

  def get_points_by_owner_id(owner_id : Int32) : Int32
    tmp = LIST[owner_id]?

    if tmp.nil? || tmp.empty?
      return 0
    end

    total_points = 0

    tmp.each_value do |points|
      total_points += points
    end

    total_points
  end

  def get_list(pc : L2PcInstance)
    LIST[pc.l2id]?
  end

  def clean_up
    sql = "DELETE from character_raid_points WHERE charId > 0"
    GameDB.exec(sql)
    LIST.clear
  rescue e
    error e
  end

  def calculate_ranking(l2id : Int32) : Int32
    rank = rank_list
    rank.fetch(l2id, 0)
  end

  def rank_list : Hash(Int32, Int32)
    tmp = {} of Int32 => Int32
    LIST.each_key do |owner_id|
      total_points = get_points_by_owner_id(owner_id)
      if total_points != 0
        tmp[owner_id] = total_points
      end
    end

    list = Array({Int32, Int32}).new(tmp.size)
    tmp.each { |k, v| list << {k, v} }
    list.sort_by! { |pair| pair[1] }
    list.reverse!
    ranking = 1
    tmp_ranking = {} of Int32 => Int32
    list.each do |pair|
      tmp_ranking[pair[0]] = ranking
      ranking += 1
    end

    tmp_ranking
  end
end
