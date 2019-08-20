module GameDB
  module SkillDAOMySQLImpl
    extend self
    extend SkillDAO

    private SELECT = "SELECT skill_id,skill_level FROM character_skills WHERE charId=? AND class_index=?"
    private INSERT = "INSERT INTO character_skills (charId,skill_id,skill_level,class_index) VALUES (?,?,?,?)"
    private UPDATE = "UPDATE character_skills SET skill_level=? WHERE skill_id=? AND charId=? AND class_index=?"
    private REPLACE = "REPLACE INTO character_skills (charId,skill_id,skill_level,class_index) VALUES (?,?,?,?)"
    private DELETE_ONE = "DELETE FROM character_skills WHERE skill_id=? AND charId=? AND class_index=?"
    private DELETE_ALL = "DELETE FROM character_skills WHERE charId=? AND class_index=?"

    def load(pc : L2PcInstance)
      GameDB.each(SELECT, pc.l2id, pc.class_index) do |rs|
        id = rs.get_i32("skill_id")
        level = rs.get_i32("skill_level")
        unless skill = SkillData[id, level]?
          warn { "Skill with ID #{id} and lv. #{level} not found." }
          next
        end

        pc.add_skill(skill)

        if Config.skill_check_enable && (!pc.override_skill_conditions? || Config.skill_check_gm)
          unless SkillTreesData.skill_allowed?(pc, skill)
            Util.punish(
              pc,
              "has invalid skill #{skill.name} (#{skill.id}/#{skill.level}), class: #{ClassListData.get_class!(pc.class_id).class_name}",
              IllegalActionPunishmentType::BROADCAST
            )
            if Config.skill_check_remove
              pc.remove_skill(skill)
            end
          end
        end
      end
    rescue e
      error e
    end

    def insert(pc : L2PcInstance, class_index : Int32, skill : Skill)
      GameDB.exec(
        INSERT,
        pc.l2id,
        skill.id,
        skill.level,
        class_index
      )
    rescue e
      error e
    end

    def insert(pc : L2PcInstance, new_class_index : Int32, new_skills : Array(Skill))
      return if new_skills.empty?

      class_index = new_class_index > -1 ? new_class_index : pc.class_index

      new_skills.each do |skill|
        GameDB.exec(
          REPLACE,
          pc.l2id,
          skill.id,
          skill.level,
          class_index
        )
      end

      # ps = GameDB.prepare
      # temp = new_skills.map do |skill|
      #   [pc.l2id, skill.id, skill.level, class_index] of DB::Any
      # end
      # ps.exec(REPLACE, temp)
    rescue e
      error e
    end

    def update(pc : L2PcInstance, class_index : Int32, new_skill : Skill, old_skill : Skill)
      GameDB.exec(
        UPDATE,
        new_skill.level,
        old_skill.id,
        pc.l2id,
        class_index
      )
    rescue e
      error e
    end

    def delete(pc : L2PcInstance, skill : Skill)
      GameDB.exec(DELETE_ONE, skill.id, pc.l2id, pc.class_index)
    rescue e
      error e
    end

    def delete_all(pc : L2PcInstance, class_index : Int32)
      GameDB.exec(DELETE_ALL, pc.l2id, class_index)
    rescue e
      error e
    end

  end
end
