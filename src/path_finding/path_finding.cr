require "./abstract_node"
require "./abstract_node_loc"
require "./geonodes/geo_path_finding"
require "./cellnodes/cell_path_finding"

module PathFinding
  extend self

  private class_getter! engine : GeoPathFinding | CellPathFinding

  def load
    if Config.pathfinding == 1
      @@engine = GeoPathFinding
    else
      @@engine = CellPathFinding
    end

    engine.load
  end

  def path_nodes_exist?(reg_offset : Int16) : Bool
    engine.path_nodes_exist?(reg_offset)
  end

  def find_path(x : Int32, y : Int32, z : Int32, tx : Int32, ty : Int32, tz : Int32, instance_id : Int32, playable : Bool) : Deque(AbstractNodeLoc)?
    engine.find_path(x, y, z, tx, ty, tz, instance_id, playable)
  end

  def get_node_pos(pos : Int32) : Int16
    (pos >> 3).to_i16
  end

  def get_node_block(pos : Int32) : Int16
    (pos % 256).to_i16
  end

  def get_region_x(pos : Int32) : Int8
    ((pos >> 8) + L2World::TILE_X_MIN).to_i8
  end

  def get_region_y(pos : Int32) : Int8
    ((pos >> 8) + L2World::TILE_Y_MIN).to_i8
  end

  def get_region_offset(rx : Int8, ry : Int8) : Int16
    ((rx.to_i32 << 5) + ry).to_i16
  end

  def calculate_world_x(x : Int16) : Int32
    L2World::MAP_MIN_X + (x.to_i32 * 128) + 48
  end

  def calculate_world_y(y : Int16) : Int32
    L2World::MAP_MIN_Y + (y.to_i32 * 128) + 48
  end
end
