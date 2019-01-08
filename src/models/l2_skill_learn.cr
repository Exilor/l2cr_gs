require "../enums/social_class"

class L2SkillLearn
  private record SubclassData, slot : Int32, lvl : Int32

  getter skill_name : String
  getter skill_id : Int32
  getter skill_level : Int32
  getter get_level : Int32
  getter level_up_sp : Int32
  getter required_items = [] of ItemHolder
  getter races = [] of Race
  getter pre_req_skills = [] of SkillHolder
  getter residence_ids = [] of Int32
  getter subclass_conditions = [] of SubclassData # L2J: _subClassLvlNumber
  getter? residence_skill : Bool
  getter? learned_by_npc : Bool
  getter? learned_by_fs : Bool
  getter? auto_get : Bool
  property social_class : SocialClass = SocialClass::VAGABOND

  def initialize(set : StatsSet)
    @skill_name = set.get_string("skillName")
    @skill_id = set.get_i32("skillId")
    @skill_level = set.get_i32("skillLvl")
    @get_level = set.get_i32("getLevel")
    @auto_get = set.get_bool("autoGet", false)
    @level_up_sp = set.get_i32("levelUpSp", 0)
    @residence_skill = set.get_bool("residenceSkill", false)
    @learned_by_npc = set.get_bool("learnedByNpc", false)
    @learned_by_fs = set.get_bool("learnedByFS", false)
  end

  def add_required_skill(skill_holder : SkillHolder)
    @pre_req_skills << skill_holder
  end

  def add_race(race : Race)
    @races << race
  end

  def add_residence_id(id : Int32)
    @residence_ids << id
  end

  def add_required_item(item_holder : ItemHolder)
    @required_items << item_holder
  end

  def add_subclass_conditions(slot : Int32, lvl : Int32)
    @subclass_conditions << SubclassData.new(slot, lvl)
  end

  def get_calculated_level_up_sp(player_class : ClassId?, learning_class : ClassId?) : Int32
    unless player_class && learning_class
      return @level_up_sp
    end

    level_up_sp = @level_up_sp
    if Config.alt_game_skill_learn && player_class != learning_class
      if player_class.mage_class? != learning_class.mage_class?
        level_up_sp *= 3
      else
        level_up_sp *= 2
      end
    end

    level_up_sp
  end

  def residencial_skill? : Bool
    residence_skill?
  end
end
