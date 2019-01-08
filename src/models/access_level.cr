class AccessLevel
  getter level = 0
  getter name = "User"
  getter name_color = 16777215
  getter title_color = 16777215
  getter? gm = false
  getter? allow_peace_attack = false
  getter? allow_fixed_res = false
  getter? allow_transaction = true
  getter? allow_alt_g = false
  getter? can_give_damage = true
  getter? can_take_aggro = true
  getter? can_gain_exp = true

  @childs_access_level : self?
  @child = 0

  def initialize
  end

  def initialize(set : StatsSet)
    @level = set.get_i32("level")
    @name = set.get_string("name")
    @name_color = ("0x" + set.get_string("nameColor", "FFFFFF")).to_i(16, prefix: true)
    @title_color = ("0x" + set.get_string("titleColor", "FFFFFF")).to_i(16, prefix: true)
    @child = set.get_i32("childAccess", 0)
    @gm = set.get_bool("isGM", false)
    @allow_peace_attack = set.get_bool("allowPeaceAttack", false)
    @allow_fixed_res = set.get_bool("allowFixedRes", false)
    @allow_transaction = set.get_bool("allowTransaction", true)
    @allow_alt_g = set.get_bool("allowAltg", false)
    @can_give_damage = set.get_bool("giveDamage", true)
    @can_take_aggro = set.get_bool("takeAggro", true)
    @can_gain_exp = set.get_bool("gainExp", true)
  end

  def has_child_access?(other : self)
    unless @childs_access_level
      return false if @child <= 0
      @childs_access_level = AdminData.get_access_level(@child)
    end

    @childs_access_level.not_nil!.level == other.level ||
    @childs_access_level.not_nil!.has_child_access?(other)
  end
end
