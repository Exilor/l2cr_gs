require "../models/entity/castle"

module CastleManager
  extend self
  include Loggable

  private CASTLES = [] of Castle
  private CASTLE_SIEGE_DATES = Concurrent::Map(Int32, Int64).new
  private CASTLE_CIRCLETS = {
    0,
    6838,
    6835,
    6839,
    6837,
    6840,
    6834,
    6836,
    8182,
    8183
  }

  def find_nearest_castle_index(obj : L2Object) : Int32
    find_nearest_castle_index(obj, Int64::MAX)
  end

  def find_nearest_castle_index(obj : L2Object, max_distance : Int64) : Int32
    index = get_castle_index(obj)

    if index < 0
      CASTLES.each_with_index do |castle, i|
        distance = castle.get_distance(obj)
        if max_distance > distance
          max_distance = distance.to_i64
          index = i
        end
      end
    end

    index
  end

  def get_castle_by_id(id : Int32) : Castle?
    CASTLES.find { |castle| castle.residence_id == id }
  end

  def get_castle_by_owner(clan : L2Clan) : Castle?
    CASTLES.find { |castle| castle.owner_id == clan.id }
  end

  def get_castle(name : String) : Castle?
    name = name.strip
    CASTLES.find &.name.casecmp?(name)
  end

  def get_castle(x : Int32, y : Int32, z : Int32) : Castle?
    CASTLES.find &.in_zone?(x, y, z)
  end

  def get_castle(obj : L2Object) : Castle?
    get_castle(*obj.xyz)
  end

  def get_castle_index(id : Int32) : Int32
    CASTLES.index { |castle| castle.residence_id == id } || -1
  end

  def get_castle_index(obj : L2Object) : Int32
    get_castle_index(*obj.xyz)
  end

  def get_castle_index(x : Int32, y : Int32, z : Int32) : Int32
    CASTLES.index { |castle| castle.in_zone?(x, y, z) } || -1
  end

  def castles : Array(Castle)
    CASTLES
  end

  def has_owned_castle? : Bool
    CASTLES.any? { |castle| castle.owner_id > 0 }
  end

  def validate_taxes(strife_owner : Int32)
    case strife_owner
    when SevenSigns::CABAL_DUSK
      max_tax = 5
    when SevenSigns::CABAL_DAWN
      max_tax = 25
    else
      max_tax = 15
    end

    CASTLES.each do |castle|
      if castle.tax_percent > max_tax
        castle.tax_percent = max_tax
      end
    end
  end

  def get_circlet : Int32
    get_circlet_by_castle_id(1)
  end

  def get_circlet_by_castle_id(id : Int32) : Int32
    id.between?(1, 9) ? CASTLE_CIRCLETS[id] : 0
  end

  def remove_circlet(clan : L2Clan, castle_id : Int32)
    clan.members.each { |m| remove_circlet(m, castle_id) }
  end

  def remove_circlet(member : L2ClanMember, castle_id : Int32)
    circlet_id = get_circlet_by_castle_id(castle_id)
    if circlet_id == 0
      return
    end

    unless pc = member.player_instance
      return
    end

    begin
      if circlet = pc.inventory.get_item_by_item_id(circlet_id)
        if circlet.equipped?
          pc.inventory.unequip_item_in_slot(circlet.location_slot)
        end
        pc.destroy_item_by_item_id("CastleCircletRemoval", circlet_id, 1, pc, true)
      end

      return
    rescue e
      error e
    end

    begin
      sql = "DELETE FROM items WHERE owner_id = ? and item_id = ?"
      GameDB.exec(sql, member.l2id, circlet_id)
    rescue e
      error e
    end
  end

  def load_instances
    GameDB.each("SELECT id FROM castle ORDER BY id") do |rs|
      id = rs.get_i32(:"id")
      CASTLES << Castle.new(id)
    end

    info { "Loaded #{CASTLES.size} castles." }
  rescue e
    error e
  end

  def update_references
    # no-op
  end

  def activate_instances
    CASTLES.each &.activate_instance
  end

  def register_siege_date(castle_id : Int32, siege_date : Int64)
    CASTLE_SIEGE_DATES[castle_id] = siege_date
  end

  def get_siege_dates(siege_date : Int64) : Int32
    CASTLE_SIEGE_DATES.count { |_, d| d - siege_date < 1000 }
  end
end
