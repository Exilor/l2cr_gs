class L2WorldRegion
  include Loggable
  include Synchronizable

  @neighbors_task : Scheduler::DelayedTask?

  getter sorrounding_regions = Concurrent::LinkedList(self).new
  getter zones = Concurrent::Array(L2ZoneType).new
  getter playables = Concurrent::Map(Int32, L2Playable).new
  getter objects = Concurrent::Map(Int32, L2Object).new
  getter? active : Bool

  def initialize(@tile_x : Int32, @tile_y : Int32)
    @active = Config.grids_always_on
  end

  def add_sorrounding_region(region : self)
    @sorrounding_regions << region
  end

  def add_zone(zone : L2ZoneType)
    @zones << zone
  end

  def remove_zone(zone : L2ZoneType)
    @zones.delete_first(zone)
  end

  def revalidate_zones(char : L2Character)
    unless char.teleporting?
      zones.each &.revalidate_in_zone(char)
    end
  end

  def remove_from_zones(char : L2Character)
    zones.each &.remove_character(char)
  end

  def contains_zone?(id) : Bool
    zones.any? { |z| z.id == id }
  end

  def check_effect_range_inside_peace_zone(skill : Skill, x : Int32, y : Int32, z : Int32) : Bool
    range = skill.effect_range
    up    = y + range
    down  = y - range
    left  = x + range
    right = x - range

    @zones.each do |e|
      if e.is_a?(L2PeaceZone)
        return false if e.inside_zone?(x, up, z)
        return false if e.inside_zone?(x, down, z)
        return false if e.inside_zone?(left, y, z)
        return false if e.inside_zone?(right, y, z)
        return false if e.inside_zone?(x, y, z)
      end
    end

    true
  end

  def neighbors_empty? : Bool
    return false if active? && !@playables.empty?
    @sorrounding_regions.none? { |n| n.active? && !n.playables.empty? }
  end

  def active=(bool : Bool)
    return if bool == @active
    @active = bool
    switch_ai(bool)
    # debug bool ? 'Starting grid.' : 'Stopping grid.'
  end

  private def start_activation
    self.active = true

    sync do
      if task = @neighbors_task
        task.cancel
        @neighbors_task = nil
      end

      task = NeighborsTask.new(self, true)
      @neighbors_task = ThreadPoolManager.schedule_general(task, Config.grid_neighbor_turnon_time * 1000)
    end
  end

  private def start_deactivation
    sync do
      if task = @neighbors_task
        task.cancel
        @neighbors_task = nil
      end

      task = NeighborsTask.new(self, false)
      @neighbors_task = ThreadPoolManager.schedule_general(task, Config.grid_neighbor_turnoff_time * 1000)
    end
  end

  private def switch_ai(val : Bool)
    c = 0

    if val
      @objects.each_value do |o|
        if o.is_a?(L2Attackable)
          c += 1
          o.status.start_hp_mp_regeneration
        elsif o.is_a?(L2Npc)
          o.start_random_animation_timer
        end
      end

      # debug "#{c} mobs were turned on."
    else
      @objects.each_value do |o|
        if o.is_a?(L2Attackable)
          c += 1
          o.target = nil
          o.stop_move(nil)
          o.stop_all_effects
          o.clear_aggro_list
          o.attack_by_list.clear
          o.known_list.remove_all_known_objects

          if o.ai?
            o.intention = AI::IDLE
            o.ai.stop_ai_task
          end
        elsif o.vehicle?
          c += 1
          o.known_list.remove_all_known_objects
        end
      end

      # debug "#{c} mobs were turned off."
    end
  end

  def add_visible_object(object : L2Object)
    unless object.world_region == self
      warn { "Expected #{object}'s region to be this region." }
    end

    @objects[object.l2id] = object
    if object.is_a?(L2Playable)
      @playables[object.l2id] = object
      if @playables.size == 1 && !Config.grids_always_on
        start_activation
      end
    end
  end

  def remove_visible_object(object : L2Object)
    unless object.world_region.nil? || object.world_region == self
      warn { "Expected #{object}'s region to be this region or nil." }
    end

    @objects.delete(object.l2id)

    if object.is_a?(L2Playable)
      @playables.delete(object.l2id)
      if @playables.empty? && !Config.grids_always_on
        start_deactivation
      end
    end
  end

  def on_death(char : L2Character)
    zones.each &.on_die_inside(char)
  end

  def on_revive(char : L2Character)
    zones.each &.on_revive_inside(char)
  end

  def neighbors_empty? : Bool
    return false if active? && !@playables.empty?
    @sorrounding_regions.none? { |n| n.active? && !n.playables.empty? }
  end

  def delete_visible_npc_spawns
    @objects.each_value do |obj|
      if obj.is_a?(L2Npc)
        obj.delete_me
        if sp = obj.spawn?
          sp.stop_respawn
          SpawnTable.delete_spawn(sp, false)
        end
        # debug "Removed #{obj}."
      end
    end

    # info "All visible NPCs have been removed."
  end

  def to_s(io : IO)
    io << '(' << @tile_x << ", " << @tile_y << ')'
  end

  def inspect(io : IO)
    to_s(io)
  end

  def to_log(io : IO)
    to_s(io)
  end

  private struct NeighborsTask
    initializer region : L2WorldRegion, activate : Bool

    def call
      if @activate
        @region.sorrounding_regions.each &.active = true
      else
        if @region.neighbors_empty?
          @region.active = false
        end

        @region.sorrounding_regions.each do |reg|
          if reg.neighbors_empty?
            reg.active = false
          end
        end
      end
    end
  end
end
