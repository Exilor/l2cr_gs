module MobGroupTable
  extend self

  FOLLOW_RANGE = 300
  RANDOM_RANGE = 300

  private GROUP_MAP = {} of Int32 => MobGroup # concurrent

  def add_group(key : Int32, group : MobGroup)
    GROUP_MAP[key] = group
  end

  def get_group(key : Int32) : MobGroup?
    GROUP_MAP[key]?
  end

  def group_count : Int32
    GROUP_MAP.size
  end

  def get_group_for_mob(mob : L2ControllableMobInstance) : MobGroup?
    GROUP_MAP.find_value &.group_member?(mob)
  end

  def groups : Iterator(MobGroup)
    GROUP_MAP.local_each_value
  end

  def remove_group(key : Int32) : Bool
    !!GROUP_MAP.delete(key)
  end
end
