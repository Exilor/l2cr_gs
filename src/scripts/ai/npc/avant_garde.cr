class Scripts::AvantGarde < AbstractNpcAI
  # NPC
  private AVANT_GARDE = 32323

  # Items
  private ITEMS = {
    10280, 10281, 10282, 10283, 10284, 10285, 10286, 10287, 10288, 10289, 10290,
    10291, 10292, 10293, 10294, 10612
  }

  # Misc
  private QUEST_VAR_NAMES = {
    "EmergentAbility65-",
    "EmergentAbility70-",
    "ClassAbility75-",
    "ClassAbility80-"
  }

  def initialize
    super(self.class.simple_name, "ai/npc")

    add_start_npc(AVANT_GARDE)
    add_talk_id(AVANT_GARDE)
    add_first_talk_id(AVANT_GARDE)
    add_acquire_skill_id(AVANT_GARDE)
  end

  def on_acquire_skill(npc, pc, skill, type)
    case type
    when AcquireSkillType::TRANSFORM
      AvantGarde.show_transform_skill_list(pc)
    when AcquireSkillType::SUBCLASS
      AvantGarde.show_subclass_skill_list(pc)
    else
      # [automatically added else]
    end
  end

  def on_adv_event(event, npc, pc)
    return unless pc

    case event
    when "32323-02.html", "32323-02a.html", "32323-02b.html",
         "32323-02c.html", "32323-05.html", "32323-05a.html",
         "32323-05no.html", "32323-06.html", "32323-06no.html"
      html = event
    when "LearnTransformationSkill"
      if Packets::Incoming::RequestAcquireSkill.can_transform?(pc)
        AvantGarde.show_transform_skill_list(pc)
      else
        html = "32323-03.html"
      end
    when "BuyTransformationItems"
      if Packets::Incoming::RequestAcquireSkill.can_transform?(pc)
        MultisellData.separate_and_send(32323001, pc, npc, false)
      else
        html = "32323-04.html"
      end
    when "LearnSubClassSkill"
      unless Packets::Incoming::RequestAcquireSkill.can_transform?(pc)
        html = "32323-04.html"
      end
      if pc.subclass_active?
        html = "32323-08.html"
      else
        if ITEMS.any? { |id| pc.inventory.get_item_by_item_id(id) }
          AvantGarde.show_subclass_skill_list(pc)
        else
          html = "32323-08.html"
        end
      end
    when "CancelCertification"
      pc.send_message("CancelCertification is not implemented.")
      if pc.subclasses.size == 0
        html = "32323-07.html"
      elsif pc.subclass_active?
        html = "32323-08.html"
      elsif pc.adena < Config.fee_delete_subclass_skills
        html = "32323-08no.html"
      else
        st = pc.get_quest_state("SubclassSkills")
        st ||= QuestManager.get_quest("SubclassSkills").not_nil!.new_quest_state(pc)

        active_certifications = 0
        QUEST_VAR_NAMES.each do |var_name|
          1.upto(Config.max_subclass) do |i|
            qvar = st.get_global_quest_var("#{var_name}#{i}")
            if !qvar.empty? && (qvar.ends_with?(';') || qvar != "0")
              active_certifications += 1
            end
          end
        end

        if active_certifications == 0
          html = "32323-10no.html"
        else
          QUEST_VAR_NAMES.each do |var_name|
            1.upto(Config.max_subclass) do |i|
              qvar_name = "#{var_name}#{i}"
              qvar = st.get_global_quest_var(qvar_name)
              if qvar.ends_with?(';')
                skill_id_var = qvar.sub(';', "")
                if skill_id_var.num?
                  skill_id = skill_id_var.to_i
                  if sk = SkillData[skill_id, 1]?
                    pc.remove_skill(sk)
                    st.save_global_quest_var(qvar_name, "0")
                  end
                else
                  warn { "Invalid subclass skill id #{skill_id_var} for player #{pc.name}." }
                end
              elsif !qvar.empty? && qvar != "0"
                if qvar.num?
                  item_obj_id = qvar.to_i
                  item_instance = pc.inventory.get_item_by_l2id(item_obj_id)
                  if item_instance
                    pc.destroy_item("CancelCertification", item_obj_id, 1, pc, false)
                  else
                    item_instance = pc.warehouse.get_item_by_l2id(item_obj_id)
                    if item_instance
                      warn { pc.name + " put a certification book into warehouse." }
                      pc.warehouse.destroy_item("CancelCertification", item_instance, 1, pc, false)
                    else
                      warn { pc.name + " deleted a certification book." }
                    end
                  end
                  st.save_global_quest_var(qvar_name, "0")
                else
                  warn { "Invalid item object id #{qvar} for player #{pc.name}." }
                end
              end
            end
          end

          pc.reduce_adena("Cleanse", Config.fee_delete_subclass_skills, npc, true)
          html = "32323-09no.html"
          pc.send_skill_list
        end
      end

      # Let's consume all certification books, even those not present in database.
      ITEMS.each do |item_id|
        if item = pc.inventory.get_item_by_item_id(item_id)
          warn { "Player #{pc.name} had 'extra' certification skill books while cancelling sub-class certifications." }
          pc.destroy_item("CancelCertificationExtraBooks", item, npc, false)
        end
      end
    else
      # [automatically added else]
    end

    html
  end

  def on_first_talk(npc, pc)
    "32323-01.html"
  end

  def on_talk(npc, pc)
    "32323-01.html"
  end

  def self.show_subclass_skill_list(pc : L2PcInstance)
    subclass_skills = SkillTreesData.get_available_subclass_skills(pc)
    asl = AcquireSkillList.new(AcquireSkillType::SUBCLASS)
    count = 0

    subclass_skills.each do |s|
      if SkillData[s.skill_id, s.skill_level]?
        count &+= 1
        asl.add_skill(s.skill_id, s.skill_level, s.skill_level, 0, 0)
      end
    end
    if count > 0
      pc.send_packet(asl)
    else
      pc.send_packet(SystemMessageId::NO_MORE_SKILLS_TO_LEARN)
    end
  end

  def self.show_transform_skill_list(pc : L2PcInstance)
    skills = SkillTreesData.get_available_transform_skills(pc)
    asl = AcquireSkillList.new(AcquireSkillType::TRANSFORM)
    counts = 0

    skills.each do |s|
      if SkillData[s.skill_id, s.skill_level]?
        counts &+= 1
        asl.add_skill(s.skill_id, s.skill_level, s.skill_level, s.level_up_sp, 0)
      end
    end

    if counts == 0
      tree = SkillTreesData.transform_skill_tree
      min_lvl = SkillTreesData.get_min_level_for_new_skill(pc, tree)
      if min_lvl > 0
        sm = SystemMessage.do_not_have_further_skills_to_learn_s1
        sm.add_int(min_lvl)
        pc.send_packet(sm)
      else
        pc.send_packet(SystemMessageId::NO_MORE_SKILLS_TO_LEARN)
      end
    else
      pc.send_packet(asl)
    end
  end
end
