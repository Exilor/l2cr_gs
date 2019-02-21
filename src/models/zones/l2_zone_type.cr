require "./l2_zone_form"
require "./abstract_zone_settings"
require "./task_zone_settings"
require "../events/event_type"

abstract class L2ZoneType < ListenersContainer
  include Loggable
  include Packets::Outgoing

  @check_affected = false
  @min_lvl = 0
  @max_lvl = 0xff
  @class_type = 0
  @character_list = {} of Int32 => L2Character
  @race : Array(Int32)?
  @class : Array(Int32)?
  @target = InstanceType::L2Character
  getter instance_template = ""
  getter settings : AbstractZoneSettings?
  getter! zone : L2ZoneForm
  getter? allow_store = true
  property name : String?
  property instance_id : Int32 = -1
  property? enabled : Bool = true

  getter_initializer id: Int32

  def settings=(settings : AbstractZoneSettings)
    @settings.try &.clear
    @settings = settings
  end

  def set_parameter(name : String, value : String)
    @check_affected = true

    case name
    when "name"
      @name = value
    when "instanceId"
      @instance_id = value.to_i
    when "instanceTemplate"
      @instance_template = value
      @instance_id = InstanceManager.create_dynamic_instance(value)
    when "affectedLvlMin"
      @min_lvl = value.to_i
    when "affectedLvlMax"
      @max_lvl = value.to_i
    when "affectedRace"
      (@race ||= [] of Int32) << value.to_i
    when "affectedClassId"
      (@class ||= [] of Int32) << value.to_i
    when "affectedClassType"
      @class_type = value == "Fighter" ? 1 : 2
    when "targetClass"
      @target = InstanceType.parse(value)
    when "allowStore"
      @allow_store = Bool.new(value)
    when "default_enabled"
      @enabled = Bool.new(value)
    else
      warn "Unknown parameter #{name.inspect} in zone #{@id}."
    end
  end

  def affected?(char : L2Character) : Bool
    return false unless @min_lvl <= char.level <= @max_lvl
    return false unless char.instance_type?(@target)

    if char.is_a?(L2PcInstance)
      if @class_type != 0
        if char.mage_class?
          return false if @class_type == 1
        elsif @class_type == 2
          return false
        end
      end

      race = @race
      if race && !race.includes?(char.race.to_i)
        return false
      end

      klass = @class
      if klass && !klass.includes?(char.class_id.to_i)
        return false
      end
    end

    true
  end

  def zone=(zone : L2ZoneForm)
    if @zone
      raise "zone already set"
    end

    @zone = zone
  end

  def inside_zone?(x : Int32, y : Int32) : Bool
    zone.inside_zone?(x, y, zone.high_z)
  end

  def inside_zone?(x : Int32, y : Int32, z : Int32) : Bool
    zone.inside_zone?(x, y, z)
  end

  def inside_zone?(loc : Locatable) : Bool
    zone.inside_zone?(*loc.xyz)
  end

  def inside_zone?(obj : L2Object) : Bool
    inside_zone?(*obj.xyz, obj.instance_id)
  end

  def inside_zone?(x : Int32, y : Int32, z : Int32, instance_id : Int32) : Bool
    if @instance_id == -1 || instance_id == -1 || @instance_id == instance_id
      return zone.inside_zone?(x, y, z)
    end

    false
  end

  def get_distance_to_zone(obj : L2Object) : Float64
    zone.get_distance_to_zone(obj.x, obj.y)
  end

  def get_distance_to_zone(x : Int32, y : Int32) : Float64
    zone.get_distance_to_zone(x, y)
  end

  def revalidate_in_zone(char : L2Character)
    if @check_affected && !affected?(char)
      return
    end

    if inside_zone?(char)
      unless @character_list.has_key?(char.l2id)
        OnCreatureZoneEnter.new(char, self).async(self)
        @character_list[char.l2id] = char
        on_enter(char)
      end
    else
      remove_character(char)
    end
  end

  def remove_character(char : L2Character)
    if @character_list.has_key?(char.l2id)
      OnCreatureZoneExit.new(char, self).async(self)
      @character_list.delete(char.l2id)
      on_exit(char)
    end
  end

  def character_in_zone?(char : L2Character) : Bool
    @character_list.has_key?(char.l2id)
  end

  def settings=(settings : AbstractZoneSettings)
    @settings.try &.clear
    @settings = settings
  end

  abstract def on_enter(char : L2Character)
  abstract def on_exit(char : L2Character)

  def on_die_inside(char)
    # no-op
  end

  def on_revive_inside(char)
    # no-op
  end

  def on_player_login_inside(pc)
    # no-op
  end

  def on_player_logout_inside(pc)
    # no-op
  end

  def characters
    @character_list
  end

  def characters_inside(&block : L2Character ->)
    @character_list.each_value { |char| yield char }
  end

  def characters_inside
    @character_list.local_each_value
  end

  def players_inside
    ret = [] of L2PcInstance
    @character_list.each_value do |char|
      if char.is_a?(L2PcInstance)
        ret << char
      end
    end
    ret
  end

  def players_inside(&block : L2PcInstance ->)
    @character_list.each_value do |char|
      if char.is_a?(L2PcInstance)
        yield char
      end
    end
  end

  def broadcast_packet(gsp : GameServerPacket)
    return if @character_list.empty?
    @character_list.each_value do |pc|
      if pc.player?
        pc.send_packet(gsp)
      end
    end
  end

  def target_type : InstanceType
    @target
  end

  def target_type=(type : InstanceType)
    @target = type
    @check_affected = true
  end

  def visualize_zone(z : Int32)
    zone.visualize_zone(z)
  end

  def to_log(io : IO)
    io << self.class << '(' << @name << ')'
  end
end
