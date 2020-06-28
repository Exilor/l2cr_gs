require "./l2_world_region"

module L2World
  extend self
  extend Loggable

  # Gracia border Flying objects not allowed to the east of it.
  GRACIA_MAX_X = -166168
  GRACIA_MAX_Z = 6105
  GRACIA_MIN_Z = -895

  # Biteshift, defines number of regions note, shifting by 15 will result
  # in regions corresponding to map tiles shifting by 12 divides one tile to
  # 8x8 regions.
  SHIFT_BY = 12

  TILE_SIZE = 32768

  # Map dimensions
  TILE_X_MIN = 11
  TILE_Y_MIN = 10
  TILE_X_MAX = 26
  TILE_Y_MAX = 26

  TILE_ZERO_COORD_X = 20
  TILE_ZERO_COORD_Y = 18

  MAP_MIN_X = (TILE_X_MIN - TILE_ZERO_COORD_X) * TILE_SIZE
  MAP_MIN_Y = (TILE_Y_MIN - TILE_ZERO_COORD_Y) * TILE_SIZE

  MAP_MAX_X = ((TILE_X_MAX - TILE_ZERO_COORD_X) + 1) * TILE_SIZE
  MAP_MAX_Y = ((TILE_Y_MAX - TILE_ZERO_COORD_Y) + 1) * TILE_SIZE

  # calculated offset used so top left region is 0,0
  OFFSET_X = (MAP_MIN_X >> SHIFT_BY).abs
  OFFSET_Y = (MAP_MIN_Y >> SHIFT_BY).abs

  # number of regions
  REGIONS_X = (MAP_MAX_X >> SHIFT_BY) + OFFSET_X
  REGIONS_Y = (MAP_MAX_Y >> SHIFT_BY) + OFFSET_Y

  private WORLD_REGIONS = Slice(Array(L2WorldRegion)).new(REGIONS_X + 1) do
    Array(L2WorldRegion).new(REGIONS_Y + 1)
  end

  private OBJECTS = Concurrent::Map(Int32, L2Object).new
  private PLAYERS = Concurrent::Map(Int32, L2PcInstance).new
  private PETS    = Concurrent::Map(Int32, L2PetInstance).new

  def load
    0.upto(REGIONS_X) do |x|
      region_list = WORLD_REGIONS[x]
      0.upto(REGIONS_Y) do |y|
        region_list << L2WorldRegion.new(x, y)
      end
    end

    0.upto(REGIONS_X) do |x|
      0.upto(REGIONS_Y) do |y|
        -1.upto(1) do |a|
          -1.upto(1) do |b|
            xa = x &+ a
            yb = y &+ b
            if xa.between?(0, REGIONS_X) && yb.between?(0, REGIONS_Y)
              WORLD_REGIONS[xa][yb].add_sorrounding_region(WORLD_REGIONS[x][y])
            end
          end
        end
      end
    end

    info { "#{REGIONS_X}x#{REGIONS_Y} region grid initialized." }
  end

  def world_regions : Slice(Array(L2WorldRegion))
    WORLD_REGIONS
  end

  def get_region(loc : Location) : L2WorldRegion
    get_region(loc.x, loc.y)
  end

  def get_region(x : Int32, y : Int32) : L2WorldRegion
    x = (x >> SHIFT_BY) + OFFSET_X
    y = (y >> SHIFT_BY) + OFFSET_Y
    WORLD_REGIONS[x][y]
  end

  def players : Enumerable(L2PcInstance)
    PLAYERS.local_each_value
  end

  def objects : Enumerable(L2Object)
    OBJECTS.local_each_value
  end

  def store_object(obj : L2Object)
    if OBJECTS.has_key?(obj.l2id)
      warn { "#{obj} already stored with ID #{obj.l2id}." }
    else
      OBJECTS[obj.l2id] = obj
    end
  end

  def remove_object(obj : L2Object)
    OBJECTS.delete(obj.l2id)
  end

  def find_object(l2id : Int32) : L2Object?
    OBJECTS[l2id]?
  end

  def get_player(name : String?) : L2PcInstance?
    if name
      PLAYERS.find_value { |pc| pc.name == name }
    end
  end

  def get_player(l2id : Int32) : L2PcInstance?
    PLAYERS[l2id]?
  end

  def get_pet(l2id : Int32) : L2PetInstance?
    PETS[l2id]?
  end

  def add_pet(l2id : Int32, pet : L2PetInstance)
    PETS[l2id] = pet
  end

  def remove_pet(pet : L2PetInstance)
    PETS.delete(pet.owner.l2id)
  end

  def remove_pet(l2id : Int32)
    PETS.delete(l2id)
  end

  def get_visible_objects(object : L2Object, radius : Number, & : L2Object ->) : Nil
    radius *= radius
    object.world_region.try &.sorrounding_regions.each do |regi|
      regi.objects.each_value do |obj|
        if obj != object
          if radius > object.calculate_distance(obj, false, true)
            yield obj
          end
        end
      end
    end
  end

  def get_visible_objects(object : L2Object, & : L2Object ->) : Nil
    object.world_region.try &.sorrounding_regions.each do |regi|
      regi.objects.each_value do |obj|
        if obj != object && obj.visible?
          yield obj
        end
      end
    end
  end

  def visible_objects_count : Int32
    OBJECTS.size
  end

  def all_players_count : Int32
    PLAYERS.size
  end

  def each_playable(object : L2Object, & : L2Object ->)
    object.world_region.try &.sorrounding_regions.each do |regi|
      regi.playables.each_value do |obj|
        if obj != object && obj.visible?
          yield obj
        end
      end
    end
  end

  def add_player_to_world(pc : L2PcInstance)
    PLAYERS[pc.l2id] = pc
  end

  def remove_from_all_players(pc : L2PcInstance)
    PLAYERS.delete(pc.l2id)
  end

  def add_visible_object(object : L2Object, region : L2WorldRegion)
    return unless region.active?

    get_visible_objects(object, 2000) do |vis|
      vis.known_list.add_known_object(object)
      object.known_list.add_known_object(vis)
    end
  end

  def remove_visible_object(object : L2Object?, old_region : L2WorldRegion?)
    return unless object && old_region

    old_region.remove_visible_object(object)

    old_region.sorrounding_regions.each do |reg|
      reg.objects.each_value do |obj|
        obj.known_list.remove_known_object(object)
      end
    end

    object.known_list.remove_all_known_objects
  end

  def delete_visible_npc_spawns
    info "Deleting all visible NPCs."
    WORLD_REGIONS.each &.each &.delete_visible_npc_spawns
    info "All visible NPCs deleted."
  end
end
