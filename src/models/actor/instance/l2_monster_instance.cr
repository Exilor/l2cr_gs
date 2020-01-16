require "../l2_attackable"
require "../known_list/monster_known_list"
require "../../../util/minion_list"

class L2MonsterInstance < L2Attackable
  private MONSTER_MAINTENANCE_INTERVAL = 1000

  @master : L2MonsterInstance?
  @minion_list : MinionList?
  @maintenance_task : Scheduler::PeriodicTask?

  setter enable_minions : Bool = true

  def initialize(template : L2NpcTemplate)
    super
    self.auto_attackable = true
  end

  def instance_type : InstanceType
    InstanceType::L2MonsterInstance
  end

  private def init_known_list : MonsterKnownList
    @known_list = MonsterKnownList.new(self)
  end

  def auto_attackable?(char : L2Character) : Bool
    super && !event_mob?
  end

  def aggressive? : Bool
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

  def maintenance_interval : Int32
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

  def delete_me : Bool
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

  def leader? : L2MonsterInstance?
    @master
  end

  def leader : L2MonsterInstance
    @master || raise "This #{self.class} has no master"
  end

  def leader=(leader : L2MonsterInstance?)
    @master = leader
  end

  def has_minions? : Bool
    !!@minion_list
  end

  def minion_list : MinionList
    @minion_list || sync { @minion_list ||= MinionList.new(self) }
  end

  def monster? : Bool
    true
  end

  def walker? : Bool
    (leader = leader?) ? leader.walker? : super
  end

  def give_raid_curse? : Bool
    if raid_minion? && (leader = leader?)
      return leader.give_raid_curse?
    end

    super
  end
end
