class L2GrandBossInstance < L2MonsterInstance
  private BOSS_MAINTENANCE_INTERVAL = 10_000

  property? give_raid_curse : Bool = true

  def initialize(template : L2NpcTemplate)
    super

    self.raid = true
    self.lethalable = false
  end

  def instance_type : InstanceType
    InstanceType::L2GrandBossInstance
  end

  def maintenance_interval : Int32
    BOSS_MAINTENANCE_INTERVAL
  end

  def on_spawn
    self.no_random_walk = true
    super
  end

  def do_die(killer : L2Character?) : Bool
    return false unless super

    if killer.is_a?(L2PcInstance)
      pc = killer
    elsif killer.is_a?(L2Summon)
      pc = killer.owner
    end

    if pc
      broadcast_packet(SystemMessage.raid_was_successful)
      if party = pc.party
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

    true
  end

  def use_vitality_rate? : Bool
    true
  end

  def get_vitality_points(damage : Int32) : Float32
    -super / 100f32
  end
end
