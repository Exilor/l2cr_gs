class Scripts::HealerTrainer < AbstractNpcAI
  private HEALER_TRAINERS = {
    30022, 30030, 30032, 30036, 30067, 30068, 30116, 30117, 30118, 30119,
    30144, 30145, 30188, 30194, 30293, 30330, 30375, 30377, 30464, 30473,
    30476, 30680, 30701, 30720, 30721, 30858, 30859, 30860, 30861, 30864,
    30906, 30908, 30912, 31280, 31281, 31287, 31329, 31330, 31335, 31969,
    31970, 31976, 32155, 32162
  }

  private MIN_LEVEL = 76
  private MIN_CLASS_LEVEL = 3

  def initialize
    super(self.class.simple_name, "ai/npc/Trainers")

    add_start_npc(HEALER_TRAINERS)
    add_talk_id(HEALER_TRAINERS)
    add_first_talk_id(HEALER_TRAINERS)
  end

  def on_adv_event(event, npc, pc)
    return unless pc && npc

    case event
    when "30864.html", "30864-1.html"
      html = event
    when "SkillTransfer"
      html = "main.html"
    when "SkillTransferLearn"
      if !npc.template.can_teach?(pc.class_id)
        html = "#{npc.id}-noteach.html"
      elsif pc.level < MIN_LEVEL || pc.class_id.level < MIN_CLASS_LEVEL
        html = "learn-lowlevel.html"
      else
        asl = AcquireSkillList.new(AcquireSkillType::TRANSFER)
        count = 0
        SkillTreesData.get_available_transfer_skills(pc).each do |sl|
          if SkillData[sl.skill_id, sl.skill_level]?
            count += 1
            asl.add_skill(sl.skill_id, sl.skill_level, sl.skill_level, sl.level_up_sp, 0)
          end
        end

        if count > 0
          pc.send_packet(asl)
        else
          pc.send_packet(SystemMessageId::NO_MORE_SKILLS_TO_LEARN)
        end
      end
    when "SkillTransferCleanse"
      if !npc.template.can_teach?(pc.class_id)
        return "cleanse-no.html"
      elsif pc.level < MIN_LEVEL || pc.class_id.level < MIN_CLASS_LEVEL
        return "cleanse-no.html"
      elsif pc.adena < Config.fee_delete_transfer_skills
        pc.send_packet(SystemMessageId::CANNOT_RESET_SKILL_LINK_BECAUSE_NOT_ENOUGH_ADENA)
      elsif has_transfer_skill_items?(pc)
        return "cleanse-no_skills.html"
      else
        has_skills = false
        SkillTreesData.get_transfer_skill_tree(pc.class_id).each_value do |sl|
          if skill = pc.get_known_skill(sl.skill_id)
            pc.remove_skill(skill)
            sl.required_items.each do |item|
              pc.add_item("Cleanse", item.id, item.count, npc, true)
            end
            has_skills = true
          end
        end

        if has_skills
          pc.reduce_adena("Cleanse", Config.fee_delete_transfer_skills, npc, true)
        end
      end
    else
      # [automatically added else]
    end


    html
  end

  private def has_transfer_skill_items?(pc)
    item_id = case pc.class_id
    when ClassId::CARDINAL then 15307
    when ClassId::EVA_SAINT then 15308
    when ClassId::SHILLIEN_SAINT then 15309
    else return false
    end

    pc.inventory.get_inventory_item_count(item_id, -1) > 0
  end
end
