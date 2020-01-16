require "../l2_npc"
require "../status/folk_status"

class L2NpcInstance < L2Npc
  def initialize(template : L2NpcTemplate)
    super
    self.invul = false
  end

  def instance_type : InstanceType
    InstanceType::L2NpcInstance
  end

  private def init_char_status
    @status = FolkStatus.new(self)
  end

  def classes_to_teach : Array(ClassId)
    template.teach_info
  end

  def self.show_skill_list(pc : L2PcInstance, npc : L2Npc, class_id : ClassId)
    npc_id = npc.template.id

    if npc_id == 32611 # Tolonis (Officer)
      skills = SkillTreesData.get_available_collect_skills(pc)
      asl = AcquireSkillList.new(AcquireSkillType::COLLECT)

      counts = 0
      skills.each do |s|
        if sk = SkillData[s.skill_id, s.skill_level]?
          counts += 1
          asl.add_skill(s.skill_id, s.skill_level, s.skill_level, 0, 1)
        end
      end

      if counts == 0
        min_level = SkillTreesData.get_min_level_for_new_skill(pc, SkillTreesData.collect_skill_tree)
        if min_level > 0
          sm = SystemMessage.do_not_have_further_skills_to_learn_s1
          sm.add_int(min_level)
          pc.send_packet(sm)
        else
          pc.send_packet(SystemMessageId::NO_MORE_SKILLS_TO_LEARN)
        end
      else
        pc.send_packet(asl)
      end

      return
    end

    unless npc.template.can_teach?(class_id)
      npc.show_no_teach_html(pc)
      return
    end

    if npc.classes_to_teach.empty?
      html = NpcHtmlMessage.new(npc.l2id)
      sb = "<html><body>I cannot teach you. My class list is empty.<br>Ask admin to fix it. Need add my npcid and classes to skill_learn.sql.<br>NpcId: #{npc_id}, Your classId: #{class_id.to_i}</body></html>"
      html.html = sb
      pc.send_packet(html)
      return
    end

    skills = SkillTreesData.get_available_skills(pc, class_id, false, false)
    asl = AcquireSkillList.new(AcquireSkillType::CLASS)
    count = 0
    pc.learning_class = class_id
    skills.each do |s|
      if SkillData[s.skill_id, s.skill_level]?
        asl.add_skill(
          s.skill_id,
          s.skill_level,
          s.skill_level,
          s.get_calculated_level_up_sp(pc.class_id, class_id),
          0
        )
        count += 1
      end
    end

    if count == 0
      skill_tree = SkillTreesData.get_complete_class_skill_tree(class_id)
      min_level = SkillTreesData.get_min_level_for_new_skill(pc, skill_tree)
      if min_level > 0
        sm = SystemMessage.do_not_have_further_skills_to_learn_s1
        sm.add_int(min_level)
        pc.send_packet(sm)
      else
        if pc.class_id.level == 1
          sm = SystemMessage.no_skills_to_learn_return_after_s1_class_change
          sm.add_int(2)
          pc.send_packet(sm)
        else
          pc.send_packet(SystemMessageId::NO_MORE_SKILLS_TO_LEARN)
        end
      end
    else
      pc.send_packet(asl)
    end
  end
end
