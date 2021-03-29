require "./mob_group_table"
require "./l2_group_spawn"

class MobGroup
  include Loggable

  getter(mobs) { Concurrent::Array(L2ControllableMobInstance).new }

  getter_initializer group_id : Int32, template : L2NpcTemplate,
    max_mob_count : Int32

  def active_mob_count : Int32
    mobs.size
  end

  def status : String
    ai = mobs[0].ai

    case ai.as(L2ControllableMobAI).alternate_ai
    when L2ControllableMobAI::AI_NORMAL
      "Idle"
    when L2ControllableMobAI::AI_FORCEATTACK
      "Force Attacking"
    when L2ControllableMobAI::AI_FOLLOW
      "Following"
    when L2ControllableMobAI::AI_CAST
      "Casting"
    when L2ControllableMobAI::AI_ATTACK_GROUP
      "Attacking Group"
    else
      "Idle"
    end
  rescue
    "Unspawned"
  end

  def group_member?(mob : L2ControllableMobInstance) : Bool
    mobs.any? { |m| mob.l2id == m.l2id }
  end

  def spawn_group(x : Int32, y : Int32, z : Int32)
    if active_mob_count > 0
      return
    end

    begin
      max_mob_count.times do
        sp = L2GroupSpawn.new(template)

        sx = Rnd.bool ? -1 : 1
        sy = Rnd.bool ? -1 : 1
        rx = Rnd.rand(MobGroupTable::RANDOM_RANGE)
        ry = Rnd.rand(MobGroupTable::RANDOM_RANGE)

        sp.x = x + (sx * rx)
        sp.y = y + (sy * ry)
        sp.z = z
        sp.stop_respawn

        SpawnTable.add_new_spawn(sp, false)
        mobs << sp.do_group_spawn.as(L2ControllableMobInstance)
      end
    rescue e
      warn e
    end
  end

  def spawn_group(pc : L2PcInstance)
    spawn_group(*pc.xyz)
  end

  def teleport_group(pc : L2PcInstance)
    remove_dead

    mobs.each do |mob_inst|
      unless mob_inst.dead?
        x = pc.x + Rnd.rand(50)
        y = pc.y + Rnd.rand(50)

        mob_inst.tele_to_location(x, y, pc.z, true)
        ai = mob_inst.ai.as(L2ControllableMobAI)
        ai.follow(pc)
      end
    end
  end

  def rand_mob : L2ControllableMobInstance?
    remove_dead
    mobs.sample?
  end

  def unspawn_group
    remove_dead

    if active_mob_count == 0
      return
    end

    mobs.each do |mob_inst|
      if mob_inst.alive?
        mob_inst.delete_me
      end

      SpawnTable.delete_spawn(mob_inst.spawn, false)
    end

    mobs.clear
  end

  def kill_group(pc : L2PcInstance)
    remove_dead

    mobs.each do |mob_inst|
      if mob_inst.alive?
        mob_inst.reduce_current_hp(mob_inst.max_hp.to_f + 1, pc, nil)
      end

      SpawnTable.delete_spawn(mob_inst.spawn, false)
    end

    mobs.clear
  end

  def set_attack_random
    remove_dead

    mobs.each do |mob_inst|
      ai = mob_inst.ai.as(L2ControllableMobAI)
      ai.alternate_ai = L2ControllableMobAI::AI_NORMAL
      ai.intention = AI::ACTIVE
    end
  end

  def attack_target=(target : L2Character)
    remove_dead

    mobs.each do |mob_inst|
      ai = mob_inst.ai.as(L2ControllableMobAI)
      ai.force_attack(target)
    end
  end

  def set_idle_mode
    remove_dead
    mobs.each { |inst| inst.ai.as(L2ControllableMobAI).stop }
  end

  def return_group(pc : L2Character)
    set_idle_mode

    mobs.each do |mob_inst|
      sx = Rnd.bool ? -1 : 1
      sy = Rnd.bool ? -1 : 1
      rx = Rnd.rand(MobGroupTable::RANDOM_RANGE)
      ry = Rnd.rand(MobGroupTable::RANDOM_RANGE)

      ai = mob_inst.ai.as(L2ControllableMobAI)
      ai.move(pc.x + (sx * rx), pc.y + (sy * ry), pc.z)
    end
  end

  def set_follow_mode(char : L2Character)
    remove_dead

    mobs.each do |mob_inst|
      ai = mob_inst.ai.as(L2ControllableMobAI)
      ai.follow(char)
    end
  end

  def set_cast_mode
    remove_dead

    mobs.each do |mob_inst|
      ai = mob_inst.ai.as(L2ControllableMobAI)
      ai.alternate_ai = L2ControllableMobAI::AI_CAST
    end
  end

  def no_move_mode=(enabled : Bool)
    remove_dead

    mobs.each do |mob_inst|
      ai = mob_inst.ai.as(L2ControllableMobAI)
      ai.not_moving = enabled
    end
  end

  private def remove_dead
    mobs.reject! &.dead?
  end

  def invul=(state : Bool)
    remove_dead

    mobs.each do |mob_inst|
      mob_inst.invul = state
    end
  end

  def attack_group=(other : MobGroup)
    remove_dead

    mobs.each do |mob_inst|
      ai = mob_inst.ai.as(L2ControllableMobAI)
      ai.force_attack_group(other)
      ai.intention = AI::ACTIVE
    end
  end
end
