require "../models/entity/fort"

module FortManager
  extend self
  extend Loggable

  private FORTS = [] of Fort

  def find_nearest_fort_index(obj : L2Object) : Int32
    find_nearest_fort_index(obj, Int64::MAX)
  end

  def find_nearest_fort_index(obj : L2Object, max_distance : Int64) : Int32
    index = get_fort_index(obj)

    if index < 0
      FORTS.each_with_index do |fort, i|
        distance = fort.get_distance(obj)
        if max_distance > distance
          max_distance = distance.to_i64
          index = i
        end
      end
    end

    index
  end

  def get_fort_by_id(id : Int32) : Fort?
    FORTS.find { |fort| fort.residence_id == id }
  end

  def get_fort_by_owner(clan : L2Clan) : Fort?
    FORTS.find { |fort| fort.owner_clan? == clan }
  end

  def get_fort(name : String) : Fort?
    name = name.strip
    FORTS.find &.name.casecmp?(name)
  end

  def get_fort(x : Int32, y : Int32, z : Int32) : Fort?
    FORTS.find &.in_zone?(x, y, z)
  end

  def get_fort(obj : L2Object) : Fort?
    get_fort(*obj.xyz)
  end

  def get_fort_index(id : Int32) : Int32
    FORTS.index { |fort| fort.residence_id == id } || -1
  end

  def get_fort_index(obj : L2Object) : Int32
    get_fort_index(*obj.xyz)
  end

  def get_fort_index(x : Int32, y : Int32, z : Int32) : Int32
    FORTS.index &.in_zone?(x, y, z) || -1
  end

  def forts : Array(Fort)
    FORTS
  end

  def load_instances
    GameDB.each("SELECT id FROM fort ORDER BY id") do |rs|
      forts << Fort.new(rs.get_i32("id"))
    end

    info { "Loaded #{FORTS.size} fortresses." }

    FORTS.each &.siege.siege_guard_manager.load_siege_guard
  rescue e
    error e
  end

  def update_references
    # no-op
  end

  def activate_instances
    FORTS.each &.activate_instance
  end
end
