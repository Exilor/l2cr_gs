require "../../models/actor/templates/l2_door_template"

module DoorData
  extend self
  extend XMLReader

  private GROUPS    = {} of String => Set(Int32)
  private DOORS     = {} of Int32  => L2DoorInstance
  private TEMPLATES = {} of Int32  => StatsSet
  private REGIONS   = {} of Int32  => Array(L2DoorInstance)

  def load
    DOORS.clear
    GROUPS.clear
    REGIONS.clear
    parse_datapack_file("doors.xml")
    info { "Loaded #{DOORS.size} door templates for #{REGIONS.size} regions." }
  end

  private def parse_document(doc : XML::Node, file : File)
    find_element(doc, "list") do |a|
      find_element(a, "door") do |b|
        set = get_attributes(b)
        set["baseHpMax"] ||= 1
        make_door(set)
        TEMPLATES[set.get_i32("id")] = set
      end
    end
  end

  private def insert_collision_data(set : StatsSet)
    height = set.get_i32("height")
    pos = set.get_string("node1").split(',')
    node_x = pos.shift.to_i
    node_y = pos.shift.to_i
    pos = set.get_string("node2").split(',')
    pos_x = pos.shift.to_i
    pos_y = pos.shift.to_i
    collision_radius = Math.min((node_x &- pos_x).abs, (node_y &- pos_y).abs)
    collision_radius = 20 if collision_radius < 20

    set["collisionHeight"] = height
    set["collisionRadius"] = collision_radius
  end

  private def make_door(set)
    insert_collision_data(set)
    template = L2DoorTemplate.new(set)
    door = L2DoorInstance.new(template)
    door.max_hp!
    door.spawn_me(template.x, template.y, template.z)
    put_door(door, MapRegionManager.get_map_region_loc_id(door))
  end

  def get_door_template(id : Int32) : StatsSet?
    TEMPLATES[id]?
  end

  def get_door(id : Int32) : L2DoorInstance?
    DOORS[id]?
  end

  def get_door!(id : Int32) : L2DoorInstance
    unless door = get_door(id)
      raise "No door with id #{id}"
    end

    door
  end

  def get_doors_by_group(group : String) : Set(Int32)?
    GROUPS[group]?
  end

  def doors : Enumerable(L2DoorInstance)
    DOORS.local_each_value
  end

  def put_door(door : L2DoorInstance, region : Int32)
    DOORS[door.id] = door
    REGIONS[region] ||= [] of L2DoorInstance
    REGIONS[region] << door
  end

  def add_door_group(group_name : String, door_id : Int32)
    (GROUPS[group_name] ||= Set(Int32).new) << door_id
  end

  def check_if_doors_between(start : AbstractNodeLoc, stop : AbstractNodeLoc, instance_id : Int32) : Bool
    check_if_doors_between(start.x, start.y, start.z, stop.x, stop.y, stop.z, instance_id)
  end

  def check_if_doors_between(x : Int32, y : Int32, z : Int32, tx : Int32, ty : Int32, tz : Int32, instance_id : Int32) : Bool
    check_if_doors_between(x, y, z, tx, ty, tz, instance_id, false)
  end

  def check_if_doors_between(x : Int32, y : Int32, z : Int32, tx : Int32, ty : Int32, tz : Int32, instance_id : Int32, double_face_check : Bool) : Bool
    if instance_id > 0 && (inst = InstanceManager.get_instance(instance_id))
      all_doors = inst.doors
    else
      all_doors = REGIONS[MapRegionManager.get_map_region_loc_id(x, y)]?
    end

    return false unless all_doors

    all_doors.each do |door|
      if door.dead? || door.open? || !door.check_collision? || door.get_x(0) == 0
        next
      end

      intersect_face = false
      4.times do |i|
        j = i &+ 1 < 4 ? i &+ 1 : 0
        denominator = ((ty - y) * (door.get_x(i) - door.get_x(j))) - ((tx - x) * (door.get_y(i) - door.get_y(j)))
        next if denominator == 0
        tx, ty, tz = tx.to_i64, ty.to_i64, tz.to_i64 # prevents overflow
        multiplier1 = (((door.get_x(j) - door.get_x(i)) * (y - door.get_y(i))) - ((door.get_y(j) - door.get_y(i)) * (x - door.get_x(i)))).fdiv(denominator)
        multiplier2 = (((tx - x) * (y - door.get_y(i))) - ((ty - y) * (x - door.get_x(i)))).fdiv(denominator)
        if multiplier1.between?(0, 1) && multiplier2.between?(0, 1)
          intersect_z = (z + (multiplier1 * (tz - z))).round
          if intersect_z > door.z_min && intersect_z < door.z_max
            if !double_face_check || intersect_face
              return true
            end

            intersect_face = true
          end
        end
      end
    end

    false
  end
end
