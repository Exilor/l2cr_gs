module GameDB
  module SkillDAO
    include Loggable

    abstract def insert(pc : L2PcInstance, class_index : Int32, skill : Skill)
    abstract def update(pc : L2PcInstance, class_index : Int32, new_skill : Skill, old_skill : Skill)
    abstract def delete(pc : L2PcInstance, skill : Skill)
    abstract def insert(pc : L2PcInstance, new_class_index : Int32, new_skills : Array(Skill))
    abstract def load(pc : L2PcInstance)
    abstract def delete_all(pc : L2PcInstance, class_index : Int32)
  end
end
