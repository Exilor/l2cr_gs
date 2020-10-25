require "../models/entity/clan_hall"
require "../models/entity/clan_hall/auctionable_hall"

module ClanHallManager
  extend self
  extend Loggable
  extend Synchronizable

  private CLAN_HALLS = Concurrent::Map(Int32, AuctionableHall).new
  private FREE_CLAN_HALLS = Concurrent::Map(Int32, AuctionableHall).new
  private ALL_AUCTIONABLE_CLAN_HALLS = {} of Int32 => AuctionableHall
  private ALL_CLAN_HALLS = {} of Int32 => ClanHall

  class_getter? loaded = false

  def load
    GameDB.each("SELECT * FROM clanhall ORDER BY id") do |rs|
      set = StatsSet.new

      id = rs.get_i32(:"id")
      owner_id = rs.get_i32(:"ownerId")
      lease = rs.get_i32(:"lease")

      set["id"] = id
      set["name"] = rs.get_string(:"name")
      set["ownerId"] = owner_id
      set["lease"] = lease
      set["desc"] = rs.get_string(:"desc")
      set["location"] = rs.get_string(:"location")
      set["paidUntil"] = rs.get_i64(:"paidUntil")
      set["grade"] = rs.get_i32(:"Grade")
      set["paid"] = rs.get_bool(:"paid")
      ch = AuctionableHall.new(set)
      ALL_AUCTIONABLE_CLAN_HALLS[id] = ch
      add_clan_hall(ch)

      if ch.owner_id > 0
        CLAN_HALLS[id] = ch
        next
      end

      FREE_CLAN_HALLS[id] = ch

      if lease > 0 && AuctionManager.get_auction(id)
        AuctionManager.init_npc(id)
      end
    end

    info { "Loaded #{clan_halls.size} clan halls." }
    info { "Loaded #{free_clan_halls.size} free clan halls." }

    @@loaded = true
  rescue e
    error e
  end

  def all_clan_halls : Interfaces::Map(Int32, ClanHall)
    ALL_CLAN_HALLS
  end

  def free_clan_halls : Interfaces::Map(Int32, AuctionableHall)
    FREE_CLAN_HALLS
  end

  def clan_halls : Interfaces::Map(Int32, AuctionableHall)
    CLAN_HALLS
  end

  def auctionable_clan_halls : Interfaces::Map(Int32, AuctionableHall)
    ALL_AUCTIONABLE_CLAN_HALLS
  end

  def add_clan_hall(hall : ClanHall)
    ALL_CLAN_HALLS[hall.id] = hall
  end

  def free?(id : Int32) : Bool
    FREE_CLAN_HALLS.has_key?(id)
  end

  def set_free(id : Int32)
    sync do
      FREE_CLAN_HALLS[id] = CLAN_HALLS[id]
      ClanTable.get_clan(FREE_CLAN_HALLS[id].owner_id).not_nil!.hideout_id = 0
      FREE_CLAN_HALLS[id].free
      CLAN_HALLS.delete(id)
    end
  end

  def set_owner(id : Int32, clan : L2Clan)
    sync do
      tmp = CLAN_HALLS[id]?
      if tmp.nil?
        tmp = CLAN_HALLS[id] = FREE_CLAN_HALLS[id]
        FREE_CLAN_HALLS.delete(id)
      else
        tmp.free
      end

      ClanTable.get_clan(clan.id).not_nil!.hideout_id = id
      tmp.owner = clan
    end
  end

  def get_clan_hall_by_id(id : Int32) : ClanHall?
    ALL_CLAN_HALLS[id]?
  end

  def get_auctionable_hall_by_id(id : Int32) : AuctionableHall?
    ALL_AUCTIONABLE_CLAN_HALLS[id]?
  end

  def get_clan_hall(x : Int32, y : Int32, z : Int32) : ClanHall?
    ALL_CLAN_HALLS.find_value { |ch| ch.in_zone?(x, y, z) }
  end

  def get_clan_hall(obj : L2Object) : ClanHall?
    get_clan_hall(*obj.xyz)
  end

  def get_nearby_clan_hall(x : Int32, y : Int32, max_dist : Int32) : AuctionableHall?
    CLAN_HALLS.each_value do |ch|
      if zone = ch.zone?
        if zone.get_distance_to_zone(x, y) < max_dist
          return ch
        end
      end
    end

    FREE_CLAN_HALLS.each_value do |ch|
      if zone = ch.zone?
        if zone.get_distance_to_zone(x, y) < max_dist
          return ch
        end
      end
    end

    nil
  end

  def get_nearby_abstract_hall(x : Int32, y : Int32, max_dist : Int32) : ClanHall?
    ALL_CLAN_HALLS.find_value do |ch|
      (zone = ch.zone?) && zone.get_distance_to_zone(x, y) < max_dist
    end
  end

  def get_clan_hall_by_owner(clan : L2Clan) : AuctionableHall?
    CLAN_HALLS.find_value { |ch| clan.id == ch.owner_id }
  end

  def get_abstract_hall_by_owner(clan : L2Clan) : ClanHall?
    CLAN_HALLS.each_value do |ch|
      if clan.id == ch.owner_id
        return ch
      end
    end

    FREE_CLAN_HALLS.each_value do |ch|
      if clan.id == ch.owner_id
        return ch
      end
    end

    nil
  end
end
