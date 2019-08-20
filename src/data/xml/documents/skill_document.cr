require "./abstract_document"

class SkillDocument < AbstractDocument
  class SkillInfo
    property id = 0
    property name = ""
    property sets = [] of StatsSet
    property(enchsets1) { [] of StatsSet }
    property(enchsets2) { [] of StatsSet }
    property(enchsets3) { [] of StatsSet }
    property(enchsets4) { [] of StatsSet }
    property(enchsets5) { [] of StatsSet }
    property(enchsets6) { [] of StatsSet }
    property(enchsets7) { [] of StatsSet }
    property(enchsets8) { [] of StatsSet }
    property skills = [] of Skill
    property current_skills = [] of Skill
    property current_level = 0

    def get_enchsets(num : Int)
      case num
      when 1 then enchsets1
      when 2 then enchsets2
      when 3 then enchsets3
      when 4 then enchsets4
      when 5 then enchsets5
      when 6 then enchsets6
      when 7 then enchsets7
      when 8 then enchsets8
      else raise IndexError.new
      end
    end
  end

  getter skills = [] of Skill

  private getter! current_skill : SkillInfo?

  private def parse_document(doc, file)
    doc.each_element do |n|
      case n.name.casecmp
      when "list"
        n.find_element("skill") do |d|
          @current_skill = SkillInfo.new
          parse_skill(d)
          @skills.concat(current_skill.skills)
        end
      when "skill"
        @current_skill = SkillInfo.new
        parse_skill(n)
        @skills.concat(current_skill.skills)
      end
    end
  end

  private def make_skills
    current_skill.current_skills = [] of Skill
    current_skill.sets.size.times do |i|
      set = current_skill.sets[i]
      current_skill.current_skills << Skill.new(set)
    end

    {% for idx in 1..8 %}
      current_skill.enchsets{{idx}}.size.times do |i|
        set = current_skill.enchsets{{idx}}[i]
        current_skill.current_skills << Skill.new(set)
      end
    {% end %}
  end

  def get_table_value(name : String)
    @tables[name][current_skill.current_level]
  end

  def get_table_value(name : String, idx : Int)
    @tables[name][idx - 1]
  end

  def stats_set
    current_skill.sets[current_skill.current_level]
  end

  private def parse_skill(n)
    skill_id = n["id"].to_i
    skill_name = n["name"]
    levels = n["levels"]
    last_level = levels.to_i

    enchant_levels = Array.new(9, 0)
    1.upto(8) do |i|
      if lvl = n["enchantGroup#{i}"]?.try &.to_i
        enchant_levels[i] = EnchantSkillGroupsData.add_new_route_for_skill(skill_id, last_level, i, lvl)
      end
    end

    current_skill.id = skill_id
    current_skill.name = skill_name

    1.upto(last_level) do |i|
      set = StatsSet.new
      set["skill_id"] = current_skill.id
      set["level"] = i
      set["name"] = current_skill.name
      current_skill.sets << set
    end

    if current_skill.sets.size != last_level
      raise "number of levels mismatch for skill with ID \#{skill_id}"
    end

    first = n.first_element_child


    n.find_element("table") { |t| parse_table(t) }

    1.upto(last_level) do |i|
      n.find_element("set") do |n|
        if n["name"].casecmp?("capsuled_items_skill")
          set_extractable_skill_data(current_skill.sets[i - 1], get_table_value("#extractableItems", i))
        else
          parse_set(n, current_skill.sets[i - 1], i)
        end
      end
    end

    1.upto(8) do |l|
      enchsets = current_skill.get_enchsets(l)
      enchant_levels[l].times do |i|
        set = StatsSet.new
        set["skill_id"] = current_skill.id
        set["level"] = i + (100 * l) + 1
        set["name"] = current_skill.name

        enchsets << set

        n.find_element("set") do |n|
          parse_set(n, enchsets[i], current_skill.sets.size)
        end

        n.find_element("enchant#{l}") { |n| parse_set(n, enchsets[i], i + 1) }
      end
      if enchsets.size != enchant_levels[l]
        raise "Number of enchant levels mismatch for skill #{skill_id}, enchant levels #{l}"
      end
    end

    make_skills

    last_level.times do |i|
      current_skill.current_level = i
      n = first
      while n
        n_name = n.name
        case n_name.casecmp
        when "cond"
          if child = n.first_element_child
            condition = parse_condition(child, current_skill.current_skills[i])
            msg = n["msg"]?
            msg_id = n["msgId"]?

            if condition && msg
              condition.message = get_value(msg, nil)
            elsif condition && msg_id
              condition.message_id = get_value(msg_id, nil).to_i
              if n["addName"]? && get_value(msg_id, nil).to_i > 0
                condition.add_name
              end
            end

            current_skill.current_skills[i].attach(condition, false)
          else
            error "#{n} has no children"
          end
        when "effects"
          parse_template(n, current_skill.current_skills[i])
        when "startEffects"
          parse_template(n, current_skill.current_skills[i], EffectScope::START)
        when "channelingEffects"
          parse_template(n, current_skill.current_skills[i], EffectScope::CHANNELING)
        when "pveEffects"
          parse_template(n, current_skill.current_skills[i], EffectScope::PVE)
        when "pvpEffects"
          parse_template(n, current_skill.current_skills[i], EffectScope::PVP)
        when "endEffects"
          parse_template(n, current_skill.current_skills[i], EffectScope::STOP)
        when "selfEffects"
          parse_template(n, current_skill.current_skills[i], EffectScope::SELF)
        end
        n = n.next_element
      end
    end

    {% for i in 1..8 %}
      {% from = (["last_level"] + (1..8).map { |j| "enchant_levels[#{j}]" })[0, i].join("+") %}
      {% to = (["last_level"] + (1..8).map { |j| "enchant_levels[#{j}]" })[0, i + 1].join("+") %}
      i = {{from.id}}

      while i < {{to.id}}
        current_skill.current_level = i - {{((["last_level"] + (1..8).map { |j| "enchant_levels[#{j}]" })[0, i].join("-")).id }}

        found_cond = found_effect = found_channeling_effects =
        found_start_effects = found_pve_effects = found_pvp_effects =
        found_end_effects = found_self_effects = false

        n = first
        while n
          n_name = n.name
          if n_name.casecmp?("enchant#{i}cond")
            found_cond = true
            condition = parse_condition(n.first_element_child, current_skill.current_skills[i])
            msg = n["msg"]?
            msg_id = n["msgId"]?.try &.to_i
            if condition && msg
              condition.message = msg
            elsif condition && msg_id
              condition.message_id = msg_id
              if n["addName"]? && msg_id > 0
                condition.add_name
              end
            end

            current_skill.current_skills[i].attach(condition, false)
          elsif n_name.casecmp?("enchant#{{{i}}}Effects")
            found_effect = true
            parse_template(n, current_skill.current_skills[i])
          elsif n_name.casecmp?("enchant#{{{i}}}startEffects")
            found_start_effects = true
            parse_template(n, current_skill.current_skills[i], EffectScope::START)
          elsif n_name.casecmp?("enchant#{{{i}}}channelingEffects")
            found_channeling_effects = true
            parse_template(n, current_skill.current_skills[i], EffectScope::CHANNELING)
          elsif n_name.casecmp?("enchant#{{{i}}}pveEffects")
            found_pve_effects = true
            parse_template(n, current_skill.current_skills[i], EffectScope::PVE)
          elsif n_name.casecmp?("enchant#{{{i}}}pvpEffects")
            found_pvp_effects = true
            parse_template(n, current_skill.current_skills[i], EffectScope::PVP)
          elsif n_name.casecmp?("enchant#{{{i}}}endEffects")
            found_end_effects = true
            parse_template(n, current_skill.current_skills[i], EffectScope::STOP)
          elsif n_name.casecmp?("enchant#{{{i}}}selfEffects")
            found_self_effects = true
            parse_template(n, current_skill.current_skills[i], EffectScope::SELF)
          end
          n = n.next_element
        end

        if !found_cond || !found_effect || !found_channeling_effects || !found_start_effects || !found_pve_effects || !found_pvp_effects || !found_end_effects || !found_self_effects
          current_skill.current_level = last_level - 1
          n = first
          while n
            n_name = n.name
            if !found_cond && n_name.casecmp?("cond")
              condition = parse_condition(n.children.first, current_skill.current_skills[i])
              msg = n["msg"]?
              msg_id = n["msgId"]?.try &.to_i
              if condition && msg
                condition.message = msg
              elsif condition && msg_id
                condition.message_id = msg_id
                if n["addName"]? && msg_id > 0
                  condition.add_name
                end
              end

              current_skill.current_skills[i].attach(condition, false)
            elsif !found_effect && n_name.casecmp?("effects")
              parse_template(n, current_skill.current_skills[i])
            elsif !found_start_effects && n_name.casecmp?("startEffects")
              parse_template(n, current_skill.current_skills[i], EffectScope::START)
            elsif !found_channeling_effects && n_name.casecmp?("channelingEffects")
              parse_template(n, current_skill.current_skills[i], EffectScope::CHANNELING)
            elsif !found_pve_effects && n_name.casecmp?("pveEffects")
              parse_template(n, current_skill.current_skills[i], EffectScope::PVE)
            elsif !found_pvp_effects && n_name.casecmp?("pvpEffects")
              parse_template(n, current_skill.current_skills[i], EffectScope::PVP)
            elsif !found_end_effects && n_name.casecmp?("endEffects")
              parse_template(n, current_skill.current_skills[i], EffectScope::STOP)
            elsif !found_self_effects && n_name.casecmp?("selfEffects")
              parse_template(n, current_skill.current_skills[i], EffectScope::SELF)
            end
            n = n.next_element
          end
        end

        i += 1
      end
    {% end %}

    current_skill.skills.concat(current_skill.current_skills)
  end
end
