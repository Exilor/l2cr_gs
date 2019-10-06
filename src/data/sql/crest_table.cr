require "../../models/l2_crest"

module CrestTable
  extend self
  extend Loggable

  private CRESTS = Concurrent::Map(Int32, L2Crest).new
  @@next_id = Atomic(Int32).new(1)

  def load
    CRESTS.clear

    crests_in_use = Set(Int32).new

    ClanTable.clans.each do |clan|
      if clan.crest_id != 0
        crests_in_use << clan.crest_id
      end

      if clan.crest_large_id != 0
        crests_in_use << clan.crest_large_id
      end

      if clan.ally_crest_id != 0
        crests_in_use << clan.ally_crest_id
      end
    end

    begin
      sql = "SELECT `crest_id`, `data`, `type` FROM `crests` ORDER BY `crest_id` DESC"
      GameDB.each(sql) do |rs|
        id = rs.get_i32("crest_id")
        if @@next_id.get <= id
          @@next_id.set(id + 1)
        end

        if !crests_in_use.includes?(id) && id != @@next_id.get - 1
          GameDB.exec("DELETE FROM crests WHERE crest_id=?", id)
          next
        end

        data = rs.get_bytes("data")
        type = rs.get_i32("type")
        if crest_type = L2Crest::CrestType.get_by_id(type)
          CRESTS[id] = L2Crest.new(id, data, crest_type)
        else
          warn { "Unknown crest type found in database: #{type}." }
        end
      end
    rescue e
      error e
    end

    move_old_crests_to_db(crests_in_use)

    info { "Loaded #{CRESTS.size} crests." }

    ClanTable.clans.each do |clan|
      if clan.crest_id != 0
        unless get_crest(clan.crest_id)
          info { "Removing non-existent crest for clan #{clan.name} (#{clan.id}). Crest ID: #{clan.crest_id}." }
          clan.crest_id = 0
          clan.change_clan_crest(0)
        end
      end

      if clan.crest_large_id != 0
        unless get_crest(clan.crest_large_id)
          info { "Removing non-existent large crest for clan #{clan.name} (#{clan.id}). Crest ID: #{clan.crest_large_id}." }
          clan.crest_large_id = 0
          clan.change_large_crest(0)
        end
      end

      if clan.ally_crest_id != 0
        unless get_crest(clan.ally_crest_id)
          info { "Removing non-existent ally crest for clan #{clan.name} (#{clan.id}). Crest ID: #{clan.ally_crest_id}." }
          clan.ally_crest_id = 0
          clan.change_ally_crest(0, true)
        end
      end
    end
  end

  private def move_old_crests_to_db(crests_in_use)
    # TODO: delete each crest file
    dir = "#{Config.datapack_root}/crests"

    return unless Dir.exists?(dir)

    Dir.glob("#{dir}/*.bmp") do |path|
      size = File.size(path)
      data = Bytes.new(size)
      File.open(path, "r", &.read_fully(data))
      file_name = File.basename(path, ".bmp")
      if file_name.starts_with?("Crest_Large_")
        crest_id = file_name.from(12).to_i
        if crests_in_use.includes?(crest_id)
          if crest = create_crest(data, L2Crest::CrestType::PLEDGE_LARGE)
            ClanTable.clans.each do |clan|
              if clan.crest_large_id == crest_id
                clan.crest_large_id = 0
                clan.change_large_crest(crest.id)
              end
            end
          end
        end
      elsif file_name.starts_with?("Crest_")
        crest_id = file_name.from(6).to_i
        if crests_in_use.includes?(crest_id)
          if crest = create_crest(data, L2Crest::CrestType::PLEDGE)
            ClanTable.clans.each do |clan|
              if clan.crest_id == crest_id
                clan.crest_id = 0
                clan.change_clan_crest(crest.id)
              end
            end
          end
        end
      elsif file_name.starts_with?("AllyCrest_")
        crest_id = file_name.from(10).to_i
        if crests_in_use.includes?(crest_id)
          if crest = create_crest(data, L2Crest::CrestType::ALLY)
            ClanTable.clans.each do |clan|
              if clan.ally_crest_id == crest_id
                clan.ally_crest_id = 0
                clan.change_ally_crest(crest.id, false)
              end
            end
          end
        end
      end
    end
  end

  def get_crest(crest_id : Int) : L2Crest?
    CRESTS[crest_id]?
  end

  def create_crest(data : Bytes, crest_type : L2Crest::CrestType) : L2Crest?
    crest = L2Crest.new(next_id, data, crest_type)
    sql = "INSERT INTO `crests`(`crest_id`, `data`, `type`) VALUES(?, ?, ?)"
    GameDB.exec(
      sql,
      crest.id,
      crest.data,
      crest.type.id,
    )
    CRESTS[crest.id] = crest
    crest
  rescue e
    error e
    nil
  end

  def remove_crest(crest_id : Int)
    CRESTS.delete(crest_id)

    if crest_id == @@next_id.get - 1
      return
    end

    GameDB.exec("DELETE FROM `crests` WHERE `crest_id` = ?", crest_id)
  rescue e
    error e
  end

  def next_id : Int32
    @@next_id.add(1) + 1
  end
end
