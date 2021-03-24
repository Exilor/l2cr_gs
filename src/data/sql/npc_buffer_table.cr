module NpcBufferTable
  extend self
  include Loggable

  private BUFFERS = {} of Int32 => NpcBufferSkills

  def load
    count = load_from("SELECT `npc_id`,`skill_id`,`skill_level`,`skill_fee_id`,`skill_fee_amount`,`buff_group` FROM `npc_buffer` ORDER BY `npc_id` ASC")
    if Config.custom_npcbuffer_tables
      count &+= load_from("SELECT `npc_id`,`skill_id`,`skill_level`,`skill_fee_id`,`skill_fee_amount`,`buff_group` FROM `custom_npc_buffer` ORDER BY `npc_id` ASC")
    end

    info { "Loaded #{BUFFERS.size} buffers and #{count} skills." }
  end

  private def load_from(sql)
    count = 0
    begin
      last_npc_id = 0
      skills = nil

      GameDB.each(sql) do |rs|
        npc_id = rs.get_i32(:"npc_id")
        skill_id = rs.get_i32(:"skill_id")
        skill_level = rs.get_i32(:"skill_level")
        fee_id = rs.get_i32(:"skill_fee_id")
        fee_amount = rs.get_i32(:"skill_fee_amount")
        group = rs.get_i32(:"buff_group")

        if npc_id != last_npc_id
          if skills && last_npc_id != 0
            BUFFERS[last_npc_id] = skills
          end

          skills = NpcBufferSkills.new(npc_id)
          skills.add_skill(skill_id, skill_level, fee_id, fee_amount, group)
        elsif skills
          skills.add_skill(skill_id, skill_level, fee_id, fee_amount, group)
        end

        last_npc_id = npc_id
        count &+= 1
      end

      if skills && last_npc_id != 0
        BUFFERS[last_npc_id] = skills
      end
    rescue e
      error e
    end

    count
  end

  def get_skill_info(npc_id : Int32, group : Int32) : NpcBufferData?
    BUFFERS[npc_id]?.try &.get_skill_group_info(group)
  end

  private struct NpcBufferData
    getter skill, fee

    def initialize(skill_id : Int32, skill_level : Int32, fee_id : Int32, fee_amount : Int32)
      @skill = SkillHolder.new(skill_id, skill_level)
      @fee = ItemHolder.new(fee_id, fee_amount.to_i64)
    end
  end

  private struct NpcBufferSkills
    @skills = {} of Int32 => NpcBufferData

    getter_initializer npc_id : Int32

    def add_skill(skill_id : Int32, skill_level : Int32, fee_id : Int32, fee_amount : Int32, group : Int32)
      @skills[group] = NpcBufferData.new(skill_id, skill_level, fee_id, fee_amount)
    end

    def get_skill_group_info(group : Int32) : NpcBufferData?
      @skills[group]?
    end
  end
end
