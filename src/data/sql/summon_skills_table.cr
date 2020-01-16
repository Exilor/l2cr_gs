module SummonSkillsTable
  extend self
  extend Loggable

  private record L2PetSkillLearn, id : Int32, level : Int32, min_level : Int32

  private SKILL_TREES = {} of Int32 => Hash(Int32, L2PetSkillLearn)

  def load
    SKILL_TREES.clear

    count = 0

    sql = "SELECT templateId, minLvl, skillId, skillLvl FROM pets_skills"
    GameDB.each(sql) do |rs|
      npc_id = rs.get_i32("templateId")
      skill_tree = SKILL_TREES[npc_id] ||= {} of Int32 => L2PetSkillLearn
      id = rs.get_i32("skillId")
      lvl = rs.get_i32("skillLvl")
      skill_learn = L2PetSkillLearn.new(id, lvl, rs.get_i32("minLvl"))
      skill_tree[SkillData.get_skill_hash(id, lvl + 1)] = skill_learn
      count += 1
    end

    info { "Loaded #{count} pet skills." }
  end

  def get_available_level(s : L2Summon, id : Int32) : Int32
    lvl = 0
    unless tree = SKILL_TREES[s.id]?
      warn { "#{s} doesn't have any skills assigned." }
      return lvl
    end

    tree.each_value do |sk|
      next if sk.id != id
      if sk.level == 0
        if s.level < 70
          lvl = s.level // 10
          lvl = 1 if lvl <= 10
        else
          lvl = 7 + ((s.level - 70) // 5)
        end

        max_lvl = SkillData.get_max_level(sk.id)
        lvl = max_lvl if lvl > max_lvl
        break
      elsif sk.min_level <= s.level
        if sk.level > lvl
          lvl = sk.level
        end
      end
    end
    debug { "Available level: #{lvl}." }
    lvl
  end
end
