require "./skill_holder"

class InvulSkillHolder < SkillHolder
  @instances = Atomic(Int32).new(1)

  def initialize(skill_id : Int32, skill_level : Int32)
    super
  end

  def initialize(holder : SkillHolder)
    super(holder.skill)
  end

  def instances
    @instances.get
  end

  def increase_instances
    @instances.add(1) + 1
  end

  def decrease_instances
    @instances.sub(1) - 1
  end
end
