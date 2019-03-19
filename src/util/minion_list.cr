class MinionList
  include Loggable
  extend Loggable

  @minion_references = [] of L2MonsterInstance
  @reused_minion_references : Array(L2MonsterInstance)?

  initializer master: L2MonsterInstance

  def spawned_minions
    @minion_references
  end

  def spawn_minions(minions : Enumerable(MinionHolder)?)
    return if minions.nil? || @master.looks_dead?

    minions.each do |minion|
      count = minion.count
      id = minion.id

      to_spawn = count - count_spawned_minions_by_id(id)
      to_spawn.times { spawn_minion(id) }
    end

    delete_reused_minions
  end

  def delete_spawned_minions
    unless @minion_references.empty?
      @minion_references.each do |minion|
        minion.leader = nil
        minion.delete_me
        @reused_minion_references.try &.push(minion)
      end

      @minion_references.clear
    end
  end

  def delete_reused_minions
    @reused_minion_references.try &.clear
  end

  def on_master_spawn
    delete_spawned_minions

    if !@reused_minion_references &&
       !@master.template.parameters["SummonPrivateRate"]? &&
       !@master.template.parameters.get_minion_list("Privates").empty? &&
       @master.spawn? && @master.spawn.respawn_enabled?

      @reused_minion_references = [] of L2MonsterInstance
    end
  end

  def on_minion_spawn(minion : L2MonsterInstance)
    @minion_references << minion
  end

  def on_master_die(force : Bool)
    delete_spawned_minions if @master.raid? || force
  end

  def on_minion_die(minion : L2MonsterInstance, respawn_time : Int32)
    minion.leader = nil
    @minion_references.delete(minion)
    @reused_minion_references.try &.push(minion)

    time = respawn_time < 0 ? @master.raid? ? Config.raid_minion_respawn_timer.to_i : 0 : respawn_time
    if time > 0 && !@master.looks_dead?
      # MinionRespawnTask.new(minion).start time
      task = ->{ minion_respawn_task(minion) }
      ThreadPoolManager.schedule_general(task, time)
    end
  end

  def on_assist(caller : L2Character, attacker : L2Character?)
    if !@master.looks_dead? && !@master.in_combat?
      @master.add_damage_hate(attacker, 0, 1)
    end

    caller_is_master = caller == @master
    aggro = caller_is_master ? 10 : 1
    if @master.raid?
      aggro *= 10
    end

    @minion_references.each do |minion|
      if minion.alive? && (caller_is_master || !minion.in_combat?)
        minion.add_damage_hate(attacker, 0, aggro)
      end
    end
  end

  def on_master_teleported
    offset = 200
    min_radius = (@master.collision_radius + 30).to_i

    @minion_references.each do |minion|
      if minion.alive? && !minion.movement_disabled?
        new_x = Rnd.rand(min_radius * 2..offset * 2)
        new_y = Rnd.rand(new_x..offset * 2)
        new_y = Math.sqrt((new_y * new_y) - (new_x * new_x))
        if new_x > offset + min_radius
          new_x = (@master.x + new_x) - offset
        else
          new_x = (@master.x + new_x) + min_radius
        end
        if new_y > offset + min_radius
          new_y = (@master.y + new_y) - offset
        else
          new_y = (@master.y + new_y) + min_radius
        end
        minion.tele_to_location(Location.new(new_x, new_y.to_i32, @master.z))
      end
    end
  end

  private def spawn_minion(minion_id : Int32)
    return if minion_id == 0

    if temp = @reused_minion_references
      if minion = temp.find { |m| m.id == minion_id }
        temp.delete(minion)
        minion.refresh_id
        MinionList.initialize_npc_instance(@master, minion)
        return
      end
    end

    MinionList.spawn_minion(@master, minion_id)
  end

  def self.spawn_minion(master : L2MonsterInstance, minion_id : Int32) : L2MonsterInstance?
    return unless template = NpcData[minion_id]?
    initialize_npc_instance(master, L2MonsterInstance.new(template))
  end

  private def minion_respawn_task(minion : L2MonsterInstance)
    if !@master.looks_dead? && @master.visible?
      unless minion.visible?
        @reused_minion_references.try &.delete(minion)
        minion.refresh_id
        MinionList.initialize_npc_instance(@master, minion)
      end
    end
  end

  def self.initialize_npc_instance(master : L2MonsterInstance, minion : L2MonsterInstance) : L2MonsterInstance
    minion.stop_all_effects
    minion.dead = false
    minion.decayed = false

    minion.heal!
    minion.heading = master.heading

    minion.leader = master

    minion.instance_id = master.instance_id

    offset = 200
    min_radius = (master.collision_radius + 30)

    new_x = Rnd.rand((min_radius.to_i * 2).to_i32..offset * 2)
    new_y = Rnd.rand(new_x..offset * 2)
    new_y = (Math.sqrt((new_y * new_y) - (new_x * new_x))).to_i
    if new_x > (offset + min_radius)
      new_x = (master.x + new_x) - offset
    else
      new_x = (master.x - new_x) + min_radius
    end
    if new_y > (offset + min_radius)
      new_y = (master.y + new_y) - offset
    else
      new_y = (master.y - new_y) + min_radius
    end

    minion.spawn_me(new_x.to_i, new_y.to_i, master.z)

    if Config.debug
      # debug "Spawned minion template #{minion.id} with object ID #{minion.l2id} to master with object ID #{master.l2id} at #{minion.x} #{minion.y} #{minion.z}."
    end

    minion
  end

  private def count_spawned_minions_by_id(minion_id : Int)
    @minion_references.count { |npc| npc.id == minion_id }
  end

  def count_spawned_minions : Int32
    @minion_references.size
  end

  def lazy_count_spawned_minions_group : Int32
    @minion_references.each.map(&.id).uniq.size
  end
end
