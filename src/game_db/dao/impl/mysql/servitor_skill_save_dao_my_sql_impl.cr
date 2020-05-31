module GameDB
  module ServitorSkillSaveDAOMySQLImpl
    extend self
    extend ServitorSkillSaveDAO

    private ADD_SKILL_SAVE = "INSERT INTO character_summon_skills_save (ownerId,ownerClassIndex,summonSkillId,skill_id,skill_level,remaining_time,buff_index) VALUES (?,?,?,?,?,?,?)"
    private RESTORE_SKILL_SAVE = "SELECT skill_id,skill_level,remaining_time,buff_index FROM character_summon_skills_save WHERE ownerId=? AND ownerClassIndex=? AND summonSkillId=? ORDER BY buff_index ASC"
    private DELETE_SKILL_SAVE = "DELETE FROM character_summon_skills_save WHERE ownerId=? AND ownerClassIndex=? AND summonSkillId=?"

    def insert(servitor : L2ServitorInstance, store_effects : Bool)
      GameDB.exec(
        DELETE_SKILL_SAVE,
        servitor.owner.l2id,
        servitor.owner.class_index,
        servitor.reference_skill
      )

      if store_effects
        buff_index = 0
        stored_skills = [] of Int32

        servitor.effect_list.each(false) do |info|
          skill = info.skill

          if skill.abnormal_type.life_force_others?
            next
          end
          if skill.toggle?
            next
          end
          if skill.dance? && !Config.alt_store_dances
            next
          end
          if stored_skills.includes?(skill.hash)
            next
          end

          stored_skills << skill.hash

          GameDB.exec(
            ADD_SKILL_SAVE,
            servitor.owner.l2id,
            servitor.owner.class_index,
            servitor.reference_skill,
            skill.id,
            skill.level,
            info.time,
            buff_index &+= 1
          )

          SummonEffectsTable.add_servitor_effect(servitor.owner, servitor.reference_skill, skill, info.time)
        end
      end
    rescue e
      error e
    end

    def load(servitor : L2ServitorInstance)
      unless SummonEffectsTable.contains_skill?(servitor.owner, servitor.reference_skill)
        owner_id = servitor.owner.l2id
        class_index = servitor.owner.class_index
        ref_skill = servitor.reference_skill
        GameDB.each(RESTORE_SKILL_SAVE, owner_id, class_index, ref_skill) do |rs|
          time = rs.get_i32(:"remaining_time")
          skill_id = rs.get_i32(:"skill_id")
          skill_lvl = rs.get_i32(:"skill_level")
          unless skill = SkillData[skill_id, skill_lvl]?
            next
          end

          if skill.has_effects?(EffectScope::GENERAL)
            SummonEffectsTable.add_servitor_effect(servitor.owner, servitor.reference_skill, skill, time)
          end
        end
      end

      GameDB.exec(
        DELETE_SKILL_SAVE,
        servitor.owner.l2id,
        servitor.owner.class_index,
        servitor.reference_skill
      )
    rescue e
      error e
    end
  end
end
