class Packets::Incoming::RequestAcquireSkill < GameClientPacket
  QUEST_VAR_NAMES = {
    "EmergentAbility65-",
    "EmergentAbility70-",
    "ClassAbility75-",
    "ClassAbility80-"
  }

  @id = 0
  @level = 0
  @skill_type = AcquireSkillType::CLASS
  @sub_type = 0

  def read_impl
    @id, @level = d, d
    @skill_type = AcquireSkillType[d]
    if @skill_type.subpledge?
      @sub_type = d
    end
  end

  def run_impl
    return unless pc = active_char

    unless 1 <= @level <= 1000 && 1 <= @id <= 32000
      warn { "Wrong level and id #{@level} #{@id}" }
      Util.punish(pc, "wrong packet data in RequestAcquireSkill.")
      return
    end

    trainer = pc.last_folk_npc

    unless trainer.is_a?(L2NpcInstance)
      debug { "#{trainer}:#{trainer.class} is not a L2NpcInstance." }
      return
    end

    if !trainer.can_interact?(pc) && !pc.gm?
      debug { "#{pc} can't interact with #{pc}." }
      return
    end

    unless skill = SkillData[@id, @level]?
      warn { "Skill with id #{@id} and level #{@level} doesn't exist." }
      return
    end

    unless s = SkillTreesData.get_skill_learn(@skill_type, @id, @level, pc)
      debug { "No skill learn data for skill with id #{@id} and level #{@level}." }
      return
    end

    unless can_be_learnt?(pc, skill, s)
      debug { "Skill with id #{@id} and level #{@level} can't be learnt by #{pc}." }
      return
    end

    debug { "Requested to learn #{@skill_type.inspect} #{skill}." }

    case @skill_type
    when AcquireSkillType::CLASS
      if check_player_skill(pc, trainer, s)
        give_skill(pc, trainer, skill)
      end
    when AcquireSkillType::TRANSFORM
      unless RequestAcquireSkill.can_transform?(pc)
        send_packet(SystemMessageId::NOT_COMPLETED_QUEST_FOR_SKILL_ACQUISITION)
        Util.punish(pc, "requested skill id #{@id}, level #{@level} without prerequisite quests.", IllegalActionPunishmentType::NONE)
        return
      end

      if check_player_skill(pc, trainer, s)
        give_skill(pc, trainer, skill)
      end
    when AcquireSkillType::FISHING
      if check_player_skill(pc, trainer, s)
        give_skill(pc, trainer, skill)
      end
    when AcquireSkillType::PLEDGE
      return unless pc.clan_leader?
      clan = pc.clan
      rep_cost = s.level_up_sp
      if clan.reputation_score >= rep_cost
        if Config.life_crystal_needed
          s.required_items.each do |item|
            unless pc.destroy_item_by_item_id("Consume", item.id, item.count, trainer, false)
              send_packet(SystemMessageId::ITEM_OR_PREREQUISITES_MISSING_TO_LEARN_SKILL)
              L2VillageMasterInstance.show_pledge_skill_list(pc)
              return
            end

            sm = SystemMessage.s2_s1_disappeared
            sm.add_item_name(item.id)
            sm.add_long(item.count)
            send_packet(sm)
          end
        end

        clan.take_reputation_score(rep_cost, true)

        sm = SystemMessage.s1_deducted_from_clan_rep
        sm.add_int(rep_cost)
        send_packet(sm)

        clan.add_new_skill(skill)
        clan.broadcast_to_online_members(PledgeSkillList.new(clan))

        send_packet(AcquireSkillDone::STATIC_PACKET)

        L2VillageMasterInstance.show_pledge_skill_list(pc)
      else
        send_packet(SystemMessageId::ACQUIRE_SKILL_FAILED_BAD_CLAN_REP_SCORE)
        L2VillageMasterInstance.show_pledge_skill_list(pc)
      end
    when AcquireSkillType::SUBPLEDGE
      clan = pc.clan
      rep_cost = s.level_up_sp
      if clan.reputation_score < rep_cost
        send_packet(SystemMessageId::ACQUIRE_SKILL_FAILED_BAD_CLAN_REP_SCORE)
        return
      end

      s.required_items.each do |item|
        unless pc.destroy_item_by_item_id("Consume", item.id, item.count, trainer, false)
          send_packet(SystemMessageId::ITEM_OR_PREREQUISITES_MISSING_TO_LEARN_SKILL)
          return
        end

        sm = SystemMessage.s2_s1_disappeared
        sm.add_item_name(item.id)
        sm.add_long(item.count)
        send_packet(sm)
      end

      if rep_cost > 0
        clan.take_reputation_score(rep_cost, true)
        sm = SystemMessage.s1_deducted_from_clan_rep
        sm.add_int(rep_cost)
        send_packet(sm)
      end

      clan.add_new_skill(skill, @sub_type)
      clan.broadcast_to_online_members(PledgeSkillList.new(clan))
      send_packet(AcquireSkillDone::STATIC_PACKET)

      RequestAcquireSkill.show_sub_unit_skill_list(pc)
    when AcquireSkillType::TRANSFER
      if check_player_skill(pc, trainer, s)
        give_skill(pc, trainer, skill)
      end
    when AcquireSkillType::SUBCLASS
      unless st = pc.get_quest_state("SubClassSkills")
        if q = QuestManager.get_quest("SubClassSkills")
          st = q.new_quest_state(pc)
        else
          warn { "Quest \"SubClassSkills\" does not exist." }
          return
        end
      end

      QUEST_VAR_NAMES.each do |var_name|
        1.upto(Config.max_subclass) do |i|
          item_l2id = st.get_global_quest_var("#{var_name}#{i}")
          debug { "var_name: #{var_name}, item_l2id: #{item_l2id}" }
          if !item_l2id.empty? && !item_l2id.ends_with?(';') && item_l2id != "0"
            if item_l2id.num?
              item_l2id = item_l2id.to_i
              if item = pc.inventory.get_item_by_l2id(item_l2id)
                s.required_items.each do |item_id_count|
                  if item.id == item_id_count.id
                    if check_player_skill(pc, trainer, s)
                      give_skill(pc, trainer, skill)
                      st.save_global_quest_var("#{var_name}#{i}", "#{skill.id};")
                    end

                    return
                  end
                end
              else
                warn { "Non-existent item for object Id #{item_l2id} for subclass skill id #{@id}, level #{@level} for player #{pc.name}." }
              end
            else
              warn { "Invalid item object Id #{item_l2id.inspect} for subclass skill id #{@id}, level #{@level} for player #{pc.name}." }
            end
          end
        end
      end

      pc.send_packet(SystemMessageId::ITEM_OR_PREREQUISITES_MISSING_TO_LEARN_SKILL)
      show_skill_list(trainer, pc)
    when AcquireSkillType::COLLECT
      if check_player_skill(pc, trainer, s)
        give_skill(pc, trainer, skill)
      end
    else
      warn { "Unknown skill type #{@skill_type}." }
    end
  end

  private def can_be_learnt?(pc, skill, skl)
    prev_skill_level = pc.get_skill_level(@id)
    case @skill_type
    when .subpledge?
      unless clan = pc.clan?
        return false
      end

      if !pc.clan_leader? || pc.has_clan_privilege?(ClanPrivilege::CL_TROOPS_FAME)
        return false
      end

      if clan.fort_id == 0 && clan.castle_id == 0
        return false
      end

      unless clan.learnable_subpledge_skill?(skill, @sub_type)
        pc.send_packet(SystemMessageId::SQUAD_SKILL_ALREADY_ACQUIRED)
        Util.punish(pc, "requested skill id #{@id}, level #{@level} without knowing its previous level.")
        warn { "#{pc} requested a subpledge skill that he can't learn." }
        return false
      end
    when .transfer?
      unless skl
        Util.punish(pc, "requested skill id #{@id}, level #{@level} which is not included in transfer skills.")
        warn { "#{pc} requested a transfer skill that he can't learn." }
      end
    when .subclass?
      if pc.subclass_active?
        pc.send_packet(SystemMessageId::SKILL_NOT_FOR_SUBCLASS)
        Util.punish(pc, "requested skill id #{@id}, level #{@level} with an active subclass.")
        return false
      end
    else
      if prev_skill_level == @level
        warn { "#{pc} trying to learn a skill level he already knows." }
        return false
      end

      if @level != 1 && prev_skill_level != @level - 1
        warn { "#{pc} trying to learn a skill level beyond his ability." }
        pc.send_packet(SystemMessageId::PREVIOUS_LEVEL_SKILL_NOT_LEARNED)
        Util.punish(pc, "requested skill id #{@id}, level #{@level} without knowing its previous level.")
        return false
      end
    end

    true
  end

  private def check_player_skill(pc, trainer, s) : Bool
    unless s
      debug "No skill given."
      return false
    end

    if s.skill_id == @id && s.skill_level == @level
      if s.get_level > pc.level
        pc.send_packet(SystemMessageId::YOU_DONT_MEET_SKILL_LEVEL_REQUIREMENTS)
        Util.punish(pc, "requested skill id #{@id}, level #{@level} without meeting its level requirement.", IllegalActionPunishmentType::NONE)
        return false
      end

      level_up_sp = s.get_calculated_level_up_sp(pc.class_id, pc.learning_class)

      if level_up_sp > 0 && level_up_sp > pc.sp
        pc.send_packet(SystemMessageId::NOT_ENOUGH_SP_TO_LEARN_SKILL)
        show_skill_list(trainer, pc)
        return false
      end

      if !Config.divine_sp_book_needed && @id == CommonSkill::DIVINE_INSPIRATION.id
        return true
      end

      unless s.required_items.empty?
        s.required_items.each do |item|
          count = pc.inventory.get_inventory_item_count(item.id, -1)
          if count < item.count
            debug { "#{pc.name} needs #{item.count} of item with id #{item.id} (has #{count})." }
            pc.send_packet(SystemMessageId::ITEM_OR_PREREQUISITES_MISSING_TO_LEARN_SKILL)
            show_skill_list(trainer, pc)
            return false
          end
        end

        s.required_items.each do |item|
          unless pc.destroy_item_by_item_id("SkillLearn", item.id, item.count, trainer, true)
            Util.punish(pc, "requested skill id #{@id}, level #{@level} possessing its required item.", IllegalActionPunishmentType::NONE)
            warn { "Player #{pc.name} tried to learn a skill without the required item." }
          end
        end
      end

      if level_up_sp > 0
        pc.sp -= level_up_sp
        pc.send_packet(StatusUpdate.sp(pc))
      end

      return true
    end

    false
  end

  private def give_skill(pc, trainer, skill)
    sm = SystemMessage.learned_skill_s1
    sm.add_skill_name(skill)
    pc.send_packet(sm)
    pc.send_packet(AcquireSkillDone::STATIC_PACKET)
    pc.add_skill(skill, true)
    pc.send_skill_list
    pc.update_shortcuts(@id, @level)
    show_skill_list(trainer, pc)

    if 1368 <= @id <= 1372
      OnPlayerSkillLearn.new(trainer, pc, skill, @skill_type).async(trainer)
    end
  end

  private def show_skill_list(trainer, pc)
    st = @skill_type

    # custom
    if st.fishing?
      klass = QuestManager.get_quest("Fisherman").class
      if klass.responds_to?(:show_fish_skill_list)
        klass.show_fish_skill_list(pc)
      end
      return
    end

    if st.transform? || st.subclass? || st.transfer? || st.fishing?
      return
    end

    L2NpcInstance.show_skill_list(pc, trainer, pc.learning_class)
  end

  def self.show_sub_unit_skill_list(pc : L2PcInstance)
    skills = SkillTreesData.get_available_subpledge_skills(pc.clan)
    asl = nil
    skills.each do |s|
      if SkillData[s.skill_id, s.skill_level]?
        asl ||= AcquireSkillList.new(AcquireSkillType::SUBPLEDGE)
        asl.add_skill(s.skill_id, s.skill_level, s.skill_level, s.level_up_sp, 0)
      end
    end

    if asl
      pc.send_packet(asl)
    else
      pc.send_packet(SystemMessageId::NO_MORE_SKILLS_TO_LEARN)
    end
  end

  def self.can_transform?(pc : L2PcInstance) : Bool
    Config.allow_transform_without_quest ||
    pc.quest_completed?("Q00136_MoreThanMeetsTheEye")
  end
end
