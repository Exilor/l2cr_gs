module BypassHandler::SkillList
  extend self
  extend BypassHandler

  def use_bypass(command : String, pc : L2PcInstance, target : L2Character?) : Bool
    return false unless target.is_a?(L2NpcInstance)

    if Config.alt_game_skill_learn
      begin
        id = command.from(9).strip
        if !id.empty?
          L2NpcInstance.show_skill_list(pc, target, ClassId[id.to_i])
        else
          classes = target.classes_to_teach
          own = classes.any? { |cid| cid.equals_or_child_of?(pc.class_id) }
          text = "<html><body><center>Skill learning:</center><br>"

          unless own
            char_type = pc.class_id.mage_class? ? "fighter" : "mage"
            text += "Skills of your class are the easiest to learn.<br>Skills of another class of your race are a little harder.<br>Skills for classes of another race are extremely difficult.<br>But the hardest of all to learn are the #{char_type} skills!<br>"
          end

          if classes.empty?
            text += "No Skills.<br>"
          else
            count = 0
            class_check = pc.class_id
            while count == 0 && class_check
              classes.each do |cid|
                if cid.level > class_check.level
                  next
                end

                if SkillTreesData.get_available_skills(pc, cid, false, false).empty?
                  next
                end

                text += "<a action=\"bypass -h npc_%objectId%_SkillList #{cid.to_i}\">Learn #{cid}'s class Skills</a><br>\n"
                count &+= 1
              end

              class_check = class_check.parent?
            end
          end
          text += "</body></html>"

          html = NpcHtmlMessage.new(target.l2id)
          html.html = text
          html["%objectId%"] = target.l2id
          pc.send_packet(html)

          pc.action_failed
        end
      rescue e
        error e
      end
    else
      L2NpcInstance.show_skill_list(pc, target, pc.class_id)
    end

    true
  end

  def commands : Enumerable(String)
    {"SkillList"}
  end
end
