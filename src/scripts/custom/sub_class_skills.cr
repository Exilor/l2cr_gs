class NpcAI::SubClassSkills < Quest
  private ALL_CERT_SKILL_IDS = {
    631, 632, 633, 634, 637, 638, 639, 640, 641, 642, 643, 644, 645, 646,
    647, 648, 650, 651, 652, 653, 654, 655, 656, 657, 658, 659, 660, 661,
    662, 799, 800, 801, 802, 803, 804, 1489, 1490, 1491
  }
  private CERT_SKILLS_BY_LEVEL = {
    {
      631, 632, 633, 634
    },
    {
      631, 632, 633, 634
    },
    {
      637, 638, 639, 640, 641, 642, 643, 644, 645, 646, 647, 648, 650,
      651, 652, 653, 654, 655, 799, 800, 801, 802, 803, 804, 1489, 1490,
      1491
    },
    {
      656, 657, 658, 659, 660, 661, 662
    }
  }

  private ALL_CERT_ITEM_IDS = {
    10280, 10281, 10282, 10283, 10284, 10285, 10286, 10287, 10288, 10289,
    10290, 10291, 10292, 10293, 10294, 10612
  }
  private CERT_ITEMS_BY_LEVEL = {
    {10280},
    {10280},
    {10612, 10281, 10282, 10283, 10284, 10285, 10286, 10287},
    {10288, 10289, 10290, 10291, 10292, 10293, 10294}
  }

  private VARS = {
    "EmergentAbility65-",
    "EmergentAbility70-",
    "ClassAbility75-",
    "ClassAbility80-"
  }

  def initialize
    super(-1, self.class.simple_name, "custom")
    self.on_enter_world = true
  end

  def on_enter_world(player)
    unless Config.skill_check_enable
      return
    end

    if player.override_skill_conditions? && !Config.skill_check_gm
      return
    end

    cert_skills = get_cert_skills(player)
    if player.subclass_active?
      cert_skills.each do |s|
        Util.handle_illegal_player_action(player, "Player #{player.name} has cert skill on subclass :#{s.name}(#{s.id}/#{s.level}), class: #{ClassListData.get_class!(player.class_id).class_name}", IllegalActionPunishmentType::NONE)

        if Config.skill_check_remove
          player.remove_skill(s)
        end
      end

      return
    end

    c_skills = cert_skills.map { |s| [s.id, s.level] }

    cert_items = get_cert_items(player)
    c_items = cert_items.map do |it|
      [it.l2id, Math.min(it.count, Int32::MAX).to_i]
    end

    st = get_quest_state(player, false)
    st ||= new_quest_state(player)

    VARS.size.downto(0) do |i|
      Config.max_subclass.downto(1) do |j|
        q_name = "#{VARS[i]}#{j}"
        q_value = st.get_global_quest_var(q_name)
        if q_value.nil? || q_value.empty?
          next
        end

        if q_value.ends_with?(";") # found skill
          begin
            id = q_value.sub(";", "").to_i

            skill = nil
            if cert_skills
              # searching skill in test array
              if c_skills
                cert_skills.size.downto(0) do |index|
                  if c_skills[index][0] == id
                    skill = cert_skills[index]?
                    c_skills[index][1] -= 1
                    break
                  end
                end
              end
              if skill
                unless CERT_SKILLS_BY_LEVEL[i].includes?(id)
                  # should remove this skill ?
                  Util.handle_illegal_player_action(player, "Invalid cert variable WITH skill:#{q_name}=#{q_value} - skill does not match certificate level", IllegalActionPunishmentType::NONE)
                end
              else
                Util.handle_illegal_player_action(player, "Invalid cert variable:#{q_name}=#{q_value} - skill not found", IllegalActionPunishmentType::NONE)
              end
            else
              Util.handle_illegal_player_action(player, "Invalid cert variable:#{q_name}=#{q_value} - no certified skills found", IllegalActionPunishmentType::NONE)
            end
          rescue e
            Util.handle_illegal_player_action(player, "Invalid cert variable:#{q_name}=#{q_value} - not a number", IllegalActionPunishmentType::NONE)
          end
        else
        # found item
          begin
            id = q_value.to_i
            if id == 0
              next
            end

            item = nil
            if cert_items
              # searching item in test array
              if c_items
                cert_items.size.downto(0) do |index|
                  if c_items[index][0] == id
                    item = cert_items[index]?
                    c_items[index][1] -= 1
                    break
                  end
                end
              end
              if item
                unless CERT_ITEMS_BY_LEVEL[i].includes?(item.id)
                  Util.handle_illegal_player_action(player, "Invalid cert variable:#{q_name}=#{q_value} - item found but does not match certificate level", IllegalActionPunishmentType::NONE)
                end
              else
                Util.handle_illegal_player_action(player, "Invalid cert variable:#{q_name}=#{q_value} - item not found", IllegalActionPunishmentType::NONE)
              end
            else
              Util.handle_illegal_player_action(player, "Invalid cert variable:#{q_name}=#{q_value} - no cert item found in inventory", IllegalActionPunishmentType::NONE)
            end
          rescue e
            Util.handle_illegal_player_action(player, "Invalid cert variable:#{q_name}=#{q_value} - not a number", IllegalActionPunishmentType::NONE)
          end
        end
      end
    end

    if cert_skills && c_skills
      c_skills.size.downto(0) do |i|
        if c_skills[i][1] == 0
          next
        end

        skill = cert_skills[i]
        if c_skills[i][1] > 0
          if c_skills[i][1] == skill.level
            Util.handle_illegal_player_action(player, "Player #{player.name} has invalid cert skill :#{skill.name}(#{skill.id}/#{skill.level})", IllegalActionPunishmentType::NONE)
          else
            Util.handle_illegal_player_action(player, "Player #{player.name} has invalid cert skill :#{skill.name}(#{skill.id}/#{skill.level}), level too high", IllegalActionPunishmentType::NONE)
          end

          if Config.skill_check_remove
            player.remove_skill(skill)
          end
        else
          Util.handle_illegal_player_action(player, "Invalid cert skill :#{skill.name}(#{skill.id}/#{skill.level}), level too low", IllegalActionPunishmentType::NONE)
        end
      end
    end

    if cert_items && c_items
      c_items.size.downto(0) do |i|
        if c_items[i][1] == 0
          next
        end

        item = cert_items[i]
        Util.handle_illegal_player_action(player, "Invalid cert item without variable or with wrong count: #{item.l2id}", IllegalActionPunishmentType::NONE)
      end
    end

    return
  end

  private def get_cert_skills(player)
    tmp = [] of Skill
    player.all_skills.each do |s|
      if s && ALL_CERT_SKILL_IDS.bsearch(s.id) >= 0
        tmp << s
      end
    end

    tmp
  end

  private def get_cert_items(player)
    tmp = [] of L2ItemInstance
    player.inventory.items.each do |i|
      if i && ALL_CERT_ITEM_IDS.bsearch(i.id) >= 0
        tmp << i
      end
    end

    tmp
  end
end
