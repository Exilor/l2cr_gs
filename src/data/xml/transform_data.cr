require "../../models/actor/transform/transform"
require "../../models/actor/transform/transform_template"
require "../../models/actor/transform/transform_level_data"
require "../../models/holders/additional_skill_holder"
require "../../models/holders/additional_item_holder"

module TransformData
  extend self
  extend XMLReader

  private DATA = {} of Int32 => Transform

  def load
    DATA.clear
    timer = Timer.new
    parse_datapack_directory("stats/transformations")
    info { "Loaded #{DATA.size} transformations in #{timer} s." }
  end

  private def parse_document(doc, file)
    doc.find_element("list") do |n|
      n.find_element("transform") do |d|
        set = StatsSet.new(d.attributes)

        transform = Transform.new(set)

        d.each_element do |cd|
          male = cd.name.casecmp?("male")
          if /^(?:male|female)$/i === cd.name
            template_data = nil
            cd.each_element do |z|
              case z.name.casecmp
              when "common"
                z.each_element do |s|
                  case s.name.casecmp
                  when "base", "stats", "defense", "magicDefense", "collision", "moving"
                    set.merge(s.attributes)
                  end
                end

                template_data = TransformTemplate.new(set)
                transform.set_template(male, template_data)
              when "skills"
                template_data ||= TransformTemplate.new(set)
                transform.set_template(male, template_data)

                z.each_element do |s|
                  i = 0
                  s.attributes.each_pair do |name, value|
                    if name.casecmp?("id")
                      id = value.to_i
                      lvl = s.attributes.to_a[i + 1][1].to_i
                      template_data.add_skill(SkillHolder.new(id, lvl))
                    end
                    i += 1
                  end
                end
              when "actions"
                template_data ||= TransformTemplate.new(set)
                transform.set_template(male, template_data)

                actions = z.content.split.map &.to_i
                list = Packets::Outgoing::ExBasicActionList.new(actions)
                template_data.basic_action_list = list
              when "additionalskills"
                template_data ||= TransformTemplate.new(set)
                transform.set_template(male, template_data)

                z.each_element do |s|
                  if s.name.casecmp?("skill")
                    i = 0
                    s.attributes.each_pair do |name, value|
                      if name.casecmp?("id")
                        id = value.to_i
                        temp = s.attributes.to_a
                        lvl = temp[i + 1][1].to_i
                        min_lvl = temp[i + 2][1].to_i
                        holder = AdditionalSkillHolder.new(id, lvl, min_lvl)
                        template_data.add_additional_skill(holder)
                      end
                      i = 0
                    end
                  end
                end
              when "items"
                template_data ||= TransformTemplate.new(set)
                transform.set_template(male, template_data)

                z.find_element("item") do |s|
                  i = 0
                  s.attributes.each_pair do |name, value|
                    if name.casecmp?("id") # CHECK
                      id = value.to_i
                      temp = s.attributes.to_a[i + 1][1]
                      allowed = Bool.new(temp)
                      holder = AdditionalItemHolder.new(id, allowed)
                      template_data.add_additional_item(holder)
                    end
                    i += 1
                  end
                end
              when "levels"
                template_data ||= TransformTemplate.new(set)
                transform.set_template(male, template_data)

                levels_set = StatsSet.new
                z.find_element("level") do |s|
                  levels_set.merge(s.attributes)
                end

                tld = TransformLevelData.new(levels_set)
                template_data.add_level_data(tld)
              end
            end
          end
        end

        DATA[transform.id] = transform
      end
    end
  end

  def get_transform(id : Int) : Transform?
    DATA[id]?
  end

  def transform_player(id : Int, pc : L2PcInstance) : Transform?
    transform = DATA[id]?
    pc.transform(transform) if transform
    unless transform
      warn { "Transformation with ID #{id} not found." }
    end
    transform
  end
end
