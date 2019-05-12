struct EnchantSkillLearn
  include Loggable

  @enchant_routes = {} of Int32 => Int32
  getter_initializer id: Int32, base_level: Int32

  def add_new_enchant_route(route : Int32, group : Int32)
    @enchant_routes[route] = group
  end

  def get_enchant_route(level : Int32) : Int32
    level / 100
  end

  def get_enchant_index(level : Int32) : Int32
    (level % 100) - 1
  end

  def get_enchant_type(level : Int32) : Int32
    ((level - 1) / 100) - 1
  end

  def first_route_group : EnchantSkillGroup?
    EnchantSkillGroupsData.get_enchant_skill_group_by_id(@enchant_routes.first.try &.last)
  end

  def each_route(&block : Int32 ->)
    @enchant_routes.each_key { |key| yield key }
  end

  def get_min_skill_level(level : Int32) : Int32
    level % 100 == 1 ? @base_level : level - 1
  end

  def max_enchant?(level : Int32) : Bool
    enchant_type = get_enchant_route level
    return false if enchant_type < 1
    return false unless tmp = @enchant_routes[enchant_type]?
    index = get_enchant_index(level)
    index + 1 >= EnchantSkillGroupsData.get_enchant_skill_group_by_id(tmp).enchant_group_details.size
  end

  def get_enchant_skill_holder(level : Int32) : EnchantSkillGroup::EnchantSkillHolder?
    enchant_type = get_enchant_route(level)
    return if enchant_type < 1
    return unless tmp = @enchant_routes[enchant_type]?
    unless group = EnchantSkillGroupsData.get_enchant_skill_group_by_id(tmp)
      warn "EnchantSkillLearn: Missing group #{enchant_type}"
      return
    end
    index = get_enchant_index(level)
    if index < 0
      group.enchant_group_details[0]?
    elsif index >= group.enchant_group_details.size
      group.enchant_group_details[EnchantSkillGroupsData.get_enchant_skill_group_by_id(@enchant_routes[enchant_type]).enchant_group_details.size - 1]
    else
      group.enchant_group_details[index]?
    end
  end
end
