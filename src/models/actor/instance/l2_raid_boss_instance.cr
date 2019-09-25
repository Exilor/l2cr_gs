class L2RaidBossInstance < L2MonsterInstance
  private RAIDBOSS_MAINTENANCE_INTERVAL = 30_000

  # @raid = true
  # @lethalable = false
  property raid_status : RaidBossSpawnManager::Status = RaidBossSpawnManager::Status::UNDEFINED
  property? give_raid_curse : Bool = true

  def initialize(template : L2NpcTemplate)
    super

    self.raid = true
    self.lethalable = false
  end

  def instance_type : InstanceType
    InstanceType::L2RaidBossInstance
  end

  def on_spawn
    self.no_rnd_walk = true
    super
  end

  def maintenance_interval : Int32
    RAIDBOSS_MAINTENANCE_INTERVAL
  end

  def get_vitality_points(damage : Int32) : Float32
    -super / 100
  end

  def use_vitality_points? : Bool
    false
  end

  def do_die(killer : L2Character?) : Bool
    unless super
      return false
    end

    if pc = killer.try &.acting_player?
      broadcast_packet(SystemMessage.raid_was_successful)

      if party = pc.party?
        party.members.each do |m|
          RaidBossPointsManager.add_points(m, id, (level // 2) + Rnd.rand(-5..5))
          if m.noble?
            Hero.set_rb_killed(m.l2id, id)
          end
        end
      else
        RaidBossPointsManager.add_points(pc, id, (level // 2) + Rnd.rand(-5..5))
        if pc.noble?
          Hero.set_rb_killed(pc.l2id, id)
        end
      end
    end

    RaidBossSpawnManager.update_status(self, true)

    true
  end

  private def start_maintenance_task
    task = ->check_and_return_to_spawn
    interval = maintenance_interval + Rnd.rand(5000)
    @maintenance_task = ThreadPoolManager.schedule_general_at_fixed_rate(task, 60000, interval)
  end

  private def check_and_return_to_spawn
    if dead? || movement_disabled? || !can_return_to_spawn_point?
      return
    end

    unless sp = spawn?
      return
    end

    if !in_combat? && !movement_disabled?
      x, y, z = sp.xyz
      range = Math.max(Config.max_drift_range, 200)
      unless inside_radius?(x, y, z, range, true, false)
        tele_to_location(x, y, z, false)
      end
    end
  end
end
