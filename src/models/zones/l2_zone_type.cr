require "./l2_zone_form"
require "./abstract_zone_settings"
require "./task_zone_settings"
require "../events/event_type"

abstract class L2ZoneType < ListenersContainer
  include Packets::Outgoing

  @check_affected = false
  @min_lvl = 0
  @max_lvl = 0xff
  @class_type = 0
  @character_list = Concurrent::Map(Int32, L2Character).new
  @race : Array(Int32)?
  @class : Array(Int32)?

  getter target_type = InstanceType::L2Character
  getter instance_template = ""
  getter settings : AbstractZoneSettings?
  getter! zone : L2ZoneForm
  getter? allow_store = true
  property name : String?
  property instance_id : Int32 = -1
  property? enabled : Bool = true

  getter_initializer id : Int32

  delegate visualize_zone, to: zone

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
      @target_type = InstanceType.parse(value)
    when "allowStore"
      @allow_store = value.to_b
    when "default_enabled"
      @enabled = value.to_b
    else
      warn { "Unknown parameter '#{name}' in zone #{@id}." }
    end
  end

  def affected?(char : L2Character) : Bool
    return false unless char.level.between?(@min_lvl, @max_lvl)
    return false unless char.instance_type?(@target_type)

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
    @zone ? raise("zone already set") : (@zone = zone)
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
    if @character_list.delete(char.l2id)
      OnCreatureZoneExit.new(char, self).async(self)
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

  def characters_inside : Enumerable(L2Character)
    @character_list.local_each_value
  end

  def players_inside : Enumerable(L2PcInstance)
    characters_inside.select(L2PcInstance)
  end

  def broadcast_packet(gsp : GameServerPacket)
    players_inside.each &.broadcast_packet(gsp)
  end

  def target_type=(type : InstanceType)
    @target_type = type
    @check_affected = true
  end

  def to_log(io : IO)
    io.print(self.class, '(', @name, ')')
  end
end
