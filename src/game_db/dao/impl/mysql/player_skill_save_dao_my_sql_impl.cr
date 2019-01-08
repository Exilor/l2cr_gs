module GameDB
  module PlayerSkillSaveDAOMySQLImpl
    extend self
    extend PlayerSkillSaveDAO
    extend Loggable

    private INSERT = "INSERT INTO character_skills_save (charId,skill_id,skill_level,remaining_time,reuse_delay,systime,restore_type,class_index,buff_index) VALUES (?,?,?,?,?,?,?,?,?)"
    private SELECT = "SELECT skill_id,skill_level,remaining_time, reuse_delay, systime, restore_type FROM character_skills_save WHERE charId=? AND class_index=? ORDER BY buff_index ASC"
    private DELETE = "DELETE FROM character_skills_save WHERE charId=? AND class_index=?"

    def delete(pc : L2PcInstance, class_index : Int32)
      GameDB.exec(DELETE, pc.l2id, class_index)
    rescue e
      error e
    end

    def delete(pc : L2PcInstance)
      delete(pc, pc.class_index)
    end

    def insert(pc, store_effects : Bool)
      buff_index = 0
      stored_skills = [] of Int32

      if store_effects
        pc.effect_list.each do |info|
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

          t = pc.get_skill_reuse_time_stamp(skill.hash)
          buff_index += 1
          GameDB.exec(
            INSERT,
            pc.l2id,
            skill.id,
            skill.level,
            info.time,
            t && t.has_not_passed? ? t.reuse : 0,
            t && t.has_not_passed? ? t.stamp : 0,
            0,
            pc.class_index,
            buff_index
          )
        end
      end

      if reuse_time_stamps = pc.skill_reuse_time_stamps
        reuse_time_stamps.each do |hash, t|
          if stored_skills.includes?(hash)
            next
          end

          if t.has_not_passed?
            buff_index += 1
            stored_skills << hash

            GameDB.exec(
              INSERT,
              pc.l2id,
              t.skill_id,
              t.skill_lvl,
              -1,
              t.reuse,
              t.stamp,
              1,
              pc.class_index,
              buff_index
            )
          end
        end
      end
    rescue e
      error e
    end

    def load(pc : L2PcInstance)
      GameDB.each(SELECT, pc.l2id, pc.class_index) do |rs|
        remaining_time = rs.get_i32("remaining_time")
        reuse_delay = rs.get_i64("reuse_delay")
        systime = rs.get_i64("systime")
        restore_type = rs.get_i32("restore_type")

        skill = SkillData[rs.get_i32("skill_id"), rs.get_i32("skill_level")]?
        unless skill
          next
        end

        time = systime - Time.ms
        if time > 10
          pc.disable_skill(skill, time)
          pc.add_time_stamp(skill, reuse_delay, systime)
        end

        if restore_type > 0
          next
        end

        skill.apply_effects(pc, pc, false, remaining_time)
      end
    rescue e
      error e
    end
  end
end
