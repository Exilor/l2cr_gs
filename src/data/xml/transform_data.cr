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
    find_element(doc, "list") do |n|
      find_element(n, "transform") do |d|
        set = get_attributes(d)

        transform = Transform.new(set)

        each_element(d) do |cd, cd_name|
          male = cd_name.casecmp?("male")
          if /^(?:male|female)$/i === cd_name
            template_data = nil
            each_element(cd) do |z, z_name|
              case z_name.casecmp
              when "common"
                each_element(z) do |s, s_name|
                  case s_name.casecmp
                  when /\A(?:base|stats|defense|magicDefense|collision|moving)\z/i
                    each_attribute(s) { |name, value| set[name] = value }
                  else
                    # [automatically added else]
                  end
                end

                template_data = TransformTemplate.new(set)
                transform.set_template(male, template_data)
              when "skills"
                template_data ||= TransformTemplate.new(set)
                transform.set_template(male, template_data)

                each_element(z) do |s|
                  i = 0
                  each_attribute(s) do |name, value|
                    if name.casecmp?("id")
                      id = value.to_i
                      lvl = get_attributes(s).to_a[i &+ 1][1].to_i
                      template_data.add_skill(SkillHolder.new(id, lvl))
                    end
                    i &+= 1
                  end
                end
              when "actions"
                template_data ||= TransformTemplate.new(set)
                transform.set_template(male, template_data)

                actions = get_content(z).split.map &.to_i
                list = Packets::Outgoing::ExBasicActionList.new(actions)
                template_data.basic_action_list = list
              when "additionalskills"
                template_data ||= TransformTemplate.new(set)
                transform.set_template(male, template_data)

                each_element(z) do |s, s_name|
                  if s_name.casecmp?("skill")
                    i = 0
                    each_attribute(s) do |name, value|
                      if name.casecmp?("id")
                        id = value.to_i
                        temp = get_attributes(s).to_a
                        lvl = temp[i &+ 1][1].to_i
                        min_lvl = temp[i &+ 2][1].to_i
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

                find_element(z, "item") do |s|
                  i = 0
                  each_attribute(s) do |name, value|
                    if name.casecmp?("id") # CHECK
                      id = value.to_i
                      temp = get_attributes(s).to_a[i &+ 1][1]
                      allowed = Bool.new(temp)
                      holder = AdditionalItemHolder.new(id, allowed)
                      template_data.add_additional_item(holder)
                    end
                    i &+= 1
                  end
                end
              when "levels"
                template_data ||= TransformTemplate.new(set)
                transform.set_template(male, template_data)

                levels_set = StatsSet.new
                find_element(z, "level") do |s|
                  levels_set.merge!(get_attributes(s))
                end

                tld = TransformLevelData.new(levels_set)
                template_data.add_level_data(tld)
              else
                # [automatically added else]
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
    unless transform = DATA[id]?
      warn { "Transformation with ID #{id} not found." }
    end
    pc.transform(transform) if transform
    transform
  end
end
