struct TimeStamp
  getter id1 : Int32, id2 : Int32, group = -1, stamp : Int64, reuse : Int64

  def initialize(skill : Skill, reuse : Int, time : Int)
    @id1 = skill.id
    @id2 = skill.level
    @reuse = reuse.to_i64
    @stamp = time > 0 ? time.to_i64 : Time.ms + reuse
  end

  def initialize(item : L2ItemInstance, reuse : Int, time : Int)
    @id1 = item.id
    @id2 = item.l2id
    @reuse = reuse.to_i64
    @stamp = time > 0 ? time.to_i64 : Time.ms + reuse
    @group = item.shared_reuse_group
  end

  def item_id : Int32
    id1
  end

  def item_l2id : Int32
    id2
  end

  def skill_id : Int32
    id1
  end

  def skill_lvl : Int32
    id2
  end

  def shared_reuse_group : Int32
    group
  end

  def remaining : Int64
    Math.max(@stamp - Time.ms, 0i64)
  end

  def has_not_passed? : Bool
    Time.ms < @stamp
  end
end
