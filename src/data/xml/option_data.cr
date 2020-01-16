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
    doc.find_element("list") do |n|
      n.find_element("option") do |d|
        id = d["id"].to_i
        op = Options.new(id)

        d.each_element do |cd|
          case cd.name
          when "for"
            cd.each_element do |fd|
              case fd.name
              when /\A(?:add|sub|mul|div|set|share|enchant|enchanthp)\z/
                parse_funcs(fd, fd.name, op)
              end
            end
          when "active_skill"
            id, lvl = cd["id"].to_i, cd["level"].to_i
            op.active_skill = SkillHolder.new(id, lvl)
          when "passive_skill"
            id, lvl = cd["id"].to_i, cd["level"].to_i
            op.passive_skill = SkillHolder.new(id, lvl)
          when "attack_skill"
            id, lvl, chance = cd["id"].to_i, cd["level"].to_i, cd["chance"].to_f
            sh = OptionsSkillHolder.new(id, lvl, chance, OptionsSkillType::ATTACK)
            op.add_activation_skill(sh)
          when "magic_skill"
            id, lvl, chance = cd["id"].to_i, cd["level"].to_i, cd["chance"].to_f
            sh = OptionsSkillHolder.new(id, lvl, chance, OptionsSkillType::MAGIC)
            op.add_activation_skill(sh)
          when "critical_skill"
            id, lvl, chance = cd["id"].to_i, cd["level"].to_i, cd["chance"].to_f
            sh = OptionsSkillHolder.new(id, lvl, chance, OptionsSkillType::CRITICAL)
            op.add_activation_skill(sh)
          end
        end

        OPTION_DATA[op.id] = op
      end
    end
  end

  private def parse_funcs(attrs, func_name, op)
    stat = Stats.from_value(attrs["stat"])
    val = attrs["val"].to_f
    order = -1
    # order appears to be unused
    op.add_func(FuncTemplate.new(nil, nil, func_name, order, stat, val))
  end

  def [](id : Int32) : Options?
    OPTION_DATA[id]?
  end
end
