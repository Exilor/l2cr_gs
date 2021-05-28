require "./events/listeners_container"
require "./interfaces/positionable"
require "../network/packets/server/*"
require "./actor/known_list/object_known_list"
require "./actor/poly/object_poly"
require "../enums/zone_id"
require "../util"

abstract class L2Object < ListenersContainer
  include Positionable
  include AbstractEventListener::Owner
  include Packets::Outgoing
  include Loggable

  @visible = false
  @x = Atomic(Int32).new(0)
  @y = Atomic(Int32).new(0)
  @z = Atomic(Int32).new(0)
  @heading = Atomic(Int32).new(0)
  @instance_id = Atomic(Int32).new(0)

  getter l2id
  getter! known_list : ObjectKnownList
  getter? invisible = false
  property world_region : L2WorldRegion?
  property name : String = ""

  def initialize(l2id : Int32)
    @l2id = l2id
    init_known_list
  end

  def_equals_and_hash @l2id

  abstract def auto_attackable?(attacker : L2Character) : Bool
  abstract def send_info(pc : L2PcInstance)

  def decay_me : Bool
    unless region = world_region
      # debug "L2Object#decay_me: @world_region must not be nil here."
    end

    sync do
      @visible = false
      self.world_region = nil
    end

    L2World.remove_visible_object(self, region)
    L2World.remove_visible_object(self, region)
    L2World.remove_object(self)

    true
  end

  def send_packet(arg : GameServerPacket | SystemMessageId)
    # no-op
  end

  def on_action(pc : L2PcInstance)
    on_action(pc, true)
  end

  def on_action(pc : L2PcInstance, interact : Bool)
    ActionHandler[instance_type].try &.action(pc, self, interact)
    pc.action_failed
  end

  def on_action_shift(pc : L2PcInstance)
    on_action_shift(pc, true)
  end

  def on_action_shift(pc : L2PcInstance, interact : Bool)
    ActionShiftHandler[instance_type].try &.action(pc, self, interact)
    pc.action_failed
  end

  def on_forced_attack(pc : L2PcInstance)
    pc.action_failed
  end

  private def init_known_list
    @known_list = ObjectKnownList.new(self)
  end

  def x : Int32
    @x.get
  end

  def x=(new_x : Int32)
    @x.set(new_x)
  end

  def y : Int32
    @y.get
  end

  def y=(new_y : Int32)
    @y.set(new_y)
  end

  def z : Int32
    @z.get
  end

  def z=(new_z : Int32)
    @z.set(new_z)
  end

  def heading : Int32
    @heading.get
  end

  def heading=(new_heading : Int32)
    @heading.set(new_heading)
  end

  def instance_id : Int32
    @instance_id.get
  end

  def instance_id=(new_instance_id : Int32)
    if new_instance_id < 0 || new_instance_id == instance_id
      return
    end

    unless new_instance = InstanceManager.get_instance(new_instance_id)
      return
    end
    old_instance = InstanceManager.get_instance(instance_id)

    case me = self
    when L2PcInstance
      if instance_id > 0 && old_instance
        old_instance.remove_player(l2id)
        if old_instance.show_timer?
          me.send_instance_update(old_instance, true)
        end
      end
      if new_instance_id > 0
        new_instance.add_player(l2id)
        if new_instance.show_timer?
          me.send_instance_update(new_instance, false)
        end
      end
      if smn = me.summon
        smn.instance_id = new_instance_id
      end
    when L2Npc
      if instance_id > 0 && old_instance
        old_instance.remove_npc(me)
      end
      if new_instance_id > 0
        new_instance.add_npc(me)
      end
    end

    @instance_id.set(new_instance_id)

    if @visible && @known_list && !player?
      decay_me
      spawn_me
    end
  end

  def location : Location
    Location.new(x, y, z, heading, instance_id)
  end

  def location=(loc : Locatable)
    @x.set(loc.x)
    @y.set(loc.y)
    @z.set(loc.z)
    @heading.set(loc.heading)
    @instance_id.set(loc.instance_id)
  end

  def instance_type : InstanceType
    InstanceType::L2Object
  end

  def instance_type?(type : InstanceType) : Bool
    instance_type.type?(type)
  end

  def acting_player : L2PcInstance?
    # return nil
  end

  def attackable? : Bool
    false
  end

  def character? : Bool
    false
  end

  def door? : Bool
    false
  end

  def monster? : Bool
    false
  end

  def npc? : Bool
    false
  end

  def pet? : Bool
    false
  end

  def playable? : Bool
    false
  end

  def player? : Bool
    false
  end

  def servitor? : Bool
    false
  end

  def summon? : Bool
    false
  end

  def trap? : Bool
    false
  end

  def item? : Bool
    false
  end

  def vehicle? : Bool
    false
  end

  def walker? : Bool
    false
  end

  def targetable? : Bool
    true
  end

  {% for const in ZoneId.constants %}
    def inside_{{const.downcase.id}}_zone? : Bool
      false
    end
  {% end %}

  def inside_zone?(zone : ZoneId) : Bool
    false
  end

  def charged_shot?(shot : ShotType) : Bool
    false
  end

  def set_charged_shot(shot : ShotType, charged : Bool)
    # no-op
  end

  def recharge_shots(physical : Bool, magical : Bool)
    # no-op
  end

  def remove_status_listener(char : L2Character)
    # no-op
  end

  def spawn_me : Bool
    if @world_region || x == 0 || y == 0 || z == 0
      raise "L2Object#spawn_me() assertion failed"
    end

    sync do
      @visible = true
      self.world_region = L2World.get_region(location)
      L2World.store_object(self)
      world_region.not_nil!.add_visible_object(self)
    end

    L2World.add_visible_object(self, world_region.not_nil!)
    on_spawn

    true
  end

  def spawn_me(x : Int32, y : Int32, z : Int32)
    if @world_region
      raise "L2Object#spawn_me(Int32, Int32, Int32) assertion failed"
    end

    sync do
      @visible = true
      x = L2World::MAP_MAX_X &- 5000 if x > L2World::MAP_MAX_X
      x = L2World::MAP_MIN_X &+ 5000 if x < L2World::MAP_MIN_X
      y = L2World::MAP_MAX_Y &- 5000 if y > L2World::MAP_MAX_Y
      y = L2World::MAP_MIN_Y &+ 5000 if y < L2World::MAP_MIN_Y
      set_xyz(x, y, z)
      self.world_region = L2World.get_region(location)
    end

    L2World.store_object(self)
    world_region.not_nil!.add_visible_object(self)
    L2World.add_visible_object(self, world_region.not_nil!)
    on_spawn
  end

  def on_spawn
    # no-op
  end

  def can_be_attacked? : Bool
    false
  end

  def visible? : Bool
    !!world_region
  end

  def visible=(bool : Bool)
    @visible = bool
    unless bool
      self.world_region = nil
    end
  end

  def toggle_visible
    visible? ? decay_me : spawn_me
  end

  def visible_for?(pc : L2PcInstance) : Bool
    !invisible? || pc.override_see_all_players?
  end

  private def bad_coords
    # no-op
  end

  def set_xyz(loc : Locatable)
    set_xyz(*loc.xyz)
  end

  def set_xyz(x : Int32, y : Int32, z : Int32)
    self.x, self.y, self.z = x, y, z

    begin
      if L2World.get_region(location) != @world_region
        update_world_region
      end
    rescue e
      error e
      bad_coords
    end
  end

  def set_xyz_invisible(x : Int32, y : Int32, z : Int32)
    if world_region
      warn "L2Object#set_xyz_invisible: @world_region should be nil."
    end

    x = L2World::MAP_MAX_X &- 5000 if x > L2World::MAP_MAX_X
    x = L2World::MAP_MIN_X &+ 5000 if x < L2World::MAP_MIN_X
    y = L2World::MAP_MAX_Y &- 5000 if y > L2World::MAP_MAX_Y
    y = L2World::MAP_MIN_Y &+ 5000 if y < L2World::MAP_MIN_Y
    set_xyz(x, y, z)
    self.visible = false
  end

  def set_location_invisible(loc : Locatable)
    set_xyz_invisible(*loc.xyz)
  end

  def update_world_region
    return unless old_region = world_region

    new_region = L2World.get_region(location)

    if new_region != old_region
      old_region.remove_visible_object(self)
      self.world_region = new_region
      new_region.add_visible_object(self)
    end
  end

  def calculate_distance(x : Int32, y : Int32, z : Int32, z_axis : Bool, squared : Bool) : Float64
    distance = Math.pow(x - x(), 2) + Math.pow(y - y(), 2)
    if z_axis
      distance += Math.pow(z - z(), 2)
    end
    squared ? distance : Math.sqrt(distance)
  end

  def calculate_distance(loc : Locatable, z_axis : Bool, squared : Bool) : Float64
    calculate_distance(*loc.xyz, z_axis, squared)
  end

  def calculate_direction_to(loc : Locatable) : Float64
    heading = Util.calculate_heading_from(self, loc) &- heading()
    heading &+= 65_535 if heading < 0
    Util.convert_heading_to_degree(heading)
  end

  def invisible=(bool : Bool)
    if @invisible = bool
      del = nil
      known_list.each_object do |obj|
        if obj.is_a?(L2PcInstance) && !visible_for?(obj)
          del ||= DeleteObject.new(self)
          obj.send_packet(del)
        end
      end
    end

    broadcast_info
  end

  def broadcast_info
    known_list.each_object do |obj|
      if obj.is_a?(L2PcInstance) && visible_for?(obj)
        send_info(obj)
      end
    end
  end

  def refresh_id
    L2World.remove_object(self)
    IdFactory.release(l2id)
    @l2id = IdFactory.next
  end

  def add_script(script : T) : T forall T
    temp = @scripts || sync do
      @scripts ||= Concurrent::Map(String, ScriptType).new
    end
    temp[script.class.name] = script
  end

  def remove_script(script : T.class) : T? forall T
    @scripts.try &.delete(script.name).as?(T)
  end

  def get_script(script : T.class) : T? forall T
    @scripts.try &.[script.name]?.as?(T)
  end

  def poly : ObjectPoly
    get_script(ObjectPoly) || add_script(ObjectPoly.new(self))
  end

  def poly? : ObjectPoly?
    get_script(ObjectPoly)
  end

  def to_s(io : IO)
    io << name
  end

  def inspect(io : IO)
    io.print({{@type.stringify + "("}}, name, ": ", l2id, ')')
  end
end
