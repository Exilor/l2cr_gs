class L2Fish
  getter fish_id : Int32
  getter item_id : Int32
  getter item_name : String
  getter fish_level : Int32
  getter fish_bite_rate : Float64
  getter fish_guts : Float64
  getter fish_grade : Int32
  getter fish_hp : Int32
  getter fish_max_length : Int32
  getter fish_length_rate : Float64
  getter hp_regen : Float64
  getter start_combat_time : Int32
  getter combat_duration : Int32
  getter guts_check_time : Int32
  getter guts_check_probability : Float64
  getter cheating_prob : Float64
  property fish_group : Int32

  def_clone

  def initialize(set : StatsSet)
    @fish_id = set.get_i32("fishId")
    @item_id = set.get_i32("itemId")
    @item_name = set.get_string("itemName")
    @fish_group = get_group_id(set.get_string("fishGroup"))
    @fish_level = set.get_i32("fishLevel")
    @fish_bite_rate = set.get_f64("fishBiteRate")
    @fish_guts = set.get_f64("fishGuts")
    @fish_hp = set.get_i32("fishHp")
    @fish_max_length = set.get_i32("fishMaxLength")
    @fish_length_rate = set.get_f64("fishLengthRate")
    @hp_regen = set.get_f64("hpRegen")
    @start_combat_time = set.get_i32("startCombatTime")
    @combat_duration = set.get_i32("combatDuration")
    @guts_check_time = set.get_i32("gutsCheckTime")
    @guts_check_probability = set.get_f64("gutsCheckProbability")
    @cheating_prob = set.get_f64("cheatingProb")
    @fish_grade = get_grade_id(set.get_string("fishGrade"))
  end

  private def get_group_id(name : String) : Int32
    case name
    when "swift"      then 1
    when "ugly"       then 2
    when "fish_box"   then 3
    when "easy_wide"  then 4
    when "easy_swift" then 5
    when "easy_ugly"  then 6
    when "hard_wide"  then 7
    when "hard_swift" then 8
    when "hard_ugly"  then 9
    when "hs_fish"    then 10
    else 0
    end
  end

  private def get_grade_id(name : String) : Int32
    name == "fish_easy" ? 0 : name == "fish_hard" ? 2 : 1
  end
end
