require "../l2_attackable"
require "../known_list/monster_known_list"
require "../../../util/minion_list"

class L2MonsterInstance < L2Attackable
  private MONSTER_MAINTENANCE_INTERVAL = 1000

  setter enable_minions : Bool = true
  @master : L2MonsterInstance?
  @minion_list : MinionList?
  @maintenance_task : Runnable::PeriodicTask?

  def initialize(template : L2NpcTemplate)
    super
    self.auto_attackable = true
  end

  def instance_type
    InstanceType::L2MonsterInstance
  end

  def init_known_list
    @known_list = MonsterKnownList.new(self)
  end

  def auto_attackable?(char)
    super && !event_mob?
  end

  def aggressive?
    template.aggressive? && !event_mob?
  end

  def on_spawn
    unless teleporting?
      if leader?
        self.no_rnd_walk = true
        self.raid_minion = leader.raid?
        leader.minion_list.on_minion_spawn(self)
      end

      if has_minions?
        minion_list.on_master_spawn
      end

      start_maintenance_task
    end

    super
  end

  def on_teleported
    super

    if has_minions?
      minion_list.on_master_teleported
    end
  end

  def maintenance_interval
    MONSTER_MAINTENANCE_INTERVAL
  end

  def start_maintenance_task
    # no op
  end

  def do_die(killer : L2Character?) : Bool
    return false unless super

    if task = @maintenance_task
      task.cancel
      @maintenance_task = nil
    end

    true
  end

  def delete_me
    if task = @maintenance_task
      task.cancel
      @maintenance_task = nil
    end

    if has_minions?
      minion_list.on_master_die(true)
    end

    if leader = leader?
      leader.minion_list.on_minion_die(self, 0)
    end

    super
  end

  def leader?
    @master
  end

  def leader : L2MonsterInstance
    @master.not_nil!
  end

  def leader=(leader : L2MonsterInstance?)
    @master = leader
  end

  def has_minions? : Bool
    !@minion_list.nil?
  end

  def minion_list : MinionList
    @minion_list || sync { @minion_list ||= MinionList.new(self) }
  end

  def monster? : Bool
    true
  end

  def walker? : Bool
    leader? ? leader.walker? : super
  end

  def give_raid_curse? : Bool
    raid_minion? && leader? ? leader.give_raid_curse? : super
  end
end
