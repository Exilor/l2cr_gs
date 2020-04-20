require "../../models/options"
require "../../models/options/options_skill_holder"
require "../../models/options/options_skill_type"

module OptionData
  extend self
  extend XMLReader

  private OPTION_DATA = {} of Int32 => Options

  def load
    OPTION_DATA.clear
    timer = Timer.new
    parse_datapack_directory("stats/options")
    info { "Loaded #{OPTION_DATA.size} options in #{timer} s." }
  end

  private def parse_document(doc, file)
    find_element(doc, "list") do |n|
      find_element(n, "option") do |d|
        id = parse_int(d, "id")
        op = Options.new(id)

        each_element(d) do |cd, cd_name|
          case cd_name
          when "for"
            each_element(cd) do |fd, fd_name|
              case fd_name
              when /\A(?:add|sub|mul|div|set|share|enchant|enchanthp)\z/
                parse_funcs(fd, fd_name, op)
              else
                # [automatically added else]
              end
            end
          when "active_skill"
            id, lvl = parse_int(cd, "id"), parse_int(cd, "level")
            op.active_skill = SkillHolder.new(id, lvl)
          when "passive_skill"
            id, lvl = parse_int(cd, "id"), parse_int(cd, "level")
            op.passive_skill = SkillHolder.new(id, lvl)
          when "attack_skill"
            id, lvl, chance = parse_int(cd, "id"), parse_int(cd, "level"), parse_double(cd, "chance")
            sh = OptionsSkillHolder.new(id, lvl, chance, OptionsSkillType::ATTACK)
            op.add_activation_skill(sh)
          when "magic_skill"
            id, lvl, chance = parse_int(cd, "id"), parse_int(cd, "level"), parse_double(cd, "chance")
            sh = OptionsSkillHolder.new(id, lvl, chance, OptionsSkillType::MAGIC)
            op.add_activation_skill(sh)
          when "critical_skill"
            id, lvl, chance = parse_int(cd, "id"), parse_int(cd, "level"), parse_double(cd, "chance")
            sh = OptionsSkillHolder.new(id, lvl, chance, OptionsSkillType::CRITICAL)
            op.add_activation_skill(sh)
          else
            # [automatically added else]
          end
        end

        OPTION_DATA[op.id] = op
      end
    end
  end

  private def parse_funcs(node, func_name, op)
    stat = Stats.from_value(parse_string(node, "stat"))
    val = parse_double(node, "val")
    order = parse_int(node, "order", -1) # order appears to be unused
    op.add_func(FuncTemplate.new(nil, nil, func_name, order, stat, val))
  end

  def [](id : Int32) : Options?
    OPTION_DATA[id]?
  end
end
