require "./l2_char_template"

class L2DoorTemplate < L2CharTemplate
  # include Identifiable

  @pos_x : Int32
  @pos_y : Int32
  @pos_z : Int32
  getter id : Int32
  getter node_x : Slice(Int32)
  getter node_y : Slice(Int32)
  getter node_z : Int32
  getter height : Int32
  getter emitter : Int32
  getter child_door_id : Int32
  getter name : String
  getter group_name : String?
  getter master_door_close : Int8
  getter master_door_open : Int8
  getter open_time = 0
  getter random_time = 0
  getter close_time : Int32
  getter level : Int32
  getter open_type : Int32
  getter clan_hall_id : Int32
  getter? show_hp : Bool
  getter? wall : Bool
  getter? targetable : Bool
  getter? open_by_default : Bool
  getter? check_collision : Bool
  getter? attackable : Bool
  getter? stealth : Bool

  def initialize(set : StatsSet)
    super

    @id = set.get_i32("id")
    @name = set.get_string("name")
    pos = set.get_string("pos").split(';')
    @pos_x = pos[0].to_i
    @pos_y = pos[1].to_i
    @pos_z = pos[2].to_i
    @height = set.get_i32("height")
    @node_z = set.get_i32("nodeZ")
    @node_x = Slice(Int32).new(4)
    @node_y = Slice(Int32).new(4)
    4.times do |i|
      st = set.get_string("node#{i + 1}").split(',')
      @node_x[i] = st.shift.to_i
      @node_y[i] = st.shift.to_i
    end
    @emitter = set.get_i32("emitter_id", 0)
    @show_hp = set.get_bool("hp_showable", true)
    @wall = set.get_bool("is_wall", false)
    @group_name = set.get_string("group", nil)
    @child_door_id = set.get_i32("child_id_event", -1)

    m = set.get_string("master_close_event", "act_nothing")
    @master_door_close = m == "act_open" ? 1i8 : m == "act_close" ? -1i8 : 0i8

    m = set.get_string("master_open_event", "act_nothing")
    @master_door_open = m == "act_open" ? 1i8 : m == "act_close" ? -1i8 : 0i8

    @targetable = set.get_bool("targetable", true)
    @open_by_default = set.get_string("default_status", "close") == "open"
    @close_time = set.get_i32("close_time", -1)
    @level = set.get_i32("level", 0)
    @open_type = set.get_i32("open_method", 0)
    @check_collision = set.get_bool("check_collision", true)
    if @open_type & L2DoorInstance::OPEN_BY_TIME == L2DoorInstance::OPEN_BY_TIME
      @open_time = set.get_i32("open_time")
      @random_time = set.get_i32("random_time", -1)
    end
    @attackable = set.get_bool("is_attackable", false)
    @clan_hall_id = set.get_i32("clanhall_id", 0)
    @stealth = set.get_bool("stealth", false)
  end

  def x : Int32
    @pos_x
  end

  def y : Int32
    @pos_y
  end

  def z : Int32
    @pos_z
  end
end
