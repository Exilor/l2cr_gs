require "../../models/l2_crest"

module CrestTable
  extend self
  include Loggable

  private CRESTS = Concurrent::Map(Int32, L2Crest).new
  private NEXT_ID = Atomic(Int32).new(1)

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
        id = rs.get_i32(:"crest_id")
        if NEXT_ID.get <= id
          NEXT_ID.set(id + 1)
        end

        if !crests_in_use.includes?(id) && id != NEXT_ID.get &- 1
          GameDB.exec("DELETE FROM crests WHERE crest_id=?", id)
          next
        end

        data = rs.get_bytes(:"data")
        type = rs.get_i32(:"type")
        if crest_type = L2Crest::Type.get_by_id(type)
          CRESTS[id] = L2Crest.new(id, data, crest_type)
        else
          warn { "Unknown crest type found in database: #{type}." }
        end
      end
    rescue e
      error e
    end

    info { "Loaded #{CRESTS.size} crests." }

    ClanTable.clans.each do |clan|
      if clan.crest_id != 0
        unless get_crest(clan.crest_id)
          info { "Removing non-existent crest for clan #{clan.name} (#{clan.id}). Crest id: #{clan.crest_id}." }
          clan.crest_id = 0
          clan.change_clan_crest(0)
        end
      end

      if clan.crest_large_id != 0
        unless get_crest(clan.crest_large_id)
          info { "Removing non-existent large crest for clan #{clan.name} (#{clan.id}). Crest id: #{clan.crest_large_id}." }
          clan.crest_large_id = 0
          clan.change_large_crest(0)
        end
      end

      if clan.ally_crest_id != 0
        unless get_crest(clan.ally_crest_id)
          info { "Removing non-existent ally crest for clan #{clan.name} (#{clan.id}). Crest id: #{clan.ally_crest_id}." }
          clan.ally_crest_id = 0
          clan.change_ally_crest(0, true)
        end
      end
    end
  end

  def get_crest(crest_id : Int) : L2Crest?
    CRESTS[crest_id]?
  end

  def create_crest(data : Bytes, crest_type : L2Crest::Type) : L2Crest?
    crest = L2Crest.new(next_id, data, crest_type)
    sql = "INSERT INTO `crests`(`crest_id`, `data`, `type`) VALUES(?, ?, ?)"
    GameDB.exec(sql, crest.id, crest.data, crest.type.id)
    CRESTS[crest.id] = crest
    crest
  rescue e
    error e
    nil
  end

  def remove_crest(crest_id : Int)
    CRESTS.delete(crest_id)

    if crest_id == NEXT_ID.get &- 1
      return
    end

    begin
      GameDB.exec("DELETE FROM `crests` WHERE `crest_id` = ?", crest_id)
    rescue e
      error e
    end
  end

  def next_id : Int32
    NEXT_ID.add(1) &+ 1
  end
end
