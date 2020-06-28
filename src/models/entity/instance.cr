require "../../enums/instance_reenter_type"
require "../../enums/instance_remove_buff_type"
require "../../enums/day_of_week"
require "../holders/instance_reenter_time_holder"

class Instance
  include Packets::Outgoing
  include Loggable
  include XMLReader

  private alias Say2 = Packets::Incoming::Say2

  @check_time_up_task : TaskScheduler::DelayedTask?
  @eject_dead_tasks = Concurrent::Map(Int32, TaskScheduler::DelayedTask?).new
  @allow_random_walk = true
  @doors = Concurrent::Map(Int32, L2DoorInstance).new
  @manual_spawn = {} of String => Array(L2Spawn)
  @last_left = -1i64

  getter id
  getter players = Concurrent::Array(Int32).new
  getter npcs = Concurrent::Array(L2Npc).new
  getter instance_start_time = Time.ms
  getter instance_end_time = -1i64
  getter timer_text = ""
  getter enter_locations = [] of Location
  setter allow_summon : Bool = true
  setter empty_destroy_time : Int64 = -1i64
  getter reenter_data = [] of InstanceReenterTimeHolder # L2J: _resetData
  getter remove_buff_type = InstanceRemoveBuffType::NONE
  getter buff_exception_list = [] of Int32 # L2J: _exceptionList
  getter? show_timer = false
  getter? timer_increase = true
  property name : String = ""
  property eject_time : Int64
  property exit_loc : Location?
  property? pvp_instance : Bool = false
  property reenter_type = InstanceReenterType::NONE # L2J: _type

  def initialize(@id : Int32)
    @eject_time = Config.eject_dead_player_time.to_i64
  end

  def initialize(@id : Int32, @name : String)
    @eject_time = Config.eject_dead_player_time.to_i64
  end

  def summon_allowed? : Bool
    @allow_summon
  end

  def duration=(val : Int)
    @check_time_up_task.try &.cancel
    task = CheckTimeUp.new(self, val.to_i32)
    @check_time_up_task = ThreadPoolManager.schedule_general(task, 500)
    @instance_end_time = Time.ms + val + 500
  end

  def includes?(l2id : Int32) : Bool
    @players.includes?(l2id)
  end

  def add_player(l2id : Int32)
    @players << l2id
  end

  def remove_player(l2id : Int32)
    @players.delete_first(l2id)
    if @players.empty? && @empty_destroy_time >= 0
      @last_left = time = Time.ms
      self.duration = @instance_end_time - time - 500
    end
  end

  def add_npc(npc : L2Npc)
    @npcs << npc
  end

  def remove_npc(npc : L2Npc)
    npc.spawn?.try &.stop_respawn
    @npcs.delete_first(npc)
  end

  def add_door(door_id : Int32, set : StatsSet)
    if @doors.has_key?(door_id)
      warn { "Door with ID #{door_id} already exists." }
      return
    end

    template = L2DoorTemplate.new(set)
    door = L2DoorInstance.new(template)
    door.instance_id = @id
    door.max_hp!
    door.spawn_me(template.x, template.y, template.z)
    @doors[door_id] = door
  end

  def doors : Enumerable(L2DoorInstance)
    @doors.local_each_value
  end

  def get_door(id : Int32) : L2DoorInstance?
    @doors[id]?
  end

  def add_enter_location(loc : Location)
    @enter_locations << loc
  end

  def remove_players
    @players.each do |id|
      if pc = L2World.get_player(id)
        next unless pc.instance_id == @id
        pc.instance_id = 0
        if loc = @exit_loc
          pc.tele_to_location(loc, true)
        else
          pc.tele_to_location(TeleportWhereType::TOWN)
        end
      end
    end

    @players.clear
  end

  def remove_npcs
    @npcs.each do |npc|
      npc.spawn?.try &.stop_respawn
      npc.delete_me
    end
    @npcs.clear
    @manual_spawn.clear
  end

  def remove_doors
    @doors.each_value do |door|
      region = door.world_region
      door.decay_me
      region.try &.remove_visible_object door
      door.known_list.remove_all_known_objects
      L2World.remove_object(door)
    end

    @doors.clear
  end

  def spawn_group(group_name : String) : Array(L2Npc)?
    if temp = @manual_spawn[group_name]?
      return temp.map &.do_spawn
    end

    warn { "Cannot spawn NPCs, wrong group name '#{group_name}'." }
    nil
  end

  def load_instance_template(file_name : String)
    parse_datapack_file("instances/" + file_name)
  rescue e
    error e
  end

  private def parse_document(doc, file)
    find_element(doc, "instance") do |n|
      parse_instance(n)
    end
  end

  private def parse_instance(node)
    @name = parse_string(node, "name")

    if temp = parse_long(node, "ejectTime", nil)
      @eject_time = 1000i64 * temp.to_i64
    end

    temp = parse_bool(node, "allowRandomWalk", nil)
    unless temp.nil?
      @allow_random_walk = temp
    end

    each_element(node) do |n, n_name|
      case n_name.casecmp
      when "activitytime"
        if temp = parse_long(n, "val", nil)
          delay = 15000
          ctu = CheckTimeUp.new(self, temp.to_i * 60000)
          @check_time_up_task = ThreadPoolManager.schedule_general(ctu, delay)
          @instance_end_time = Time.ms + (temp.to_i64 * 60000) + 15000
        end
      when "allowsummon"
        temp = parse_bool(n, "val", nil)
        unless temp.nil?
          self.allow_summon = temp
        end
      when "emptydestroytime"
        if temp = parse_string(n, "val", nil)
          @empty_destroy_time = temp.to_i64 * 1000
        end
      when "showtimer"
        if temp = parse_string(n, "val", nil)
          @show_timer = Bool.new(temp)
        end
        if temp = parse_string(n, "increase", nil)
          @timer_increase = Bool.new(temp)
        end
        if temp = parse_string(n, "text", nil)
          @timer_text = temp
        end
      when "pvpinstance"
        if temp = parse_string(n, "val", nil)
          self.pvp_instance = Bool.new(temp)
        end
      when "doorlist"
        find_element(n, "door") do |d|
          door_id = parse_int(d, "doorId")
          unless template = DoorData.get_door_template(door_id)
            raise "Door with id #{door_id} not found."
          end
          ss = StatsSet.new
          ss.merge!(template)
          find_element(d, "set") do |b|
            key = parse_string(b, "name")
            val = parse_string(b, "val")
            ss[key] = val
          end
          add_door(door_id, ss)
        end
      when "spawnlist"
        find_element(n, "group") do |group|
          spawn_group = parse_string(group, "name")
          manual_spawn = [] of L2Spawn
          each_element(group) do |d|
            npc_id = parse_int(d, "npcId", 0)
            x = parse_int(d, "x", 0)
            y = parse_int(d, "y", 0)
            z = parse_int(d, "z", 0)
            heading = parse_int(d, "heading", 0)
            respawn = parse_int(d, "respawn", 0)

            delay = parse_int(d, "onKillDelay", -1)
            respawn_random = parse_int(d, "respawnRandom", 0)

            if temp = parse_string(d, "allowRandomWalk", nil)
              allow_random_walk = Bool.new(temp)
            end

            area_name = parse_string(d, "areaName", nil)
            global_map_id = parse_int(d, "globalMapId", 0)

            spawn_dat = L2Spawn.new(npc_id)
            spawn_dat.x = x
            spawn_dat.y = y
            spawn_dat.z = z
            spawn_dat.amount = 1
            spawn_dat.heading = heading
            spawn_dat.set_respawn_delay(respawn, respawn_random)
            if respawn == 0
              spawn_dat.stop_respawn
            else
              spawn_dat.start_respawn
            end
            spawn_dat.instance_id = id()
            if allow_random_walk.nil?
              spawn_dat.no_random_walk = !@allow_random_walk
            else
              spawn_dat.no_random_walk = !allow_random_walk
            end
            spawn_dat.area_name = area_name
            spawn_dat.global_map_id = global_map_id
            if spawn_group == "general"
              spawned = spawn_dat.do_spawn
              if delay >= 0 && spawned.is_a?(L2Attackable)
                spawned.on_kill_delay = delay
              end
            else
              manual_spawn << spawn_dat
            end
          end
          unless manual_spawn.empty?
            @manual_spawn[spawn_group] = manual_spawn
          end
        end
      when "exitpoint"
        x = parse_int(n, "x")
        y = parse_int(n, "y")
        z = parse_int(n, "z")
        @exit_loc = Location.new(x, y, z)
      when "spawnpoints"
        @enter_locations.clear
        find_element(n, "Location") do |loc|
          begin
            x = parse_int(loc, "x")
            y = parse_int(loc, "y")
            z = parse_int(loc, "z")
            @enter_locations << Location.new(x, y, z)
          rescue e
            error e
          end
        end
      when "reenter"
        if temp = parse_enum(n, "additionStyle", InstanceReenterType, nil)
          @reenter_type = temp
        end

        find_element(n, "reset") do |d|
          time = -1i64
          day = nil
          hour = -1
          minute = -1

          if temp = parse_string(d, "time", nil)
            time = temp.to_i64
            if time > 0
              @reenter_data << InstanceReenterTimeHolder.new(time)
            end
          elsif time == -1
            if temp = parse_string(d, "day", nil)
              day = DayOfWeek.parse(temp)
            end
            if temp = parse_string(d, "hour", nil)
              hour = temp.to_i
            end
            if temp = parse_string(d, "minute", nil)
              minute = temp.to_i
            end
            @reenter_data << InstanceReenterTimeHolder.new(day, hour, minute)
          end
        end
      when "removebuffs"
        if temp = parse_enum(n, "type", InstanceRemoveBuffType, nil)
          @remove_buff_type = temp
        end
        find_element(n, "skill") do |d|
          if temp = parse_int(d, "id", nil)
            @buff_exception_list << temp
          end
        end
      end
    end
  end

  protected def do_check_time_up(remaining : Int32)
    cs = nil

    if @players.empty? && @empty_destroy_time == 0
      remaining = 0
      interval = 500
    elsif @players.empty? && @empty_destroy_time > 0
      empty_time_left = (@last_left + @empty_destroy_time) + Time.ms
      if empty_time_left <= 0
        interval = 0
        remaining = 0
      elsif remaining > 300_000 && empty_time_left > 300_000
        interval = 300_000
        remaining -= 300_000
      elsif remaining > 60_000 && empty_time_left > 60_000
        interval = 60_000
        remaining -= 60_000
      elsif remaining > 30_000 && empty_time_left > 30_000
        interval = 30_000
        remaining -= 30_000
      else
        interval = 10_000
        remaining -= 10_000
      end
    elsif remaining > 300_000
      time_left = remaining // 60_000
      interval = 300_000
      sm = SystemMessage.dungeon_expires_in_s1_minutes
      sm.add_string(time_left.to_s)
      Broadcast.to_players_in_instance(sm, id)
      remaining -= 300_000
    elsif remaining > 60_000
      time_left = remaining // 60_000
      interval = 60_000
      sm = SystemMessage.dungeon_expires_in_s1_minutes
      sm.add_string(time_left.to_s)
      Broadcast.to_players_in_instance(sm, id)
      remaining -= 60_000
    elsif remaining > 30_000
      time_left = remaining // 1000
      interval = 30_000
      cs = CreatureSay.new(0, Say2::ALLIANCE, "Notice", "#{time_left} seconds left")
      remaining -= 30_000
    else
      time_left = remaining // 1000
      interval = 10_000
      cs = CreatureSay.new(0, Say2::ALLIANCE, "Notice", "#{time_left} seconds left")
      remaining -= 10_000
    end

    if cs
      @players.each do |pc_id|
        if pc = L2World.get_player(pc_id)
          if pc.instance_id == id
            pc.send_packet(cs)
          end
        end
      end
    end

    cancel_timer

    if remaining >= 10_000
      task = CheckTimeUp.new(self, remaining)
    else
      task = TimeUp.new(self)
    end

    @check_time_up_task = ThreadPoolManager.schedule_general(task, interval)
  end

  def cancel_timer
    @check_time_up_task.try &.cancel
  end

  def cancel_eject_dead_player(pc : L2PcInstance)
    @eject_dead_tasks[pc.l2id]?.try &.cancel
  end

  def add_eject_dead_task(pc : L2PcInstance)
    task = -> do
      if pc.dead? && pc.instance_id == id
        pc.instance_id = 0
        if loc = exit_loc
          pc.tele_to_location(loc, true)
        else
          pc.tele_to_location(TeleportWhereType::TOWN)
        end
      end
    end
    @eject_dead_tasks[pc.l2id] = ThreadPoolManager.schedule_general(task, @eject_time)
  end

  def notify_death(killer : L2Character?, victim : L2Character)
    if inst = InstanceManager.get_player_world(victim.acting_player.not_nil!)
      inst.on_death(killer, victim)
    end
  end

  def remove_buff_enabled? : Bool
    !remove_buff_type.none?
  end

  private struct CheckTimeUp
    initializer instance : Instance, remaining : Int32

    def call
      @instance.do_check_time_up(@remaining)
    end
  end

  private struct TimeUp
    initializer instance : Instance

    def call
      InstanceManager.destroy_instance(@instance.id)
    end
  end
end
