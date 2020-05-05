require "./holders/skill_holder"
require "./l2_pet_level_data"

class L2PetData
  @level_stats = {} of Int32 => L2PetLevelData

  getter min_level = Int8::MAX
  getter food = [] of Int32
  getter available_skills = [] of L2PetSkillLearn
  property hungry_limit : Int32 = 1
  property? sync_level : Bool = false

  getter_initializer npc_id : Int32, item_id : Int32

  def add_new_stat(level : Int, data : L2PetLevelData)
    if @min_level > level
      @min_level = level.to_i8
    end

    @level_stats[level] = data
  end

  def get_pet_level_data(level : Int) : L2PetLevelData
    @level_stats[level]
  end

  def add_food(food_id : Int32)
    @food << food_id
  end

  def add_new_skill(skill_id : Int32, skill_lvl : Int32, pet_lvl : Int32)
    @available_skills << L2PetSkillLearn.new(skill_id, skill_lvl, pet_lvl)
  end

  def get_available_level(skill_id : Int32, pet_lvl : Int32) : Int32
    lvl = 0

    @available_skills.each do |sk|
      next if sk.skill_id != skill_id
      if sk.skill_lvl == 0
        if pet_lvl < 70
          lvl = pet_lvl // 10
          if lvl <= 0
            lvl = 1
          end
        else
          lvl = 7 + ((pet_lvl - 70) // 5)
        end

        max_lvl = SkillData.get_max_level(sk.skill_id)
        if lvl > max_lvl
          lvl = max_lvl
        end

        break
      elsif sk.min_level <= pet_lvl
        if sk.skill_lvl > lvl
          lvl = sk.skill_lvl
        end
      end
    end

    lvl
  end

  class L2PetSkillLearn < SkillHolder
    getter min_level

    def initialize(id : Int32, lvl : Int32, @min_level : Int32)
      super(id, lvl)
    end
  end
end
