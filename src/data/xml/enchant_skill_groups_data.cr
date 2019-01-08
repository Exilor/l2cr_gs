require "../../models/skills/enchant_skill_learn"
require "../../models/skills/enchant_skill_group"

module EnchantSkillGroupsData
  extend self
  extend XMLReader
  extend Loggable

  NORMAL_ENCHANT_BOOK  = 6622
  SAFE_ENCHANT_BOOK    = 9627
  CHANGE_ENCHANT_BOOK  = 9626
  UNTRAIN_ENCHANT_BOOK = 9625

  private ENCHANT_SKILL_GROUPS = {} of Int32 => EnchantSkillGroup
  private ENCHANT_SKILL_TREES  = {} of Int32 => EnchantSkillLearn

  def load
    timer = Timer.new
    ENCHANT_SKILL_GROUPS.clear
    ENCHANT_SKILL_TREES.clear

    parse_datapack_file("enchantSkillGroups.xml")

    routes = 0
    ENCHANT_SKILL_GROUPS.each_value do |group|
      routes += group.enchant_group_details.size
    end

    info "Loaded #{ENCHANT_SKILL_GROUPS.size} groups and #{routes} routes in #{timer.result} s."
  end

  private def parse_document(doc, file)
    doc.find_element("list") do |n|
      n.find_element("group") do |d|
        id = d["id"].to_i

        group = ENCHANT_SKILL_GROUPS[id] ||= EnchantSkillGroup.new(id)

        d.find_element("enchant") do |b|
          set = StatsSet.new(b.attributes)
          group.add_enchant_detail(set)
        end
      end
    end
  end

  def add_new_route_for_skill(skill_id : Int32, max_lvl : Int32, route : Int32, group : Int32) : Int32
    enchantable_skill = ENCHANT_SKILL_TREES[skill_id] ||= EnchantSkillLearn.new(skill_id, max_lvl)

    if tmp = ENCHANT_SKILL_GROUPS[group]?
      enchantable_skill.add_new_enchant_route(route, group)
      tmp.enchant_group_details.size
    else
      error "Error while loading enchant skill ID: #{skill_id} route: #{route} missing group: #{group}."
      0
    end
  end

  def get_skill_enchantment_for_skill(skill : Skill) : EnchantSkillLearn?
    esl = get_skill_enchantment_by_skill_id(skill.id)
    if esl && skill.level >= esl.base_level
      esl
    end
  end

  def get_skill_enchantment_by_skill_id(skill_id : Int32) : EnchantSkillLearn
    ENCHANT_SKILL_TREES[skill_id]
  end

  def get_enchant_skill_group_by_id(id : Int32) : EnchantSkillGroup
    ENCHANT_SKILL_GROUPS[id]
  end

  def get_enchant_skill_sp_cost(skill : Skill) : Int32
    if esl = ENCHANT_SKILL_TREES[skill.id]
      if esh = esl.get_enchant_skill_holder(skill.level)
        return esh.sp_cost
      end
    end

    Int32::MAX
  end

  def get_enchant_skill_adena_cost(skill : Skill) : Int32
    if esl = ENCHANT_SKILL_TREES[skill.id]?
      if esh = esl.get_enchant_skill_holder(skill.level)
        return esh.adena_cost
      end
    end

    Int32::MAX
  end

  def get_enchant_skill_rate(pc : L2PcInstance, skill : Skill)
    if esl = ENCHANT_SKILL_TREES[skill.id]?
      if esh = esl.get_enchant_skill_holder(skill.level)
        return esh.get_rate(pc)
      end
    end

    0
  end
end
