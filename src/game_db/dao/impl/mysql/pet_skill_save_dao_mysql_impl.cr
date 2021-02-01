module GameDB
  module PetSkillSaveDAOMySQLImpl
    extend self
    extend PetSkillSaveDAO

    private ADD_SKILL_SAVE = "INSERT INTO character_pet_skills_save (petObjItemId,skill_id,skill_level,remaining_time,buff_index) VALUES (?,?,?,?,?)"
    private RESTORE_SKILL_SAVE = "SELECT petObjItemId,skill_id,skill_level,remaining_time,buff_index FROM character_pet_skills_save WHERE petObjItemId=? ORDER BY buff_index ASC"
    private DELETE_SKILL_SAVE = "DELETE FROM character_pet_skills_save WHERE petObjItemId=?"

    def insert(pet : L2PetInstance, store_effects : Bool)
      GameDB.transaction do |tr|
        tr.exec(DELETE_SKILL_SAVE, pet.control_l2id)

        if store_effects
          buff_index = 0
          stored_skills = [] of Int32

          pet.effect_list.each do |info|
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

            tr.exec(
              ADD_SKILL_SAVE,
              pet.control_l2id,
              skill.id,
              skill.level,
              info.time,
              buff_index &+= 1
            )

            SummonEffectsTable.add_pet_effect(pet.control_l2id, skill, info.time)
          end
        end
      end
    rescue e
      error e
    end

    def load(pet : L2PetInstance)
      unless SummonEffectsTable.contains_pet_id?(pet.control_l2id)
        GameDB.each(RESTORE_SKILL_SAVE, pet.control_l2id) do |rs|
          time = rs.get_i32(:"remaining_time")
          skill_id = rs.get_i32(:"skill_id")
          skill_lvl = rs.get_i32(:"skill_level")
          unless skill = SkillData[skill_id, skill_lvl]?
            next
          end

          if skill.has_effects?(EffectScope::GENERAL)
            SummonEffectsTable.add_pet_effect(pet.control_l2id, skill, time)
          end
        end
      end

      GameDB.exec(DELETE_SKILL_SAVE, pet.control_l2id)
    rescue e
      error e
    end
  end
end
